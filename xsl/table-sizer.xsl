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
    exclude-result-prefixes="#all">

<!-- ============================================================= -->
<!--  MODULE:    PLOS ONE Table Sizer stylesheet                   -->
<!--  VERSION:   1.0                                               -->
<!--  DATE:      April 2013                                        -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--  SYSTEM:    PLoS                                              -->
<!--                                                               -->
<!--  PURPOSE:   Format tables so another stylesheet can make      -->
<!--             decisions based on their formatted sizes          -->
<!--                                                               -->
<!--  PROCESSOR DEPENDENCIES:                                      -->
<!--             None: standard XSLT 2.0                           -->
<!--             Tested using Saxon 9.4 HE                         -->
<!--                                                               -->
<!--  COMPONENTS REQUIRED:                                         -->
<!--             1) This stylesheet                                -->
<!--             2) The module plos-xslfo.xsl                      -->
<!--             3) The module xhtml-tables-fo.xsl                 -->
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
<!-- ============================================================= -->

<!-- ============================================================= -->
<!-- IMPORTS                                                       -->
<!-- ============================================================= -->

<xsl:import href="plos-xslfo.xsl" />


<!-- ============================================================= -->
<!-- STYLESHEET PARAMETERS                                         -->
<!-- ============================================================= -->

<!-- A very long length, required because Antenna House doesn't
     support unbounded page dimensions. -->
<xsl:param name="very-long" select="'36in'" as="xs:string" />


<!-- ============================================================= -->
<!-- TOP-LEVEL TEMPLATES                                           -->
<!-- ============================================================= -->


<xsl:template match="/">
  <xsl:message select="concat('page width: ',
                              $page-page-width-inches,
                              'in / ',
                              $page-page-width-inches * 72,
                              'pt')" />
  <xsl:message select="concat('column width: ',
                              $page-column-width-inches,
                              'in / ',
                              $page-column-width-inches * 72,
                              'pt')" />
  <xsl:message select="concat('page height: ',
                              $page-page-height-inches,
                              'in / ',
                              $page-page-height-inches * 72,
                              'pt')" />
  <fo:root>
    <fo:layout-master-set>
      <xsl:call-template name="define-sizer-simple-page-masters"/>
    </fo:layout-master-set>
    <fo:page-sequence master-reference="page-wide">
      <xsl:call-template name="flow">
        <xsl:with-param name="prefix"
                        select="'page-wide-'"
                        as="xs:string"
                        tunnel="yes" />
      </xsl:call-template>
    </fo:page-sequence>
    <fo:page-sequence master-reference="column-wide">
      <xsl:call-template name="flow">
        <xsl:with-param name="prefix"
                        select="'column-wide-'"
                        as="xs:string"
                        tunnel="yes" />
      </xsl:call-template>
    </fo:page-sequence>
    <fo:page-sequence master-reference="page-high">
      <!-- Graphics don't get rotated so no need to process captions
           but it's happening anyway. -->
      <xsl:call-template name="flow">
        <xsl:with-param name="prefix"
                        select="'page-high-'"
                        as="xs:string"
                        tunnel="yes" />
      </xsl:call-template>
    </fo:page-sequence>
  </fo:root>
</xsl:template>

<xsl:template name="flow">
  <xsl:param name="prefix" as="xs:string?" tunnel="yes" />

  <fo:flow flow-name="body" xsl:use-attribute-sets="fo:flow">
    <!-- Do each table. -->
    <xsl:apply-templates select="//table-wrap"/>
    <!-- Also do the '(continued)' label for each table. -->
    <xsl:for-each select="//table-wrap">
      <fo:float axf:float="auto-next top"
                axf:float-margin-y="10pt"
                margin-bottom="4pt"
                axf:float-reference="page"
                axf:float-move="auto-next">
         <!-- FIXME: shouldn't have to recreate label block, but real
             templates currently don't allow simple rewriting of
             label. -->
         <fo:block-container>
           <fo:block id="label-{$prefix}{@id}"
                     xsl:use-attribute-sets="table-wrap-label-block">
             <fo:inline xsl:use-attribute-sets="label">
               <xsl:value-of select="label" />
               <xsl:text> (continued).</xsl:text>
             </fo:inline>
           </fo:block>
           <!-- Empty block to ensure usual space-after from
                'table-wrap-label-block' gets used.  Without it, the
                label block is the only thing in the block-container
                and doesn't need any space-after. -->
           <fo:block />
         </fo:block-container>
      </fo:float>
    </xsl:for-each>
    <!-- Do only the caption and DOI for each fig. -->
    <xsl:for-each select="//fig | //fig-group">
      <fo:float axf:float="auto-next top"
                axf:float-margin-y="10pt"
                margin-bottom="4pt"
                axf:float-reference="page"
                axf:float-move="auto-next">
        <fo:block-container xsl:use-attribute-sets="fig-box">
          <xsl:call-template name="assign-id"/>
          <xsl:apply-templates select="caption" mode="run-in-title"/>
          <xsl:apply-templates select="object-id" />
        </fo:block-container>
      </fo:float>
    </xsl:for-each>
  </fo:flow>
</xsl:template>


<xsl:template name="define-sizer-simple-page-masters">

  <!-- Page-wide page -->
  <fo:simple-page-master master-name="page-wide"
    page-width="{$page-width}" page-height="{$very-long}"
    margin-top="0.5in"
    margin-left="{$page-margin-left}" margin-right="{$page-margin-right}">
    <fo:region-body region-name="body" margin-top="24pt"
      margin-left="0pt" margin-right="0in"
      column-count="1" />
  </fo:simple-page-master>

  <!-- Column-wide page -->
  <fo:simple-page-master
      master-name="column-wide"
      page-width="{$page-column-width-inches}in"
      page-height="{$very-long}">
    <fo:region-body region-name="body" margin-top="24pt"
      margin-left="0in" margin-right="0in"
      column-count="1" />
  </fo:simple-page-master>

  <!-- 'page-high'-wide page -->
  <fo:simple-page-master
      master-name="page-high"
      page-width="{$page-page-height-inches}in"
      page-height="{$very-long}">
    <fo:region-body region-name="body"
      column-count="1" />
  </fo:simple-page-master>
</xsl:template>

<xsl:template
    match="xref[@ref-type = ('bibr', 'supplementary-material')]">
  <!-- Don't make a link for xref since target either won't be in
       'sizer' file or will be there multiple times. -->
  <xsl:apply-templates />
</xsl:template>

</xsl:stylesheet>
