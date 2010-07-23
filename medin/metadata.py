"""
Representation of MEDIN Metadata Specification

This is a DOM representing the MEDIN schema. It is populated by
mapping the object to a provider database schema. This mapping is done
using the appropriate provider plugin module in the medin.provider
package.
"""
import libxml2

class Metadata(object):
    """
    The top level object
    """

    # Element 1
    title = None

    # Element 2 - a list of alternative titles
    alt_titles = None

    # Element 3
    abstract = None

    # Element 4
    resource_type = None

    # Element 5
    resource_locators = None

    # Element 6
    unique_id = None

    # Element 12
    bounding_box = None

    # Element 26 
    date = None

    # Element 27
    standard = 'MEDIN Discovery Metadata Standard'

    # Element 28
    version = 'Version 2.3'

    # Element 29
    language = 'English'

    def __init__(self):
        self.alt_titles = []
        self.resource_locators = []

class ResourceLocator(object):
    """
    Element 5
    """
    url = None
    name = None

    def __init__(self, url, name=None):
        self.url = url
        self.name = name

    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, str(self))

    def __str__(self):
        if self.name:
            return self.name + self.url
        return self.url


class UniqueId(object):
    """
    Element 6
    """
    id = None
    codespace = None
    
    def __init__(self, id, codespace=None):
        self.id = id
        self.codespace = codespace

    def __eq__(self, other):
        return self.id == other.id and self.codespace == other.codespace

    def __ne__(self, other):
        return not self.__eq__(other)

    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, str(self))

    def __str__(self):
        if self.codespace:
            return self.codespace + self.id
        return self.id

class BoundingBox(object):
    """
    Element 12
    """
    minx = None
    miny = None
    maxx = None
    maxy = None

    def __init__(self, minx, miny, maxx, maxy):
        self.minx = minx
        self.miny = miny
        self.maxx = maxx
        self.maxy = maxy

    def __eq__(self, other):
        return self.minx == other.minx and self.miny == other.miny \
               and self.maxx == other.maxx and self.maxy == other.maxy

    def __ne__(self, other):
        return not self.__eq__(other)

    def __repr__(self):
        return "<%s(%s)>" % (self.__class__.__name__, str(self))

    def __str__(self):
        return '[%s, %s, %s, %s]' % tuple([str(o) for o in (self.minx, self.miny, self.maxx, self.maxy)])

class XMLBuilder(object):
    """
    Turn a Metadata object into XML

    The sole purpose of this class is to convert Metadata DOM
    instances to a Libxml2 document (see the build() method)
    """

    def __init__(self, metadata):
        from medin import __version__
        self.m = metadata

        # create the document
        self.doc = doc = libxml2.newDoc("1.0")
        comment = doc.newDocComment("Created by MEDIN Metadata Generator version %s" % str(__version__))
        doc.addChild(comment)

        # create the root element and namespaces
        self.root = root = doc.newChild(None, "MD_Metadata", None)
        gmd = root.newNs("http://www.isotc211.org/2005/gmd", "gmd")
        gco = root.newNs("http://www.isotc211.org/2005/gco", "gco")
        root.setNs(gmd)
        self.ns = {'gmd':gmd,
                   'gco':gco}

    def build(self):
        """
        Populate the XML document from the metadata DOM

        This should only be called once per instance!
        """

        self.root.addChild(self.identificationInfo())
        self.root.addChild(self.hierarchyLevel())
        self.root.addChild(self.distributionInfo())
        self.root.addChild(self.dateStamp())
        self.root.addChild(self.metadataStandardName())
        self.root.addChild(self.metadataStandardVersion())
        self.root.addChild(self.language())
        
        return self.doc

    def identificationInfo(self):
        """
        Create the identification information
        """
        identificationInfo = self.doc.newDocNode(self.ns['gmd'], 'identificationInfo', None)
        MD_DataIdentification = identificationInfo.newChild(None, 'MD_DataIdentification', None)
        citation = MD_DataIdentification.newChild(None, 'citation', None)
        CI_Citation = citation.newChild(None, 'CI_Citation', None)
        CI_Citation.addChild(self.title())
        for node in self.alternativeTitles():
            CI_Citation.addChild(node)
        CI_Citation.addChild(self.identifier())
        MD_DataIdentification.addChild(self.abstract())
        MD_DataIdentification.addChild(self.extent())

        return identificationInfo

    def hierarchyLevel(self):
        hierarchyLevel = self.doc.newDocNode(self.ns['gmd'], 'hierarchyLevel', None)
        hierarchyLevel.addChild(self.resourceType())
        return hierarchyLevel

    def distributionInfo(self):
        distributionInfo = self.doc.newDocNode(self.ns['gmd'], 'distributionInfo', None)
        MD_Distribution = distributionInfo.newChild(None, 'MD_Distribution', None)
        MD_Distribution.addChild(self.doc.newDocComment(
                "ISO 19115 Constraints require this element!"))
        distributionFormat = MD_Distribution.newChild(None, 'distributionFormat', None)
        distributionFormat.setNsProp(self.ns['gco'], 'nilReason', 'inapplicable')
        if not self.m.resource_locators:
            return distributionInfo
        transferOptions = MD_Distribution.newChild(None, 'transferOptions', None)
        MD_DigitalTransferOptions = transferOptions.newChild(
            None, 'MD_DigitalTransferOptions', None)
        onLine = MD_DigitalTransferOptions.newChild(None, 'onLine', None)
        for node in self.resourceLocators():
            onLine.addChild(node)
        return distributionInfo

    def title(self):
        """
        Element 1 to XML
        """
        title = self.doc.newDocNode(self.ns['gmd'], 'title', None)
        characterString = title.newChild(self.ns['gco'], 'CharacterString', self.m.title)
        return title

    def alternativeTitles(self):
        """
        Element 2 to XML
        """
        alt_titles = []
        for title in self.m.alt_titles:
            alternateTitle = self.doc.newDocNode(self.ns['gmd'], 'alternateTitle', None)
            characterString = alternateTitle.newChild(self.ns['gco'], 'CharacterString', str(title))
            alt_titles.append(alternateTitle)
        return alt_titles

    def abstract(self):
        """
        Element 3 to XML
        """
        abstract = self.doc.newDocNode(self.ns['gmd'], 'abstract', None)
        characterString = abstract.newChild(self.ns['gco'], 'CharacterString', str(self.m.abstract))
        return abstract

    def resourceType(self):
        """
        Element 4 to XML
        (must be 5 [dataset], 6 [series], or 14 [service])
        """
        term = self.m.vocabs.getResourceTypeFromCode(self.m.resource_type).term
        MD_ScopeCode = self.doc.newDocNode(self.ns['gmd'], 'MD_ScopeCode', term)
        MD_ScopeCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode')
        MD_ScopeCode.setProp('codeListValue', term)
        return MD_ScopeCode

    def resourceLocators(self):
        """
        Element 5 to XML
        Not known how to present resource's name, or how to show >1 locator.
        """
        resource_locators = []
        for rl in self.m.resource_locators:        
            CI_OnlineResource = self.doc.newDocNode(self.ns['gmd'], 'CI_OnlineResource', None)
            linkage = CI_OnlineResource.newChild(None, 'linkage', None)
            URL = linkage.newChild(None, 'URL', rl.url)
            # query: what's the XML spec for providing link's name??
            if rl.name:
                name = linkage.newChild(None, 'name', rl.name)
            resource_locators.append(CI_OnlineResource)
        return resource_locators

    def identifier(self):
        """
        Element 6 to XML
        """
        unique_id = self.m.unique_id
        identifier = self.doc.newDocNode(self.ns['gmd'], 'identifier', None)
        code = identifier.newChild(None, 'code', None)
        characterString = code.newChild(self.ns['gco'], 'CharacterString', unique_id.id)
        if unique_id.codespace:
            codeSpace = identifier.newChild(None, 'codeSpace', None)
            characterString = codeSpace.newChild(self.ns['gco'], 'CharacterString', unique_id.codespace)
            
        return identifier

    def extent(self):
        """
        Element 12
        """
        bbox = self.m.bounding_box
        extent = self.doc.newDocNode(self.ns['gmd'], 'extent', None)
        EX_Extent = extent.newChild(None, 'EX_Extent', None)
        geographicElement = EX_Extent.newChild(None, 'geographicElement', None)
        EX_GeographicBoundingBox = geographicElement.newChild(None, 'EX_GeographicBoundingBox', None)
        westBoundLongitude = EX_GeographicBoundingBox.newChild(None, 'westBoundLongitude', None)
        decimal = westBoundLongitude.newChild(self.ns['gco'], 'Decimal', str(bbox.minx))
        eastBoundLongitude = EX_GeographicBoundingBox.newChild(None, 'eastBoundLongitude', None)
        decimal = eastBoundLongitude.newChild(self.ns['gco'], 'Decimal', str(bbox.maxx))
        southBoundLongitude = EX_GeographicBoundingBox.newChild(None, 'southBoundLongitude', None)
        decimal = southBoundLongitude.newChild(self.ns['gco'], 'Decimal', str(bbox.miny))
        northBoundLongitude = EX_GeographicBoundingBox.newChild(None, 'northBoundLongitude', None)
        decimal = northBoundLongitude.newChild(self.ns['gco'], 'Decimal', str(bbox.maxy))

        return extent

    def dateStamp(self):
        """
        Element 26 to XML
        """
        import datetime
        
        dateStamp = self.doc.newDocNode(self.ns['gmd'], 'dateStamp', None)
        sdate = self.m.date.isoformat()
        if isinstance(self.m.date, datetime.datetime):
            ele_name = 'DateTime'
        else:
            ele_name = 'Date'
        date = dateStamp.newChild(self.ns['gco'], ele_name, sdate)
        return dateStamp

    def metadataStandardName(self):
        """
        Element 27 to XML
        """
        metadataStandardName = self.doc.newDocNode(self.ns['gmd'], 'metadataStandardName', None)
        characterString = metadataStandardName.newChild(self.ns['gco'], 'CharacterString', self.m.standard)
        return metadataStandardName

    def metadataStandardVersion(self):
        """
        Element 28 to XML
        """
        metadataStandardVersion = self.doc.newDocNode(self.ns['gmd'], 'metadataStandardVersion', None)
        characterString = metadataStandardVersion.newChild(self.ns['gco'], 'CharacterString', self.m.version)
        return metadataStandardVersion

    def language(self):
        """
        Element 29 to XML
        """
        language = self.doc.newDocNode(self.ns['gmd'], 'language', None)
        languageCode = language.newChild(None, 'LanguageCode', self.m.language)
        languageCode.setProp("codeList", "http://www.loc.gov/standards/iso639-2/php/code_list.php")
        languageCode.setProp("codeListValue", "eng")

        return language
