__version__ = '0.0.1'

# ensure we're using UTF-8
import sys
sys = reload(sys)
sys.setdefaultencoding('utf-8')

import datetime
import libxml2
import medin.metadata
import medin.vocabulary
from copy import copy
from string import strip

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

def die(msg):
    """End the program with a message to standard error"""

    sys.stderr.write("%s\n" % msg)
    try:
        log(msg)
    except NameError:
        pass                    # for when the medin module can't be imported

    sys.exit(1)

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

try:
    doc = libxml2.parseFile('-')
except libxml2.parserError:
    die('The input could not be parsed as XML')

if doc.getRootElement().name != 'GEMINIDiscoveryMetadata':
    die('The XML document does not appear to be GEMINI metadata')
version = getXpathValue(doc, '/GEMINIDiscoveryMetadata/metadataStandardVersion')
if version is None:
    die('No GEMINI version information is present in the input')
versions = version.strip().split('.')
if versions[0] != '1':
    die('Expected GEMINI version 1, found: %s' % version)    

metadata = medin.metadata.Metadata()
vocab = medin.vocabulary.Session()

xpath = doc.xpathNewContext()

# get an unique identifer
from uuid import uuid4
metadata.unique_id = medin.metadata.UniqueId(uuid4().hex, 'http://data.offshorewind.co.uk/')

copyXpathValue(doc, '/GEMINIDiscoveryMetadata/title', metadata, 'title', 'missing')
copyXpathValues(doc, '/GEMINIDiscoveryMetadata/alttitle', metadata, 'alt_titles')
copyXpathValue(doc, '/GEMINIDiscoveryMetadata/abstract', metadata, 'abstract', 'missing')
copyXpathValue(doc, '/GEMINIDiscoveryMetadata/lineage', metadata, 'lineage', 'missing')
metadata.resource_type = 'dataset'

for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/accessConstraint'):
    value = int(value)
    term = vocab.getAccessRestrictionFromCode(value)
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
        term = vocab.getAccessRestrictionFromCode(code)
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
    minx = getXpathValue(xpath, './westBoundLongitude', 'missing')
    miny = getXpathValue(xpath, './southBoundLatitude', 'missing')
    maxx = getXpathValue(xpath, './eastBoundLongitude', 'missing')
    maxy = getXpathValue(xpath, './northBoundLatitude', 'missing')

    if extent.prop('system') == 'britishnationalgrid':
        # transform the points to WGS84
        try:
            minx, miny, z = transformPoint(minx, miny)
        except ValueError:
            pass

        try:
            maxx, maxy, z = transformPoint(maxx, maxy)
        except ValueError:
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
    freq = vocab.getMaintenanceFrequencyFromCode(int(value))
if not freq:
    freq = vocab.getMaintenanceFrequency('unknown')
metadata.update_frequency = freq.term

for value in getXpathValues(doc, '/GEMINIDiscoveryMetadata/topic', 'missing'):
    term = vocab.getTopicCategoryFromCode(value)
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
    distributor.role = vocab.getContactRole('distributor')
    metadata.responsible_parties.append(distributor)

    # copy the distributor to the point of contact
    pointOfContact = copy(distributor)
    pointOfContact.role = vocab.getContactRole('pointOfContact')
    metadata.responsible_parties.append(pointOfContact)

    # copy the distributor to the custodian
    custodian = copy(distributor)
    custodian.role = vocab.getContactRole('custodian')
    metadata.responsible_parties.append(custodian)

    # copy the distributor to the originator
    originator = copy(distributor)
    originator.role = vocab.getContactRole('originator')
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
metadata.keywords.append(vocab.getTermFromCode(18, 'NDGO0001'))

value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/subject')
if value:
    metadata.keywords.extend([medin.vocabulary.NERCTerm(None, v, None) for v in map(strip, value.split(';')) if v])

info = [getXpathValue(doc, '/GEMINIDiscoveryMetadata/supplementalInformation')]
value = getXpathValue(doc, '/GEMINIDiscoveryMetadata/presentationType')
if value:
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

builder = medin.metadata.XMLBuilder(metadata)

print builder.build()
