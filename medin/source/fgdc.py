import datetime
import libxml2
import medin.metadata
import medin.vocabulary
from copy import copy
from string import strip

import logging
logger = logging.getLogger(__name__)

class Term(object):
    """
    An object conforming to the medin.vocabulary.Term interface
    """
    thesaurus = None
    definition = None
    code = None
    term = None
    def __init__(self, term):
        self.term = term

    def getTerm(self):
        return term

def getSpatialReferenceSystem(code):
    mapping = {
        '001': 'urn:ogc:def:crs:EPSG::27700',
        '002': 'urn:ogc:def:crs:EPSG::29903',
        '003': 'urn:ogc:def:crs:EPSG::2157',
        '004': 'urn:ogc:def:crs:EPSG::4326',
        '011': 'postcode',
        '012': 'parish',
        '013': 'ward',
        '014': 'electoral constituency',
        '015': 'census area',
        '016': 'local authority',
        '017': 'region',
        '018': 'country',
        '019': 'Health Authority area'
        }

    try:
        return mapping[code]
    except KeyError:
        return code

def getPresentationType(code):
    mapping = {
        '001': 'digital representation of a primarily textual item (can contain illustrations also)',
        '002': 'representation of a primarily textual item (can contain illustrations also) on paper, photographic material, or other media',
        '003': 'likeness of natural or man-made features, objects, and activities acquired through the sensing of visual or any other segment of the electromagnetic spectrum by sensors, such as thermal infrared, and high resolution radar and stored in digital format',
        '004': 'likeness of natural or man-made features, objects, and activities acquired through the sensing of visual or any other segment of the electromagnetic spectrum by sensors, such as thermal infrared, and high resolution radar and reproduced on paper, photographic material, or other media for use directly by the human user',
        '005': 'map represented in raster or vector form',
        '006': 'map printed on paper, photographic material, or other media for use directly by the human user',
        '007': 'multi-dimensional digital representation of a feature, process, etc.',
        '008': '3-dimensional, physical model',
        '009': 'vertical cross-section in digital form',
        '010': 'vertical cross-section printed on paper, etc.',
        '011': 'digital representation of facts or figures systematically displayed, especially in columns',
        '012': 'representation of facts or figures systematically displayed, especially in columns, printed on paper, photographic material, or other media',
        '013': 'digital video recording',
        '014': 'video recording on film'
        }

    try:
        return mapping[code]
    except KeyError:
        return code

def parse_date(date):
    """
    Parse a date string into a datetime object
    """
    global _datep
    try:
        datep = _datep
    except NameError:
        from re import compile
        # create a pattern that matches any isoformat date or time
        datep = _datep = compile('^(?P<year>\d{4})(?:(?P<month>\d{2})(?:(?P<day>\d{2}))?)?$')

    try:
        groups = datep.match(date.strip()).groupdict()
    except AttributeError:
        raise ValueError('Bad date value: %s' % str(date))

    if groups['day']:
        # it is a date object
        return datetime.date(*[int(groups[k]) for k in ('year', 'month', 'day')])
    elif groups['month']:
        #  it is a YearMonth object
        return medin.metadata.YearMonth(*[int(groups[k]) for k in ('year', 'month')])

    # it's a Year object
    return medin.metadata.Year(int(groups['year']))

def parse_time(time):
    """
    Parse a time string into a datetime.time object
    """
    global _timep
    try:
        timep = _timep
    except NameError:
        from re import compile
        # create a pattern that matches any isoformat date or time
        timep = _timep = compile('^(?P<hour>\d{2})(?:(?P<minute>\d{2})(?:(?P<second>\d{2}))?)?$')

    try:
        groups = timep.match(time.strip()).groups()
    except AttributeError:
        raise ValueError('Bad time value: %s' % str(time))

    time = datetime.time(*[int(v) if v is not None else 0 for v in groups])
    return time

def parse_date_range(date_range):
    date_range = [d.strip() for d in date_range.split('-')]
    if len(date_range) > 1:
        begin, end = date_range
        if not end:             # it's an empty string
            end = None
        if not begin:
            begin = None
    else:
        begin = date_range[0]
        end = None
    if begin:
        begin = parse_date(begin)
    if end:
        end = parse_date(end)

    return begin, end

def getXpath(ctxt, xpath):
    try:
        return ctxt.xpathEval(xpath)[0]
    except IndexError:
        return None

def getXpathValue(ctxt, xpath, nilReason=None):
    try:
        value = ctxt.xpathEval(xpath)[0].content.strip()
    except IndexError:
        value = None
    if not value and nilReason:
        value = medin.metadata.Nil(nilReason)
    return value

def getXpathValues(ctxt, xpath, nilReason=None):
    values = [node.content for node in ctxt.xpathEval(xpath) if node.content]
    if not values and nilReason:
        values.append(medin.metadata.Nil(nilReason))
    return values

def copyXpathValue(source, xpath, dest, attr, nilReason=None):
    value = getXpathValue(source, xpath, nilReason)
    setattr(dest, attr, value)

def copyXpathValues(source, xpath, dest, attr, nilReason=None):
    values = getXpathValues(source, xpath, nilReason)
    setattr(dest, attr, values)

def checkNillable(value):
    nil = {
        'Unknown': 'unknown',
        'None': 'inapplicable',
        'Unpublished': 'withheld'
    }
    try:
        return medin.metadata.Nil(nil[value])
    except KeyError:
        return value

def getNillable(value):
    nillable = checkNillable(value)
    if not isinstance(nillable, medin.metadata.Nil):
        raise ValueError('Value is not nillable: %s' % value)
    return nillable

def getNillableDate(date):
    try:
        return getNillable(date)
    except ValueError:
        return parse_date(date)

def create_date_time(ctxt, date_path, time_path):
    value = getXpathValue(ctxt, date_path)
    date = None
    if value:
        try:
            date = parse_date(value)
        except ValueError:
            try:
                date = checkNillable(value)
            except KeyError:
                raise ValueError('Bad date value: %s' % value)

        if isinstance(date, datetime.date):
            # try and get the time information
            value = getXpathValue(ctxt, time_path)
            try:
                time = parse_time(value.strip())
            except (ValueError, AttributeError):
                pass            # take into account 'Unknown' etc.
            else:
                date = datetime.datetime.fromordinal(date.toordinal())
                date = date.replace(**dict([(k, getattr(time, k)) for k in ['hour', 'minute', 'second', 'microsecond']]))

    return date
    
import re
_start_tag = re.compile('.*(<\w+).+')
def parse_filename(filename, vocabs, use_uuid, codespace, skip_invalid):
    """
    Parse a FGDC XML file into a MEDIN metadata object
    """

    global libxml_err
    libxml_err = ''
    def errorhandler(ctxt, msg, severity, reserved):
        global libxml_err
        libxml_err += '%s' % msg
    
    logger.info('Parsing %s' % filename)
    try:
        if filename != '-':
            try:
                fh = open(filename, 'r')
            except Exception, e:
                raise RuntimeError('The input file could not be read: %s' % str(e))
        else:
            from sys import stdin as fh

        # catch html input which stalls the libxml2 parser
        xml = ''
        line = fh.readline()
        while line:
            xml += line
            match = _start_tag.match(line)
            if match:
                if '<metadata' not in match.groups()[0]:
                    raise RuntimeError('The input document does not appear to be FGDC metadata: %s' % filename)
                break
            line = fh.readline()

        # read the rest of the xml
        if line:
            xml += fh.read()

        parserCtxt = libxml2.createMemoryParserCtxt(xml, len(xml))
        parserCtxt.setErrorHandler(errorhandler, None)

        # a memory parser is used instead of directly using a file
        # parser because the latter stalls for a long time when passed
        # HTML input
        parsed = parserCtxt.parseDocument()
        if libxml_err:
            logger.debug('libxml2 error: %s' % libxml_err.strip()) # output the libxml error messages
        if parsed != 0:
            raise RuntimeError('The input could not be parsed as XML: %s' % filename)

        doc = parserCtxt.doc()
        if doc.getRootElement().name != 'metadata':
            raise RuntimeError('The XML document does not appear to be FGDC metadata: %s' % filename)
        version = getXpathValue(doc, '/metadata/metainfo/metstdv')
        if version is None:
            raise RuntimeError('No FGDC version information is present: %s' % filename)
        if version.strip().upper() != 'FGDC-STD-001-1998':
            raise RuntimeError('Expected version FGDC-STD-001-1998, found %s: %s' % (version, filename))
    except RuntimeError, e:
        if not skip_invalid:
            raise
        logger.warn(str(e))
        return None

    metadata = medin.metadata.Metadata()

    xpath = doc.xpathNewContext()

    # get an unique identifer
    from os.path import basename, splitext
    identifier = splitext(basename(filename))[0]
    if use_uuid or identifier == '-':
        from uuid import uuid4
        identifier = uuid4().hex

    metadata.unique_id = medin.metadata.UniqueId(identifier, codespace)

    copyXpathValue(doc, '/metadata/idinfo/citation/citeinfo/title', metadata, 'title')
    copyXpathValue(doc, '/metadata/idinfo/descript/abstract', metadata, 'abstract')
    metadata.resource_type = 'dataset'

    for node in xpath.xpathEval('//citation/citeinfo'):
        xpath.setContextNode(node)
        url = getXpathValue(xpath, './onlink')
        if not url:
            continue
        resource_locator = medin.metadata.ResourceLocator()
        resource_locator.url = url
        copyXpathValue(xpath, './title', resource_locator, 'description')
        copyXpathValue(xpath, './geoform', resource_locator, 'name')
        
        metadata.resource_locators.append(resource_locator)
    xpath.setContextNode(doc)

    for value in getXpathValues(doc, '/metadata/idinfo/keywords/theme/themekey'):
        if not value:
            continue
        term = medin.vocabulary.Term(None, value)
        metadata.topic_categories.append(term)

    for value in getXpathValues(doc, '/metadata/idinfo/keywords/place/placekey'):
        if not value:
            continue
        term = medin.vocabulary.Term(None, value)
        metadata.keywords.append(term)

    for value in getXpathValues(doc, '/metadata/idinfo/keywords/stratum/stratkey'):
        if not value:
            continue
        term = medin.vocabulary.Term(None, value)
        metadata.keywords.append(term)

    for value in getXpathValues(doc, '/metadata/idinfo/keywords/temporal/tempkey'):
        if not value:
            continue
        term = medin.vocabulary.Term(None, value)
        metadata.keywords.append(term)

    # append the NERC Data Grid OAI harvesting keyword
    metadata.keywords.append(vocabs.getTermFromCode(18, 'NDGO0001'))

    extent = getXpath(xpath, '/metadata/idinfo/spdom/bounding')
    if extent:
        xpath.setContextNode(extent)
        minx = getXpathValue(xpath, './westbc')
        miny = getXpathValue(xpath, './southbc')
        maxx = getXpathValue(xpath, './eastbc')
        maxy = getXpathValue(xpath, './northbc')

        bbox = medin.metadata.BoundingBox(minx, miny, maxx, maxy)
        metadata.bounding_box = bbox
        xpath.setContextNode(doc)

    dates = []
    tr = medin.metadata.TemporalReference()
    dates.append(create_date_time(doc, '/metadata/idinfo/timeperd/timeinfo/sngdate/caldate', '/metadata/idinfo/timeperd/timeinfo/sngdate/time'))
    for node in xpath.xpathEval('/metadata/idinfo/timeperd/timeinfo/mdattim/sngdate'):
        xpath.setContextNode(node)
        dates.append(create_date_time(xpath, './caldate', './time'))
    xpath.setContextNode(doc)

    for node in xpath.xpathEval('/metadata/idinfo/timeperd/timeinfo/rngdates'):
        xpath.setContextNode(node)
        dates.append(create_date_time(xpath, './begdate', './begtime'))
        dates.append(create_date_time(xpath, './enddate', './endtime'))
    xpath.setContextNode(doc)

    valid_dates = [d for d in dates if hasattr(d, 'year')]
    if valid_dates:
        tr.begin = min(valid_dates)
        tr.creation = tr.begin
    else:
        tr.creation = medin.metadata.Nil('missing')

    if len(valid_dates) > 1:
        tr.end = max(valid_dates)

    value = getXpathValue(doc, '/metadata/idinfo/citation/citeinfo/pubdate')
    if value:
        try:
            tr.publication = getNillableDate(value)
        except ValueError, e:
            reasons = {
                'Unknown': 'unknown',
                'Unpublished material': 'withheld'
                }
            try:
                tr.publication = medin.metadata.Nil(reasons[value])
            except KeyError:
                raise
    else:
        tr.publication = medin.metadata.Nil('missing')
    metadata.temporal_reference = tr

    value = checkNillable(getXpathValue(doc, '/metadata/dataqual/lineage/procstep/procdesc'))
    metadata.lineage = value

    values = getXpathValues(doc, '/metadata/dataqual/posacc/horizpa/qhorizpa/horizpav')
    if values:
        for value in values:
            metadata.spatial_resolutions.append(medin.metadata.SpatialResolution(distance=value))
    else:
        sr = medin.metadata.SpatialResolution(distance=medin.metadata.Nil('inapplicable'))
        metadata.spatial_resolutions = [sr]

    info = [getXpathValue(doc, '/metadata/idinfo/descript/supplinf')]
    metadata.additional_info = "\n\n".join([v for v in info if v])


    value = getXpathValue(doc, '/metadata/idinfo/accconst')
    term = vocabs.getAccessRestrictionFromCode(8)
    metadata.access_constraint_terms.append(term)
    if value is 'None':
        metadata.other_access_constraints.append('Please contact the data custodian for data access details')
    else:
        metadata.other_access_constraints.append(value)

    value = getXpathValue(doc, '/metadata/idinfo/useconst')
    if value is 'None':
        metadata.use_limitations.append('Please contact the data custodian for use constraint details')
    else:
        metadata.use_limitations.append(value)


    #value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/spatialReferenceSystem')
    #if value:
    #    metadata.srs = getSpatialReferenceSystem(value)

    for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/BrowseGraphic'):
        if not value: continue
        resource_locator = medin.metadata.ResourceLocator()
        resource_locator.url = value
        resource_locator.name = 'Graphic'
        resource_locator.description = 'The image associated with the dataset'
        resource_locator.function = 'information'
        metadata.resource_locators.append(resource_locator)

    for extent in getXpathValues(doc, '/GEMINIDiscoveryMetadata/extent'):
        if not extent:
            continue
        term = Term(extent)
        term.thesaurus = medin.metadata.Nil('missing')
        metadata.extents.append(term)

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/freqUpdate')
    freq = None
    if value:
        freq = vocabs.getMaintenanceFrequencyFromCode(int(value))
    if not freq:
        freq = vocabs.getMaintenanceFrequency('unknown')
    metadata.update_frequency = freq.term

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/dateStamp')
    try:
        metadata.date = parse_date(value)
    except ValueError:
        metadata.date = datetime.datetime.now()

    for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/dataFormat'):
        metadata.data_formats.extend([medin.vocabulary.Term(None, v) for v in map(strip, value.split(',')) if v])

    distributorNode = getXpath(xpath, '/GEMINIDiscoveryMetadata/distributor')
    if distributorNode:
        xpath.setContextNode(distributorNode)
        distributor = medin.metadata.ResponsibleParty()
        copyXpathValue(xpath, './webAddress', distributor, 'website')
        copyXpathValue(xpath, './contactTitle', distributor, 'position')
        copyXpathValue(xpath, './name', distributor, 'organisation')
        copyXpathValue(xpath, './telephone', distributor, 'phone')
        copyXpathValue(xpath, './postalAddress', distributor, 'address')
        copyXpathValue(xpath, './facsimile', distributor, 'fax')
        copyXpathValue(xpath, './email', distributor, 'email', 'missing')
        distributor.role = vocabs.getContactRole('distributor')
        metadata.responsible_parties.append(distributor)

        # copy the distributor to the point of contact
        pointOfContact = copy(distributor)
        pointOfContact.role = vocabs.getContactRole('pointOfContact')
        metadata.responsible_parties.append(pointOfContact)

        # copy the distributor to the custodian
        custodian = copy(distributor)
        custodian.role = vocabs.getContactRole('custodian')
        metadata.responsible_parties.append(custodian)

        # copy the distributor to the originator
        originator = copy(distributor)
        originator.role = vocabs.getContactRole('originator')
        metadata.responsible_parties.append(originator)

        xpath.setContextNode(doc)

    verticalNode = getXpath(xpath, '/GEMINIDiscoveryMetadata/verticalextent')
    if verticalNode:
        xpath.setContextNode(verticalNode)
        minimum = getXpathValue(xpath, './minvalue')
        maximum = getXpathValue(xpath, './maxvalue')
        crs = getXpathValue(xpath, './vertdatum')
        metadata.vertical_extent = medin.metadata.VerticalExtent(minimum, maximum, crs)

        xpath.setContextNode(doc)

    doc.freeDoc()
    xpath.xpathFreeContext()
    return metadata

from os.path import isdir, join, splitext
from os import listdir
def parse_files(files, vocabs, use_uuid, codespace, skip_invalid, read_dirs, recurse):
    for path in files:
        if isdir(path) and read_dirs:
            for metadata in parse_files(
                [join(path, fname) for fname in listdir(path)],
                vocabs,
                use_uuid,
                codespace,
                skip_invalid,
                recurse,
                recurse):
                yield metadata
        else:
            if splitext(path)[1] != '.xml':
                continue
            metadata = parse_filename(path, vocabs, use_uuid, codespace, skip_invalid)
            if metadata is not None:
                yield metadata

def set_argument_subparser(subparsers):
    import argparse
    description = """  Convert FGDC XML files into the MEDIN metadata format.

basic usage:
  FILE simply represents a XML metadata file in FGDC format and can be
  specified multiple times e.g.

  %(prog)s fgdc-1.xml fgdc-2.xml /directory/of/files
"""

    subparser = subparsers.add_parser(
        'fgdc',
        description=description,
        formatter_class=argparse.RawDescriptionHelpFormatter)

    def get_provider(args, vocabs, contacts):
        logger.info('Using the %s metadata source' % __name__)

        def metadata_generator():
            for metadata in parse_files(args.input, vocabs, args.uuid, args.codespace, args.skip_invalid, True, args.recurse):
                yield metadata
        return metadata_generator

    subparser.add_argument('-u', '--uuid', action='store_true',
                           help="Base the individual identifier on a randomly generated UUID string. The identifier otherwise defaults to the filename.")
    subparser.add_argument('-c', '--codespace', default=None,
                           help="Specify the codespace for the metadata. This is used in generating the unique identifier.")
    subparser.add_argument('-r', '--recurse', action='store_true',
                           help="If FILE is a directory, recurse into its sub-directories.")
    subparser.add_argument('-s', '--skip-invalid', action='store_true',
                           help="Skip invalid input files, outputting a warning message. The default is for the program to terminate on invalid files.")
    subparser.add_argument("input", nargs='*', default='-', metavar='FILE', help="FILE is either a FGDC XML file or a directory of such files in which case all files within the directory having a `.xml` extension are parsed.  This option can be specified multiple times and defaults to standard input.")
    subparser.set_defaults(output=get_provider)