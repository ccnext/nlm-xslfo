<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:aat="http://www.antennahouse.com/names/XSL/AreaTree"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">

<!-- ============================================================= -->
<!--  MODULE:    PLOS ONE fo:page-sequence splitter stylesheet     -->
<!--  VERSION:   1.0                                               -->
<!--  DATE:      July 2013                                         -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--  SYSTEM:    PLOS                                              -->
<!--                                                               -->
<!--  PURPOSE:   Splits FO into multiple fo:page-sequence when     -->
<!--             tables or figures would otherwise appear after    -->
<!--             the 'Supplementary Information',                  -->
<!--             'Acknowledgemnts', or 'References' sections.      -->
<!--                                                               -->
<!--  PROCESSOR DEPENDENCIES:                                      -->
<!--             None: standard XSLT 2.0                           -->
<!--             Tested using Saxon 9.4 HE                         -->
<!--                                                               -->
<!--  COMPONENTS REQUIRED:                                         -->
<!--             1) This stylesheet                                -->
<!--             2) The module size-chooser.xsl and the modules    -->
<!--                that it requires                               -->
<!--                                                               -->
<!--  INPUT:     An XML document valid to the NLM/NCBI Journal     -->
<!--             Publishing 3.0 DTD as used in PLOS ONE.           -->
<!--                                                               -->
<!--  OUTPUT:    XSL-FO. Uses XSL-FO 1.1 features; tested with     -->
<!--             AntennaHouse 6.1                                  -->
<!--                                                               -->
<!--  ORGANIZATION OF THIS STYLESHEET:                             -->
<!--             IMPORTS                                           -->
<!--             KEYS                                              -->
<!--             STYLESHEET PARAMETERS                             -->
<!--             GLOBAL VARIABLES                                  -->
<!--             TOP-LEVEL TEMPLATES                               -->
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
<!-- ============================================================= -->

<!-- ============================================================= -->
<!-- IMPORTS                                                       -->
<!-- ============================================================= -->

<xsl:import href="size-chooser.xsl" />


<!-- ============================================================= -->
<!-- KEYS                                                          -->
<!-- ============================================================= -->

<!-- 'aat:AbsoluteFloatReferenceArea' elements in area tree XML. -->
<xsl:key name="floats"
         match="aat:AbsoluteFloatArea"
         use="true()" />

<xsl:key
    name="supplementary-material"
    match='aat:BlockArea[contains(@role, "supplementary-material")]
                        [@is-first eq "true"]'
    use="true()" />

<xsl:key
    name="author-contributions"
    match='aat:BlockArea[contains(@role, "author-contributions")]
                        [@is-first eq "true"]'
    use="true()" />

<xsl:key
    name="references"
    match='aat:BlockArea[contains(@role, "references")]
                        [@is-first eq "true"]'
    use="true()" />


<!-- ============================================================= -->
<!-- STYLESHEET PARAMETERS                                         -->
<!-- ============================================================= -->

<xsl:param name="fo-area-tree-dir" select="'../at'" as="xs:string" />

<xsl:param name="fo-area-tree"
           select="concat($area-tree-dir,
                          '/',
                          replace(tokenize(base-uri(), '/')[last()],
                                  '.xml$',
                                  '-sizer.AT.xml'))"
           as="xs:string?" />


<!-- ============================================================= -->
<!-- GLOBAL VARIABLES                                              -->
<!-- ============================================================= -->

<!-- FO area tree as an XML document. -->
<xsl:variable
    name="fo-area-tree-doc"
    select="if (doc-available($fo-area-tree))
            then doc($fo-area-tree)
            else ()"
    as="document-node()?"/>


<!-- ============================================================= -->
<!-- TOP-LEVEL TEMPLATES                                           -->
<!-- ============================================================= -->

<xsl:template match="/">
  <xsl:message select="concat('debug: ', $debug)" />
  <xsl:message select="concat('fo-area-tree: ', $fo-area-tree)" />
  <xsl:variable
      name="first-supplementary-material"
      select="key('supplementary-material', true(), $fo-area-tree-doc)[1]"
      as="element(aat:BlockArea)?"/>
  <xsl:variable
      name="first-supplementary-material-page"
      select="$first-supplementary-material/
                ancestor::aat:PageViewportArea/
                  @abs-page-number"
      as="xs:integer?" />
  <xsl:message
      select="concat('First supplementary-material: ',
                     $first-supplementary-material-page)" />
  <xsl:variable
      name="first-author-contributions"
      select="key('author-contributions', true(), $fo-area-tree-doc)[1]"
      as="element(aat:BlockArea)?"/>
  <xsl:variable
      name="first-author-contributions-page"
      select="$first-author-contributions/
                ancestor::aat:PageViewportArea/
                  @abs-page-number"
      as="xs:integer?" />
  <xsl:message
      select="concat('First author-contributions: ',
                     $first-author-contributions-page)" />
  <xsl:variable
      name="first-references"
      select="key('references', true(), $fo-area-tree-doc)[1]"
      as="element(aat:BlockArea)?"/>
  <xsl:variable
      name="first-references-page"
      select="$first-references/
                ancestor::aat:PageViewportArea/
                  @abs-page-number"
      as="xs:integer?" />
  <xsl:message
      select="concat('First references: ',
                     $first-references-page)" />
  <xsl:variable
      name="last-float"
      select="key('floats', true(), $fo-area-tree-doc)[last()]"
      as="element(aat:AbsoluteFloatArea)?"/>
  <!--
  <xsl:for-each select="key('supplementary-material', true(), $fo-area-tree-doc)">
    <xsl:message select="string(@role)" />
  </xsl:for-each>
  -->
  <xsl:variable
      name="last-float-page"
      select="$last-float/
                ancestor::aat:PageViewportArea/
                  @abs-page-number"
      as="xs:integer?" />
  <xsl:message
      select="concat('Last float page: ',
                     $last-float-page)" />
  <xsl:for-each select="key('supplementary-material', true(), $fo-area-tree-doc)">
    <xsl:message select="concat('supplementary-material: ', string(@role))" />
  </xsl:for-each>
  <xsl:variable
      name="float-after-si-etc"
      select="exists($last-float-page) and
              ((exists($first-supplementary-material-page) and
                $last-float-page > $first-supplementary-material-page) or
               (exists($first-author-contributions-page) and
                $last-float-page > $first-author-contributions-page) or
               (exists($first-references-page) and
                $last-float-page > $first-references-page))"
               
      as="xs:boolean" />
  <xsl:message
      select="concat('float-after-si-etc: ', $float-after-si-etc)" />
  <xsl:apply-imports>
    <xsl:with-param name="split" select="$float-after-si-etc" as="xs:boolean" tunnel="yes" />
  </xsl:apply-imports>
</xsl:template>

</xsl:stylesheet>
