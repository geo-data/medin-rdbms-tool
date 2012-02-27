<?xml version="1.0" standalone="yes"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:srv="http://www.isotc211.org/2005/srv" version="1.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<axsl:param name="archiveDirParameter"/><axsl:param name="archiveNameParameter"/><axsl:param name="fileNameParameter"/><axsl:param name="fileDirParameter"/>

<!--PHASES-->


<!--PROLOG-->
<axsl:output xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>

<!--KEYS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<axsl:template match="*" mode="schematron-select-full-path"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<axsl:template match="*" mode="schematron-get-full-path"><axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/><axsl:text>/</axsl:text><axsl:choose><axsl:when test="namespace-uri()=''"><axsl:value-of select="name()"/><axsl:variable name="p_1" select="1+    count(preceding-sibling::*[name()=name(current())])"/><axsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<axsl:value-of select="$p_1"/>]</axsl:if></axsl:when><axsl:otherwise><axsl:text>*[local-name()='</axsl:text><axsl:value-of select="local-name()"/><axsl:text>' and namespace-uri()='</axsl:text><axsl:value-of select="namespace-uri()"/><axsl:text>']</axsl:text><axsl:variable name="p_2" select="1+   count(preceding-sibling::*[local-name()=local-name(current())])"/><axsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<axsl:value-of select="$p_2"/>]</axsl:if></axsl:otherwise></axsl:choose></axsl:template><axsl:template match="@*" mode="schematron-get-full-path"><axsl:text>/</axsl:text><axsl:choose><axsl:when test="namespace-uri()=''">@<axsl:value-of select="name()"/></axsl:when><axsl:otherwise><axsl:text>@*[local-name()='</axsl:text><axsl:value-of select="local-name()"/><axsl:text>' and namespace-uri()='</axsl:text><axsl:value-of select="namespace-uri()"/><axsl:text>']</axsl:text></axsl:otherwise></axsl:choose></axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<axsl:template match="node() | @*" mode="schematron-get-full-path-2"><axsl:for-each select="ancestor-or-self::*"><axsl:text>/</axsl:text><axsl:value-of select="name(.)"/><axsl:if test="preceding-sibling::*[name(.)=name(current())]"><axsl:text>[</axsl:text><axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/><axsl:text>]</axsl:text></axsl:if></axsl:for-each><axsl:if test="not(self::*)"><axsl:text/>/@<axsl:value-of select="name(.)"/></axsl:if></axsl:template>

<!--MODE: GENERATE-ID-FROM-PATH -->
<axsl:template match="/" mode="generate-id-from-path"/><axsl:template match="text()" mode="generate-id-from-path"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/></axsl:template><axsl:template match="comment()" mode="generate-id-from-path"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/></axsl:template><axsl:template match="processing-instruction()" mode="generate-id-from-path"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/></axsl:template><axsl:template match="@*" mode="generate-id-from-path"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:value-of select="concat('.@', name())"/></axsl:template><axsl:template match="*" mode="generate-id-from-path" priority="-0.5"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:text>.</axsl:text><axsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/></axsl:template><!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<axsl:template match="node() | @*" mode="schematron-get-full-path-3"><axsl:for-each select="ancestor-or-self::*"><axsl:text>/</axsl:text><axsl:value-of select="name(.)"/><axsl:if test="parent::*"><axsl:text>[</axsl:text><axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/><axsl:text>]</axsl:text></axsl:if></axsl:for-each><axsl:if test="not(self::*)"><axsl:text/>/@<axsl:value-of select="name(.)"/></axsl:if></axsl:template>

<!--MODE: GENERATE-ID-2 -->
<axsl:template match="/" mode="generate-id-2">U</axsl:template><axsl:template match="*" mode="generate-id-2" priority="2"><axsl:text>U</axsl:text><axsl:number level="multiple" count="*"/></axsl:template><axsl:template match="node()" mode="generate-id-2"><axsl:text>U.</axsl:text><axsl:number level="multiple" count="*"/><axsl:text>n</axsl:text><axsl:number count="node()"/></axsl:template><axsl:template match="@*" mode="generate-id-2"><axsl:text>U.</axsl:text><axsl:number level="multiple" count="*"/><axsl:text>_</axsl:text><axsl:value-of select="string-length(local-name(.))"/><axsl:text>_</axsl:text><axsl:value-of select="translate(name(),':','.')"/></axsl:template><!--Strip characters--><axsl:template match="text()" priority="-1"/>

<!--SCHEMA METADATA-->
<axsl:template match="/"><svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" title="MEDIN Discovery Metadata Profile" schemaVersion="1.7"><axsl:comment><axsl:value-of select="$archiveDirParameter"/>   
		 <axsl:value-of select="$archiveNameParameter"/>  
		 <axsl:value-of select="$fileNameParameter"/>  
		 <axsl:value-of select="$fileDirParameter"/></axsl:comment><svrl:text>
    This Schematron schema is based on MEDIN_Schema_Documentation_2_3.doc. The text describing
    each metadata element has been extracted from this document. Reference has also been made to
    the INSPIRE Metadata Implementing Rules: Technical Guidelines based on EN ISO 19115 and EN ISO 19139
    which is available at:
  </svrl:text><svrl:text>
    http://inspire.jrc.ec.europa.eu/reports/ImplementingRules/metadata/MD_IR_and_ISO_20090218.pdf
  </svrl:text><svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml/3.2" prefix="gml"/><svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/><svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/><svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmx" prefix="gmx"/><svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/><svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/srv" prefix="srv"/><svrl:active-pattern><axsl:attribute name="name">Element 1 - Resource Title (M)</axsl:attribute><svrl:text>Mandatory element. Only one resource title allowed. Free text.</svrl:text><svrl:text>
      The title is used to provide a brief and precise description of the dataset.
      The following format is recommended:
    </svrl:text><svrl:text>
      'Date' 'Originating organization/programme' 'Location' 'Type of survey'.
      It is advised that acronyms and abbreviations are reproduced in full.
      Example: Centre for Environment, Fisheries and Aquaculture Science (Cefas).
    </svrl:text><svrl:text>
      <axsl:text/>Example 1:<axsl:text/> 1992 Centre for Environment, Fisheries and Aquaculture Science (Cefas)
      North Sea 2m beam trawl survey.
    </svrl:text><svrl:text>
      <axsl:text/>Example 2:<axsl:text/> 1980-2000 Marine Life Information Network UK
      (MarLIN) Sealife Survey records.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M9"/><svrl:active-pattern><axsl:attribute name="id">MedinResourceTitleGcoTypeTest</axsl:attribute><axsl:attribute name="name">MedinResourceTitleGcoTypeTest</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M10"/><svrl:active-pattern><axsl:attribute name="name">Element 2 - Alternative Resource Title (O)</axsl:attribute><svrl:text>
      Optional element.  Multiple alternative resource titles allowed.  Free text.
    </svrl:text><svrl:text>
      The alternative title is used to add the names by which a dataset may be known and may
      include short name, other name, acronym or alternative language title.
    </svrl:text><svrl:text>Example</svrl:text><svrl:text>
      1980-2000 MarLIN Volunteer Sighting records.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M11"/><svrl:active-pattern><axsl:attribute name="id">MedinAlternativeResourceTitleInnerText</axsl:attribute><axsl:attribute name="name">MedinAlternativeResourceTitleInnerText</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M12"/><svrl:active-pattern><axsl:attribute name="name">Element 3 - Resource Abstract (M)</axsl:attribute><svrl:text>Mandatory element.  Only one resource abstract allowed.  Free text.</svrl:text><svrl:text>
      The abstract should provide a clear and brief statement of the content of the resource.
      Include what has been recorded, what form the data takes, what purpose it was collected for,
      and any limiting information, i.e. limits or caveats on the use and interpretation of
      the data.  Background methodology and quality information should be entered into the
      Lineage element (element 10).  It is recommended that acronyms and abbreviations are
      reproduced in full. e.g. Centre for Environment, Fisheries and Aquaculture Science (Cefas).
    </svrl:text><svrl:text>Examples</svrl:text><svrl:text>
      <axsl:text/>Example 1:<axsl:text/> Benthic marine species abundance data from an assessment
      of the cumulative impacts of aggregate extraction on seabed macro-invertebrate communities.
      The purpose of this study was to determine whether there was any evidence of a large-scale
      cumulative impact on benthic macro-invertebrate communities as a result of the multiple
      sites of aggregate extraction located off Great Yarmouth in the southern North Sea.
    </svrl:text><svrl:text>
      <axsl:text/>Example 2:<axsl:text/> As part of the UK Department of Trade and Industry's (DTI's)
      ongoing sectorial Strategic Environmental Assessment (SEA) programme, a seabed survey
      programme (SEA2) was undertaken in May/June 2001 for areas in the central and southern
      North Sea UKCS.  This report summarizes the sediment total hydrocarbon and aromatic data
      generated from the analyses of selected samples from three main study areas:
    </svrl:text><svrl:text>
      Area 1: the major sandbanks off the coast of Norfolk and Lincolnshire in the Southern North Sea (SNS);
    </svrl:text><svrl:text>
      Area 2: the Dogger Bank in the SNS; and
    </svrl:text><svrl:text>
      Area 3: the pockmarks in the Fladen Ground vicinity of the central North Sea (CNS).
    </svrl:text><svrl:text>
      <axsl:text/>Example 3:<axsl:text/> Survey dataset giving port soundings in Great Yarmouth.
    </svrl:text><svrl:text>
      <axsl:text/>Example 4:<axsl:text/> Conductivity, Temperature, Depth (CTD) grid survey in
      the Irish Sea undertaken in August 1981.  Only temperature profiles due to conductivity
      sensor malfunction.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M13"/><svrl:active-pattern><axsl:attribute name="id">MedinResourceAbstractGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinResourceAbstractGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M14"/><svrl:active-pattern><axsl:attribute name="name">Element 4 - Resource Type (M)</axsl:attribute><svrl:text>
      Mandatory element.  One occurrence allowed.  Controlled vocabulary.
    </svrl:text><svrl:text>
      Identify the type of resource e.g. a dataset using the controlled vocabulary,
      MD_ScopeCode from ISO 19115.  (See Annex 2 for codelist).
      In order to comply with INSPIRE the resource type must be a dataset,
      a series (collection of datasets with a common specification) or a service.
    </svrl:text><svrl:text>
      Example
    </svrl:text><svrl:text>
      series
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M15"/><svrl:active-pattern><axsl:attribute name="name">Element 5 - Resource Locator (C)</axsl:attribute><svrl:text>Conditional element.  Multiple resource locators are allowed.  Free text.</svrl:text><svrl:text>
      Formerly named online resource. If the resource is available online you must provide a
      web address (URL) that links to the resource.
    </svrl:text><svrl:text>
      Schematron note: The condition cannot be tested with Schematron.
    </svrl:text><svrl:text>Element 5.1 - Resource locator url (C)</svrl:text><svrl:text>Conditional element.  Free text.</svrl:text><svrl:text>The URL (web address).</svrl:text><svrl:text>Element 5.2 - Resource locator name (O)</svrl:text><svrl:text>Optional element.  Free text.</svrl:text><svrl:text>The name of the web resource.</svrl:text><svrl:text>Example</svrl:text><svrl:text>
      Resource locator url:
      http://www.defra.gov.uk/marine/science/monitoring/merman.htm
      Resource locator name: The Marine Environment National Monitoring and Assessment Database
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M16"/><svrl:active-pattern><axsl:attribute name="id">MedinResouceLocatorGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinResouceLocatorGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M17"/><svrl:active-pattern><axsl:attribute name="name">Element 6 - Unique Resource Identifier (M)</axsl:attribute><svrl:text>
      Mandatory element (for datasets and series of datasets).  One occurrence allowed.  Free text.
    </svrl:text><svrl:text>
      Provide a code uniquely identifying the resource. You may also specify a code space.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M18"/><svrl:active-pattern><axsl:attribute name="id">MedinUniqueResourceIdentifierGcoTypePattern</axsl:attribute><axsl:attribute name="name">MedinUniqueResourceIdentifierGcoTypePattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M19"/><svrl:active-pattern><axsl:attribute name="id">MedinUniqueResourceIdentifierCodeSpaceGcoTypePattern</axsl:attribute><axsl:attribute name="name">MedinUniqueResourceIdentifierCodeSpaceGcoTypePattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M20"/><svrl:active-pattern><axsl:attribute name="name">Element 7 - Coupled Resource (C)</axsl:attribute><svrl:text>
      Conditional element.  Mandatory if the datasets a service operates on are available.
      Multiple coupled resource occurrences allowed.
    </svrl:text><svrl:text>
      An INSPIRE element referring to data services such as a data download or mapping
      web services.  It identifies the data resource(s) used by the service if these are
      available separately from the service.  You should supply the Unique resource identifiers
      of the relevent datasets (See element 6).
    </svrl:text><svrl:text>Example</svrl:text><svrl:text>MRMLN0000345</svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M21"/><svrl:active-pattern><axsl:attribute name="name">Element 8 - Resource Language (C)</axsl:attribute><svrl:text>
      Conditional element.  Mandatory when the described resource contains textual information.
      Multiple resource languages allowed.  This element is not required if a service is being
      described rather than a dataset or series of datasets.  Controlled vocabulary, ISO 639-2.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M22"/><svrl:active-pattern><axsl:attribute name="id">MedinResourceLanguageLanguagePattern</axsl:attribute><axsl:attribute name="name">MedinResourceLanguageLanguagePattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M23"/><svrl:active-pattern><axsl:attribute name="name">Element 9 - Topic Category (C)</axsl:attribute><svrl:text>
      Conditional element.  Mandatory for datasets and series of datasets.  Multiple topic
      categories are allowed.  This element is not required if a service is being described.
      Controlled vocabulary.
    </svrl:text><svrl:text>
      This element is mandatory for INSPIRE and must be included, however, MEDIN will use the
      Keywords as these are more valuable to allow users to search for datasets.  This indicates
      the main theme(s) of the data resource.  It is required for INSPIRE compliance.  The relevant
      topic category should be selected from the ISO MD_TopicCategory list.  The full list can be
      found in Annex 4. Within MEDIN the parameter group keywords from the controlled vocabulary 
      P021 (BODC Parameter Discovery Vocabulary) available at
      http://vocab.ndg.nerc.ac.uk/client/vocabServer.jsp (included in element 11) 
      are mapped to the ISO Topic Categories so it is possible to generate the topic categories 
      automatically once the keywords from P021 have been selected.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M24"/><svrl:active-pattern><axsl:attribute name="id">MedinTopicCategoryCodeInnerText</axsl:attribute><axsl:attribute name="name">MedinTopicCategoryCodeInnerText</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M25"/><svrl:active-pattern><axsl:attribute name="name">Element 10 - Spatial Data Service Type (C)</axsl:attribute><svrl:text>
      Conditional element.  Mandatory if the described resource is a service.  One occurrence allowed.
    </svrl:text><svrl:text>
      An element required by INSPIRE for metadata about data services e.g. web services1.  If a
      service is being described (from Element 4) it must be assigned a service type from the
      INSPIRE Service type codelist.  See Annex 5 for list.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M26"/><svrl:active-pattern><axsl:attribute name="id">MedinSpatialDataServiceTypeGcoTypePattern</axsl:attribute><axsl:attribute name="name">MedinSpatialDataServiceTypeGcoTypePattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M27"/><svrl:active-pattern><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M28"/><svrl:active-pattern><axsl:attribute name="name">Element 11 - Keywords (M)</axsl:attribute><svrl:text>
      Mandatory element.  Multiple keywords allowed.  Controlled vocabularies.
    </svrl:text><svrl:text>
      The entry should consist of two sub-elements the keywords and reference to the controlled
      vocabulary used as shown in the sub elements below.  To allow searching of the dataset 
      keywords should be chosen from at least one of 3 codelists.
    </svrl:text><svrl:text>
      INSPIRE Keywords - A list of the INSPIRE theme keywords is available in Annex 9. 
      This list is also available at http://www.eionet.europa.eu/gemet/inspire_themes 
      At least one INSPIRE theme keyword is required for INSPIRE compliance.
    </svrl:text><svrl:text>
      MEDIN Keywords - MEDIN mandates the use of the SeaDataNet Parameter Discovery Vocabulary 
      P021 to provide further ability to search by terms that are more related to the marine domain. 
      This list are available at http://vocab.ndg.nerc.ac.uk/client/vocabServer.jsp In particular 
      the parameter groups and codes that are used may be searched through a more user friendly 
      interface which has been built as part of the European funded SeaDataNet project at 
      http://seadatanet.maris2.nl/v_bodc_vocab/vocabrelations.aspx
    </svrl:text><svrl:text>
      MEDIN also uses the SeaDataNet Parameter Discovery Vocabulary to provide further ability to search
      by terms that are more related to the marine domain.  This is available at:
      http://vocab.ndg.nerc.ac.uk/clients/getList?recordKeys=http://vocab.ndg.nerc.ac.uk/list/P021/current&amp;earliestRecord=&amp;submit=submit
    </svrl:text><svrl:text>
      Vertical Extent Keywords - A mandatory vocabulary of keywords is available to describe 
      the vertical extent of the resource (e.g. data set). The vocabulary can be downloaded 
      as L131 at http://vocab.ndg.nerc.ac.uk/client/vocabServer.jsp and can also be seen in 
      Annex 9: This list is also available at: These lists are also available through a more 
      user friendly interface at http://seadatanet.maris2.nl/v_bodc_vocab/welcome.aspx/
    </svrl:text><svrl:text>
      A mandatory vocabulary of keywords is available to describe the vertical extent of 
      the resource (e.g. data set). The vocabulary can be downloaded as L131 (Vertical Co-ordinate Coverages) at 
      http://vocab.ndg.nerc.ac.uk/client/vocabServer.jsp and can also be seen in Annex 9: 
      This list is also available at: These lists are also available through a more user 
      friendly interface at http://seadatanet.maris2.nl/v_bodc_vocab/welcome.aspx/
    </svrl:text><svrl:text>
      Other vocabularies may be used as required as long as they follow the format specified in 11.1 – 11.2.3
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M29"/><svrl:active-pattern><axsl:attribute name="name">Element 12 - Geographical Bounding Box (M)</axsl:attribute><svrl:text>
      Mandatory element.  One occurrence of each sub-element allowed.  Numeric and controlled vocabulary.
    </svrl:text><svrl:text>
      These four sub-elements represent the geographical bounding box of the resource's extent
      and should be kept as small as possible.  The co-ordinates of this bounding box should be
      expressed as decimal degrees longitude and latitude.  A minimum of two and a maximum of four
      decimal places should be provided.
    </svrl:text><svrl:text>
      Latitudes between 0 and 90N, and longitudes between 0 and 180E should be expressed as positive
      numbers, and latitudes between 0 and 90S, and longitudes between 0 and 180W should be expressed
      as negative numbers.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M30"/><svrl:active-pattern><axsl:attribute name="id">MedinGeographicBoundingBoxPattern</axsl:attribute><axsl:attribute name="name">MedinGeographicBoundingBoxPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M31"/><svrl:active-pattern><axsl:attribute name="name">Element 13 - Extent (O)</axsl:attribute><svrl:text>
      Optional element.  Multiple occurrences of extents allowed.  Controlled vocabulary.
    </svrl:text><svrl:text>
      Keywords selected from controlled vocabularies to describe the spatial extent of the resource.  
      MEDIN strongly recommends the use of the SeaVox Sea Areas 
      (http://www.bodc.ac.uk/data/codes_and_formats/seavox/ 
      or e-mail enquiries@oceannet.org for further details) which is a managed vocabulary and has a 
      worldwide distribution. Other vocabularies available including ICES areas and rectangles 
      www.ices.dk , or Charting Progress 2 regions. may be used as long as they follow the format 
      specified in 13.1 – 13.2.3.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M32"/><svrl:active-pattern><axsl:attribute name="id">MedinExtentCodeGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinExtentCodeGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M33"/><svrl:active-pattern><axsl:attribute name="id">MedinExtentAuthorityGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinExtentAuthorityGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M34"/><svrl:active-pattern><axsl:attribute name="name">Element 14 - Vertical Extent Information (O)</axsl:attribute><svrl:text>
      Optional element.  The vertical extent information should be filled in where the vertical
      co-ordinates are significant to the resource.  One occurrence allowed.  Numeric free text
      and controlled vocabulary.
    </svrl:text><svrl:text>
      The vertical extent element has four sub-elements; the minimum vertical extent value, the
      maximum vertical extent value, the units and the coordinate reference system.  Depth
      below sea water surface should be a negative number.  Depth taken in the intertidal zone
      above the sea level should be positive.  If the dataset covers from the intertidal to the
      subtidal zone then the 14.1 should be used to record the highest intertidal point and 14.2
      the deepest subtidal depth.  Although the element itself is optional if it is filled in then
      its sub-elements are either mandatory or conditional.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M35"/><svrl:active-pattern><axsl:attribute name="id">MedinVerticalExtentInformationGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinVerticalExtentInformationGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M36"/><svrl:active-pattern><axsl:attribute name="name">Element 15 - Spatial Reference System (M)</axsl:attribute><svrl:text>
      Mandatory element.  One occurrence allowed.  Controlled vocabulary.
    </svrl:text><svrl:text>
      Describes the system of spatial referencing (typically a coordinate reference system) used
      in the resource.  This should be derived from a controlled vocabulary.  The SeaDataNet list
      http://vocab.ndg.nerc.ac.uk/clients/getList?recordKeys=http://vocab.ndg.nerc.ac.uk/list/L101/current&amp;earliestRecord=&amp;submit=submit
      is recommended.  Please contact MEDIN if updates to this list are required.
      Do not guess if not known.
    </svrl:text><svrl:text>
      Examples
    </svrl:text><svrl:text>
      <axsl:text/>Example 1:<axsl:text/> WGS84
    </svrl:text><svrl:text>
      <axsl:text/>Example 2:<axsl:text/> National Grid of Great Britain
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M37"/><svrl:active-pattern><axsl:attribute name="id">MedinSpatialReferenceSystemGcoTypeTypePatternTest</axsl:attribute><axsl:attribute name="name">MedinSpatialReferenceSystemGcoTypeTypePatternTest</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M38"/><svrl:active-pattern><axsl:attribute name="name">Element 16 - Temporal Reference (M)</axsl:attribute><svrl:text>
      Mandatory element.  At least one of the sub-elements must be included.  One occurrence
      allowed of each sub element.  Date/Time format.
    </svrl:text><svrl:text>
      It is recommended that all known temporal references of the resource are included. 
      The temporal extent of the resource (e.g. the period overwhich a data set covers) 
      and the date of publication (i.e. the date at which it was made publically available) 
      are mandatory.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M39"/><svrl:active-pattern><axsl:attribute name="id">MedinTemporalReferenceGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinTemporalReferenceGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M40"/><svrl:active-pattern><axsl:attribute name="name">Element 16.1 - Temporal Extent (M)</axsl:attribute><svrl:text>
      Mandatory Element. One occurrence allowed. Date or Date/Time format.
    </svrl:text><svrl:text>
      This describes the start and end date of the resource e.g. survey, and should be included
      where known.  You should include both a start and end date.  It is recommended that a full
      date including year, month and day is added, but it is accepted that for some historical
      resources only vague dates (year only, year and month only) are available.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M41"/><svrl:active-pattern><axsl:attribute name="name">Element 16.2 - Date of Publication (M)</axsl:attribute><svrl:text>
      Mandatory element.  Complete if known.  One occurrence allowed.  Date/Time format.
    </svrl:text><svrl:text>
      This describes the publication date of the resource and should be included where known.
      If the resource is previously unpublished please use the date that the resource was made
      publically available via the MEDIN network.  It is recommended that a full date including
      year, month and day is added, but it is accepted that for some historical resources only
      vague dates (year only, year and month only) are available.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M42"/><svrl:active-pattern><axsl:attribute name="name">Element 16.3 - Date of Last Revision (O)</axsl:attribute><svrl:text>
      Optional element.  Complete if known.  One occurrence allowed.  Date/Time format.
    </svrl:text><svrl:text>
      This describes the most recent date that the resource was revised.  It is recommended that a
      full date including year, month and day is added.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M43"/><svrl:active-pattern><axsl:attribute name="name">Element 16.4 - Date of Creation (O)</axsl:attribute><svrl:text>
      Optional element.  Complete if known.  One occurrence allowed.  Date/Time format.
    </svrl:text><svrl:text>
      This describes the most recent date that the resource was created.  It is recommended that
      a full date including year, month and day is added.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M44"/><svrl:active-pattern><axsl:attribute name="name">Element 17 - Lineage (C)</axsl:attribute><svrl:text>
      Mandatory element for datasets or series of datasets.  One occurrence allowed.  This Element
      is not required if a service is being described.  Free text.
    </svrl:text><svrl:text>
      Lineage includes the background information, history of the sources of data used and can
      include data quality statements.  The lineage element can include information about: source
      material; data collection methods used; data processing methods used; quality control
      processes.  Please indicate any data collection standards used.  Additional information
      source to record relevant references to the data e.g reports, articles, website.
    </svrl:text><svrl:text>
      <axsl:text/>Example 1:<axsl:text/> This dataset was collected by the Fisheries Research Services and
      provided to the British Oceanographic Data Centre for long term archive and management.
    </svrl:text><svrl:text>
      <axsl:text/>Example 2:<axsl:text/> (no protocols or standards used)- Forty 0.1m2 Hamon grab samples were collected
      from across the region, both within and beyond the extraction area, and analyzed for macrofauna
      and sediment particle size distribution in order to produce a regional description of the status
      of the seabed environment.  Samples were sieved over a 1mm mesh sieve.  In addition, the data
      were analyzed in relation to the area of seabed impacted by dredging over the period 1993-1998.
      Areas subject to 'direct' impacts were determined through reference to annual electronic records of
      dredging activity and this information was then used to model the likely extent of areas potentially
      subject to 'indirect' ecological and geophysical impact.
    </svrl:text><svrl:text>
      <axsl:text/>Example 3:<axsl:text/> (collected using protocols and standards) - Data was collected
      using the NMMP data collection, processing and Quality Assurance SOPs and complies to MEDIN
      data standards.
    </svrl:text><svrl:text>
      <axsl:text/>Example 4:<axsl:text/> Survey data from MNCR lagoon surveys were used to create a
      GIS layer of the extent of saline lagoons in the UK that was ground-truthed using 2006-2008
      aerial coastal photography obtained from the Environment Agency and site visits to selected
      locations.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M45"/><svrl:active-pattern><axsl:attribute name="id">MedinLineageGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinLineageGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M46"/><svrl:active-pattern><axsl:attribute name="name">Element 18 - Spatial Resolution (C)</axsl:attribute><svrl:text>
      Mandatory element for datasets and series of datasets.  Multiple occurrences allowed. 
      Numeric (positive whole number) and free text.
    </svrl:text><svrl:text>
      Provides an indication of the spatial resolution of the data; i.e. how accurate 
      the spatial positions are likely to be.  An approximate value may be given.
    </svrl:text><svrl:text>
      Spatial resolution may be presented as a distance measurement, in which case 
      the units must be provided, or an equivalent scale. The equivalent scale is 
      presented as a positive integer and only the denominator is encoded (e.g. 
      1:50,000 is encoded as 50000).
    </svrl:text><svrl:text>
      GEMINI2 mandates the use of a distance measurement to express the spatial 
      resolution. MEDIN is in discussions with GEMINI and ISO to allow the use 
      of scale for this element.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M47"/><svrl:active-pattern><axsl:attribute name="id">MedinDistanceGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinDistanceGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M48"/><svrl:active-pattern><axsl:attribute name="id">MedinEquivalentScaleGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinEquivalentScaleGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M49"/><svrl:active-pattern><axsl:attribute name="name">Element 19 - Additional Information Source (O)</axsl:attribute><svrl:text>
      Optional element.  Multiple occurrences allowed.  Free text.
    </svrl:text><svrl:text>
      Any references to external information that are considered useful, e.g. project website,
      report, journal article may be recorded.  It should not be used to record additional
      information about the resource.
    </svrl:text><svrl:text>
      Example
    </svrl:text><svrl:text>
      Malthus, T.J., Harries, D.B., Karpouzli, E., Moore, C.G., Lyndon, A.R., Mair, J.M.,
      Foster-Smith, B.,Sotheran, I. and Foster-Smith, D. (2006). Biotope mapping of the
      Sound of Harris, Scotland. Scottish Natural Heritage Commissioned Report No. 212
      (ROAME No. F01AC401/2).
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M50"/><svrl:active-pattern><axsl:attribute name="id">MedinAdditionalInformationSourceGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinAdditionalInformationSourceGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M51"/><svrl:active-pattern><axsl:attribute name="name">Element 20 - Limitations on Public Access (M)</axsl:attribute><svrl:text>
      Mandatory element.  Multiple occurrences allowed.  Controlled vocabulary and free text.
    </svrl:text><svrl:text>
      This element describes any restrictions imposed on the resource for security and other
      reasons using the controlled ISO vocabulary RestrictionCode (See Annex 6).  If restricted
      or otherRestrictions is chosen please provide information on any limitations to access of
      resource and the reasons for them.  If there are no limitations on public access, this must
      be indicated.
    </svrl:text><svrl:text>
      Examples
    </svrl:text><svrl:text>
      <axsl:text/>Example 1:<axsl:text/> accessConstraints:
    </svrl:text><svrl:text>
      otherRestrictions: No restrictions to public access
    </svrl:text><svrl:text>
      <axsl:text/>Example 2:<axsl:text/> accessConstraints:
    </svrl:text><svrl:text>
      otherRestrictions: Restricted public access, only available at 10km resolution.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M52"/><svrl:active-pattern><axsl:attribute name="id">MedinOtherConstraintsInnerTextPattern</axsl:attribute><axsl:attribute name="name">MedinOtherConstraintsInnerTextPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M53"/><svrl:active-pattern><axsl:attribute name="name">Element 21 - Conditions for Access and Use Constraints (M)</axsl:attribute><svrl:text>
      Mandatory element.  Multiple occurrences allowed.  Free text.
    </svrl:text><svrl:text>
      This element describes any restrictions and legal restraints on using the data.  
      Any known constraints such as fees should be identified.  If no conditions 
      apply, then “no conditions apply” should be recorded.
    </svrl:text><svrl:text>
      Examples
    </svrl:text><svrl:text>
      <axsl:text/>Example 1:<axsl:text/> Data is freely available for research or commercial use
      providing that the originators are acknowledged in any publications produced.
    </svrl:text><svrl:text>
      <axsl:text/>Example 2:<axsl:text/> Data is freely available for use in teaching and conservation
      but permission must be sought for use if the data will be reproduced in full or part or if
      used in any analyses.
    </svrl:text><svrl:text>
      <axsl:text/>Example 3:<axsl:text/> Not suitable for use in navigation.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M54"/><svrl:active-pattern><axsl:attribute name="id">MedinConditionsForAccessAndUseConstraintsGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinConditionsForAccessAndUseConstraintsGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M55"/><svrl:active-pattern><axsl:attribute name="name">Element 22 - Responsible Party (M)</axsl:attribute><svrl:text>
      Mandatory element.  Multiple occurrences are allowed for some responsible party roles.
      Must include minimum of person/organization name and email address.  Free text and
      controlled vocabulary.
    </svrl:text><svrl:text>
      Provides a description of an organization or person who has a role for the dataset 
      or resource. A full list of roles is available in Annex 7. MEDIN mandates that 
      the roles of 'Originator' and 'Custodian' (data holder) and the role of 'Distributor' 
      should be entered if different to the Custodian. The ‘Metadata point of contact’ 
      is also mandatory. Other types of responsible party may be specified from the 
      controlled vocabulary (see Annex 7 for codelist) if desired.
    </svrl:text><svrl:text>
      If the data has been lodged with a MEDIN apprroved Data Archive Centre then 
      the DAC should be specified as the Custodian.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M56"/><svrl:active-pattern><axsl:attribute name="name">Element 22.1 - Originator Point of Contact (M)</axsl:attribute><svrl:text>
      Mandatory element.  Multiple occurrences of originators allowed.  Must include
      minimum of person/organization name and email address.
    </svrl:text><svrl:text>
      Person(s) or organization(s) who created the resource.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M57"/><svrl:active-pattern><axsl:attribute name="id">MedinOriginatorPointOfContactResponsiblePartyPattern</axsl:attribute><axsl:attribute name="name">MedinOriginatorPointOfContactResponsiblePartyPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M58"/><svrl:active-pattern><axsl:attribute name="name">Element 22.2 - Custodian Point of Contact (M)</axsl:attribute><svrl:text>
      Mandatory element.  Multiple occurrences of custodians allowed.  Must include 
      minimum of person/organization name and email address.
    </svrl:text><svrl:text>
      Person(s) or organization(s) that accept responsibility for the data and 
      ensures appropriate case and maintenance. If the datset has been lodged 
      with a Data Archive Centres then this should be entered.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M59"/><svrl:active-pattern><axsl:attribute name="id">MedinCustodianPointOfContactResponsiblePartyPattern</axsl:attribute><axsl:attribute name="name">MedinCustodianPointOfContactResponsiblePartyPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M60"/><svrl:active-pattern><axsl:attribute name="name">Element 22.3 - Distributor Point of Contact (C)</axsl:attribute><svrl:text>
      Conditional element.  Multiple occurrences of originators allowed.  Must include minimum 
      of person/organization name and email address.
    </svrl:text><svrl:text>
      Person(s) or organization(s) that distributes the resource.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M61"/><svrl:active-pattern><axsl:attribute name="id">MedinDistributorPointOfContactResponsiblePartyPattern</axsl:attribute><axsl:attribute name="name">MedinDistributorPointOfContactResponsiblePartyPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M62"/><svrl:active-pattern><axsl:attribute name="name">Element 22.3 - Metadata Point of Contact (M)</axsl:attribute><svrl:text>
      Mandatory element.  One occurence allowed.  Must include minimum of
      person/organization name and email address.
    </svrl:text><svrl:text>
      Person or organization with responsibility for the maintenance of the metadata for the resource.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M63"/><svrl:active-pattern><axsl:attribute name="id">MedinMetadataPointOfContactResponsiblePartyPattern</axsl:attribute><axsl:attribute name="name">MedinMetadataPointOfContactResponsiblePartyPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M64"/><svrl:active-pattern><axsl:attribute name="name">Element 23 - Data Format (O)</axsl:attribute><svrl:text>
      Optional element.  Multiple data formats are allowed.  Free text.
    </svrl:text><svrl:text>
      Indicate the formats in which digital data can be provided for transfer.
    </svrl:text><svrl:text>
      Examples
    </svrl:text><svrl:text>
      ESRI Shapefiles
    </svrl:text><svrl:text>
      Comma Separated Value (.csv) file
    </svrl:text><svrl:text>
      Tiff image files
    </svrl:text><svrl:text>
      MPEG video files
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M65"/><svrl:active-pattern><axsl:attribute name="id">MedinDataFormatNameGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinDataFormatNameGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M66"/><svrl:active-pattern><axsl:attribute name="id">MedinDataFormatVersionGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinDataFormatVersionGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M67"/><svrl:active-pattern><axsl:attribute name="name">Element 24 - Frequency of Update (C)</axsl:attribute><svrl:text>
      Mandatory for datasets and series of datasets, Conditional for services.  
      One occurrence allowed.  Controlled vocabulary.
    </svrl:text><svrl:text>
      This describes the frequency that the resource (data set) is modified 
      or updated and should be included if known.  For example if the data 
      set is from a monitoring programme which samples once per year then 
      the frequency is annually. Select one option from ISO frequency of 
      update codelist (MD_FrequencyOfUpdate codelist).  The full code list 
      is presented in Annex 8.
    </svrl:text><svrl:text>
      Examples
    </svrl:text><svrl:text>
      <axsl:text/>Example 1:<axsl:text/> monthly
    </svrl:text><svrl:text>
      <axsl:text/>Example 2:<axsl:text/> annually
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M68"/><svrl:active-pattern><axsl:attribute name="id">MedinFrequencyOfUpdateInnerTextPattern</axsl:attribute><axsl:attribute name="name">MedinFrequencyOfUpdateInnerTextPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M69"/><svrl:active-pattern><axsl:attribute name="name">Element 25 - INSPIRE Conformity (C)</axsl:attribute><svrl:text>
      Conditional element.  Multiple occurrences allowed.  Required if the resource provider
      is claiming conformance to INSPIRE.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M70"/><svrl:active-pattern><axsl:attribute name="name">Element 25.1 - INSPIRE Degree of Conformity (C)</axsl:attribute><svrl:text>
      Conditional element.  Multiple occurrences allowed.  Required if the resource provider
      is claiming conformance to INSPIRE.
    </svrl:text><svrl:text>
      This element relates to the INSPIRE Directive 1 and indicates whether a resource conforms to
      a product specification or other INSPIRE thematic specification.  The values are as followed.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M71"/><svrl:active-pattern><axsl:attribute name="id">MedinDegreeOfConformityGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinDegreeOfConformityGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M72"/><svrl:active-pattern><axsl:attribute name="id">MedinDegreeOfConformityExplanationGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinDegreeOfConformityExplanationGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M73"/><svrl:active-pattern><axsl:attribute name="name">Element 25.2 - INSPIRE Specification (C)</axsl:attribute><svrl:text>
      Conditional element.  Multiple occurrences allowed.  Required if the resource provider is
      claiming conformance to INSPIRE.  Controlled vocabulary.
    </svrl:text><svrl:text>
      If the resource is intended to conform to the INSPIRE thematic data specification, cite the
      data or thematic specifications that it conforms to using this element.
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M74"/><svrl:active-pattern><axsl:attribute name="id">MedinSpecificationTitleGcoTypeTest</axsl:attribute><axsl:attribute name="name">MedinSpecificationTitleGcoTypeTest</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M75"/><svrl:active-pattern><axsl:attribute name="id">MedinSpecificationDateGcoTypeTest</axsl:attribute><axsl:attribute name="name">MedinSpecificationDateGcoTypeTest</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M76"/><svrl:active-pattern><axsl:attribute name="id">MedinSpecificationDateTypeInnerTextTest</axsl:attribute><axsl:attribute name="name">MedinSpecificationDateTypeInnerTextTest</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M77"/><svrl:active-pattern><axsl:attribute name="name">Element 26 - Date of Update of Metadata (M)</axsl:attribute><svrl:text>Mandatory element.  One occurence allowed.  Date format.</svrl:text><svrl:text>
      This describes the last date the metadata was updated on. If the metadata has 
      not been updated it should give the date on which it was created. This should 
      be provided as a date in the format:
    </svrl:text><svrl:text>Example</svrl:text><svrl:text>2008-05-12</svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M78"/><svrl:active-pattern><axsl:attribute name="id">MedinDateOfUpdateOfMetadataGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinDateOfUpdateOfMetadataGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M79"/><svrl:active-pattern><axsl:attribute name="name">Element 27 - Metadata Standard Name (M)</axsl:attribute><svrl:text>
      Mandatory element.  One occurence allowed.
    </svrl:text><svrl:text>
      Identify the metadata standard used to create the metadata.
    </svrl:text><svrl:text>
      Example
    </svrl:text><svrl:text>
      MEDIN Metadata Specification
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M80"/><svrl:active-pattern><axsl:attribute name="id">MedinMetadataStandardNameInnerText</axsl:attribute><axsl:attribute name="name">MedinMetadataStandardNameInnerText</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M81"/><svrl:active-pattern><axsl:attribute name="name">Element 28 - Metadata Standard Version (M)</axsl:attribute><svrl:text>
      Mandatory element.  One occurence allowed.
    </svrl:text><svrl:text>
      Identify the version of the metadata standard used to create the metadata.
    </svrl:text><svrl:text>
      Example
    </svrl:text><svrl:text>
      Version 1.0
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M82"/><svrl:active-pattern><axsl:attribute name="id">MedinMetadataStandardVersionInnerText</axsl:attribute><axsl:attribute name="name">MedinMetadataStandardVersionInnerText</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M83"/><svrl:active-pattern><axsl:attribute name="name">Element 29 - Metadata Language (M)</axsl:attribute><svrl:text>
      Mandatory element.  Multiple metadata languages allowed.  Controlled vocabulary.
    </svrl:text><svrl:text>
      Describes the language(s) elements of the metadata.
    </svrl:text><svrl:text>
      Select the relevant 3-letter code(s) from the ISO 639-2 code list of languages.
      Additional languages may be added to this list if required.  A full list of UK
      language codes is listed in Annex 3 and a list of recognized languages is available
      online http://www.loc.gov/standards/iso639-2.
    </svrl:text><svrl:text>
      Examples
    </svrl:text><svrl:text>
      <axsl:text/>Example 1:<axsl:text/> eng (English)
    </svrl:text><svrl:text>
      <axsl:text/>Example 2:<axsl:text/> cym (Welsh)
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M84"/><svrl:active-pattern><axsl:attribute name="id">MedinMetadataLanguageLanguagePattern</axsl:attribute><axsl:attribute name="name">MedinMetadataLanguageLanguagePattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M85"/><svrl:active-pattern><axsl:attribute name="id">MedinMetadataLanguageGcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">MedinMetadataLanguageGcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M86"/></svrl:schematron-output></axsl:template>

<!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">MEDIN Discovery Metadata Profile</svrl:text>

<!--PATTERN Element 1 - Resource Title (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 1 - Resource Title (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M9"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:citation/*/gmd:title) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:citation/*/gmd:title) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Resource Title is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/></axsl:template><axsl:template match="text()" priority="-1" mode="M9"/><axsl:template match="@*|node()" priority="-2" mode="M9"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/></axsl:template>

<!--PATTERN MedinResourceTitleGcoTypeTest-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:citation/*/gmd:title" priority="1000" mode="M10"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/></axsl:template><axsl:template match="text()" priority="-1" mode="M10"/><axsl:template match="@*|node()" priority="-2" mode="M10"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/></axsl:template>

<!--PATTERN Element 2 - Alternative Resource Title (O)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 2 - Alternative Resource Title (O)</svrl:text><axsl:template match="text()" priority="-1" mode="M11"/><axsl:template match="@*|node()" priority="-2" mode="M11"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/></axsl:template>

<!--PATTERN MedinAlternativeResourceTitleInnerText-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:citation/*//gmd:alternateTitle" priority="1000" mode="M12"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:citation/*//gmd:alternateTitle"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/></axsl:template><axsl:template match="text()" priority="-1" mode="M12"/><axsl:template match="@*|node()" priority="-2" mode="M12"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/></axsl:template>

<!--PATTERN Element 3 - Resource Abstract (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 3 - Resource Abstract (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M13"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:abstract) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:abstract) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Resource Abstract is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/></axsl:template><axsl:template match="text()" priority="-1" mode="M13"/><axsl:template match="@*|node()" priority="-2" mode="M13"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/></axsl:template>

<!--PATTERN MedinResourceAbstractGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:abstract" priority="1000" mode="M14"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:abstract"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/></axsl:template><axsl:template match="text()" priority="-1" mode="M14"/><axsl:template match="@*|node()" priority="-2" mode="M14"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/></axsl:template>

<!--PATTERN Element 4 - Resource Type (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 4 - Resource Type (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M15"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:hierarchyLevel) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:hierarchyLevel) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Resource Type is mandatory. One occurrence is allowed.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(gmd:hierarchyLevel/*/@codeListValue, 'series') or                    contains(gmd:hierarchyLevel/*/@codeListValue, 'service')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(gmd:hierarchyLevel/*/@codeListValue, 'series') or contains(gmd:hierarchyLevel/*/@codeListValue, 'service')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Value of Resource Type must be dataset, series or service.
        Value of Resource Type is '<axsl:text/><axsl:value-of select="gmd:hierarchyLevel/*/@codeListValue"/><axsl:text/>'
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/></axsl:template><axsl:template match="text()" priority="-1" mode="M15"/><axsl:template match="@*|node()" priority="-2" mode="M15"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/></axsl:template>

<!--PATTERN Element 5 - Resource Locator (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 5 - Resource Locator (C)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M16"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage) = 0 or                    (starts-with(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*, 'http://')  or                    starts-with(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*, 'https://') or                    starts-with(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*, 'ftp://'))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage) = 0 or (starts-with(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*, 'http://') or starts-with(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*, 'https://') or starts-with(gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*, 'ftp://'))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The value of resource locator does not appear to be a valid URL. It has a value of 
        '<axsl:text/><axsl:value-of select="gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:linkage/*"/><axsl:text/>'
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M16"/></axsl:template><axsl:template match="text()" priority="-1" mode="M16"/><axsl:template match="@*|node()" priority="-2" mode="M16"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M16"/></axsl:template>

<!--PATTERN MedinResouceLocatorGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:name" priority="1000" mode="M17"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/*/gmd:name"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M17"/></axsl:template><axsl:template match="text()" priority="-1" mode="M17"/><axsl:template match="@*|node()" priority="-2" mode="M17"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M17"/></axsl:template>

<!--PATTERN Element 6 - Unique Resource Identifier (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 6 - Unique Resource Identifier (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M18"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and                    count(gmd:identificationInfo/*/gmd:citation/*/gmd:identifier) = 1) or                    (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and count(gmd:identificationInfo/*/gmd:citation/*/gmd:identifier) = 1) or (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        If the Resource Type is dataset or series one Unique Resource Identifier must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M18"/></axsl:template><axsl:template match="text()" priority="-1" mode="M18"/><axsl:template match="@*|node()" priority="-2" mode="M18"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M18"/></axsl:template>

<!--PATTERN MedinUniqueResourceIdentifierGcoTypePattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code" priority="1000" mode="M19"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M19"/></axsl:template><axsl:template match="text()" priority="-1" mode="M19"/><axsl:template match="@*|node()" priority="-2" mode="M19"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M19"/></axsl:template>

<!--PATTERN MedinUniqueResourceIdentifierCodeSpaceGcoTypePattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace" priority="1000" mode="M20"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M20"/></axsl:template><axsl:template match="text()" priority="-1" mode="M20"/><axsl:template match="@*|node()" priority="-2" mode="M20"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M20"/></axsl:template>

<!--PATTERN Element 7 - Coupled Resource (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 7 - Coupled Resource (C)</svrl:text><axsl:template match="text()" priority="-1" mode="M21"/><axsl:template match="@*|node()" priority="-2" mode="M21"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M21"/></axsl:template>

<!--PATTERN Element 8 - Resource Language (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 8 - Resource Language (C)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M22"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and                    count(/*/gmd:identificationInfo/*/gmd:language) &gt;= 1) or                    (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and count(/*/gmd:identificationInfo/*/gmd:language) &gt;= 1) or (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        If the Resource Type is dataset or series, Resource Language must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M22"/></axsl:template><axsl:template match="text()" priority="-1" mode="M22"/><axsl:template match="@*|node()" priority="-2" mode="M22"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M22"/></axsl:template>

<!--PATTERN MedinResourceLanguageLanguagePattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:language" priority="1000" mode="M23"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:language"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(./gco:CharacterString = 'eng' or ./gco:CharacterString = 'cym' or ./gco:CharacterString = 'gle' or ./gco:CharacterString = 'gla' or ./gco:CharacterString = 'cor') or                    (./gmd:LanguageCode/@codeListValue='eng' or ./gmd:LanguageCode/@codeListValue='cym' or ./gmd:LanguageCode/@codeListValue='gle' or ./gmd:LanguageCode/@codeListValue='gla' or ./gmd:LanguageCode/@codeListValue='cor')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(./gco:CharacterString = 'eng' or ./gco:CharacterString = 'cym' or ./gco:CharacterString = 'gle' or ./gco:CharacterString = 'gla' or ./gco:CharacterString = 'cor') or (./gmd:LanguageCode/@codeListValue='eng' or ./gmd:LanguageCode/@codeListValue='cym' or ./gmd:LanguageCode/@codeListValue='gle' or ./gmd:LanguageCode/@codeListValue='gla' or ./gmd:LanguageCode/@codeListValue='cor')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> must be one of eng, cym, gle, gla or cor.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M23"/></axsl:template><axsl:template match="text()" priority="-1" mode="M23"/><axsl:template match="@*|node()" priority="-2" mode="M23"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M23"/></axsl:template>

<!--PATTERN Element 9 - Topic Category (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 9 - Topic Category (C)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M24"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and                    count(/*/gmd:identificationInfo/*/gmd:topicCategory) &gt;= 1) or                    (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and count(/*/gmd:identificationInfo/*/gmd:topicCategory) &gt;= 1) or (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        If the Resource Type is dataset or series, one or more Topic Categories must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M24"/></axsl:template><axsl:template match="text()" priority="-1" mode="M24"/><axsl:template match="@*|node()" priority="-2" mode="M24"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M24"/></axsl:template>

<!--PATTERN MedinTopicCategoryCodeInnerText-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:topicCategory" priority="1000" mode="M25"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:topicCategory"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="string-length(gmd:MD_TopicCategoryCode) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="string-length(gmd:MD_TopicCategoryCode) &gt; 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element should have a value.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M25"/></axsl:template><axsl:template match="text()" priority="-1" mode="M25"/><axsl:template match="@*|node()" priority="-2" mode="M25"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M25"/></axsl:template>

<!--PATTERN Element 10 - Spatial Data Service Type (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 10 - Spatial Data Service Type (C)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M26"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'service')) and                    count(/*/gmd:identificationInfo/*/srv:serviceType) = 1) or                    (contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(gmd:hierarchyLevel/*/@codeListValue, 'series'))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'service')) and count(/*/gmd:identificationInfo/*/srv:serviceType) = 1) or (contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(gmd:hierarchyLevel/*/@codeListValue, 'series'))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        If the Resource Type is service, one Spatial Data Service Type must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M26"/></axsl:template><axsl:template match="text()" priority="-1" mode="M26"/><axsl:template match="@*|node()" priority="-2" mode="M26"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M26"/></axsl:template>

<!--PATTERN MedinSpatialDataServiceTypeGcoTypePattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/srv:serviceType" priority="1000" mode="M27"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/srv:serviceType"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M27"/></axsl:template><axsl:template match="text()" priority="-1" mode="M27"/><axsl:template match="@*|node()" priority="-2" mode="M27"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M27"/></axsl:template>

<!--PATTERN -->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/srv:serviceType" priority="1000" mode="M28"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/srv:serviceType"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="contains(., 'discovery') or                   contains(., 'view') or                   contains(., 'download') or                   contains(., 'transformation') or                   contains(., 'invoke') or                   contains(., 'other')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="contains(., 'discovery') or contains(., 'view') or contains(., 'download') or contains(., 'transformation') or contains(., 'invoke') or contains(., 'other')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Service type must be one of 'discovery', 'view', 'download', 'transformation', 'invoke'
        or 'other' following INSPIRE generic names.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M28"/></axsl:template><axsl:template match="text()" priority="-1" mode="M28"/><axsl:template match="@*|node()" priority="-2" mode="M28"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M28"/></axsl:template>

<!--PATTERN Element 11 - Keywords (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 11 - Keywords (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M29"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:descriptiveKeywords) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:descriptiveKeywords) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Keywords are mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:descriptiveKeywords/*/gmd:thesaurusName) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:descriptiveKeywords/*/gmd:thesaurusName) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Thesaurus Name is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:descriptiveKeywords/*/gmd:keyword[starts-with(*/@xlink:href,'http://vocab.ndg.nerc.ac.uk/term/N010/')][substring-after(*/@xlink:href,'http://vocab.ndg.nerc.ac.uk/term/N010/')][contains(*/@xlink:href,'/NDGO0001')]) +                    count(*/gmd:descriptiveKeywords/*/gmd:keyword[*/@xlink:href='http://vocab.ndg.nerc.ac.uk/term/N010/0']) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:descriptiveKeywords/*/gmd:keyword[starts-with(*/@xlink:href,'http://vocab.ndg.nerc.ac.uk/term/N010/')][substring-after(*/@xlink:href,'http://vocab.ndg.nerc.ac.uk/term/N010/')][contains(*/@xlink:href,'/NDGO0001')]) + count(*/gmd:descriptiveKeywords/*/gmd:keyword[*/@xlink:href='http://vocab.ndg.nerc.ac.uk/term/N010/0']) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The NERC Data Grid OAI harvesting keyword must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M29"/></axsl:template><axsl:template match="text()" priority="-1" mode="M29"/><axsl:template match="@*|node()" priority="-2" mode="M29"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M29"/></axsl:template>

<!--PATTERN Element 12 - Geographical Bounding Box (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 12 - Geographical Bounding Box (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M30"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(../gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(../gmd:hierarchyLevel/*/@codeListValue, 'series')) and                    count(*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox) = 1) or                   contains(../gmd:hierarchyLevel/*/@codeListValue, 'service')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(../gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(../gmd:hierarchyLevel/*/@codeListValue, 'series')) and count(*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox) = 1) or contains(../gmd:hierarchyLevel/*/@codeListValue, 'service')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Geographic bounding box is mandatory. One shall be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M30"/></axsl:template><axsl:template match="text()" priority="-1" mode="M30"/><axsl:template match="@*|node()" priority="-2" mode="M30"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M30"/></axsl:template>

<!--PATTERN MedinGeographicBoundingBoxPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox |                /*/gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/*[@gco:isoType='gmd:EX_GeographicBoundingBox'] |                /*/gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox |                /*/gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement/*[@gco:isoType='gmd:EX_GeographicBoundingBox']" priority="1000" mode="M31"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox |                /*/gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/*[@gco:isoType='gmd:EX_GeographicBoundingBox'] |                /*/gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox |                /*/gmd:identificationInfo/*/srv:extent/*/gmd:geographicElement/*[@gco:isoType='gmd:EX_GeographicBoundingBox']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="gmd:westBoundLongitude &gt;= -180.0 and gmd:westBoundLongitude &lt;= 180.0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="gmd:westBoundLongitude &gt;= -180.0 and gmd:westBoundLongitude &lt;= 180.0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        westBoundLongitude has a value of <axsl:text/><axsl:value-of select="gmd:westBoundLongitude"/><axsl:text/> which is outside bounds.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="gmd:eastBoundLongitude &gt;= -180.0 and gmd:eastBoundLongitude &lt;= 180.0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="gmd:eastBoundLongitude &gt;= -180.0 and gmd:eastBoundLongitude &lt;= 180.0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        eastBoundLongitude has a value of <axsl:text/><axsl:value-of select="gmd:eastBoundLongitude"/><axsl:text/> which is outside bounds.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="gmd:southBoundLatitude &gt;= -90.0 and gmd:southBoundLatitude &lt;= gmd:northBoundLatitude"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="gmd:southBoundLatitude &gt;= -90.0 and gmd:southBoundLatitude &lt;= gmd:northBoundLatitude"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        southBoundLatitude has a value of <axsl:text/><axsl:value-of select="gmd:southBoundLatitude"/><axsl:text/> which is outside bounds.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="gmd:northBoundLatitude &lt;= 90.0 and gmd:northBoundLatitude &gt;= gmd:southBoundLatitude"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="gmd:northBoundLatitude &lt;= 90.0 and gmd:northBoundLatitude &gt;= gmd:southBoundLatitude"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        northBoundLatitude has a value of <axsl:text/><axsl:value-of select="gmd:northBoundLatitude"/><axsl:text/> which is outside bounds.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M31"/></axsl:template><axsl:template match="text()" priority="-1" mode="M31"/><axsl:template match="@*|node()" priority="-2" mode="M31"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M31"/></axsl:template>

<!--PATTERN Element 13 - Extent (O)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 13 - Extent (O)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier" priority="1000" mode="M32"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:authority) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:authority) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Extent vocabulary name is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M32"/></axsl:template><axsl:template match="text()" priority="-1" mode="M32"/><axsl:template match="@*|node()" priority="-2" mode="M32"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M32"/></axsl:template>

<!--PATTERN MedinExtentCodeGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier/*/gmd:code" priority="1000" mode="M33"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier/*/gmd:code"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M33"/></axsl:template><axsl:template match="text()" priority="-1" mode="M33"/><axsl:template match="@*|node()" priority="-2" mode="M33"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M33"/></axsl:template>

<!--PATTERN MedinExtentAuthorityGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier/*/gmd:authority/*/gmd:title" priority="1000" mode="M34"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/*/*/gmd:geographicElement/*/gmd:geographicIdentifier/*/gmd:authority/*/gmd:title"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M34"/></axsl:template><axsl:template match="text()" priority="-1" mode="M34"/><axsl:template match="@*|node()" priority="-2" mode="M34"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M34"/></axsl:template>

<!--PATTERN Element 14 - Vertical Extent Information (O)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 14 - Vertical Extent Information (O)</svrl:text><axsl:template match="text()" priority="-1" mode="M35"/><axsl:template match="@*|node()" priority="-2" mode="M35"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M35"/></axsl:template>

<!--PATTERN MedinVerticalExtentInformationGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:extent/*/gmd:verticalElement/*/gmd:minimumValue |                /*/gmd:identificationInfo/*/gmd:extent/*/gmd:verticalElement/*/gmd:maximumValue" priority="1000" mode="M36"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:extent/*/gmd:verticalElement/*/gmd:minimumValue |                /*/gmd:identificationInfo/*/gmd:extent/*/gmd:verticalElement/*/gmd:maximumValue"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M36"/></axsl:template><axsl:template match="text()" priority="-1" mode="M36"/><axsl:template match="@*|node()" priority="-2" mode="M36"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M36"/></axsl:template>

<!--PATTERN Element 15 - Spatial Reference System (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 15 - Spatial Reference System (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M37"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:referenceSystemInfo) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:referenceSystemInfo) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Coordinate reference system information must be supplied.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M37"/></axsl:template><axsl:template match="text()" priority="-1" mode="M37"/><axsl:template match="@*|node()" priority="-2" mode="M37"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M37"/></axsl:template>

<!--PATTERN MedinSpatialReferenceSystemGcoTypeTypePatternTest-->


	<!--RULE -->
<axsl:template match="/*/gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier/*/gmd:code" priority="1000" mode="M38"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier/*/gmd:code"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M38"/></axsl:template><axsl:template match="text()" priority="-1" mode="M38"/><axsl:template match="@*|node()" priority="-2" mode="M38"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M38"/></axsl:template>

<!--PATTERN Element 16 - Temporal Reference (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 16 - Temporal Reference (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M39"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:citation/*/gmd:date/*/gmd:dateType/*[@codeListValue='revision']) &lt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:citation/*/gmd:date/*/gmd:dateType/*[@codeListValue='revision']) &lt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Only one revision date allowed.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:citation/*/gmd:date/*/gmd:dateType/*[@codeListValue='creation']) &lt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:citation/*/gmd:date/*/gmd:dateType/*[@codeListValue='creation']) &lt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Only one creation date allowed.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M39"/></axsl:template><axsl:template match="text()" priority="-1" mode="M39"/><axsl:template match="@*|node()" priority="-2" mode="M39"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M39"/></axsl:template>

<!--PATTERN MedinTemporalReferenceGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:citation/*/gmd:date/*/gmd:date" priority="1000" mode="M40"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:citation/*/gmd:date/*/gmd:date"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M40"/></axsl:template><axsl:template match="text()" priority="-1" mode="M40"/><axsl:template match="@*|node()" priority="-2" mode="M40"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M40"/></axsl:template>

<!--PATTERN Element 16.1 - Temporal Extent (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 16.1 - Temporal Extent (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M41"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(../gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(../gmd:hierarchyLevel/*/@codeListValue, 'series')) and                    count(*/gmd:extent/*/gmd:temporalElement) = 1) or                   contains(../gmd:hierarchyLevel/*/@codeListValue, 'service')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(../gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(../gmd:hierarchyLevel/*/@codeListValue, 'series')) and count(*/gmd:extent/*/gmd:temporalElement) = 1) or contains(../gmd:hierarchyLevel/*/@codeListValue, 'service')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Temporal extent is mandatory for datasets and series. One must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M41"/></axsl:template><axsl:template match="text()" priority="-1" mode="M41"/><axsl:template match="@*|node()" priority="-2" mode="M41"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M41"/></axsl:template>

<!--PATTERN Element 16.2 - Date of Publication (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 16.2 - Date of Publication (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M42"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:citation/*/gmd:date/*/gmd:dateType[*/@codeListValue='publication']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:citation/*/gmd:date/*/gmd:dateType[*/@codeListValue='publication']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Publication date is mandatory. One must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M42"/></axsl:template><axsl:template match="text()" priority="-1" mode="M42"/><axsl:template match="@*|node()" priority="-2" mode="M42"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M42"/></axsl:template>

<!--PATTERN Element 16.3 - Date of Last Revision (O)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 16.3 - Date of Last Revision (O)</svrl:text><axsl:template match="text()" priority="-1" mode="M43"/><axsl:template match="@*|node()" priority="-2" mode="M43"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M43"/></axsl:template>

<!--PATTERN Element 16.4 - Date of Creation (O)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 16.4 - Date of Creation (O)</svrl:text><axsl:template match="text()" priority="-1" mode="M44"/><axsl:template match="@*|node()" priority="-2" mode="M44"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M44"/></axsl:template>

<!--PATTERN Element 17 - Lineage (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 17 - Lineage (C)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M45"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and                    count(gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement) = 1) or                    (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and count(gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement) = 1) or (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Lineage is mandatory for datasets and series of datasets.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M45"/></axsl:template><axsl:template match="text()" priority="-1" mode="M45"/><axsl:template match="@*|node()" priority="-2" mode="M45"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M45"/></axsl:template>

<!--PATTERN MedinLineageGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement" priority="1000" mode="M46"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M46"/></axsl:template><axsl:template match="text()" priority="-1" mode="M46"/><axsl:template match="@*|node()" priority="-2" mode="M46"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M46"/></axsl:template>

<!--PATTERN Element 18 - Spatial Resolution (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 18 - Spatial Resolution (C)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M47"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and                    count(gmd:identificationInfo/*/gmd:spatialResolution) &gt;= 1) or                    (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(gmd:hierarchyLevel/*/@codeListValue, 'series')) and count(gmd:identificationInfo/*/gmd:spatialResolution) &gt;= 1) or (contains(gmd:hierarchyLevel/*/@codeListValue, 'service'))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Spatial resolution is mandatory for datasets and series of datasets.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M47"/></axsl:template><axsl:template match="text()" priority="-1" mode="M47"/><axsl:template match="@*|node()" priority="-2" mode="M47"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M47"/></axsl:template>

<!--PATTERN MedinDistanceGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:distance" priority="1000" mode="M48"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:distance"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M48"/></axsl:template><axsl:template match="text()" priority="-1" mode="M48"/><axsl:template match="@*|node()" priority="-2" mode="M48"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M48"/></axsl:template>

<!--PATTERN MedinEquivalentScaleGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator" priority="1000" mode="M49"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:spatialResolution/*/gmd:equivalentScale/*/gmd:denominator"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M49"/></axsl:template><axsl:template match="text()" priority="-1" mode="M49"/><axsl:template match="@*|node()" priority="-2" mode="M49"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M49"/></axsl:template>

<!--PATTERN Element 19 - Additional Information Source (O)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 19 - Additional Information Source (O)</svrl:text><axsl:template match="text()" priority="-1" mode="M50"/><axsl:template match="@*|node()" priority="-2" mode="M50"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M50"/></axsl:template>

<!--PATTERN MedinAdditionalInformationSourceGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:supplementalInformation" priority="1000" mode="M51"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:supplementalInformation"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M51"/></axsl:template><axsl:template match="text()" priority="-1" mode="M51"/><axsl:template match="@*|node()" priority="-2" mode="M51"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M51"/></axsl:template>

<!--PATTERN Element 20 - Limitations on Public Access (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 20 - Limitations on Public Access (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M52"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:resourceConstraints/*/gmd:accessConstraints) +                   count(*/gmd:resourceConstraints/*/gmd:otherConstraints) +                   count(*/gmd:classification/*/gmd:resourceConstraints/*/gmd:classification) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:resourceConstraints/*/gmd:accessConstraints) + count(*/gmd:resourceConstraints/*/gmd:otherConstraints) + count(*/gmd:classification/*/gmd:resourceConstraints/*/gmd:classification) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Limitations on Public Access is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M52"/></axsl:template><axsl:template match="text()" priority="-1" mode="M52"/><axsl:template match="@*|node()" priority="-2" mode="M52"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M52"/></axsl:template>

<!--PATTERN MedinOtherConstraintsInnerTextPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints" priority="1000" mode="M53"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M53"/></axsl:template><axsl:template match="text()" priority="-1" mode="M53"/><axsl:template match="@*|node()" priority="-2" mode="M53"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M53"/></axsl:template>

<!--PATTERN Element 21 - Conditions for Access and Use Constraints (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 21 - Conditions for Access and Use Constraints (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M54"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:resourceConstraints/*/gmd:useLimitation) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:resourceConstraints/*/gmd:useLimitation) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Conditions for Access and Use Constraints is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M54"/></axsl:template><axsl:template match="text()" priority="-1" mode="M54"/><axsl:template match="@*|node()" priority="-2" mode="M54"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M54"/></axsl:template>

<!--PATTERN MedinConditionsForAccessAndUseConstraintsGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation" priority="1000" mode="M55"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:useLimitation"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M55"/></axsl:template><axsl:template match="text()" priority="-1" mode="M55"/><axsl:template match="@*|node()" priority="-2" mode="M55"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M55"/></axsl:template>

<!--PATTERN Element 22 - Responsible Party (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 22 - Responsible Party (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1001" mode="M56"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:contact) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:contact) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Metadata point of contact is a mandatory element. One or more must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M56"/></axsl:template>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M56"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:pointOfContact) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:pointOfContact) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Point of Contact is a mandatory element. One or more must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:pointOfContact/*/gmd:role/*[@codeListValue = 'originator']) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:pointOfContact/*/gmd:role/*[@codeListValue = 'originator']) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Originator point of contact is a mandatory element. At least one must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:pointOfContact/*/gmd:role/*[@codeListValue = 'custodian']) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:pointOfContact/*/gmd:role/*[@codeListValue = 'custodian']) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Custodian point of contact is a mandatory element. At least one must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M56"/></axsl:template><axsl:template match="text()" priority="-1" mode="M56"/><axsl:template match="@*|node()" priority="-2" mode="M56"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M56"/></axsl:template>

<!--PATTERN Element 22.1 - Originator Point of Contact (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 22.1 - Originator Point of Contact (M)</svrl:text><axsl:template match="text()" priority="-1" mode="M57"/><axsl:template match="@*|node()" priority="-2" mode="M57"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M57"/></axsl:template>

<!--PATTERN MedinOriginatorPointOfContactResponsiblePartyPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue = 'originator']" priority="1000" mode="M58"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue = 'originator']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:organisationName) + count(*/gmd:individualName) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:organisationName) + count(*/gmd:individualName) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        At least organisation name or individual name must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        One or more email addresses must be supplied.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M58"/></axsl:template><axsl:template match="text()" priority="-1" mode="M58"/><axsl:template match="@*|node()" priority="-2" mode="M58"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M58"/></axsl:template>

<!--PATTERN Element 22.2 - Custodian Point of Contact (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 22.2 - Custodian Point of Contact (M)</svrl:text><axsl:template match="text()" priority="-1" mode="M59"/><axsl:template match="@*|node()" priority="-2" mode="M59"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M59"/></axsl:template>

<!--PATTERN MedinCustodianPointOfContactResponsiblePartyPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue = 'custodian']" priority="1000" mode="M60"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:pointOfContact[*/gmd:role/*/@codeListValue = 'custodian']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:organisationName) + count(*/gmd:individualName) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:organisationName) + count(*/gmd:individualName) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        At least organisation name or individual name must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        One or more email addresses must be supplied.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M60"/></axsl:template><axsl:template match="text()" priority="-1" mode="M60"/><axsl:template match="@*|node()" priority="-2" mode="M60"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M60"/></axsl:template>

<!--PATTERN Element 22.3 - Distributor Point of Contact (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 22.3 - Distributor Point of Contact (C)</svrl:text><axsl:template match="text()" priority="-1" mode="M61"/><axsl:template match="@*|node()" priority="-2" mode="M61"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M61"/></axsl:template>

<!--PATTERN MedinDistributorPointOfContactResponsiblePartyPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorContact[*/gmd:role/*/@codeListValue = 'distributor']" priority="1000" mode="M62"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:distributionInfo/*/gmd:distributor/*/gmd:distributorContact[*/gmd:role/*/@codeListValue = 'distributor']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:organisationName) + count(*/gmd:individualName) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:organisationName) + count(*/gmd:individualName) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        At least organisation name or individual name must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        One or more email addresses must be supplied.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M62"/></axsl:template><axsl:template match="text()" priority="-1" mode="M62"/><axsl:template match="@*|node()" priority="-2" mode="M62"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M62"/></axsl:template>

<!--PATTERN Element 22.3 - Metadata Point of Contact (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 22.3 - Metadata Point of Contact (M)</svrl:text><axsl:template match="text()" priority="-1" mode="M63"/><axsl:template match="@*|node()" priority="-2" mode="M63"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M63"/></axsl:template>

<!--PATTERN MedinMetadataPointOfContactResponsiblePartyPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:contact" priority="1000" mode="M64"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:contact"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:organisationName) + count(*/gmd:individualName) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:organisationName) + count(*/gmd:individualName) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        At least organisation name or individual name must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress) &gt;= 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress) &gt;= 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        One or more email addresses must be supplied.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M64"/></axsl:template><axsl:template match="text()" priority="-1" mode="M64"/><axsl:template match="@*|node()" priority="-2" mode="M64"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M64"/></axsl:template>

<!--PATTERN Element 23 - Data Format (O)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 23 - Data Format (O)</svrl:text><axsl:template match="text()" priority="-1" mode="M65"/><axsl:template match="@*|node()" priority="-2" mode="M65"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M65"/></axsl:template>

<!--PATTERN MedinDataFormatNameGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:resourceFormat/*/gmd:name" priority="1000" mode="M66"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:resourceFormat/*/gmd:name"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M66"/></axsl:template><axsl:template match="text()" priority="-1" mode="M66"/><axsl:template match="@*|node()" priority="-2" mode="M66"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M66"/></axsl:template>

<!--PATTERN MedinDataFormatVersionGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:resourceFormat/*/gmd:version" priority="1000" mode="M67"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:resourceFormat/*/gmd:version"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M67"/></axsl:template><axsl:template match="text()" priority="-1" mode="M67"/><axsl:template match="@*|node()" priority="-2" mode="M67"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M67"/></axsl:template>

<!--PATTERN Element 24 - Frequency of Update (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 24 - Frequency of Update (C)</svrl:text>

	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo" priority="1000" mode="M68"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((contains(../gmd:hierarchyLevel/*/@codeListValue, 'dataset') or                    contains(../gmd:hierarchyLevel/*/@codeListValue, 'series')) and                    count(*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency) = 1) or                    (contains(../gmd:hierarchyLevel/*/@codeListValue, 'service'))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((contains(../gmd:hierarchyLevel/*/@codeListValue, 'dataset') or contains(../gmd:hierarchyLevel/*/@codeListValue, 'series')) and count(*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency) = 1) or (contains(../gmd:hierarchyLevel/*/@codeListValue, 'service'))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Frequency of update is mandatory for datasets and series. One must be provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M68"/></axsl:template><axsl:template match="text()" priority="-1" mode="M68"/><axsl:template match="@*|node()" priority="-2" mode="M68"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M68"/></axsl:template>

<!--PATTERN MedinFrequencyOfUpdateInnerTextPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency" priority="1000" mode="M69"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:identificationInfo/*/gmd:resourceMaintenance/*/gmd:maintenanceAndUpdateFrequency"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="string-length(*/@codeListValue) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="string-length(*/@codeListValue) &gt; 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element should have a value.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M69"/></axsl:template><axsl:template match="text()" priority="-1" mode="M69"/><axsl:template match="@*|node()" priority="-2" mode="M69"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M69"/></axsl:template>

<!--PATTERN Element 25 - INSPIRE Conformity (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 25 - INSPIRE Conformity (C)</svrl:text><axsl:template match="text()" priority="-1" mode="M70"/><axsl:template match="@*|node()" priority="-2" mode="M70"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M70"/></axsl:template>

<!--PATTERN Element 25.1 - INSPIRE Degree of Conformity (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 25.1 - INSPIRE Degree of Conformity (C)</svrl:text><axsl:template match="text()" priority="-1" mode="M71"/><axsl:template match="@*|node()" priority="-2" mode="M71"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M71"/></axsl:template>

<!--PATTERN MedinDegreeOfConformityGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:pass" priority="1000" mode="M72"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:pass"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M72"/></axsl:template><axsl:template match="text()" priority="-1" mode="M72"/><axsl:template match="@*|node()" priority="-2" mode="M72"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M72"/></axsl:template>

<!--PATTERN MedinDegreeOfConformityExplanationGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:explanation" priority="1000" mode="M73"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:explanation"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M73"/></axsl:template><axsl:template match="text()" priority="-1" mode="M73"/><axsl:template match="@*|node()" priority="-2" mode="M73"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M73"/></axsl:template>

<!--PATTERN Element 25.2 - INSPIRE Specification (C)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 25.2 - INSPIRE Specification (C)</svrl:text><axsl:template match="text()" priority="-1" mode="M74"/><axsl:template match="@*|node()" priority="-2" mode="M74"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M74"/></axsl:template>

<!--PATTERN MedinSpecificationTitleGcoTypeTest-->


	<!--RULE -->
<axsl:template match="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/*/gmd:title" priority="1000" mode="M75"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/*/gmd:title"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M75"/></axsl:template><axsl:template match="text()" priority="-1" mode="M75"/><axsl:template match="@*|node()" priority="-2" mode="M75"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M75"/></axsl:template>

<!--PATTERN MedinSpecificationDateGcoTypeTest-->


	<!--RULE -->
<axsl:template match="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/*/gmd:date/*/gmd:date" priority="1000" mode="M76"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/*/gmd:date/*/gmd:date"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M76"/></axsl:template><axsl:template match="text()" priority="-1" mode="M76"/><axsl:template match="@*|node()" priority="-2" mode="M76"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M76"/></axsl:template>

<!--PATTERN MedinSpecificationDateTypeInnerTextTest-->


	<!--RULE -->
<axsl:template match="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/*/gmd:date/*/gmd:dateType" priority="1000" mode="M77"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/*/gmd:date/*/gmd:dateType"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="string-length(*/@codeListValue) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="string-length(*/@codeListValue) &gt; 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element should have a value.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M77"/></axsl:template><axsl:template match="text()" priority="-1" mode="M77"/><axsl:template match="@*|node()" priority="-2" mode="M77"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M77"/></axsl:template>

<!--PATTERN Element 26 - Date of Update of Metadata (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 26 - Date of Update of Metadata (M)</svrl:text><axsl:template match="text()" priority="-1" mode="M78"/><axsl:template match="@*|node()" priority="-2" mode="M78"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M78"/></axsl:template>

<!--PATTERN MedinDateOfUpdateOfMetadataGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:dateStamp" priority="1000" mode="M79"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:dateStamp"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M79"/></axsl:template><axsl:template match="text()" priority="-1" mode="M79"/><axsl:template match="@*|node()" priority="-2" mode="M79"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M79"/></axsl:template>

<!--PATTERN Element 27 - Metadata Standard Name (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 27 - Metadata Standard Name (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M80"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:metadataStandardName) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:metadataStandardName) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Metadata standard name is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M80"/></axsl:template><axsl:template match="text()" priority="-1" mode="M80"/><axsl:template match="@*|node()" priority="-2" mode="M80"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M80"/></axsl:template>

<!--PATTERN MedinMetadataStandardNameInnerText-->


	<!--RULE -->
<axsl:template match="/*/gmd:metadataStandardName" priority="1000" mode="M81"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:metadataStandardName"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="string-length(gco:CharacterString) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="string-length(gco:CharacterString) &gt; 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element should have a value.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M81"/></axsl:template><axsl:template match="text()" priority="-1" mode="M81"/><axsl:template match="@*|node()" priority="-2" mode="M81"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M81"/></axsl:template>

<!--PATTERN Element 28 - Metadata Standard Version (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 28 - Metadata Standard Version (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M82"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:metadataStandardVersion) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:metadataStandardVersion) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Metadata standard version is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M82"/></axsl:template><axsl:template match="text()" priority="-1" mode="M82"/><axsl:template match="@*|node()" priority="-2" mode="M82"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M82"/></axsl:template>

<!--PATTERN MedinMetadataStandardVersionInnerText-->


	<!--RULE -->
<axsl:template match="/*/gmd:metadataStandardVersion" priority="1000" mode="M83"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:metadataStandardVersion"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="string-length(gco:CharacterString) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="string-length(gco:CharacterString) &gt; 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element should have a value.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M83"/></axsl:template><axsl:template match="text()" priority="-1" mode="M83"/><axsl:template match="@*|node()" priority="-2" mode="M83"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M83"/></axsl:template>

<!--PATTERN Element 29 - Metadata Language (M)-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element 29 - Metadata Language (M)</svrl:text>

	<!--RULE -->
<axsl:template match="/*" priority="1000" mode="M84"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:language) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:language) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        Metadata Language is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M84"/></axsl:template><axsl:template match="text()" priority="-1" mode="M84"/><axsl:template match="@*|node()" priority="-2" mode="M84"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M84"/></axsl:template>

<!--PATTERN MedinMetadataLanguageLanguagePattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:language" priority="1000" mode="M85"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:language"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(./gco:CharacterString = 'eng' or ./gco:CharacterString = 'cym' or ./gco:CharacterString = 'gle' or ./gco:CharacterString = 'gla' or ./gco:CharacterString = 'cor') or                    (./gmd:LanguageCode/@codeListValue='eng' or ./gmd:LanguageCode/@codeListValue='cym' or ./gmd:LanguageCode/@codeListValue='gle' or ./gmd:LanguageCode/@codeListValue='gla' or ./gmd:LanguageCode/@codeListValue='cor')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(./gco:CharacterString = 'eng' or ./gco:CharacterString = 'cym' or ./gco:CharacterString = 'gle' or ./gco:CharacterString = 'gla' or ./gco:CharacterString = 'cor') or (./gmd:LanguageCode/@codeListValue='eng' or ./gmd:LanguageCode/@codeListValue='cym' or ./gmd:LanguageCode/@codeListValue='gle' or ./gmd:LanguageCode/@codeListValue='gla' or ./gmd:LanguageCode/@codeListValue='cor')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> must be one of eng, cym, gle, gla or cor.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M85"/></axsl:template><axsl:template match="text()" priority="-1" mode="M85"/><axsl:template match="@*|node()" priority="-2" mode="M85"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M85"/></axsl:template>

<!--PATTERN MedinMetadataLanguageGcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="/*/gmd:language" priority="1000" mode="M86"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/*/gmd:language"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M86"/></axsl:template><axsl:template match="text()" priority="-1" mode="M86"/><axsl:template match="@*|node()" priority="-2" mode="M86"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M86"/></axsl:template></axsl:stylesheet>
