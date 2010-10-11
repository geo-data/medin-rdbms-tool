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

    # Element 7
    coupled_resources = None

    # Element 8
    resource_languages = None

    # Element 9
    topic_categories = None

    # Element 10
    service_type = None

    # Element 11
    keywords = None

    # Element 12
    bounding_box = None

    # Element 13
    extents = None

    # Element 14
    vertical_extent = None

    # Element 15
    spatial_reference_system = None

    # Element 16
    temporal_reference = None

    # Element 17
    lineage = None
    
    # Element 18
    spatial_resolution = None
    
    # Element 19
    additional_info = None

    # Element 20
    limitations_public_access = None
    limitations_public_access_vocab = None

    # Element 21
    conditions_applying_for_access_and_use = None

    # Element 22
    responsible_parties = None

    # Element 23
    data_format = None

    # Element 24
    frequency_of_update = None

    # Element 25
    inspire_conformity = None

    # Element 26 
    date = None

    # Element 27
    standard = 'MEDIN Discovery Metadata Standard'

    # Element 28
    version = 'Version 2.3'

    # Element 29
    language = 'English'

    def __init__(self):
        # multiple values
        self.alt_titles = []
        self.resource_locators = []
        self.coupled_resources = []
        self.resource_languages = []
        self.topic_categories = []
        self.keywords = []
        self.spatial_resolution = []
        self.limitations_public_access = []
        self.limitations_public_access_vocab = []
        self.conditions_applying_for_access_and_use = []
        self.responsible_parties = []

class ResourceLocator(object):
    """
    Element 5
    """
    url = None
    name = None

class UniqueId(object):
    """
    Element 6
    (jra: not sure the purpose of the comparison methods -- is it for suds?)
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

class CoupledResource(object):
    """
    Element 7
    """
    resource = None

class ResourceLanguage(object):
    """
    Element 8
    """
    language = None
    code = None

class Keyword(object):
    """
    Element 11
    """
    keyword = None
    thesaurus = None

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

class VerticalExtent(object):
    """
    Element 14
    """
    minv = None
    maxv = None
    refid = None

    def __init__(self, minv, maxv, refid):
        self.minv = minv
        self.maxv = maxv
        self.refid = refid

    def __nonzero__(self):
        return minv is not None

#class SpatialReferenceSystem(object):
#    """
#    Element 15
#    """
#    code = None
#    codeSpace = None

class TemporalReference(object):
    """
    Element 16
    """
    extent_begin = None
    extent_end = None
    date_publication = None
    #date_publication_type = None
    date_revision = None
    #date_revision_type = None
    date_creation = None
    #date_creation_type = None

    def __init__(self, begin, end, pub, rev, create):
        self.extent_begin = begin
        self.extent_end = end
        self.date_publication = pub
        self.date_revision = rev
        self.date_creation = create

    def __nonzero__(self):
        return self.extent_begin is not None

class SpatialResolution(object):
    """
    Element 18
    """
    distance = None
    equivalent_scale = None
    def __init__(self, distance, equivalent_scale):
        self.distance = distance
        self.equivalent_scale = equivalent_scale


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
        gml = root.newNs("http://www.opengis.net/gml/3.2", "gml")
        gmd = root.newNs("http://www.isotc211.org/2005/gmd", "gmd")
        gco = root.newNs("http://www.isotc211.org/2005/gco", "gco")
        xlink = root.newNs("http://www.w3.org/1999/xlink", "xlink")
        srv = root.newNs("http://www.isotc211.org/2005/srv", "srv")
        root.setNs(gmd)
        self.ns = {'gml':gml,
                   'gmd':gmd,
                   'gco':gco,
                   'srv':srv,
                   'xlink':xlink}

    def build(self):
        """
        Populate the XML document from the metadata DOM

        This should only be called once per instance!
        """

        self.root.addChild(self.identificationInfo())
        self.root.addChild(self.hierarchyLevel())
        self.root.addChild(self.distributionInfo())
        for node in self.responsibleParties_distributors():
            self.root.addChild(node)
        self.root.addChild(self.spatialReferenceSystem())
        self.root.addChild(self.dataQualityInfo())
        for node in self.responsibleParties_pointsOfContact():
            self.root.addChild(node)
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
        for node in self.resourceLanguages():
            MD_DataIdentification.addChild(node)
        SV_ServiceIdentification = self.ServiceIdentification()
        if SV_ServiceIdentification.children is not None:
            MD_DataIdentification.addChild(SV_ServiceIdentification)
        for node in self.topicCategories():
            MD_DataIdentification.addChild(node)

        nodes = self.keywords()
        # TODO: add other keyword types (date etc.)
        if nodes is not None:
            descriptiveKeywords = MD_DataIdentification.newChild(
                None, 'descriptiveKeywords', None)
            MD_Keywords = descriptiveKeywords.newChild(
                None, 'MD_Keywords', None)
            for node in nodes:
                MD_Keywords.addChild(node)
        MD_DataIdentification.addChild(self.temporalReference());
        for node in self.temporalReferenceDates():
            CI_Citation.addChild(node)

        MD_DataIdentification.addChild(self.spatialResolution())

        if self.m.additional_info is not None:
            MD_DataIdentification.addChild(self.additionalInfo())


        resourceConstraints = MD_DataIdentification.newChild(
#self.doc.newDocNode(
            None, 'resourceConstraints', None)
        MD_LegalConstraints = resourceConstraints.newChild(
            None, 'MD_LegalConstraints', None)
        for node in self.limitationsOnPublicAccess():
            MD_LegalConstraints.addChild(node)
        for node in self.conditionsForAccessAndUse():
            MD_DataIdentification.addChild(node)

        #MD_DataIdentification.addChild(self.responsibleParties_originator())

        if self.m.data_format is not None:
            MD_DataIdentification.addChild(self.dataFormat())

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
        if self.m.resource_locators:
            transferOptions = MD_Distribution.newChild(None, 'transferOptions', None)
            MD_DigitalTransferOptions = transferOptions.newChild(
                None, 'MD_DigitalTransferOptions', None)
            onLine = MD_DigitalTransferOptions.newChild(None, 'onLine', None)
            for node in self.resourceLocators():
                onLine.addChild(node)
        return distributionInfo

    def dataQualityInfo(self):
        dataQualityInfo = self.doc.newDocNode(
            self.ns['gmd'], 'dataQualityInfo', None)
        DQ_DataQuality = dataQualityInfo.newChild(None, 'DQ_DataQuality', None)
        DQ_DataQuality.addChild(self.doc.newDocComment(
                "Scope - Required by ISO 19115 constraint"))
        scope = DQ_DataQuality.newChild(None, 'scope', None)
        SQ_Scope = scope.newChild(None, 'SQ_Scope', None)
        level = SQ_Scope.newChild(None, 'level', 'dataset')
        level.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode')
        level.setProp('codeListValue', 'dataset')
        
        DQ_DataQuality.addChild(self.doc.newDocComment("Lineage"))
        DQ_DataQuality.addChild(self.lineage())
        return dataQualityInfo

    def ServiceIdentification(self):
        SV_ServiceIdentification = self.doc.newDocNode(
            self.ns['srv'], 'SV_ServiceIdentification', None)

        for node in self.coupledResources():
            SV_ServiceIdentification.addChild(node)

        if self.m.service_type:
            SV_ServiceIdentification.addChild(self.spatialDataServiceType())

        return SV_ServiceIdentification


    def extent(self):
        extent = self.doc.newDocNode(self.ns['gmd'], 'extent', None)
        EX_Extent = extent.newChild(None, 'EX_Extent', None)
        geographicElement = EX_Extent.newChild(None, 'geographicElement', None)
        geographicElement.addChild(self.boundingBox());

        if self.m.extents is not None:
            EX_GeographicDescription = geographicElement.newChild(
                None, 'EX_GeographicDescription', None)
            EX_GeographicDescription.addChild(self.doc.newDocComment(
                    'Extent - by Identifier'))
            for node in self.extents():
                EX_GeographicDescription.addChild(node)

        if self.m.vertical_extent is not None:
            EX_Extent.addChild(self.verticalExtent())

        return extent


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
        MD_ScopeCode.setProp(
            'codeList',
            'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode')
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

    def coupledResources(self):
        """
        Element 7 to XML
        """
        coupled_resources = []
        for coupled_resource in self.m.coupled_resources:
            operatesOn = self.doc.newDocNode(self.ns['srv'], 'operatesOn', None)
            operatesOn.setNsProp(self.ns['xlink'], 'href', coupled_resource.resource)
            coupled_resources.append(operatesOn)
        return coupled_resources

    def resourceLanguages(self):
        """
        Element 8 to XML
        """
        resource_languages = []
        try:
            it = iter(self.m.resource_languages)
        except TypeError:
            return []

        for resource_language in self.m.resource_languages:
            language = self.doc.newDocNode(self.ns['gmd'], 'language', None)
            LanguageCode = language.newChild(None, 'LanguageCode', resource_language.language)
            LanguageCode.setProp('codeList', 'http://www.loc.gov/standards/iso639-2/php/code_list.php')
            LanguageCode.setProp('codeListValue', resource_language.code)
            resource_languages.append(language)
        return resource_languages

    def topicCategories(self):
        """
        Element 9 to XML
        """
        try:
            it = iter(self.m.topic_categories)
        except TypeError:
            return []

        topic_catagories = []
        for topic_category in self.m.topic_categories:
            if not self.m.vocabs.getTopicCategory(topic_category):
                continue
            topicCategory = self.doc.newDocNode(self.ns['gmd'], 'topicCateogory', None)
            MD_TopicCategoryCode = topicCategory.newChild(None, 'MD_TopicCategoryCode', topic_category)
            topic_categories.append(topicCategory)
        return topic_categories

    def spatialDataServiceType(self):
        """
        Element 10 to XML
        """
        serviceType = self.doc.newDocNode(self.ns['srv'], 'serviceType', None)
        LocalName = serviceType.newChild(self.ns['gco'], 'LocalName', self.m.vocabs.getINSPIREDataTypeFromCode(self.m.service_type))
        return serviceType

    def keywords(self):
        """
        Element 11 to XML
        """
        keyword_nodes = []
        thesaurus_nodes = []
        thesauri = set() # all elements distinct
        for node in self.m.keywords:
            keyword = self.doc.newDocNode(self.ns['gmd'], 'keyword', None)
            CharacterString = keyword.newChild(
                self.ns['gco'], 'CharacterString', node.keyword)
            keyword_nodes.append(keyword)
            thesauri.add(node.thesaurus)

        for thesaurus_id in thesauri:
            thesaurus = self.m.vocabs.getThesaurus(thesaurus_id)
            # TODO: add date, date type -- add to vocabs?
            thesaurus.date = 'TO DO'
            thesaurus.dateType = 'TO DO'
            
            thesaurusName = self.doc.newDocNode(
                self.ns['gmd'], 'thesaurusName', None)
            CI_Citation = thesaurusName.newChild(None, 'CI_Citation', None)
            title = CI_Citation.newChild(None, 'title', None)
            CharacterString = title.newChild(
                self.ns['gco'], 'CharacterString', thesaurus.name)

            date = CI_Citation.newChild(None, 'date', None)
            CI_Date = date.newChild(None, 'CI_Date', None)
            date2 = CI_Date.newChild(None, 'date', None)
            Date = date2.newChild(self.ns['gco'], 'Date', thesaurus.date)
            dateType = CI_Date.newChild(None, 'dateType', None)
            CI_DateTypeCode = dateType.newChild(None, 'CI_DateTypeCode', thesaurus.dateType)
            CI_DateTypeCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode')
            CI_DateTypeCode.setProp('codeListValue', thesaurus.dateType)

            thesaurus_nodes.append(thesaurusName)

        return keyword_nodes + thesaurus_nodes
            
    def boundingBox(self):
        """
        Element 12 to XML
        """
        bbox = self.m.bounding_box
        EX_GeographicBoundingBox = self.doc.newDocNode(
            self.ns['gmd'], 'EX_GeographicBoundingBox', None)
        westBoundLongitude = EX_GeographicBoundingBox.newChild(
            None, 'westBoundLongitude', None)
        eastBoundLongitude = EX_GeographicBoundingBox.newChild(
            None, 'eastBoundLongitude', None)
        southBoundLongitude = EX_GeographicBoundingBox.newChild(
            None, 'southBoundLongitude', None)
        northBoundLongitude = EX_GeographicBoundingBox.newChild(
            None, 'northBoundLongitude', None)
        westBoundLongitude.newChild(self.ns['gco'], 'Decimal', str(bbox.minx))
        eastBoundLongitude.newChild(self.ns['gco'], 'Decimal', str(bbox.maxx))
        southBoundLongitude.newChild(self.ns['gco'], 'Decimal', str(bbox.miny))
        northBoundLongitude.newChild(self.ns['gco'], 'Decimal', str(bbox.maxy))
        return EX_GeographicBoundingBox

    def extents(self):
        """
        Element 13 to XML
        (a lot like Element 11 -- also TODO: unfinished (thesaurus date & dateType)
        (not used in bodc, so untested!)
        """
#        extent_name_nodes = []
#        thesaurus_nodes = []
        nodes = []
        thesauri = {}

        # collect thesauri
        for node in self.m.extents:
            if node.thesaurus in thesauri:
                thesauri[node.thesaurus].add(node)
            else:
                thesauri[node.thesaurus] = set(node)

        # loop through nodes in order of thesaurus
        for thesaurus in theauri:
            # thesaurus stuff...
            geographicIdentifier = self.doc.newDocNode(self.ns['gmd'], 'geographicIdentifier', None)
            MD_Identifier = geographicIdentifier.newChild(None, 'MD_Identifier', None)
            authority = MD_Identifier.newChild(None, 'authority', None)
            CI_Citation = authority.newChild(None, 'CI_Citation', None)
            title = CI_Citation.newChild(None, 'title', None)

            # TODO: vocab lookup
            CharacterString = title.newChild(self.ns['gco'], 'CharacterString', thesaurus)

            date = CI_Citation.newChild(None, 'date', None)
            CI_Date = date.newChild(None, 'CI_Date', None)
            date2 = CI_Date.newChild(None, 'date', None)
            Date = date2.newChild(self.ns['gco'], 'Date', 'to do')
            dateType = date.newChild(None, 'dateType', None)
            CI_DateTypeCode = date.newChild(None, 'CI_DateTypeCode', 'to do')
            CI_DateTypeCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode')
            CI_DateTypeCode.setProp('codeListValue', 'to do')

            # code stuff (potentially many per thesaurus?)
            for node in thesauri[thesaurus]:
                code = MD_Identifier.newChild(None, 'code', None)
                CharacterString = code.newChild(self.ns['gco'], 'CharacterString', node.keyword)

            nodes.append(geographicIdentifier)
        
        return nodes

    def verticalExtent(self):
        """
        Element 14 to XML
        """
        verticalElement = self.doc.newDocNode(
            self.ns['gmd'], 'verticalElement', None)
        EX_VerticalExtent = verticalElement.newChild(
            None, 'EX_VerticalExtent', None)
        minimumValue = EX_VerticalExtent.newChild(None, 'minimumValue', None)
        maximumValue = EX_VerticalExtent.newChild(None, 'maximumValue', None)
        minimumValue.setNsProp(
            self.ns['gco'], 'Real', self.m.vertical_extent.minv)
        maximumValue.setNsProp(
            self.ns['gco'], 'Real', self.m.vertical_extent.maxv)
        verticalCRS = EX_VerticalExtent.newChild(None, 'verticalCRS', None)
        verticalCRS.setNsProp(
            self.ns['xlink'], 'href', self.m.vertical_extent.refid)

        return verticalElement
        
    def spatialReferenceSystem(self):
        """
        Element 15 to XML
        """

        code = None #self.m.vocabs(...)
        codeSpace = None #self.m.vocabs(...) # self.m.spatial_reference_system


        referenceSystemInfo = self.doc.newDocNode(
            self.ns['gmd'], 'referenceSystemInfo', None)
        MD_ReferenceSystem = referenceSystemInfo.newChild(
            None, 'MD_ReferenceSystem', None)
        referenceSystemIdentifier = MD_ReferenceSystem.newChild(
            None, 'referenceSystemIdentifier', None)
        RS_Identifier = referenceSystemIdentifier.newChild(
            None, 'RS_Identifier', None)
        code = RS_Identifier.newChild(None, 'code', None)
        CharacterString = code.newChild(
            self.ns['gco'], 'CharacterString',
            self.m.spatial_reference_system)#.code)
        codeSpace = RS_Identifier.newChild(None, 'codeSpace', None)
        CharacterString = codeSpace.newChild(
            self.ns['gco'], 'CharacterString', 'TODO')
            #self.m.spatial_reference_system.codeSpace)
        return referenceSystemInfo

    def temporalReference(self):
        """
        Element 16.1 to XML
        """
        extent = self.doc.newDocNode(self.ns['gmd'], 'extent', None)
        EX_Extent = extent.newChild(None, 'EX_Extent', None)
        temporalElement = EX_Extent.newChild(None, 'temporalElement', None)
        extent2 = temporalElement.newChild(None, 'extent', None)
        TimePeriod = extent2.newChild(self.ns['gml'], 'TimePeriod', None)
        TimePeriod.setProp('id', 'medinMEDIN01')
        TimePeriod.newChild(
            None, 'beginPosition', self.m.temporal_reference.extent_begin)
        TimePeriod.newChild(
            None, 'endPosition', self.m.temporal_reference.extent_end)
        return extent
        
    def temporalReferenceDates(self):
        """
        Element 16.[234] to XML
        """
        # TODO: temporal citation publication date gets put in CI_Citation !! (assume creation and revision are the same)
        nodes = []
        if self.m.temporal_reference.date_publication is not None:
            date = self.doc.newDocNode(self.ns['gmd'], 'date', None)
            CI_Date = date.newChild(None, 'CI_Date', None)
            date2 = CI_Date.newChild(None, 'date', None)
            Date = date2.newChild(self.ns['gco'], 'Date',
                                  str(self.m.temporal_reference.date_publication))
            dateType = CI_Date.newChild(None, 'dateType', None)
            CI_DateTypeCode = dateType.newChild(None, 'CI_DateTypeCode',
                                                'publication')
            CI_DateTypeCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode')
            CI_DateTypeCode.setProp('codeListValue', 'publication')
            nodes.append(date)

        if self.m.temporal_reference.date_revision is not None:
            date = self.doc.newDocNode(self.ns['gmd'], 'date', None)
            CI_Date = date.newChild(None, 'CI_Date', None)
            date2 = CI_Date.newChild(None, 'date', None)
            Date = date2.newChild(self.ns['gco'], 'Date',
                                  str(self.m.temporal_reference.date_revision))
            dateType = CI_Date.newChild(None, 'dateType', None)
            CI_DateTypeCode = dateType.newChild(None, 'CI_DateTypeCode',
                                                'revision')
            CI_DateTypeCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode')
            CI_DateTypeCode.setProp('codeListValue', 'revision')
            nodes.append(date)

        if self.m.temporal_reference.date_creation is not None:
            date = self.doc.newDocNode(self.ns['gmd'], 'date', None)
            CI_Date = date.newChild(None, 'CI_Date', None)
            date2 = CI_Date.newChild(None, 'date', None)
            Date = date2.newChild(self.ns['gco'], 'Date',
                                  str(self.m.temporal_reference.date_creation))
            dateType = CI_Date.newChild(None, 'dateType', None)
            CI_DateTypeCode = dateType.newChild(None, 'CI_DateTypeCode',
                                                'creation')
            CI_DateTypeCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode')
            CI_DateTypeCode.setProp('codeListValue', 'creation')
            nodes.append(date)

        return nodes

    def lineage(self):
        """
        Element 17 to XML
        """
        lineage = self.doc.newDocNode(self.ns['gmd'], 'lineage', None)
        LI_Lineage = lineage.newChild(None, 'LI_Lineage', None)
        statement = LI_Lineage.newChild(None, 'statement', None)
        statement.newChild(self.ns['gco'], 'CharacterString', self.m.lineage)
        return lineage

    def spatialResolution(self):
        """
        Element 18 to XML
        """
        spatialResolution = self.doc.newDocNode(
            self.ns['gmd'], 'spatialResolution', None)
        MD_Resolution = spatialResolution.newChild(None, 'MD_Resolution', None)

        for x in self.m.spatial_resolution:
            if x.distance is not None:
                distance = MD_Resolution.newChild(None, 'distance', None)
                if x.distance == 'inapplicable':
                    distance.setNsProp(
                        self.ns['gco'], 'nilReason', 'inapplicable')
                else:
                    Distance = distance.newChild(self.ns['gco'], 'Distance',
                                                 x.distance)
                    Distance.setProp('uom', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/uom/gmxUom.xml#m')
            elif x.equivalent_scale is not None:
                equivalentScale = MD_Resolution.newChild(
                    None, 'equivalentScale', None)
                MD_RepresentativeFraction = equivalentScale.newChild(
                    None, 'MD_RepresentativeFraction', None)
                denominator = MD_RepresentativeFraction.newChild(
                    None, 'denominator', None)
                denominator.newChild(self.ns['gco'], 'Integer',
                                     x.equivalent_scale)
        return spatialResolution

    def addtionalInfo(self):
        """
        Element 19 to XML
        """
        supplementalInformation = self.doc.newDocNode(
            self.ns['gmd'], 'supplementalInformation', None)
        supplementalInformation.newChild(self.ns['gco'], 'CharacterString', self.m.additional_info)
        return supplementalInformation

    def limitationsOnPublicAccess(self):
        """
        Element 20 to XML
        """
        nodes = []
        for node in self.m.limitations_public_access_vocab:
            access_restriction = self.m.vocabs.getAccessRestrictionFromCode(node.ISOCODEID)
            print "%d %s" % (node.ISOCODEID, access_restriction)
            accessConstraints = self.doc.newDocNode(
                self.ns['gmd'], 'accessConstraints', None)
            MD_RestrictionCode = accessConstraints.newChild(
                None, 'MD_RestrictionCode', access_restriction)
            MD_RestrictionCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode')
            MD_RestrictionCode.setProp('codeListValue', access_restriction)
            nodes.append(accessConstraints)

        for node in self.m.limitations_public_access:
            otherConstraints = self.doc.newDocNode(
                self.ns['gmd'], 'otherConstraints', None)
            otherConstraints.newChild(self.ns['gco'], 'CharacterString',
                                      str(node))
            nodes.append(otherConstraints)
        return nodes

    def conditionsForAccessAndUse(self):
        """
        Element 21 to XML
        """
        nodes = []
        for node in self.m.limitations_public_access:
            resourceConstraints = self.doc.newDocNode(
                self.ns['gmd'], 'resourceConstraints', None)
            MD_Constraints = resourceConstraints.newChild(
                None, 'MD_Constraints', None)
            useLimitation = MD_Constraints.newChild(
                None, 'useLimitation', None)
            useLimitation.newChild(self.ns['gco'], 'CharacterString', str(node))
            nodes.append(resourceConstraints)
        return nodes

    def responsibleParties_pointsOfContact(self):
        """
        Element 22.4 to XML
        TODO:
        """
        return []
        contacts = []
        for party in self.m.responsible_parties:
            if self.m.vocabs.getContactRoleFromCode(party.ROLEID) == 'pointOfContact':
                full_name = "%s %s" % (party.FIRSTNAME, party.SURNAME)
                


                contact = self.doc.newDocNode(
                    self.ns['gmd'], 'contact', None)
                CI_ResponsibleParty = contact.newChild(
                    None, 'CI_ResponsibleParty', None)
                individual_name = CI_ResponsibleParty.newChild(
                    None, 'individual_name', None)
                individual_name.newChild(
                    self.ns['gco'], 'CharacterString', full_name)

                if contact.PHONE or contact.address or contact.email:
                    contactInfo = contact.newChild(None, 'contactInfo', None)
                    CI_Contact = contactInfo.newChild(None, 'CI_Contact', None)
                    if contact.PHONE:
                        phone = CI_Contact.newChild(None, 'phone', None)
                        CI_Telephone = phone.newChild(None, 'CI_Telephone', None)
                        voice = CI_Telephone.newChild(None, 'voice', None)
                        voice.newChild(self.ns['gco'], 'CharacterString', contact.PHONE)
                    if contact.address:
                        pass
                    if contact.email:
                        pass

                role = CI_ResponsibleParty.newChild(None, 'role', None)
                CI_RoleCode = role.newChild(None, 'CI_RoleCode', 'pointOfContact')
                CI_RoleCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode')
                CI_RoleCode.setProp('codeListValue', 'pointOfContact')


                contacts.append(contact)
        return contacts
    
    def responsibleParties_originator(self):
        """
        Element 22.1 to XML
        TODO:
        """
        
        contacts = []
        for contact in self.m.responsible_parties:
            if self.m.vocabs.getContactRoleFromCode(party.ROLEID) == 'originator':
                pointOfContact = self.doc.newDocNode(self.ns['gmd'], 'pointOfContact', None)
                CI_ResponsibleParty = pointOfContact.newChild(None, 'CI_ResponsibleParty', None)
                organisationName = CI_ResponsibleParty.newChild(None, 'organisationName', None)
                organisationName.newChild(self.ns['gco'], 'CharacterString', contact.ORGID)
                positionName = CI_ResponsibleParty.newChild(None, 'positionName', None)
                organisationName.newChild(self.ns['gco'], 'CharacterString', contact.POSITIONTITLE)
                
                if contact.PHONE or contact.address or contact.email:
                    contactInfo = CI_ResponsibleParty.newChild(None, 'contactInfo', None)
                    CI_Contact = contactInfo.newChild(None, 'CI_Contact', None)
                    if contact.PHONE:
                        pass
                    if contact.address:
                        pass
                    if contact.email:
                        pass
                
                role = CI_ResponsibleParty.newChild(None, 'role', None)
                CI_RoleCode = role.newChild(None, 'CI_RoleCode', 'originator')
                CI_RoleCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode')
                CI_RoleCode.setProp('codeListValue', 'originator')
                contacts.append(pointOfContact)
        return contacts
    
    def responsibleParties_distributors(self):
        return []

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
