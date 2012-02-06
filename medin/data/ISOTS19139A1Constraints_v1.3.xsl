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
<axsl:template match="/"><svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" title="ISO / TS 19139 Table A.1 Constraints" schemaVersion="1.3"><axsl:comment><axsl:value-of select="$archiveDirParameter"/>   
		 <axsl:value-of select="$archiveNameParameter"/>  
		 <axsl:value-of select="$fileNameParameter"/>  
		 <axsl:value-of select="$fileDirParameter"/></axsl:comment><svrl:text>
    This Schematron schema is designed to test the constraints presented in ISO / TS 19139 Table A.1.
  </svrl:text><svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml/3.2" prefix="gml"/><svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/><svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/><svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmx" prefix="gmx"/><svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/><svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/srv" prefix="srv"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 1</axsl:attribute><svrl:text>language: documented if not defined by the encoding standard</svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M8"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 2</axsl:attribute><svrl:text>
      characterSet: documented if ISO/IEC 10646 not used and not defined by the encoding standard
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M9"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 3</axsl:attribute><svrl:text>
      characterSet: documented if ISO/IEC 10646 is not used
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M10"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 4</axsl:attribute><svrl:text>
      MD_Metadata.hierarchyLevel = 'dataset' implies count (extent.geographicElement.EX_GeograpicBoundingBox) +
      count(extent.geographicElement.EX_GeographicDescription) &gt;= 1
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M11"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 5</axsl:attribute><svrl:text>
      MD_Metadata.hierarchyLevel notEqual 'dataset' implies topicCategory is not mandatory
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M12"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 6</axsl:attribute><svrl:text>
      Either 'aggregateDataSetName' or 'aggregateDataSetIdentifier' must be documented
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M13"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 7</axsl:attribute><svrl:text>
      otherConstraints: documented if accessConstraints = 'otherRestrictions'
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M14"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW7_InnerTextPattern</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW7_InnerTextPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M15"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 8</axsl:attribute><svrl:text>
      'report' or 'lineage' role is mandatory if scope.DQ_Scope.level = 'dataset'
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M16"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 9</axsl:attribute><svrl:text>
      'levelDescription' is mandatory if 'level' notEqual 'dataset' or 'series'
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M17"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 10</axsl:attribute><svrl:text>
      If (count(source) + count(processStep) = 0) and (DQ_DataQuality.scope.level = 'dataset'
      or 'series') then statement is mandatory
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M18"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Rows 11 and 12</axsl:attribute><svrl:text>
      Row 11 - 'source' role is mandatory if LI_Lineage.statement and 'processStep' role are not documented
    </svrl:text><svrl:text>
      Row 12 - 'processStep' role is mandatory if LI_Lineage.statement and 'source' role are not documented
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M19"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 13</axsl:attribute><svrl:text>
      'description' is mandatory if 'sourceExtent' is not documented
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M20"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 14</axsl:attribute><svrl:text>
      'sourceExtent' is mandatory if 'description' is not documented
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M21"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 15</axsl:attribute><svrl:text>
      'checkPointDescription' is mandatory if 'checkPointAvailability' = 1
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M22"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 16</axsl:attribute><svrl:text>
      'units' is mandatory if 'maxValue' or 'minValue' are provided
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M23"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 17</axsl:attribute><svrl:text>
      'densityUnits' is mandatory if 'density' is provided
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M24"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 18</axsl:attribute><svrl:text>
      count(distributionFormat + distributorFormat) &gt; 0
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M25"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 19</axsl:attribute><svrl:text>
      if 'dataType' notEqual 'codelist', 'enumeration' or 'codeListElement' then 'obligation',
      'maximumOccurrence' and 'domainValue' are mandatory
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M26"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW19_InnerTextPattern_Obligation</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW19_InnerTextPattern_Obligation</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M27"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW19_GcoTypeTestPattern_MaximumOccurrence</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW19_GcoTypeTestPattern_MaximumOccurrence</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M28"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW19_GcoTypeTestPattern_DomainValue</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW19_GcoTypeTestPattern_DomainValue</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M29"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 20</axsl:attribute><svrl:text>
      if 'obligation' = 'conditional' then 'condition' is mandatory
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M30"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW20_GcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW20_GcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M31"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 21</axsl:attribute><svrl:text>
      if 'dataType' = 'codeListElement' then 'domainCode' is mandatory
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M32"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW21_GcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW21_GcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M33"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 22</axsl:attribute><svrl:text>
      if 'dataType' notEqual 'codeListElement' then 'shortName' is mandatory
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M34"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW22_GcoTypeTestPattern</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW22_GcoTypeTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M35"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 23</axsl:attribute><svrl:text>
      count(description + geographicElement + temporalElement + verticalElement) &gt; 0
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M36"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 24</axsl:attribute><svrl:text>
      count(individualName + organisationName + positionName) &gt; 0
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M37"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 25</axsl:attribute><svrl:text>
      Distance: the UoM element of the Distance Type must be instantiated using the UomLength_PropertyType
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M38"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW25_GcoUomTestPattern</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW25_GcoUomTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M39"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 26</axsl:attribute><svrl:text>
      Length: The UoM element of the Length Type must be instantiated using the UomLength_PropertyType
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M40"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW26_GcoUomTestPattern</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW26_GcoUomTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M41"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 27</axsl:attribute><svrl:text>
      Scale: The UoM element of the Scale Type must be instantiated using the UomScale_PropertyType
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M42"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW27_GcoUomTestPattern</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW27_GcoUomTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M43"/><svrl:active-pattern><axsl:attribute name="name">ISO / TS 19139 Table A.1 Row 28</axsl:attribute><svrl:text>
      Angle: The UoM element of the Angle Type must be instantiated using the UomAngle_PropertyType
    </svrl:text><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M44"/><svrl:active-pattern><axsl:attribute name="id">ISO19139A1_ROW28_GcoUomTestPattern</axsl:attribute><axsl:attribute name="name">ISO19139A1_ROW28_GcoUomTestPattern</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M45"/><svrl:active-pattern><axsl:attribute name="name">Element Values or Nil Reason Attributes</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M46"/></svrl:schematron-output></axsl:template>

<!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Constraints</svrl:text>

<!--PATTERN ISO / TS 19139 Table A.1 Row 1-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 1</svrl:text><axsl:template match="text()" priority="-1" mode="M8"/><axsl:template match="@*|node()" priority="-2" mode="M8"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 2-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 2</svrl:text><axsl:template match="text()" priority="-1" mode="M9"/><axsl:template match="@*|node()" priority="-2" mode="M9"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 3-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 3</svrl:text><axsl:template match="text()" priority="-1" mode="M10"/><axsl:template match="@*|node()" priority="-2" mode="M10"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 4-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 4</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_Metadata | //*[@gco:isoType = 'gmd:MD_Metadata']" priority="1000" mode="M11"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata | //*[@gco:isoType = 'gmd:MD_Metadata']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((not(gmd:hierarchyLevel) or gmd:hierarchyLevel/*/@codeListValue='dataset')                    and (count(gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox) +                    count(gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicDescription)) &gt;= 1) or                   (gmd:hierarchyLevel/*/@codeListValue != 'dataset')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((not(gmd:hierarchyLevel) or gmd:hierarchyLevel/*/@codeListValue='dataset') and (count(gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox) + count(gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicDescription)) &gt;= 1) or (gmd:hierarchyLevel/*/@codeListValue != 'dataset')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_DataIdentification: MD_Metadata.hierarchyLevel = 'dataset' implies count (extent.geographicElement.EX_GeographicBoundingBox) +
        count (extent.geographicElement.EX_GeographicDescription) &gt;=1
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/></axsl:template><axsl:template match="text()" priority="-1" mode="M11"/><axsl:template match="@*|node()" priority="-2" mode="M11"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 5-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 5</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_Metadata | //*[@gco:isoType = 'gmd:MD_Metadata']" priority="1000" mode="M12"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata | //*[@gco:isoType = 'gmd:MD_Metadata']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(not(gmd:hierarchyLevel) or (gmd:hierarchyLevel/*/@codeListValue = 'dataset'))                    and (gmd:identificationInfo/*/gmd:topicCategory) or                   gmd:hierarchyLevel/*/@codeListValue != 'dataset'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(not(gmd:hierarchyLevel) or (gmd:hierarchyLevel/*/@codeListValue = 'dataset')) and (gmd:identificationInfo/*/gmd:topicCategory) or gmd:hierarchyLevel/*/@codeListValue != 'dataset'"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_DataIdentification: The topicCategory element is mandatory if hierarchyLevel is dataset.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/></axsl:template><axsl:template match="text()" priority="-1" mode="M12"/><axsl:template match="@*|node()" priority="-2" mode="M12"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 6-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 6</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_AggregateInformation | //*[@gco:isoType = 'gmd:MD_AggregateInformation']" priority="1000" mode="M13"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_AggregateInformation | //*[@gco:isoType = 'gmd:MD_AggregateInformation']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="gmd:aggregateDataSetName or gmd:aggregateDataSetIdentifier"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="gmd:aggregateDataSetName or gmd:aggregateDataSetIdentifier"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_AggregateInformation: Either 'aggregateDataSetName' or 'aggregateDataSetIdentifier' must be documented.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/></axsl:template><axsl:template match="text()" priority="-1" mode="M13"/><axsl:template match="@*|node()" priority="-2" mode="M13"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 7-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 7</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_LegalConstraints | //*[@gco:isoType='gmd:MD_LegalConstraints']" priority="1000" mode="M14"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_LegalConstraints | //*[@gco:isoType='gmd:MD_LegalConstraints']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(count(gmd:accessConstraints/*[@codeListValue = 'otherRestrictions']) &gt;= 1 and                    gmd:otherConstraints) or                    count(gmd:accessConstraints/*[@codeListValue = 'otherRestrictions']) = 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(count(gmd:accessConstraints/*[@codeListValue = 'otherRestrictions']) &gt;= 1 and gmd:otherConstraints) or count(gmd:accessConstraints/*[@codeListValue = 'otherRestrictions']) = 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_LegalConstraints: otherConstraints: documented if accessConstraints = 'otherRestrictions'.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(count(gmd:useConstraints/*[@codeListValue = 'otherRestrictions']) &gt;= 1 and                    gmd:otherConstraints) or                   count(gmd:useConstraints/*[@codeListValue = 'otherRestrictions']) = 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(count(gmd:useConstraints/*[@codeListValue = 'otherRestrictions']) &gt;= 1 and gmd:otherConstraints) or count(gmd:useConstraints/*[@codeListValue = 'otherRestrictions']) = 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_LegalConstraints: otherConstraints: documented if useConstraints = 'otherRestrictions'
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/></axsl:template><axsl:template match="text()" priority="-1" mode="M14"/><axsl:template match="@*|node()" priority="-2" mode="M14"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/></axsl:template>

<!--PATTERN ISO19139A1_ROW7_InnerTextPattern-->


	<!--RULE -->
<axsl:template match="//gmd:MD_LegalConstraints | //*[@gco:isoType='gmd:MD_LegalConstraints']" priority="1000" mode="M15"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_LegalConstraints | //*[@gco:isoType='gmd:MD_LegalConstraints']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(count(gmd:otherConstraints) = 0) or                    (string-length(normalize-space(gmd:otherConstraints)) &gt; 0) or                   (gmd:otherConstraints/@gco:nilReason = 'inapplicable' or                   gmd:otherConstraints/@gco:nilReason = 'missing' or                    gmd:otherConstraints/@gco:nilReason = 'template' or                   gmd:otherConstraints/@gco:nilReason = 'unknown' or                   gmd:otherConstraints/@gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(count(gmd:otherConstraints) = 0) or (string-length(normalize-space(gmd:otherConstraints)) &gt; 0) or (gmd:otherConstraints/@gco:nilReason = 'inapplicable' or gmd:otherConstraints/@gco:nilReason = 'missing' or gmd:otherConstraints/@gco:nilReason = 'template' or gmd:otherConstraints/@gco:nilReason = 'unknown' or gmd:otherConstraints/@gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The '<axsl:text/><axsl:value-of select="name(gmd:otherConstraints)"/><axsl:text/>' element should have a value.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/></axsl:template><axsl:template match="text()" priority="-1" mode="M15"/><axsl:template match="@*|node()" priority="-2" mode="M15"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 8-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 8</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:DQ_DataQuality | //*[@gco:isoType = 'gmd:DQ_DataQuality']" priority="1000" mode="M16"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:DQ_DataQuality | //*[@gco:isoType = 'gmd:DQ_DataQuality']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(gmd:scope/*/gmd:level/*/@codeListValue = 'dataset') and ((count(gmd:report) + count(gmd:lineage)) &gt; 0) or                   (gmd:scope/*/gmd:level/*/@codeListValue != 'dataset')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(gmd:scope/*/gmd:level/*/@codeListValue = 'dataset') and ((count(gmd:report) + count(gmd:lineage)) &gt; 0) or (gmd:scope/*/gmd:level/*/@codeListValue != 'dataset')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        DQ_DataQuality: 'report' or 'lineage' role is mandatory if scope.DQ_Scope.level = 'dataset'
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M16"/></axsl:template><axsl:template match="text()" priority="-1" mode="M16"/><axsl:template match="@*|node()" priority="-2" mode="M16"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M16"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 9-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 9</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:DQ_Scope | //*[@gco:isoType = 'gmd:DQ_Scope']" priority="1000" mode="M17"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:DQ_Scope | //*[@gco:isoType = 'gmd:DQ_Scope']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="gmd:level/*/@codeListValue = 'dataset' or gmd:level/*/@codeListValue = 'series' or gmd:levelDescription"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="gmd:level/*/@codeListValue = 'dataset' or gmd:level/*/@codeListValue = 'series' or gmd:levelDescription"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        DQ_Scope: 'levelDescription' is mandatory if 'level' notEqual 'dataset' or 'series'.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M17"/></axsl:template><axsl:template match="text()" priority="-1" mode="M17"/><axsl:template match="@*|node()" priority="-2" mode="M17"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M17"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 10-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 10</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:LI_Lineage | //*[@gco:isoType = 'gmd:LI_Lineage']" priority="1000" mode="M18"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:LI_Lineage | //*[@gco:isoType = 'gmd:LI_Lineage']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((count(gmd:source) + count(gmd:processStep) = 0) and                   (../../gmd:scope/*/gmd:level/*/@codeListValue = 'dataset' or ../../gmd:scope/*/gmd:level/*/@codeListValue = 'series') and                   count(gmd:statement) = 1) or                    (../../gmd:scope/*/gmd:level/*/@codeListValue != 'dataset' or ../../gmd:scope/*/gmd:level/*/@codeListValue != 'series')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((count(gmd:source) + count(gmd:processStep) = 0) and (../../gmd:scope/*/gmd:level/*/@codeListValue = 'dataset' or ../../gmd:scope/*/gmd:level/*/@codeListValue = 'series') and count(gmd:statement) = 1) or (../../gmd:scope/*/gmd:level/*/@codeListValue != 'dataset' or ../../gmd:scope/*/gmd:level/*/@codeListValue != 'series')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        LI_Lineage: If (count(source) + count(processStep) = 0) and (DQ_DataQuality.scope.level = 'dataset'
        or 'series') then statement is mandatory. <axsl:text/><axsl:value-of select="count(gmd:statement)"/><axsl:text/>
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M18"/></axsl:template><axsl:template match="text()" priority="-1" mode="M18"/><axsl:template match="@*|node()" priority="-2" mode="M18"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M18"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Rows 11 and 12-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Rows 11 and 12</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:LI_Lineage | //*[@gco:isoType = 'gmd:LI_Lineage']" priority="1000" mode="M19"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:LI_Lineage | //*[@gco:isoType = 'gmd:LI_Lineage']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(not(gmd:statement) and not(gmd:processStep) and gmd:source) or                    (not(gmd:statement) and not(gmd:source) and gmd:processStep) or                   gmd:statement"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(not(gmd:statement) and not(gmd:processStep) and gmd:source) or (not(gmd:statement) and not(gmd:source) and gmd:processStep) or gmd:statement"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        LI_Lineage: 'source' role is mandatory if LI_Lineage.statement and 'processStep' role are not documented.
        LI_Lineage: 'processStep' role is mandatory if LI_Lineage.statement and 'source' role are not documented.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M19"/></axsl:template><axsl:template match="text()" priority="-1" mode="M19"/><axsl:template match="@*|node()" priority="-2" mode="M19"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M19"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 13-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 13</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:LI_Source | //*[@gco:isoType = 'gmd:LI_Source']" priority="1000" mode="M20"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:LI_Source | //*[@gco:isoType = 'gmd:LI_Source']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="gmd:sourceExtent or gmd:description"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="gmd:sourceExtent or gmd:description"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        LI_Source: 'description' is mandatory if 'sourceExtent' is not documented.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M20"/></axsl:template><axsl:template match="text()" priority="-1" mode="M20"/><axsl:template match="@*|node()" priority="-2" mode="M20"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M20"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 14-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 14</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:LI_Source | //*[@gco:isoType = 'gmd:LI_Source']" priority="1000" mode="M21"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:LI_Source | //*[@gco:isoType = 'gmd:LI_Source']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="gmd:sourceExtent or gmd:description"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="gmd:sourceExtent or gmd:description"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        LI_Source: 'sourceExtent' is mandatory if 'description' is not documented.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M21"/></axsl:template><axsl:template match="text()" priority="-1" mode="M21"/><axsl:template match="@*|node()" priority="-2" mode="M21"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M21"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 15-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 15</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_Georectified | //*[@gco:isoType = 'gmd:MD_Georectified']" priority="1000" mode="M22"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Georectified | //*[@gco:isoType = 'gmd:MD_Georectified']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((gmd:checkPointAvailability/gco:Boolean = '1' or                    gmd:checkPointAvailability/gco:Boolean = 'true') and                   gmd:checkPointDescription) or gmd:checkPointAvailability/gco:Boolean = 0 or                   gmd:checkPointAvailability/gco:Boolean = 'false'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((gmd:checkPointAvailability/gco:Boolean = '1' or gmd:checkPointAvailability/gco:Boolean = 'true') and gmd:checkPointDescription) or gmd:checkPointAvailability/gco:Boolean = 0 or gmd:checkPointAvailability/gco:Boolean = 'false'"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_Georectified: 'checkPointDescription' is mandatory if 'checkPointAvailability' = 1
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M22"/></axsl:template><axsl:template match="text()" priority="-1" mode="M22"/><axsl:template match="@*|node()" priority="-2" mode="M22"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M22"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 16-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 16</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_Band | //*[@gco:isoType = 'gmd:MD_Band']" priority="1000" mode="M23"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Band | //*[@gco:isoType = 'gmd:MD_Band']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((gmd:maxValue or gmd:minValue) and gmd:units) or                    (not(gmd:maxValue) and not(gmd:minValue) and not(gmd:units))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((gmd:maxValue or gmd:minValue) and gmd:units) or (not(gmd:maxValue) and not(gmd:minValue) and not(gmd:units))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_Band: 'units' is mandatory if 'maxValue' or 'minValue' are provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M23"/></axsl:template><axsl:template match="text()" priority="-1" mode="M23"/><axsl:template match="@*|node()" priority="-2" mode="M23"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M23"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 17-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 17</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_Medium | //*[@gco:isoType = 'gmd:MD_Medium']" priority="1000" mode="M24"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Medium | //*[@gco:isoType = 'gmd:MD_Medium']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(gmd:density and gmd:densityUnits) or (not(gmd:density) and not(gmd:densityUnits))"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(gmd:density and gmd:densityUnits) or (not(gmd:density) and not(gmd:densityUnits))"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_Medium: 'densityUnits' is mandatory if 'density' is provided.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M24"/></axsl:template><axsl:template match="text()" priority="-1" mode="M24"/><axsl:template match="@*|node()" priority="-2" mode="M24"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M24"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 18-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 18</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_Distribution | //*[@gco:isoType = 'gmd:MD_Distribution']" priority="1000" mode="M25"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Distribution | //*[@gco:isoType = 'gmd:MD_Distribution']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:distributionFormat) &gt; 0 or                    count(gmd:distributor/*/gmd:distributorFormat) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:distributionFormat) &gt; 0 or count(gmd:distributor/*/gmd:distributorFormat) &gt; 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_Distribution / MD_Format: count(distributionFormat + distributorFormat) &gt; 0.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M25"/></axsl:template><axsl:template match="text()" priority="-1" mode="M25"/><axsl:template match="@*|node()" priority="-2" mode="M25"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M25"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 19-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 19</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']" priority="1000" mode="M26"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(gmd:dataType/*/@codeListValue = 'codelist' or                    gmd:dataType/*/@codeListValue = 'enumeration' or                    gmd:dataType/*/@codeListValue = 'codelistElement') or                   gmd:obligation"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(gmd:dataType/*/@codeListValue = 'codelist' or gmd:dataType/*/@codeListValue = 'enumeration' or gmd:dataType/*/@codeListValue = 'codelistElement') or gmd:obligation"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_ExtendedElementInformation: if 'dataType' notEqual 'codelist', 
        'enumeration' or 'codelistElement' then 'obligation' is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(gmd:dataType/*/@codeListValue = 'codelist' or                    gmd:dataType/*/@codeListValue = 'enumeration' or                    gmd:dataType/*/@codeListValue = 'codelistElement') or                   gmd:maximumOccurrence"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(gmd:dataType/*/@codeListValue = 'codelist' or gmd:dataType/*/@codeListValue = 'enumeration' or gmd:dataType/*/@codeListValue = 'codelistElement') or gmd:maximumOccurrence"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_ExtendedElementInformation: if 'dataType' notEqual 'codelist', 
        'enumeration' or 'codelistElement' then 'maximumOccurence' is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(gmd:dataType/*/@codeListValue = 'codelist' or                    gmd:dataType/*/@codeListValue = 'enumeration' or                    gmd:dataType/*/@codeListValue = 'codelistElement') or                   gmd:domainValue"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(gmd:dataType/*/@codeListValue = 'codelist' or gmd:dataType/*/@codeListValue = 'enumeration' or gmd:dataType/*/@codeListValue = 'codelistElement') or gmd:domainValue"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_ExtendedElementInformation: if 'dataType' notEqual 'codelist', 
        'enumeration' or 'codelistElement' then 'domainValue' is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M26"/></axsl:template><axsl:template match="text()" priority="-1" mode="M26"/><axsl:template match="@*|node()" priority="-2" mode="M26"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M26"/></axsl:template>

<!--PATTERN ISO19139A1_ROW19_InnerTextPattern_Obligation-->


	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']" priority="1000" mode="M27"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(count(gmd:obligation) = 0) or                    (string-length(normalize-space(gmd:obligation)) &gt; 0) or                   (gmd:obligation/@gco:nilReason = 'inapplicable' or                   gmd:obligation/@gco:nilReason = 'missing' or                    gmd:obligation/@gco:nilReason = 'template' or                   gmd:obligation/@gco:nilReason = 'unknown' or                   gmd:obligation/@gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(count(gmd:obligation) = 0) or (string-length(normalize-space(gmd:obligation)) &gt; 0) or (gmd:obligation/@gco:nilReason = 'inapplicable' or gmd:obligation/@gco:nilReason = 'missing' or gmd:obligation/@gco:nilReason = 'template' or gmd:obligation/@gco:nilReason = 'unknown' or gmd:obligation/@gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The '<axsl:text/><axsl:value-of select="name(gmd:obligation)"/><axsl:text/>' element should have a value.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M27"/></axsl:template><axsl:template match="text()" priority="-1" mode="M27"/><axsl:template match="@*|node()" priority="-2" mode="M27"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M27"/></axsl:template>

<!--PATTERN ISO19139A1_ROW19_GcoTypeTestPattern_MaximumOccurrence-->


	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation/gmd:maximumOccurrence |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:maximumOccurrence" priority="1000" mode="M28"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation/gmd:maximumOccurrence |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:maximumOccurrence"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M28"/></axsl:template><axsl:template match="text()" priority="-1" mode="M28"/><axsl:template match="@*|node()" priority="-2" mode="M28"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M28"/></axsl:template>

<!--PATTERN ISO19139A1_ROW19_GcoTypeTestPattern_DomainValue-->


	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation/gmd:domainValue |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:domainValue" priority="1000" mode="M29"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation/gmd:domainValue |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:domainValue"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M29"/></axsl:template><axsl:template match="text()" priority="-1" mode="M29"/><axsl:template match="@*|node()" priority="-2" mode="M29"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M29"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 20-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 20</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']" priority="1000" mode="M30"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((gmd:obligation/*/@codeListValue = 'conditional') and gmd:condition) or                   gmd:obligation/*/@codeListValue != 'conditional' or not(gmd:obligation)"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((gmd:obligation/*/@codeListValue = 'conditional') and gmd:condition) or gmd:obligation/*/@codeListValue != 'conditional' or not(gmd:obligation)"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_ExtendedElementInformation: if 'obligation' = 'conditional' then 'condition' is mandatory
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M30"/></axsl:template><axsl:template match="text()" priority="-1" mode="M30"/><axsl:template match="@*|node()" priority="-2" mode="M30"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M30"/></axsl:template>

<!--PATTERN ISO19139A1_ROW20_GcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation/gmd:condition |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:condition" priority="1000" mode="M31"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation/gmd:condition |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:condition"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M31"/></axsl:template><axsl:template match="text()" priority="-1" mode="M31"/><axsl:template match="@*|node()" priority="-2" mode="M31"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M31"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 21-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 21</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']" priority="1000" mode="M32"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((gmd:dataType/*/@codeListValue = 'codelistElement') and gmd:domainCode) or                   gmd:dataType/*/@codeListValue != 'codelistElement'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((gmd:dataType/*/@codeListValue = 'codelistElement') and gmd:domainCode) or gmd:dataType/*/@codeListValue != 'codelistElement'"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_ExtendedElementInformation: if 'dataType' = 'codeListElement' then 'domainCode' is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M32"/></axsl:template><axsl:template match="text()" priority="-1" mode="M32"/><axsl:template match="@*|node()" priority="-2" mode="M32"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M32"/></axsl:template>

<!--PATTERN ISO19139A1_ROW21_GcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation/gmd:domainCode |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:domainCode" priority="1000" mode="M33"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation/gmd:domainCode |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:domainCode"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M33"/></axsl:template><axsl:template match="text()" priority="-1" mode="M33"/><axsl:template match="@*|node()" priority="-2" mode="M33"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M33"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 22-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 22</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']" priority="1000" mode="M34"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation | //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="((gmd:dataType/*/@codeListValue != 'codelistElement') and gmd:shortName) or                   gmd:dataType/*/@codeListValue = 'codelistElement'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="((gmd:dataType/*/@codeListValue != 'codelistElement') and gmd:shortName) or gmd:dataType/*/@codeListValue = 'codelistElement'"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        MD_ExtendedElementInformation: if 'dataType' notEqual 'codeListElement' then 'shortName' is mandatory.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M34"/></axsl:template><axsl:template match="text()" priority="-1" mode="M34"/><axsl:template match="@*|node()" priority="-2" mode="M34"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M34"/></axsl:template>

<!--PATTERN ISO19139A1_ROW22_GcoTypeTestPattern-->


	<!--RULE -->
<axsl:template match="//gmd:MD_ExtendedElementInformation/gmd:shortName |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:shortName" priority="1000" mode="M35"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_ExtendedElementInformation/gmd:shortName |                 //*[@gco:isoType = 'gmd:MD_ExtendedElementInformation']/gmd:shortName"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(string-length(.) &gt; 0) or                    (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld')"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(string-length(.) &gt; 0) or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld')"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The <axsl:text/><axsl:value-of select="name(.)"/><axsl:text/> element must have a value or a Nil Reason.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M35"/></axsl:template><axsl:template match="text()" priority="-1" mode="M35"/><axsl:template match="@*|node()" priority="-2" mode="M35"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M35"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 23-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 23</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:EX_Extent | //*[@gco:isoType = 'gmd:EX_Extent']" priority="1000" mode="M36"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:EX_Extent | //*[@gco:isoType = 'gmd:EX_Extent']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:description) + count(gmd:geographicElement) +                    count(gmd:temporalElement) + count(gmd:verticalElement) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:description) + count(gmd:geographicElement) + count(gmd:temporalElement) + count(gmd:verticalElement) &gt; 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        EX_Extent: count(description + geographicElement + temporalExtent + verticalElement) &gt; 0
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M36"/></axsl:template><axsl:template match="text()" priority="-1" mode="M36"/><axsl:template match="@*|node()" priority="-2" mode="M36"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M36"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 24-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 24</svrl:text>

	<!--RULE -->
<axsl:template match="//gmd:CI_ResponsibleParty | //*[@gco:isoType = 'gmd:CI_ResponsibleParty']" priority="1000" mode="M37"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:CI_ResponsibleParty | //*[@gco:isoType = 'gmd:CI_ResponsibleParty']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(gmd:individualName) + count(gmd:organisationName) + count(gmd:positionName) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(gmd:individualName) + count(gmd:organisationName) + count(gmd:positionName) &gt; 0"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        count(individualName + organisationName + positionName) &gt; 0
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M37"/></axsl:template><axsl:template match="text()" priority="-1" mode="M37"/><axsl:template match="@*|node()" priority="-2" mode="M37"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M37"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 25-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 25</svrl:text><axsl:template match="text()" priority="-1" mode="M38"/><axsl:template match="@*|node()" priority="-2" mode="M38"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M38"/></axsl:template>

<!--PATTERN ISO19139A1_ROW25_GcoUomTestPattern-->


	<!--RULE -->
<axsl:template match="//gco:Distance" priority="1000" mode="M39"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gco:Distance"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(./@uom) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(./@uom) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The '<axsl:text/><axsl:value-of select="name(../..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(.)"/><axsl:text/>' element must have a uom attribute.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M39"/></axsl:template><axsl:template match="text()" priority="-1" mode="M39"/><axsl:template match="@*|node()" priority="-2" mode="M39"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M39"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 26-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 26</svrl:text><axsl:template match="text()" priority="-1" mode="M40"/><axsl:template match="@*|node()" priority="-2" mode="M40"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M40"/></axsl:template>

<!--PATTERN ISO19139A1_ROW26_GcoUomTestPattern-->


	<!--RULE -->
<axsl:template match="//gco:Length" priority="1000" mode="M41"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gco:Length"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(./@uom) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(./@uom) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The '<axsl:text/><axsl:value-of select="name(../..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(.)"/><axsl:text/>' element must have a uom attribute.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M41"/></axsl:template><axsl:template match="text()" priority="-1" mode="M41"/><axsl:template match="@*|node()" priority="-2" mode="M41"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M41"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 27-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 27</svrl:text><axsl:template match="text()" priority="-1" mode="M42"/><axsl:template match="@*|node()" priority="-2" mode="M42"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M42"/></axsl:template>

<!--PATTERN ISO19139A1_ROW27_GcoUomTestPattern-->


	<!--RULE -->
<axsl:template match="//gco:Scale" priority="1000" mode="M43"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gco:Scale"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(./@uom) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(./@uom) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The '<axsl:text/><axsl:value-of select="name(../..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(.)"/><axsl:text/>' element must have a uom attribute.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M43"/></axsl:template><axsl:template match="text()" priority="-1" mode="M43"/><axsl:template match="@*|node()" priority="-2" mode="M43"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M43"/></axsl:template>

<!--PATTERN ISO / TS 19139 Table A.1 Row 28-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">ISO / TS 19139 Table A.1 Row 28</svrl:text><axsl:template match="text()" priority="-1" mode="M44"/><axsl:template match="@*|node()" priority="-2" mode="M44"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M44"/></axsl:template>

<!--PATTERN ISO19139A1_ROW28_GcoUomTestPattern-->


	<!--RULE -->
<axsl:template match="//gco:Angle" priority="1000" mode="M45"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gco:Angle"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(./@uom) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(./@uom) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The '<axsl:text/><axsl:value-of select="name(../..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(.)"/><axsl:text/>' element must have a uom attribute.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M45"/></axsl:template><axsl:template match="text()" priority="-1" mode="M45"/><axsl:template match="@*|node()" priority="-2" mode="M45"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M45"/></axsl:template>

<!--PATTERN Element Values or Nil Reason Attributes-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron">Element Values or Nil Reason Attributes</svrl:text>

	<!--RULE -->
<axsl:template match="//*" priority="1000" mode="M46"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//*"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(*) &gt; 0 or                    namespace-uri() = 'http://www.isotc211.org/2005/gco' or                   namespace-uri() = 'http://www.isotc211.org/2005/gmx' or                   namespace-uri() = 'http://www.opengis.net/gml/3.2' or                   namespace-uri() = 'http://www.opengis.net/gml' or                   @codeList or                   @codeListValue or                   local-name() = 'MD_TopicCategoryCode' or                   local-name() = 'MD_PixelOrientationCode' or                   local-name() = 'URL' or                   (@gco:nilReason = 'inapplicable' or                   @gco:nilReason = 'missing' or                    @gco:nilReason = 'template' or                   @gco:nilReason = 'unknown' or                   @gco:nilReason = 'withheld') or                    @xlink:href"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(*) &gt; 0 or namespace-uri() = 'http://www.isotc211.org/2005/gco' or namespace-uri() = 'http://www.isotc211.org/2005/gmx' or namespace-uri() = 'http://www.opengis.net/gml/3.2' or namespace-uri() = 'http://www.opengis.net/gml' or @codeList or @codeListValue or local-name() = 'MD_TopicCategoryCode' or local-name() = 'MD_PixelOrientationCode' or local-name() = 'URL' or (@gco:nilReason = 'inapplicable' or @gco:nilReason = 'missing' or @gco:nilReason = 'template' or @gco:nilReason = 'unknown' or @gco:nilReason = 'withheld') or @xlink:href"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The '<axsl:text/><axsl:value-of select="name(.)"/><axsl:text/>' element has no child elements.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="(namespace-uri() = 'http://www.isotc211.org/2005/gco' and string-length() &gt; 0) or                   namespace-uri() != 'http://www.isotc211.org/2005/gco'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="(namespace-uri() = 'http://www.isotc211.org/2005/gco' and string-length() &gt; 0) or namespace-uri() != 'http://www.isotc211.org/2005/gco'"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>
        The '<axsl:text/><axsl:value-of select="name(../..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(..)"/><axsl:text/>/<axsl:text/><axsl:value-of select="name(.)"/><axsl:text/>' gco element has no value.
      </svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M46"/></axsl:template><axsl:template match="text()" priority="-1" mode="M46"/><axsl:template match="@*|node()" priority="-2" mode="M46"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M46"/></axsl:template></axsl:stylesheet>
