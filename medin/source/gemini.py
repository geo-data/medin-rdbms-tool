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
        value = ctxt.xpathEval(xpath)[0].content
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

_ct = None
def transformPoint(x, y, z=0):
    """
    Transform a point from BNG to WGS84
    """
    global _ct
    x = float(x)
    y = float(y)
    if not _ct:
        from osgeo import osr
        src = osr.SpatialReference()
        src.ImportFromEPSG(27700)
        dst = osr.SpatialReference()
        dst.ImportFromEPSG(4326)
        _ct = osr.CoordinateTransformation(src, dst)

    return  _ct.TransformPoint(x, y, z)

import re
_start_tag = re.compile('.*(<\w+).+')
def parse_filename(filename, vocabs, use_uuid, codespace, skip_invalid):
    """
    Parse a GEMINI XML file into a MEDIN metadata object
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
                if '<GEMINIDiscoveryMetadata' not in match.groups()[0]:
                    raise RuntimeError('The input document does not appear to be GEMINI metadata: %s' % filename)
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
        if doc.getRootElement().name != 'GEMINIDiscoveryMetadata':
            raise RuntimeError('The XML document does not appear to be GEMINI metadata: %s' % filename)
        version = getXpathValue(doc, '/GEMINIDiscoveryMetadata/metadataStandardVersion')
        if version is None:
            raise RuntimeError('No GEMINI version information is present: %s' % filename)
        versions = version.strip().split('.')
        if versions[0] != '1':
            raise RuntimeError('Expected GEMINI version 1, found %s: %s' % (version, filename))
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

    copyXpathValue(doc, '/GEMINIDiscoveryMetadata/title', metadata, 'title', 'missing')
    copyXpathValues(doc, '/GEMINIDiscoveryMetadata/alttitle', metadata, 'alt_titles')
    copyXpathValue(doc, '/GEMINIDiscoveryMetadata/abstract', metadata, 'abstract', 'missing')
    copyXpathValue(doc, '/GEMINIDiscoveryMetadata/lineage', metadata, 'lineage', 'missing')
    metadata.resource_type = 'dataset'

    for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/accessConstraint'):
        value = int(value)
        term = vocabs.getAccessRestrictionFromCode(value)
        if term:
            metadata.access_constraint_terms.append(term)
    if 'otherRestrictions' in [term.term for term in  metadata.access_constraint_terms]:
        metadata.other_access_constraints.append('Please contact the data custodian for data access details')
    if not metadata.access_constraint_terms:
        metadata.access_constraint_terms.append(medin.metadata.Nil('missing'))

    for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/useConstraint'):
        try:
            code = int(value)
        except ValueError:
            pass
        else:
            term = vocabs.getAccessRestrictionFromCode(code)
            if term:
                term = term.definition
        if not term:
            term = value
        metadata.use_limitations.append(term)

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/spatialReferenceSystem')
    if value:
        metadata.srs = getSpatialReferenceSystem(value)

    values = getXpathValues(doc, '/GEMINIDiscoveryMetadata/spatialResolution')
    if values:
        for value in values:
            metadata.spatial_resolutions.append(medin.metadata.SpatialResolution(distance=value))
    else:
        sr = medin.metadata.SpatialResolution(distance=medin.metadata.Nil('inapplicable'))
        metadata.spatial_resolutions = [sr]

    for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/OnlineResource'):
        resource_locator = medin.metadata.ResourceLocator()
        resource_locator.url = value
        metadata.resource_locators.append(resource_locator)

    for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/BrowseGraphic'):
        if not value: continue
        resource_locator = medin.metadata.ResourceLocator()
        resource_locator.url = value
        resource_locator.name = 'Graphic'
        resource_locator.description = 'The image associated with the dataset'
        resource_locator.function = 'information'
        metadata.resource_locators.append(resource_locator)

    extent = getXpath(xpath, '/GEMINIDiscoveryMetadata/geographicBox')
    if extent:
        xpath.setContextNode(extent)
        minx = getXpathValue(xpath, './westBoundLongitude')
        miny = getXpathValue(xpath, './southBoundLatitude')
        maxx = getXpathValue(xpath, './eastBoundLongitude')
        maxy = getXpathValue(xpath, './northBoundLatitude')

        if extent.prop('system') == 'britishnationalgrid':
            # transform the points to WGS84
            try:
                minx, miny, z = transformPoint(minx, miny)
            except (ValueError, TypeError):
                pass

            try:
                maxx, maxy, z = transformPoint(maxx, maxy)
            except (ValueError, TypeError):
                pass

        bbox = medin.metadata.BoundingBox(minx, miny, maxx, maxy)
        metadata.bounding_box = bbox
        xpath.setContextNode(doc)

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

    for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/topic'):
        if not value:
            continue
        term = vocabs.getTopicCategoryFromCode(value)
        if not term:
            term = medin.vocabulary.Term(None, value)
        metadata.topic_categories.append(term)

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/dateStamp')
    try:
        metadata.date = parse_date(value)
    except ValueError:
        metadata.date = datetime.datetime.now()

    tr = medin.metadata.TemporalReference()
    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/date')
    if value:
        begin, end = parse_date_range(value)
        tr.begin = begin
        tr.end = end
        tr.creation = begin
    else:
        tr.creation = medin.metadata.Nil('missing')

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/datarefdate')
    if value:
        tr.publication = parse_date(value)
    else:
        tr.publication = medin.metadata.Nil('missing')
    metadata.temporal_reference = tr

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

    # append the NERC Data Grid OAI harvesting keyword
    metadata.keywords.append(vocabs.getTermFromCode(18, 'NDGO0001'))

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/subject')
    if value:
        metadata.keywords.extend([medin.vocabulary.NERCTerm(None, v, None) for v in map(strip, value.split(';')) if v])

    info = [getXpathValue(doc, '/GEMINIDiscoveryMetadata/supplementalInformation')]
    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/presentationType')
    if value:
        value = getPresentationType(value)
        info.append("Presentation type: %s" % value)

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/spatialRepresentation')
    if value:
        info.append("Spatial representation type: %s" % value)

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/supplyMedia')
    if value:
        info.append("Supply media: %s" % value)

    value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/origin')
    if value:
        info.append("Origin: %s" % value)

    metadata.additional_info = "\n\n".join([v for v in info if v])

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
    description = """  Convert GEMINI version 1 XML files into the MEDIN metadata format.

basic usage:
  FILE simply represents a XML metadata file in GEMINI version 1
  format and can be specified multiple times e.g.

  %(prog)s gemini-1.xml gemini-2.xml

  Note that this source only supports GEMINI: later versions of GEMINI
  are not yet supported.
"""

    subparser = subparsers.add_parser(
        'gemini',
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
    subparser.add_argument("input", nargs='*', default='-', metavar='FILE', help="FILE is either a GEMINI XML file or a directory of such files in which case all files within the directory having a `.xml` extension are parsed.  This option can be specified multiple times and defaults to standard input.")
    subparser.set_defaults(output=get_provider)
