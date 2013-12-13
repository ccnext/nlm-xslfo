<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:pf="http://plos.org/namespace/function"
    xmlns:po="http://plos.org/namespace/plos-one"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="mml pf po xlink xs">

<!-- ============================================================= -->
<!--  MODULE:    PLOS ONE XSL-FO stylesheet                        -->
<!--  VERSION:   1.0                                               -->
<!--  DATE:      December 2012                                     -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--  SYSTEM:    PLoS                                              -->
<!--                                                               -->
<!--  PURPOSE:   Add @id to certain elements to make it easier     -->
<!--             to correlate FO and area trees.                   -->
<!--                                                               -->
<!--  PROCESSOR DEPENDENCIES:                                      -->
<!--             None: standard XSLT 2.0                           -->
<!--             Tested using Saxon 9.4 HE                         -->
<!--                                                               -->
<!--  COMPONENTS REQUIRED:                                         -->
<!--             1) This stylesheet                                -->
<!--             2) The module xhtml-tables-fo.xsl                 -->
<!--             If input contains OASIS tables, they must         -->
<!--             be converted into XHTML in a pre-process          -->
<!--                                                               -->
<!--  INPUT:     An XML document valid to the NLM/NCBI Journal     -->
<!--             Publishing 3.0 DTD as used in PLOS ONE.           -->
<!--                                                               -->
<!--  OUTPUT:    XSL-FO. Uses XSL-FO 1.1 features; tested with     -->
<!--             AntennaHouse 4.3 with MathML support.             -->
<!--                                                               -->
<!--  ORGANIZATION OF THIS STYLESHEET:                             -->
<!--             TOP-LEVEL PARAMETERS                              -->
<!--             KEYS FOR ID AND RID                               -->
<!--             TYPOGRAPHIC SPECIFICATIONS                        -->
<!--               Attribute sets                                  -->
<!--             TOP-LEVEL TEMPLATES                               -->
<!--             METADATA PROCESSING                               -->
<!--               Named templates for metadata processing         -->
<!--             DEFAULT TEMPLATES (mostly in no mode)             -->
<!--               Titles                                          -->
<!--               Figures, lists and block-level objects          -->
<!--               Tables                                          -->
<!--               Inline elements                                 -->
<!--               Back matter                                     -->
<!--               Floats group                                    -->
<!--               Citation content                                -->
<!--               Footnotes and cross-references                  -->
<!--               Mode "format"                                   -->
<!--               Mode "label"                                    -->
<!--               Mode "label-text"                               -->
<!--               MathML handling                                 -->
<!--               Writing a name                                  -->
<!--             UTILITY TEMPLATES                                 -->
<!--               Stylesheeet diagnostics                         -->
<!--               Date formatting templates                       -->
<!--               ID assignment                                   -->
<!--             END OF STYLESHEET                                 -->
<!--                                                               -->
<!--  CREATED FOR:                                                 -->
<!--             Public Library of Science (PLoS)                  -->
<!--                                                               -->
<!--  CREATED BY:                                                  -->
<!--             Mentea                                            -->
<!--             13 Kelly's Bay Beach                              -->
<!--             Skerries, Co. Dublin                              -->
<!--             Ireland                                           -->
<!--             http://www.mentea.net                             -->
<!--             info@mentea.net                                   -->
<!--                                                               -->
<!--             Based on JATS XSL-FO preview stylesheet by        -->
<!--             Mulberry Technologies, Inc.                       -->
<!--                                                               -->

<!-- ============================================================= -->
<!--             CHANGE HISTORY                                    -->
<!-- =============================================================


    ============================================================= -->

<!-- ============================================================= -->
<!-- IMPORTS                                                       -->
<!-- ============================================================= -->

<xsl:param name="idable" select="'tr'" as="xs:string" />

<xsl:variable name="idable-seq"
              select="tokenize($idable, '\s+')"
              as="xs:string*" />

<xsl:template match="*[local-name() = $idable-seq]">
  <xsl:copy>
    <xsl:apply-templates select="@* except @id"/>
    <xsl:call-template name="assign-id"/>
    <xsl:apply-templates select="node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- ============================================================= -->
<!-- ID assignment                                                 -->
<!-- ============================================================= -->
<!-- An id can be derived for any element. If an @id is given,
     it is presumed unique and copied. If not, one is generated.   -->

<xsl:template name="assign-id" as="attribute(id)">
  <xsl:param name="node" select="."/>
  <xsl:param name="prefix" as="xs:string?" tunnel="yes" />
  <!--<xsl:message select="concat(local-name($node), ':', @prefix, ':', pf:get-id($node))" />-->
  <xsl:attribute name="id">
    <xsl:value-of select="$prefix" />
    <xsl:sequence select="pf:get-id($node)" />
  </xsl:attribute>
</xsl:template>

<xsl:function name="pf:get-id" as="xs:string">
  <xsl:param name="node" as="node()" />
  <xsl:value-of>
    <xsl:apply-templates select="$node" mode="id"/>
  </xsl:value-of>
</xsl:function>

<xsl:template match="*" mode="id">
  <xsl:value-of select="@id"/>
  <xsl:if test="empty(@id)">
    <xsl:value-of select="generate-id(.)"/>
  </xsl:if>
</xsl:template>


<xsl:template match="article | sub-article | response" mode="id">
  <xsl:value-of select="@id"/>
  <xsl:if test="empty(@id)">
    <xsl:value-of select="local-name()"/>
    <xsl:number from="article" level="multiple"
      count="article | sub-article | response" format="1-1"/>
  </xsl:if>
</xsl:template>


<!-- ============================================================= -->
<!-- END OF STYLESHEET                                             -->
<!-- ============================================================= -->

</xsl:stylesheet>
