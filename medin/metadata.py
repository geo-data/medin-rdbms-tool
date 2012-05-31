# Created by Homme Zwaagstra
# 
# Copyright (c) 2011 GeoData Institute
# http://www.geodata.soton.ac.uk
# geodata@soton.ac.uk
# 
# Unless explicitly acquired and licensed from Licensor under another
# license, the contents of this file are subject to the Reciprocal
# Public License ("RPL") Version 1.5, or subsequent versions as
# allowed by the RPL, and You may not copy or use this file in either
# source code or executable form, except in compliance with the terms
# and conditions of the RPL.
# 
# All software distributed under the RPL is provided strictly on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR
# IMPLIED, AND LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES,
# INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT, OR
# NON-INFRINGEMENT. See the RPL for specific language governing rights
# and limitations under the RPL.
# 
# You can obtain a full copy of the RPL from
# http://opensource.org/licenses/rpl1.5.txt or geodata@soton.ac.uk

"""
Representation of MEDIN Metadata Specification

This is a DOM representing the MEDIN schema. It is populated by
mapping the object to a provider database schema. This mapping is done
using the appropriate provider plugin module in the medin.provider
package.
"""
import libxml2
from xml.sax.saxutils import escape
from medin.util import Proxy
from medin.vocabulary import Session as VocabSession

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
    srs = None

    # Element 16
    temporal_reference = None

    # Element 17
    lineage = None

    # Element 18
    spatial_resolutions = None

    # Element 19
    additional_info = None

    # Element 20
    access_constraint_terms = None # terms from controlled vocabularies
    other_access_constraints = None # other free text access constraints

    # Element 21
    use_limitations = None

    # Element 22
    responsible_parties = None

    # Element 23
    data_formats = None

    # Element 24
    update_frequency = None

    # Element 25
    inspire_conformity = None

    # Element 26
    date = None

    # Element 27
    standard = 'MEDIN Discovery Metadata Standard'

    # Element 28
    version = 'Version 2.3.5'

    # Element 29
    language = None

    # Element 30
    parent_id = None

    def __init__(self):
        # multiple values
        self.alt_titles = []
        self.resource_locators = []
        self.coupled_resources = []
        self.resource_languages = []
        self.topic_categories = []
        self.keywords = []
        self.spatial_resolutions = []
        self.access_constraint_terms = []
        self.other_access_constraints = []
        self.use_limitations = []
        self.responsible_parties = []
        self.data_formats = []
        self.extents = []

        # default values
        self.language = ResourceLanguage('English', 'eng')

    def fileIdentifier(self):
        """
        Generate an unique file identifier for this metadata entry

        This identifier is derived from the UUID 5 algorithm (an UUID
        derived from an URL).  The URL is created from the unique
        identifer (Element 6).
        """

        if self.unique_id:
            return self.unique_id.asIdentifier()
        return None

    def mappedKeywords(self):
        """
        Return a list of keywords

        The keywords have been augmented by associating them with
        INSPIRE theme keywords.
        """

        try:
            # try and return the keywords from the cache
            return self._mapped_keywords
        except AttributeError:
            pass

        keywords = set(self.keywords)
        keywords.update(self._mapKeywords(6))
        self._mapped_keywords = keywords
        return keywords

    def _mapKeywords(self, thesaurus_id, initial_terms=None):
        """
        Map existing keywords to a particular thesaurus

        This finds all synonyms and broader terms for existing
        keywords, returning those terms that belong to the specified
        thesaurus.
        """

        vocab = VocabSession()
        thesaurus = vocab.getThesaurus(thesaurus_id)

        def setMapping(term, topics, mapped):
            mapped.add(term)
            if term in thesaurus.members:
                topics.add(term)
            else:
                for attr in (getattr(term, name) for name in ('synonyms', 'broader')):
                    for other_term in attr.itervalues():
                        if other_term not in mapped:
                            setMapping(other_term, topics, mapped)
        
        mapping = set()         # the associated keywords
        mapped = set() # list of terms already associated (used to prevent recursion)

        if initial_terms:
            mapping.update(initial_terms)

        for term in self.keywords:
            setMapping(term, mapping, mapped)

        def reduceMapped(term, mapping):
            """
            Reduce the set terms to the most specific
            available.

            i.e. get rid of broader terms that have narrower
            definitions available
            """
            for t in term.broader.itervalues():
                if t in mapping:
                    mapping.remove(t)
                reduceMapped(t, mapping)
            
        for term in list(mapping):
            if term in mapping:  # it may have been removed already
                reduceMapped(term, mapping)

        return mapping

    def mappedTopicCategories(self):
        """
        Return a list of topic categories

        The list is generated from existing topic categories as well
        as those mapped to topic categories from other vocabularies
        (notably Sea Data Parameters P021)
        """

        try:
            # try and return the topics from the cache
            return self._mapped_topics
        except AttributeError:
            pass

        self._mapped_topics = topic_categories = self._mapKeywords(3, self.topic_categories)
        return topic_categories

class Comment(Proxy):
    """
    A class containing a comment about a particular metadata element
    """
    comment = None

class Year(Proxy):
    """
    Class representing a year
    """
    
    def __init__(self, year):
        from datetime import date
        super(Year, self).__init__(date(year, 1, 1))

    def isoformat(self):
        return '%d' % self.year
        
    def __str__(self):
        return str(self.year)

class YearMonth(Proxy):
    """
    Class representing a year and a month
    """
    def __init__(self, year, month):
        from datetime import date
        super(YearMonth, self).__init__(date(year, month, 1))
    
    def isoformat(self):
        return '%d-%02d' % (self.__subject__.year, self.__subject__.month)
    
    def __str__(self):
        return self.isoformat()

class Nil(object):
    def __init__(self, reason):
        self.reason = reason

    def __repr__(self):
        return '<Nil(%s)' % repr(self.reason)

    def __str__(self):
        return str(self.reason)

    def __hash__(self):
        return hash(self.__class__) + hash(self.reason)

class ResourceLocator(object):
    """
    Element 5
    """
    url = None
    name = None
    description = None
    function = None

    def __nonzero__(self):
        return bool(self.url or self.name)

class UniqueId(object):
    """
    Element 6

    The comparison methods are there to make it possible for this
    object to be used in SQLAlchemy filters on SQL queries.
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

    def asIdentifier(self):
        """
        Generate an unique identifier for this id

        This identifier is derived from the UUID 5 algorithm (an UUID
        derived from an URL).
        """
        from uuid import uuid5, NAMESPACE_URL

        name = str(self)
        return uuid5(NAMESPACE_URL, name).hex

    def __repr__(self):
        return "<%s('%s')>" % (self.__class__.__name__, str(self))

    def __str__(self):
        if self.codespace:
            return self.codespace + self.id
        return self.id

    def __add__(self, other):
        return str(self) + str(other)

    @classmethod
    def FromQualifiedId(cls, qualified_id):
        """
        Create an UniqueId object from a fully qualified identifier
        """

        split = qualified_id.rsplit('/', 1)
        try:
            codespace, id = split
            codespace += '/'
        except ValueError:
            codespace = None
            id = split[0]

        return cls(id, codespace)

class ResourceLanguage(object):
    """
    Element 8
    """
    name = None
    code = None

    def __init__(self, name, code):
        self.name = name
        self.code = code

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

    def __nonzero__(self):
        return bool(self.minx or self.miny or self.maxx or self.maxy)

    def __str__(self):
        return '[%s, %s, %s, %s]' % tuple([str(o) for o in (self.minx, self.miny, self.maxx, self.maxy)])

class VerticalExtent(object):
    """
    Element 14
    """
    minimum = None
    maximum = None
    crs = None

    def __init__(self, minimum, maximum, crs):
        self.minimum = minimum
        self.maximum = maximum
        self.crs = crs

    def __nonzero__(self):
        return bool(self.minimum and self.maximum and self.crs)

class TemporalReference(object):
    """
    Element 16
    """
    begin = None
    end = None
    publication = None
    revision = None
    creation = None

    def __init__(self, begin=None, end=None, publication=None, revision=None, creation=None):
        self.begin = begin
        self.end = end
        self.publication = publication
        self.revision = revision
        self.creation = creation

    def __nonzero__(self):
        return bool(self.begin or self.end or self.publication or self.revision or self.creation)

class SpatialResolution(object):
    """
    Element 18
    """
    distance = None
    equivalent_scale = None
    def __init__(self, distance=None, equivalent_scale=None):
        self.distance = distance
        self.equivalent_scale = equivalent_scale

class ResponsibleParty(object):
    """
    Element 22
    """
    position = None
    individual = None
    organisation = None
    address = None
    city = None
    zipcode = None
    state = None
    country = None
    website = None
    phone = None
    fax = None
    email = None
    role = None

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
        gmx = root.newNs("http://www.isotc211.org/2005/gmx", "gmx")
        root.setNs(gmd)
        self.ns = {'gml':gml,
                   'gmd':gmd,
                   'gmx':gmx,
                   'gco':gco,
                   'srv':srv,
                   'xlink':xlink}

    def addChild(self, parent, child):
        """
        Add a new child node to `parent`

        If it is a commented node, then the comment is added as a
        previous sibling to the child node.
        """
        if not child:
            return False

        child, comment = child
        node = parent.addChild(child)
        if comment:
            comment_node = self.doc.newDocComment(comment)
            node.addPrevSibling(comment_node)
        return True

    def build(self):
        """
        Populate the XML document from the metadata DOM

        This should only be called once per instance!
        """

        fileIdentifier = self.fileIdentifier()
        if fileIdentifier:
            self.root.addChild(fileIdentifier)
        self.root.addChild(self.language())
        node = self.parentIdentifier()
        if node: self.root.addChild(node)
        node = self.resourceType()
        if node: self.root.addChild(node)
        for node in self.metadataPointsOfContact():
            self.root.addChild(node)
        dateStamp = self.dateStamp()
        if dateStamp:
            self.root.addChild(dateStamp)
        node = self.metadataStandardName()
        if node: self.root.addChild(node)
        node = self.metadataStandardVersion()
        if node: self.root.addChild(node)
        self.addChild(self.root, self.spatialReferenceSystem())
        self.root.addChild(self.identificationInfo())
        self.root.addChild(self.distributionInfo())
        self.root.addChild(self.dataQualityInfo())

        return self.doc

    def setNodeValue(self, node, value, type_=None, attrs={}):
        """
        Set the value of an XML node

        If a type is specified the value is wrapped in the appropriate
        type element. If the value is a `Nil` object the node is
        attributed appropriately instead of assigning a value.
        """
        # check if it's a Nil value
        if isinstance(value, Nil):
            node.setNsProp(self.ns['gco'], 'nilReason', str(value))
            return

        # check if we need to wrap the value in a type elementn
        if not type_:
            node.setContent(str(value))
            return

        child = node.newChild(self.ns['gco'], type_, escape(str(value)))

        # add any attributes to the type element
        for attr, value in attrs.iteritems():
            child.setProp(attr, value)

    def fileIdentifier(self):
        """
        Create the unique metadata identifier
        """
        identifier = self.m.fileIdentifier()
        if not identifier:
            return None

        fileIdentifier = self.doc.newDocNode(self.ns['gmd'], 'fileIdentifier', None)
        fileIdentifier.newChild(self.ns['gco'], 'CharacterString', escape(str(identifier)))

        return fileIdentifier

    def identificationInfo(self):
        """
        Create the identification information
        """
        identificationInfo = self.doc.newDocNode(self.ns['gmd'], 'identificationInfo', None)
        MD_DataIdentification = identificationInfo.newChild(None, 'MD_DataIdentification', None)

        citation = MD_DataIdentification.newChild(None, 'citation', None)
        CI_Citation = citation.newChild(None, 'CI_Citation', None)
        title = self.title()
        if title:
            CI_Citation.addChild(title)
        for node in self.alternativeTitles():
            CI_Citation.addChild(node)
        for node in self.temporalReferenceDates():
            CI_Citation.addChild(node)

        identifier = self.identifier()
        if identifier:
            CI_Citation.addChild(identifier)

        abstract = self.abstract()
        if abstract:
            MD_DataIdentification.addChild(abstract)

        for node in self.pointsOfContact():
            MD_DataIdentification.addChild(node)

        node = self.frequencyOfUpdate()
        if node: MD_DataIdentification.addChild(node)

        for node in self.dataFormats():
            MD_DataIdentification.addChild(node)

        nodes = self.keywords()
        if nodes:
            for node in nodes:
                MD_DataIdentification.addChild(node)

        node = self.resourceConstraints()
        if node: MD_DataIdentification.addChild(node)

        node = self.spatialResolution()
        if node: MD_DataIdentification.addChild(node)

        for node in self.resourceLanguages():
            MD_DataIdentification.addChild(node)

        for node in self.topicCategories():
            MD_DataIdentification.addChild(node)

        node = self.extent()
        if node:
            MD_DataIdentification.addChild(node)

        SV_ServiceIdentification = self.serviceIdentification()
        if SV_ServiceIdentification: MD_DataIdentification.addChild(SV_ServiceIdentification)

        node = self.additionalInfo()
        if node: MD_DataIdentification.addChild(node)

        return identificationInfo

    def distributionInfo(self):
        distributionInfo = self.doc.newDocNode(self.ns['gmd'], 'distributionInfo', None)
        MD_Distribution = distributionInfo.newChild(None, 'MD_Distribution', None)
        MD_Distribution.addChild(self.doc.newDocComment("ISO 19115 Constraints require this element!"))
        distributionFormat = MD_Distribution.newChild(None, 'distributionFormat', None)
        self.setNodeValue(distributionFormat, Nil('inapplicable'))

        for node in self.distributors():
            MD_Distribution.addChild(node)

        for node in self.resourceLocators():
            MD_Distribution.addChild(node)

        return distributionInfo

    def dataQualityInfo(self):
        dataQualityInfo = self.doc.newDocNode(
            self.ns['gmd'], 'dataQualityInfo', None)
        DQ_DataQuality = dataQualityInfo.newChild(None, 'DQ_DataQuality', None)
        DQ_DataQuality.addChild(self.doc.newDocComment(
                "Scope - Required by ISO 19115 constraint"))
        scope = DQ_DataQuality.newChild(None, 'scope', None)
        DQ_Scope = scope.newChild(None, 'DQ_Scope', None)
        level = DQ_Scope.newChild(None, 'level', None)
        MD_ScopeCode = level.newChild(None, 'MD_ScopeCode', 'dataset')
        MD_ScopeCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode')
        MD_ScopeCode.setProp('codeListValue', 'dataset')

        lineage = self.lineage()
        if lineage:
            DQ_DataQuality.addChild(self.doc.newDocComment("Lineage"))
            DQ_DataQuality.addChild(self.lineage())
        return dataQualityInfo

    def serviceIdentification(self):
        SV_ServiceIdentification = self.doc.newDocNode(
            self.ns['srv'], 'SV_ServiceIdentification', None)

        for node in self.coupledResources():
            SV_ServiceIdentification.addChild(node)

        node = self.spatialDataServiceType()
        if node: SV_ServiceIdentification.addChild(node)

        if SV_ServiceIdentification.children:
            return SV_ServiceIdentification

        return None

    def extent(self):
        extent = self.doc.newDocNode(self.ns['gmd'], 'extent', None)
        EX_Extent = extent.newChild(None, 'EX_Extent', None)

        bbox = self.boundingBox()
        if bbox: EX_Extent.addChild(bbox)

        for node in self.extents():
            EX_Extent.addChild(node)

        node = self.temporalExtent()
        if node: EX_Extent.addChild(node)

        node = self.verticalExtent()
        if node: EX_Extent.addChild(node)

        if EX_Extent.children:
            return extent
        return None

    def title(self):
        """
        Element 1 to XML
        """
        if not self.m.title:
            return None

        title = self.doc.newDocNode(self.ns['gmd'], 'title', None)
        self.setNodeValue(title, self.m.title, 'CharacterString')
        return title

    def alternativeTitles(self):
        """
        Element 2 to XML
        """
        alt_titles = []
        for title in self.m.alt_titles:
            alternateTitle = self.doc.newDocNode(self.ns['gmd'], 'alternateTitle', None)
            characterString = alternateTitle.newChild(self.ns['gco'], 'CharacterString', escape(str(title)))
            alt_titles.append(alternateTitle)
        return alt_titles

    def abstract(self):
        """
        Element 3 to XML
        """
        if not self.m.abstract:
            return None

        abstract = self.doc.newDocNode(self.ns['gmd'], 'abstract', None)
        self.setNodeValue(abstract, self.m.abstract, 'CharacterString')
        return abstract

    def resourceType(self):
        """
        Element 4 to XML
        (must be 5 [dataset], 6 [series], or 14 [service])
        """
        if not self.m.resource_type:
            return None

        resource_type = escape(str(self.m.resource_type))
        hierarchyLevel = self.doc.newDocNode(self.ns['gmd'], 'hierarchyLevel', None)
        MD_ScopeCode = hierarchyLevel.newChild(None, 'MD_ScopeCode', resource_type)
        MD_ScopeCode.setProp(
            'codeList',
            'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode')
        MD_ScopeCode.setProp('codeListValue', resource_type)
        return hierarchyLevel

    def resourceLocators(self):
        """
        Element 5 to XML
        Not known how to present resource's name, or how to show >1 locator.
        """
        resource_locators = []
        for rl in self.m.resource_locators:
            transferOptions = self.doc.newDocNode(self.ns['gmd'], 'transferOptions', None)
            MD_DigitalTransferOptions = transferOptions.newChild(None, 'MD_DigitalTransferOptions', None)
            onLine = MD_DigitalTransferOptions.newChild(None, 'onLine', None)
            CI_OnlineResource = onLine.newChild(None, 'CI_OnlineResource', None)
            linkage = CI_OnlineResource.newChild(None, 'linkage', None)
            if rl.url: url = escape(str(rl.url))
            else: url = None
            linkage.newChild(None, 'URL', url)
            if rl.name:
                name = CI_OnlineResource.newChild(None, 'name', None)
                name.newChild(self.ns['gco'], 'CharacterString', escape(str(rl.name)))

            if rl.description:
                description = CI_OnlineResource.newChild(None, 'description', None)
                description.newChild(self.ns['gco'], 'CharacterString', escape(str(rl.description)))

            if rl.function:
                value = escape(str(rl.function))
                function = CI_OnlineResource.newChild(None, 'function', None)
                CI_OnLineFunctionCode = function.newChild(None, 'CI_OnLineFunctionCode', value)
                CI_OnLineFunctionCode.setProp('codeList',
                                              'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode')
                CI_OnLineFunctionCode.setProp('codeListValue', value)

            resource_locators.append(transferOptions)
        return resource_locators

    def identifier(self):
        """
        Element 6 to XML
        """
        unique_id = self.m.unique_id
        if not unique_id:
            return None

        identifier = self.doc.newDocNode(self.ns['gmd'], 'identifier', None)
        RS_Identifier = identifier.newChild(None, 'RS_Identifier', None)
        code = RS_Identifier.newChild(None, 'code', None)
        characterString = code.newChild(self.ns['gco'], 'CharacterString', escape(str(unique_id.id)))
        if unique_id.codespace:
            codeSpace = RS_Identifier.newChild(None, 'codeSpace', None)
            characterString = codeSpace.newChild(self.ns['gco'], 'CharacterString', escape(str(unique_id.codespace)))

        return identifier

    def coupledResources(self):
        """
        Element 7 to XML
        """
        coupled_resources = []
        for coupled_resource in self.m.coupled_resources:
            operatesOn = self.doc.newDocNode(self.ns['srv'], 'operatesOn', None)
            operatesOn.setNsProp(self.ns['xlink'], 'href', escape(str(coupled_resource)))
            coupled_resources.append(operatesOn)

        return coupled_resources

    def resourceLanguages(self):
        """
        Element 8 to XML
        """
        nodes = []

        if not self.m.resource_languages:
            # if no resource languages are present use the metadata
            # language as a default
            languages = [self.m.language]
        else:
            languages = self.m.resource_languages

        for resource_language in languages:
            nodes.append(self.languageToXML(resource_language))
        return nodes

    def topicCategories(self):
        """
        Element 9 to XML
        """
        topic_categories = []
        for topic_category in self.m.mappedTopicCategories():
            topicCategory = self.doc.newDocNode(self.ns['gmd'], 'topicCategory', None)
            MD_TopicCategoryCode = topicCategory.newChild(None, 'MD_TopicCategoryCode', escape(topic_category.term))
            topic_categories.append(topicCategory)
        return topic_categories

    def spatialDataServiceType(self):
        """
        Element 10 to XML
        """
        if not self.m.service_type:
            return None

        serviceType = self.doc.newDocNode(self.ns['srv'], 'serviceType', None)
        serviceType.newChild(self.ns['gco'], 'LocalName', escape(str(self.m.service_type)))

        return serviceType

    def keywords(self):
        """
        Element 11 to XML
        """

        # add in the automatically mapped keywords
        nodes = []
        keywords = self.m.mappedKeywords()
        if not keywords:
            return []

        # associate keywords with thesauri
        thesauri = {}
        for term in keywords:
            try:
                collections = term.collections.values()
            except AttributeError:
                # it's not a mappable, so likely to be a `Nil` object:
                # add it as such
                collections = [term.collections]

            if not len(collections):
                # add a default 'thesaurus'
                collections.append('')

            for thesaurus in collections:
                try:
                    thesauri[thesaurus].append(term)
                except KeyError:
                    thesauri[thesaurus] = [term]

        # create nodes for each thesaurus
        for thesaurus, terms in thesauri.items():
            descriptiveKeywords = self.doc.newDocNode(self.ns['gmd'], 'descriptiveKeywords', None)
            MD_Keywords = descriptiveKeywords.newChild(None, 'MD_Keywords', None)

            # add the thesaurus terms
            for term in terms:
                keyword = MD_Keywords.newChild(None, 'keyword', None)
                try:
                    url = term.uri
                except AttributeError:
                    url = None

                if not url:
                    CharacterString = keyword.newChild(self.ns['gco'], 'CharacterString', escape(term.term))
                else:
                    Anchor = keyword.newChild(self.ns['gmx'], 'Anchor', escape(term.term))
                    Anchor.setNsProp(self.ns['xlink'], 'href', escape(str(url)))

            if thesaurus:
                thesaurusName = MD_Keywords.newChild(None, 'thesaurusName', None)
                thesaurusName.addChild(self.thesaurusToXML(thesaurus))
            nodes.append(descriptiveKeywords)

        return nodes

    def boundingBox(self):
        """
        Element 12 to XML
        """
        bbox = self.m.bounding_box
        if not bbox:
            return None

        geographicElement = self.doc.newDocNode(self.ns['gmd'], 'geographicElement', None)
        EX_GeographicBoundingBox = geographicElement.newChild(None, 'EX_GeographicBoundingBox', None)
        westBoundLongitude = EX_GeographicBoundingBox.newChild(
            None, 'westBoundLongitude', None)
        if bbox.minx is not None:
            minx = bbox.minx
        else:
            minx = Nil('inapplicable')
        self.setNodeValue(westBoundLongitude, minx, 'Decimal')

        eastBoundLongitude = EX_GeographicBoundingBox.newChild(
            None, 'eastBoundLongitude', None)
        if bbox.maxx is not None:
            maxx = bbox.maxx
        else:
            maxx = Nil('inapplicable')
        self.setNodeValue(eastBoundLongitude, maxx, 'Decimal')

        southBoundLatitude = EX_GeographicBoundingBox.newChild(
            None, 'southBoundLatitude', None)
        if bbox.miny is not None:
            miny = bbox.miny
        else:
            miny =  Nil('inapplicable')
        self.setNodeValue(southBoundLatitude, miny, 'Decimal')

        northBoundLatitude = EX_GeographicBoundingBox.newChild(
            None, 'northBoundLatitude', None)
        if bbox.maxy is not None:
            maxy = bbox.maxy
        else:
            maxy = Nil('inapplicable')
        self.setNodeValue(northBoundLatitude, maxy, 'Decimal')

        return geographicElement

    def dateToXML(self, date):
        """
        Convert a date or datetime object to XML
        """
        if not date:
            return None

        from datetime import datetime

        sdate = date.isoformat()
        if isinstance(date, datetime):
            ele_name = 'DateTime'
        else:
            ele_name = 'Date'
        return self.doc.newDocNode(self.ns['gco'], ele_name, escape(sdate))

    def dateToDateType(self, date, code):
        """
        Convert a date or datetime object with associated type code to XML
        """
        code = escape(code)
        date_node = self.doc.newDocNode(self.ns['gmd'], 'date', None)
        CI_Date = date_node.newChild(None, 'CI_Date', None)
        date_node2 = CI_Date.newChild(None, 'date', None)
        if not isinstance(date, Nil):
            date_node2.addChild(self.dateToXML(date))
        else:
            self.setNodeValue(date_node2, date)
        dateType = CI_Date.newChild(None, 'dateType', None)
        CI_DateTypeCode = dateType.newChild(None, 'CI_DateTypeCode', code)
        CI_DateTypeCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode')
        CI_DateTypeCode.setProp('codeListValue', code)

        return date_node

    def thesaurusToXML(self, thesaurus):
        """
        Convert a thesaurus instance to an XML Citation node

        This is used when serialising elements 13 and 11
        """

        CI_Citation = self.doc.newDocNode(self.ns['gmd'], 'CI_Citation', None)
        title = CI_Citation.newChild(None, 'title', None)
        title.newChild(self.ns['gco'], 'CharacterString', escape(str(thesaurus.title)))
        CI_Citation.addChild(self.dateToDateType(thesaurus.date, 'revision'))

        return CI_Citation

    def extents(self):
        """
        Element 13 to XML
        """
        nodes = []
        extents = self.m.extents
        if not extents:
            return nodes

        # create nodes for each thesaurus
        for term in extents:
            try:
                thesauri = term.collections.values()
            except AttributeError:
                # it's not a mappable, so likely to be a `Nil` object:
                # add it as such
                thesauri = [term.collections]
            
            for thesaurus in thesauri:
                geographicElement = self.doc.newDocNode(self.ns['gmd'], 'geographicElement', None)
                EX_GeographicDescription = geographicElement.newChild(
                    None, 'EX_GeographicDescription', None)
                EX_GeographicDescription.addChild(self.doc.newDocComment(
                        'Extent - by Identifier'))
                geographicIdentifier = EX_GeographicDescription.newChild(None, 'geographicIdentifier', None)
                MD_Identifier = geographicIdentifier.newChild(None, 'MD_Identifier', None)
                authority = MD_Identifier.newChild(None, 'authority', None)
                if not isinstance(thesaurus, Nil):
                    authority.addChild(self.thesaurusToXML(thesaurus))
                else:
                    self.setNodeValue(authority, thesaurus)

                code = MD_Identifier.newChild(None, 'code', None)
                try:
                    url = term.uri
                except AttributeError:
                    # it's a simple string term
                    url = None

                if not url:
                    CharacterString = code.newChild(self.ns['gco'], 'CharacterString', escape(str(term.term)))
                else:
                    Anchor = code.newChild(self.ns['gmx'], 'Anchor', escape(term.term))
                    Anchor.setNsProp(self.ns['xlink'], 'href', escape(str(url)))

            nodes.append(geographicElement)

        return nodes

    def verticalExtent(self):
        """
        Element 14 to XML
        """
        vextent = self.m.vertical_extent
        if not vextent:
            return None

        verticalElement = self.doc.newDocNode(
            self.ns['gmd'], 'verticalElement', None)
        EX_VerticalExtent = verticalElement.newChild(
            None, 'EX_VerticalExtent', None)
        minimumValue = EX_VerticalExtent.newChild(None, 'minimumValue', None)
        maximumValue = EX_VerticalExtent.newChild(None, 'maximumValue', None)
        self.setNodeValue(minimumValue, vextent.minimum, 'Real')
        self.setNodeValue(maximumValue, vextent.maximum, 'Real')
        verticalCRS = EX_VerticalExtent.newChild(None, 'verticalCRS', None)
        verticalCRS.setNsProp(
            self.ns['xlink'], 'href', escape(str(vextent.crs)))

        return verticalElement

    def spatialReferenceSystem(self):
        """
        Element 15 to XML
        """

        srs = self.m.srs
        if not srs:
            return None

        referenceSystemInfo = self.doc.newDocNode(
            self.ns['gmd'], 'referenceSystemInfo', None)

        if isinstance(srs, Nil):
            self.setNodeValue(referenceSystemInfo, srs)
        else:
            MD_ReferenceSystem = referenceSystemInfo.newChild(
                None, 'MD_ReferenceSystem', None)
            referenceSystemIdentifier = MD_ReferenceSystem.newChild(
                None, 'referenceSystemIdentifier', None)
            RS_Identifier = referenceSystemIdentifier.newChild(
                None, 'RS_Identifier', None)
            code = RS_Identifier.newChild(None, 'code', None)
            self.setNodeValue(code, srs, 'CharacterString')
            codeSpace = RS_Identifier.newChild(None, 'codeSpace', None)
            CharacterString = codeSpace.newChild(
                self.ns['gco'], 'CharacterString', 'OGP')

        comment = getattr(srs, 'comment', None)
        return (referenceSystemInfo, comment)

    def temporalExtent(self):
        """
        Element 16.1 to XML
        """

        if not self.m.temporal_reference:
            return None

        ref = self.m.temporal_reference
        if not (ref.begin or ref.end):
            return None

        temporalElement = self.doc.newDocNode(self.ns['gmd'], 'temporalElement', None)
        EX_TemporalExtent = temporalElement.newChild(None, 'EX_TemporalExtent', None)
        extent = EX_TemporalExtent.newChild(None, 'extent', None)
        TimePeriod = extent.newChild(self.ns['gml'], 'TimePeriod', None)
        TimePeriod.setNsProp(self.ns['gml'], 'id', 'medinMEDIN01')

        if ref.begin:
            TimePeriod.newChild(None, 'beginPosition', escape(str(ref.begin)))
        elif ref.end:
            beginPosition = TimePeriod.newChild(None, 'beginPosition', escape(str(ref.end)))
            beginPosition.setProp('indeterminatePosition', 'before')
            
        if ref.end:
            TimePeriod.newChild(None, 'endPosition', escape(str(ref.end)))
        elif ref.begin:
            # default to the system time
            from datetime import date
            end = date.today()

            endPosition = TimePeriod.newChild(None, 'endPosition', escape(str(end)))
            endPosition.setProp('indeterminatePosition', 'after')

        return temporalElement

    def temporalReferenceDates(self):
        """
        Element 16.[234] to XML
        """

        nodes = []
        ref = self.m.temporal_reference
        if not ref:
            return nodes

        for code in ('publication', 'creation', 'revision'):
            date = getattr(ref, code)
            if not date:
                continue
            nodes.append(self.dateToDateType(date, code))

        return nodes

    def lineage(self):
        """
        Element 17 to XML
        """
        if not self.m.lineage:
            return None

        lineage = self.doc.newDocNode(self.ns['gmd'], 'lineage', None)
        LI_Lineage = lineage.newChild(None, 'LI_Lineage', None)
        statement = LI_Lineage.newChild(None, 'statement', None)
        self.setNodeValue(statement, self.m.lineage, 'CharacterString')
        return lineage

    def spatialResolution(self):
        """
        Element 18 to XML
        """
        if not self.m.spatial_resolutions:
            return None

        spatialResolution = self.doc.newDocNode(
            self.ns['gmd'], 'spatialResolution', None)
        MD_Resolution = spatialResolution.newChild(None, 'MD_Resolution', None)

        for x in self.m.spatial_resolutions:
            if x.distance is not None:
                distance = MD_Resolution.newChild(None, 'distance', None)
                self.setNodeValue(distance, x.distance, 'Distance', {
                        'uom': 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/uom/gmxUom.xml#m'
                        })
            elif x.equivalent_scale is not None:
                equivalentScale = MD_Resolution.newChild(
                    None, 'equivalentScale', None)
                MD_RepresentativeFraction = equivalentScale.newChild(
                    None, 'MD_RepresentativeFraction', None)
                denominator = MD_RepresentativeFraction.newChild(
                    None, 'denominator', None)
                self.setNodeValue(denominator, x.equivalent_scale, 'Integer')
        return spatialResolution

    def additionalInfo(self):
        """
        Element 19 to XML
        """
        info = self.m.additional_info
        if not info:
            return None

        supplementalInformation = self.doc.newDocNode(self.ns['gmd'], 'supplementalInformation', None)
        supplementalInformation.newChild(self.ns['gco'], 'CharacterString', escape(str(info)))
        return supplementalInformation

    def resourceConstraints(self):
        access_constraints = self.conditionsForAccessAndUse() # element 21
        legal_constraints = self.limitationsOnPublicAccess() # element 20

        if legal_constraints:
            element_name = 'MD_LegalConstraints'
        elif access_constraints:
            element_name = 'MD_Constraints'
        else:
            return None

        resourceConstraints = self.doc.newDocNode(self.ns['gmd'], 'resourceConstraints', None)
        MD_Constraints = resourceConstraints.newChild(None, element_name, None)
        for node in access_constraints + legal_constraints:
            MD_Constraints.addChild(node)

        return resourceConstraints

    def limitationsOnPublicAccess(self):
        """
        Element 20 to XML
        """
        nodes = []

        # process the controlled vocabulary terms
        terms = self.m.access_constraint_terms
        if terms:
            for term in terms:
                accessConstraints = self.doc.newDocNode(self.ns['gmd'], 'accessConstraints', None)
                if not isinstance(term, Nil):
                    restriction = escape(term.term)
                    MD_RestrictionCode = accessConstraints.newChild(None, 'MD_RestrictionCode', restriction)
                    MD_RestrictionCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode')
                    MD_RestrictionCode.setProp('codeListValue', restriction)
                else:
                    self.setNodeValue(accessConstraints, term)
                nodes.append(accessConstraints)

        # process the free text constraints
        other = self.m.other_access_constraints
        if other:
            for text in other:
                otherConstraints = self.doc.newDocNode(self.ns['gmd'], 'otherConstraints', None)
                otherConstraints.newChild(self.ns['gco'], 'CharacterString', escape(str(text)))
                nodes.append(otherConstraints)

        return nodes

    def conditionsForAccessAndUse(self):
        """
        Element 21 to XML
        """
        nodes = []
        limitations = list(self.m.use_limitations)
        if not limitations:
            limitations.append('no conditions apply')

        for limitation in limitations:
            useLimitation = self.doc.newDocNode(self.ns['gmd'], 'useLimitation', None)
            useLimitation.newChild(self.ns['gco'], 'CharacterString', escape(str(limitation)))
            nodes.append(useLimitation)

        return nodes

    def responsiblePartyToXML(self, party):
        """
        Converts a responsible party object to XML
        """

        CI_ResponsibleParty = self.doc.newDocNode(self.ns['gmd'], 'CI_ResponsibleParty', None)

        individual = party.individual
        if individual:
            individualName = CI_ResponsibleParty.newChild(None, 'individualName', None)
            self.setNodeValue(individualName, individual, 'CharacterString')

        organisation = party.organisation
        if organisation:
            organisationName = CI_ResponsibleParty.newChild(None, 'organisationName', None)
            self.setNodeValue(organisationName, organisation, 'CharacterString')

        position = party.position
        if position:
            positionName = CI_ResponsibleParty.newChild(None, 'positionName', None)
            self.setNodeValue(positionName, position, 'CharacterString')

        details = []
        if party.phone or party.fax:
            phone = self.doc.newDocNode(self.ns['gmd'], 'phone', None)
            CI_Telephone = phone.newChild(None, 'CI_Telephone', None)
            if party.phone:
                voice = CI_Telephone.newChild(None, 'voice', None)
                self.setNodeValue(voice, party.phone, 'CharacterString')
            if party.fax:
                facsimile = CI_Telephone.newChild(None, 'facsimile', None)
                self.setNodeValue(facsimile, party.fax, 'CharacterString')
            details.append(phone)

        address = self.doc.newDocNode(self.ns['gmd'], 'address', None)
        CI_Address = address.newChild(None, 'CI_Address', None)
        if party.address:
            for line in  party.address.splitlines():
                for point in (p.strip() for p in line.split(",")):
                    if not point:
                        continue
                    deliveryPoint = CI_Address.newChild(None, 'deliveryPoint', None)
                    self.setNodeValue(deliveryPoint, point, 'CharacterString')
        if party.city:
            deliveryPoint = CI_Address.newChild(None, 'city', None)
            self.setNodeValue(deliveryPoint, party.city, 'CharacterString')
        if party.state:
            deliveryPoint = CI_Address.newChild(None, 'administrativeArea', None)
            self.setNodeValue(deliveryPoint, party.state, 'CharacterString')
        if party.zipcode:
            deliveryPoint = CI_Address.newChild(None, 'postalCode', None)
            self.setNodeValue(deliveryPoint, party.zipcode, 'CharacterString')
        if party.country:
            deliveryPoint = CI_Address.newChild(None, 'country', None)
            self.setNodeValue(deliveryPoint, party.country, 'CharacterString')
        if party.email:
            electronicMailAddress = CI_Address.newChild(None, 'electronicMailAddress', None)
            self.setNodeValue(electronicMailAddress, party.email, 'CharacterString')
        if CI_Address.children:
            details.append(address)

        if party.website:
            onlineResource = self.doc.newDocNode(self.ns['gmd'], 'onlineResource', None)
            CI_OnlineResource = onlineResource.newChild(None, 'CI_OnlineResource', None)
            linkage = CI_OnlineResource.newChild(None, 'linkage', None)
            URL = linkage.newChild(None, 'URL', None)
            self.setNodeValue(URL, party.website)
            details.append(onlineResource)

        if details:
            contactInfo = CI_ResponsibleParty.newChild(None, 'contactInfo', None)
            CI_Contact = contactInfo.newChild(None, 'CI_Contact', None)
            for node in details:
                CI_Contact.addChild(node)

        if party.role:
            role = CI_ResponsibleParty.newChild(None, 'role', None)
            value = escape(str(party.role))
            CI_RoleCode = role.newChild(None, 'CI_RoleCode', value)
            CI_RoleCode.setProp('codeList', 'http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode')
            CI_RoleCode.setProp('codeListValue', value)

        return CI_ResponsibleParty

    def pointsOfContact(self):
        """
        Element 22.[12] to XML
        """

        contacts = []
        for party in self.m.responsible_parties:
            if not party.role or party.role.term in ('pointOfContact', 'distributor'):
                # we don't want the metadata point of contact or the originator
                continue

            pointOfContact = self.doc.newDocNode(self.ns['gmd'], 'pointOfContact', None)
            pointOfContact.addChild(self.responsiblePartyToXML(party))
            contacts.append(pointOfContact)

        return contacts

    def distributors(self):
        """
        Element 22.3 to XML
        """
        contacts = []

        # get the distributor(s)
        parties = [party for party in self.m.responsible_parties if party.role and party.role.term == 'distributor']
        if not parties:
            # if there aren't any distributors, use the custodian instead
            parties = []
            for party in (party for party in self.m.responsible_parties if party.role and party.role.term == 'custodian'):
                party.role.term = 'distributor' # the custodian needs to be a distributor in this instance
                parties.append(party)

        # convert the parties to XML
        for party in parties:
            distributor = self.doc.newDocNode(self.ns['gmd'], 'distributor', None)
            MD_Distributor = distributor.newChild(None, 'MD_Distributor', None)
            distributorContact = MD_Distributor.newChild(None, 'distributorContact', None)
            distributorContact.addChild(self.responsiblePartyToXML(party))
            contacts.append(distributor)

        return contacts

    def metadataPointsOfContact(self):
        """
        Element 22.4 to XML
        """
        contacts = []
        for party in self.m.responsible_parties:
            if not party.role or party.role.term != 'pointOfContact':
                # we only want the metadata point of contact
                continue

            contact = self.doc.newDocNode(self.ns['gmd'], 'contact', None)
            contact.addChild(self.responsiblePartyToXML(party))
            contacts.append(contact)

        return contacts

    def dataFormats(self):
        """
        Element 23 to XML
        """
        nodes = []
        for term in self.m.data_formats:
            resourceFormat = self.doc.newDocNode(self.ns['gmd'], 'resourceFormat', None)
            MD_Format = resourceFormat.newChild(None, 'MD_Format', None)
            name = MD_Format.newChild(None, 'name', None)
            self.setNodeValue(name, term.term, 'CharacterString')
            version = MD_Format.newChild(None, 'version', None)
            try:
                ver = term.version
            except AttributeError:
                ver = None
            if not ver:
                ver = Nil('unknown')
            self.setNodeValue(version, ver, 'CharacterString')
            nodes.append(resourceFormat)

        return nodes

    def frequencyOfUpdate(self):
        """
        Element 24 to XML
        """
        frequency = self.m.update_frequency
        if not frequency:
            return None

        term = escape(str(frequency))
        resourceMaintenance = self.doc.newDocNode(self.ns['gmd'], 'resourceMaintenance', None)
        MD_MaintenanceInformation = resourceMaintenance.newChild(None, 'MD_MaintenanceInformation', None)
        maintenanceAndUpdateFrequency = MD_MaintenanceInformation.newChild(None, 'maintenanceAndUpdateFrequency', None)
        MD_MaintenanceFrequencyCode = maintenanceAndUpdateFrequency.newChild(None, 'MD_MaintenanceFrequencyCode', term)
        MD_MaintenanceFrequencyCode.setProp("codeList", "http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_MaintenanceFrequencyCode")
        MD_MaintenanceFrequencyCode.setProp("codeListValue", term)

        return resourceMaintenance

    def dateStamp(self):
        """
        Element 26 to XML
        """
        dateStamp = self.doc.newDocNode(self.ns['gmd'], 'dateStamp', None)
        date = self.dateToXML(self.m.date)
        if not date:
            return None
        dateStamp.addChild(date)
        return dateStamp

    def metadataStandardName(self):
        """
        Element 27 to XML
        """
        standard = self.m.standard
        if not standard:
            return None

        metadataStandardName = self.doc.newDocNode(self.ns['gmd'], 'metadataStandardName', None)
        characterString = metadataStandardName.newChild(self.ns['gco'], 'CharacterString', escape(str(standard)))
        return metadataStandardName

    def metadataStandardVersion(self):
        """
        Element 28 to XML
        """
        version = self.m.version
        if not version:
            return None

        metadataStandardVersion = self.doc.newDocNode(self.ns['gmd'], 'metadataStandardVersion', None)
        characterString = metadataStandardVersion.newChild(self.ns['gco'], 'CharacterString', escape(str(version)))
        return metadataStandardVersion

    def languageToXML(self, language):
        node = self.doc.newDocNode(self.ns['gmd'], 'language', None)
        languageCode = node.newChild(None, 'LanguageCode', escape(str(language.name)))
        languageCode.setProp("codeList", "http://www.loc.gov/standards/iso639-2/php/code_list.php")
        languageCode.setProp("codeListValue", escape(str(language.code)))

        return node

    def language(self):
        """
        Element 29 to XML
        """
        return self.languageToXML(self.m.language)

    def parentIdentifier(self):
        """
        Element 30 to XML
        """
        parent_id = self.m.parent_id
        if not parent_id:
            return None

        parentIdentifier = self.doc.newDocNode(self.ns['gmd'], 'parentIdentifier', None)
        characterString = parentIdentifier.newChild(self.ns['gco'], 'CharacterString', escape(parent_id.asIdentifier()))

        return parentIdentifier
