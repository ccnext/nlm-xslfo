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
<!--  MODULE:    PLOS ONE XSL-FO stylesheet                        -->
<!--  VERSION:   1.0                                               -->
<!--  DATE:      December 2012                                     -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--  SYSTEM:    PLOS                                              -->
<!--                                                               -->
<!--  PURPOSE:   Format PLOS ONE articles.                         -->
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

This stylesheet started as a copy of the public domain JATS preview
stylesheet, which is written in XSLT 1.0.  This version is changed to
directly support PLOS ONE formatting and to use XSLT 2.0 features.

    ============================================================= -->

<!-- ============================================================= -->
<!-- IMPORTS                                                       -->
<!-- ============================================================= -->

<xsl:import href="size-functions.xsl" />


<!-- ============================================================= -->
<!-- WHITE-SPACE HANDLING                                          -->
<!-- ============================================================= -->

<xsl:strip-space elements="aff caption ref-list xref" />


<!-- ============================================================= -->
<!-- KEYS FOR ID AND RID                                           -->
<!-- ============================================================= -->

<xsl:key name="fn-by-type" match="fn[@fn-type]" use="@fn-type" />

<xsl:key name="element-by-id" match="*[@id]" use="@id" />

<xsl:key name="xref-by-rid" match="xref[@rid]" use="@rid" />


<!-- ============================================================= -->
<!-- STYLESHEET PARAMETERS                                         -->
<!-- ============================================================= -->
<!-- These affect the operation of the stylesheet as a whole. They
     can be overridden at runtime, if desired (use an empty
     string for a false() value), or (better) by an importing
     stylesheet. -->

<!-- IDs of tables and figures to be forced to be page-wide. -->
<xsl:param name="page-wide"
           select="()"
           as="xs:string?" />

<xsl:param name="area-tree-dir" select="'../fo'" as="xs:string" />

<xsl:param name="area-tree"
           select="concat($area-tree-dir,
                          '/',
                          replace(tokenize(base-uri(), '/')[last()],
                                  '.xml$',
                                  '-sizer.AT.xml'))"
           as="xs:string?" />

<!-- If mathml-support is turned off, MathML will be removed from the
     output (while its content is passed through). This allows the
     stylesheet to be used with an XSL-FO engine that does not support
     MathML (while also disabling MathML, of course -->
<xsl:param name="mathml-support" select="true()"/>


<!-- base-dir specifies the base directory used to evaluate
     relative URIs. If this is left as the default, the
     formatter will guess as to where graphics are located when
     relative paths are given.

     For example:

     A graphic has <graphic xlink:href="images/babypic.jpg"/>
     base-dir is provided as 'file:///c:/Projects/NLM-data'
     The graphic should be found at
      file:///c:/Projects/NLM-data/images/babypic.jpg

-->
<xsl:param name="base-dir" select="false()"/>

<xsl:param name="graphics-dir" select="'../downloads/'" as="xs:string" />

<!-- 'sizer' area tree as an XML document. -->
<xsl:variable
    name="area-tree-doc"
    select="if (doc-available($area-tree))
            then doc($area-tree)
            else ()"
    as="document-node()?"/>

<!-- Debug options. -->
<xsl:param
    name="debug"
    as="xs:string?" />

<xsl:variable
    name="debug.figure"
    select="tokenize($debug, ',\s*') = 'figure'"
    as="xs:boolean" />

<xsl:variable
    name="debug.table"
    select="tokenize($debug, ',\s*') = 'table'"
    as="xs:boolean" />

<!-- ============================================================= -->
<!-- TYPOGRAPHIC SPECIFICATIONS                                    -->
<!-- ============================================================= -->

<xsl:variable name="page-wide-ids"
              select="tokenize($page-wide, ',\s*')"
              as="xs:string*" />

<!-- Most typographical specification is done below by named
     attribute sets, but a few global variables are useful.        -->

<xsl:variable name="mainindent" select="'0pt'"/>

<!-- 'font-family' property value when a sans-serif font is
     required. -->
<xsl:variable name="sans-serif-font-family"
        select="'Arial, ''DejaVu Sans'', ''Lucida Sans Unicode'', ''MS PGothic'', OpenSymbol, sans-serif'"
        as="xs:string" />

<!-- Font used for Section titles and the like. -->
<xsl:variable name="titlefont"
        select="$sans-serif-font-family"
        as="xs:string" />

<!-- Font used for normal paragraph text.  -->
<xsl:variable name="textfont"
        select="$sans-serif-font-family"
        as="xs:string" />

<!-- Font used for headers and footers. -->
<xsl:variable name="header-footer-font"
        select="$sans-serif-font-family"
        as="xs:string" />

<!-- Font size for normal paragraph text and the like. -->
<xsl:variable name="textsize"
              select="'8.5pt'"
              as="xs:string" />
<!-- points -->

<!-- Font size for subscripts and superscripts. -->
<xsl:variable name="textsize-sub-sup"
              select="'60%'"
              as="xs:string" />

<!-- Font size for text inside table and table-wrap. -->
<xsl:variable name="textsize-table"
              select="'6.5pt'"
              as="xs:string" />

<!-- Font size for subscripts and superscripts inside table and
     table-wrap-foot. -->
<xsl:variable name="textsize-table-sub-sup"
              select="'85%'"
              as="xs:string" />

<!-- Font size for text in headers and footers. -->
<xsl:variable name="header-footer-textsize" select="'8pt'"/>

<!-- Font size for normal paragraph text and the like. -->
<xsl:variable name="mathsize" select="'big'"/>
<!-- small | normal | big | number v-unit See
     http://www.w3.org/TR/MathML2/chapter3.html#presm.commatt (and
     http://www.w3.org/TR/MathML2/chapter2.html#fund.attval for units)
     -->

<!-- Vertical baseline-to-baseline distance for normal
     paragraph text and the like. -->
<xsl:variable name="textleading" select="'11pt'" as="xs:string" />
<!-- points -->

<!-- Vertical baseline-to-baseline distance for headers and footers. -->
<xsl:variable name="header-footer-textleading" select="'10.5pt'" as="xs:string" />
<!-- points -->

<xsl:variable name="page-width" select="'8.5in'" as="xs:string" />
<xsl:variable name="page-height" select="'11in'" as="xs:string" />
<xsl:variable name="page-margin-left" select="'0.8in'" as="xs:string" />
<xsl:variable name="page-margin-right" select="'0.8in'" as="xs:string" />
<xsl:variable name="page-margin-top" select="'0.5in'" as="xs:string" />
<xsl:variable name="page-margin-bottom" select="'0.5in'" as="xs:string" />
<xsl:variable name="page-column-count" select="2" as="xs:integer" />
<xsl:variable name="page-column-gap" select="'19pt'" as="xs:string" />

<xsl:variable name="region-body-margin-top" select="'36pt'" as="xs:string" />
<xsl:variable name="region-body-margin-bottom" select="'36pt'" as="xs:string" />

<xsl:variable name="generated-titles" as="element(title)+">
  <title name="ack">Acknowledgements</title>
  <title name="fn">Author Contributions</title>
</xsl:variable>

<xsl:variable
    name="page-page-width-inches"
    select="pf:length-to-inches($page-width) -
            (pf:length-to-inches($page-margin-left) +
             pf:length-to-inches($page-margin-right))"
    as="xs:double" />

<xsl:variable
    name="page-column-width-inches"
    select="(pf:length-to-inches($page-width) -
             (pf:length-to-inches($page-margin-left) +
              pf:length-to-inches($page-margin-right)) -
              ($page-column-count - 1) * pf:length-to-inches($page-column-gap)) div
            $page-column-count"
    as="xs:double" />

<xsl:variable
    name="page-page-height-inches"
    select="pf:length-to-inches($page-height) -
            pf:sum-lengths-to-inches(($page-margin-top,
                                      $page-margin-bottom,
                                      $region-body-margin-top,
                                      $region-body-margin-bottom))"
    as="xs:double" />

<xsl:variable
    name="dpi"
    select="300"
    as="xs:integer" />

<xsl:variable name="units" as="element(unit)+">
  <unit name="in" per-inch="1" />
  <unit name="pt" per-inch="72" />
  <unit name="pc" per-inch="6" />
  <unit name="cm" per-inch="2.54" />
  <unit name="mm" per-inch="25.4" />
  <unit name="px" per-inch="96" />
</xsl:variable>

<xsl:variable
    name="units-pattern"
    select="concat('(',
                   string-join($units/@name, '|'),
                   ')')"
    as="xs:string" />

<xsl:function name="pf:sum-lengths-to-inches" as="xs:double">
  <xsl:param name="lengths" as="xs:string*" />

  <xsl:sequence select="sum(for $length in $lengths
                              return pf:length-to-inches($length))" />
</xsl:function>

<xsl:function name="pf:sum-lengths-to-pt" as="xs:double">
  <xsl:param name="lengths" as="xs:string*" />

  <xsl:sequence select="sum(for $length in $lengths
                              return pf:length-to-pt($length))" />
</xsl:function>

<xsl:function name="pf:length-to-inches" as="xs:double">
  <xsl:param name="length" as="xs:string" />

  <xsl:choose>
    <xsl:when test="matches($length, concat('^-?\d+(\.\d*)?', $units-pattern, '$'))">
      <!--<xsl:message select="$length" />-->
      <xsl:analyze-string
          select="$length"
          regex="{concat('^(-?\d+(\.\d*)?)', $units-pattern, '$')}">
        <xsl:matching-substring>
          <xsl:sequence select="xs:double(regex-group(1)) div
                                xs:double($units[@name eq regex-group(3)]/@per-inch)" />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="concat('Unrecognized length: ', $length)" />
      <xsl:sequence select="0" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="pf:length-to-pt" as="xs:double">
  <xsl:param name="length" as="xs:string" />

  <xsl:choose>
    <xsl:when test="matches($length, concat('^-?\d+(\.\d*)?', $units-pattern, '$'))">
      <!--<xsl:message select="$length" />-->
      <xsl:analyze-string
          select="$length"
          regex="{concat('^(-?\d+(\.\d*)?)', $units-pattern, '$')}">
        <xsl:matching-substring>
          <xsl:sequence
              select="xs:double(regex-group(1)) * $units[@name eq 'pt']/@per-inch div
                      xs:double($units[@name eq regex-group(3)]/@per-inch)" />
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="concat('Unrecognized length: ', $length)" />
      <xsl:sequence select="0" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- pf:is-column-wide($graphic as element(graphic)) as xs:boolean -->
<!-- Returns true() if $graphic should be column-wide.  Will not be
     column-wide if $page-wide-ids includes $graphic/id or if can
     determine from 'identity' file that the graphic is too wide for a
     column. -->
<xsl:function name="pf:is-column-wide" as="xs:boolean">
  <xsl:param name="graphic" as="element(graphic)" />

  <xsl:choose>
    <xsl:when test="$graphic/../@id = $page-wide-ids">
      <xsl:sequence select="false()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="href"
                    select="pf:resolve-href($graphic)" as="xs:string" />
      <xsl:variable name="identify-file"
                    select="replace($href, '\.tif$', '.identify')"
                    as="xs:string" />
      <xsl:if test="$debug.figure">
        <xsl:message select="tokenize($graphic/@xlink:href, '/')[last()]" />
      </xsl:if>
      <xsl:choose>
        <xsl:when test="unparsed-text-available($identify-file)">
          <!--<xsl:message select="normalize-space(unparsed-text($identify-file))" />-->
          <xsl:variable
              name="tokens"
              select="tokenize(normalize-space(unparsed-text($identify-file)), ':')"
              as="xs:string+" />
          <xsl:variable
              name="width"
              select="xs:integer($tokens[1]) div
                      (xs:double(substring-before($tokens[3], ' ')) *
                       (if (substring-after($tokens[3], ' ') eq 'PixelsPerCentimeter')
                          then 2.54
                        else 1))"
              as="xs:double" />
          <xsl:if test="$debug.figure">
            <xsl:message select="concat('graphic width: ', $width, 'in')" />
          </xsl:if>
          <xsl:sequence select="$width &lt;= $page-column-width-inches * 1.1" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:message
              select="concat('No .identify file at ''',
                             replace($href, '\.tif$', '.identify'),
                             '''')" />
          <xsl:sequence select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<!-- ============================================================= -->
<!-- Attribute sets                                                -->
<!-- ============================================================= -->

<xsl:attribute-set name="page-header-title-cell">
  <xsl:attribute name="width" select="'40%'" />
</xsl:attribute-set>

<xsl:attribute-set name="page-header-pageno-cell">
  <xsl:attribute name="width" select="'0.5in'" />
</xsl:attribute-set>

<xsl:attribute-set name="page-header">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$header-footer-font"/>
  </xsl:attribute>
  <xsl:attribute name="font-size" select="$header-footer-textsize" />
  <xsl:attribute name="line-height" select="$header-footer-textleading" />
</xsl:attribute-set>

<xsl:attribute-set name="metadata-line">
  <xsl:attribute name="font-size" select="'9pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="metadata-label">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$titlefont"/>
  </xsl:attribute>
  <xsl:attribute name="keep-with-next" select="'always'" />
  <xsl:attribute name="font-size" select="'8pt'" />
  <xsl:attribute name="font-weight" select="'bold'" />
</xsl:attribute-set>

<!-- PLOS ONE other metadata in the 'abstract box'. -->
<xsl:attribute-set name="po:other-metadata">
  <xsl:attribute name="role" select="'other-metadata'" />
  <xsl:attribute name="start-indent" select="'8pt'" />
  <xsl:attribute name="end-indent" select="'8pt'" />
  <xsl:attribute name="font-size" select="'7pt'" />
  <xsl:attribute name="line-height" select="'8.5pt'" />
  <xsl:attribute name="space-before" select="'3.5pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="sans-serif">
  <xsl:attribute name="font-family" select="$sans-serif-font-family" />
</xsl:attribute-set>

<xsl:attribute-set name="monospace">
  <xsl:attribute name="font-family" select="'monospace'" />
</xsl:attribute-set>

<xsl:attribute-set name="warning" use-attribute-sets="sans-serif">
  <xsl:attribute name="font-style" select="'italic'" />
  <xsl:attribute name="color" select="'darkred'" />
</xsl:attribute-set>

<xsl:attribute-set name="generated"/>

<xsl:attribute-set name="data"/>

<xsl:attribute-set name="subscript-superscript">
  <!-- Font-size is reduced in tables, so use a different font-size
       same to keep them legible. -->
  <xsl:attribute
      name="font-size"
      select="if (exists(ancestor::table) or
                  exists(ancestor::table-wrap-foot))
                then $textsize-table-sub-sup
              else $textsize-sub-sup" />
</xsl:attribute-set>

<xsl:attribute-set name="subscript"
                   use-attribute-sets="subscript-superscript">
  <xsl:attribute name="vertical-align" select="'sub'" />
</xsl:attribute-set>

<xsl:attribute-set name="superscript"
                   use-attribute-sets="subscript-superscript">
  <xsl:attribute name="vertical-align" select="'super'" />
</xsl:attribute-set>

<xsl:attribute-set name="label">
  <xsl:attribute name="keep-with-next" select="'always'" />
  <xsl:attribute name="font-family">
    <xsl:value-of select="$titlefont"/>
  </xsl:attribute>
  <!--<xsl:attribute name="font-size" select="'9pt'" />-->
  <xsl:attribute name="font-weight" select="'bold'" />
</xsl:attribute-set>

<xsl:attribute-set name="ref-label" use-attribute-sets="label">
  <xsl:attribute name="font-size" select="'7pt'" />
  <xsl:attribute name="font-weight" select="'normal'" />
  <xsl:attribute name="text-align" select="'end'" />
</xsl:attribute-set>

<xsl:attribute-set name="table-wrap-label-block">
  <xsl:attribute name="role" select="'table-wrap-label-block'" />
  <xsl:attribute name="keep-with-next" select="'always'" />
  <xsl:attribute name="font-family">
    <xsl:value-of select="$titlefont"/>
  </xsl:attribute>
  <xsl:attribute name="font-size" select="'9pt'" />
  <xsl:attribute name="text-align" select="'justify'" />
  <xsl:attribute name="border-bottom" select="'1pt solid black'" />
  <xsl:attribute name="padding-after" select="'9pt'" />
  <xsl:attribute name="space-after" select="'12pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="fo:flow">
  <xsl:attribute name="margin-left" select="$mainindent" />
  <xsl:attribute name="font-family" select="$textfont" />
  <xsl:attribute name="font-size" select="$textsize" />
  <xsl:attribute name="line-height" select="$textleading" />
  <xsl:attribute name="line-height.minimum" select="concat($textleading, ' * 1.0')" />
  <xsl:attribute name="line-height.maximum" select="concat($textleading, ' * 1.1')" />
  <xsl:attribute name="line-height-shift-adjustment" select="'disregard-shifts'" />
  <xsl:attribute name="line-stacking-strategy" select="'max-height'" />
</xsl:attribute-set>

<xsl:attribute-set name="title">
  <xsl:attribute name="font-family" select="$titlefont" />
  <xsl:attribute name="font-weight" select="'bold'" />
  <xsl:attribute name="keep-with-next" select="'always'" />
</xsl:attribute-set>

<xsl:attribute-set name="main-title" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'10pt'" />
  <xsl:attribute name="line-height" select="'12pt'" />
  <xsl:attribute name="space-after" select="'10pt'" />
  <xsl:attribute name="id"
                 select="if (self::title)
                           then (../@id, generate-id(..))[1]
                         else (@id, generate-id(.))[1]" />
</xsl:attribute-set>

<xsl:attribute-set name="section-title" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'9pt'" />
  <xsl:attribute name="font-weight" select="'bold'" />
  <xsl:attribute name="line-height" select="'11pt'" />
  <xsl:attribute name="space-after" select="'2pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="subsection-title" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'12pt'" />
  <xsl:attribute name="line-height" select="'14pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="block-title" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'11pt'" />
  <xsl:attribute name="line-height" select="'13pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="subtitle" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'10pt'" />
  <xsl:attribute name="line-height" select="'12pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="panel">
  <xsl:attribute name="space-before" select="'6pt'" />
  <xsl:attribute name="space-after" select="'6pt'" />
</xsl:attribute-set>

<!-- PLOS ONE box around abstract and other metadata. -->
<xsl:attribute-set name="po:abstract-box">
  <xsl:attribute name="border" select="'1pt solid black'" />
  <xsl:attribute name="start-indent" select="'4pt'" />
  <xsl:attribute name="end-indent" select="'4pt'" />
  <xsl:attribute name="padding" select="'4pt'" />
  <xsl:attribute name="padding-top" select="'5pt'" />
  <xsl:attribute name="padding-bottom" select="'8pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="abstract-text" use-attribute-sets="sans-serif">
  <xsl:attribute name="font-size" select="'9pt'" />
  <xsl:attribute name="line-height" select="'10pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="abstract-section-title">
  <xsl:attribute name="font-weight" select="'bold'" />
  <xsl:attribute name="font-style" select="'italic'" />
</xsl:attribute-set>

<xsl:attribute-set name="abstract-paragraph" use-attribute-sets="paragraph">
  <xsl:attribute name="space-before" select="'5pt'" />
  <xsl:attribute name="text-indent" select="if (position() = 1) then '0pt' else '1em'" />
</xsl:attribute-set>

<xsl:attribute-set name="abstract" use-attribute-sets="panel abstract-text">
  <xsl:attribute name="background-color" select="'rgb(207, 230, 247)'" />
  <xsl:attribute name="start-indent" select="'15pt'" />
  <xsl:attribute name="end-indent" select="'15pt'" />
  <xsl:attribute name="space-before" select="'0pt'" />
  <xsl:attribute name="space-after" select="'5pt'" />
  <xsl:attribute name="padding" select="'10pt'" />
  <xsl:attribute name="text-indent" select="'0pt'" />
</xsl:attribute-set>

<xsl:function name="pf:abstract-title-attributes" as="attribute()*">
  <xsl:param name="context" as="node()" />

  <xsl:variable name="dummy" as="element(dummy)">
    <dummy xsl:use-attribute-sets="abstract-text" />
  </xsl:variable>

  <xsl:sequence select="$dummy/@*" />
  <xsl:attribute name="font-weight" select="'bold'" />
  <xsl:attribute name="start-indent" select="'inherit'" />
  <xsl:attribute name="space-after" select="'10pt'" />
</xsl:function>

<xsl:attribute-set name="box">
  <!--<xsl:attribute name="border" select="'thin solid black'" />-->
  <xsl:attribute name="padding" select="'4pt'" />
  <xsl:attribute name="space-before" select="'4pt'" />
  <xsl:attribute name="space-after" select="'4pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="firstpage-title" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'18pt'" />
  <xsl:attribute name="font-weight" select="'bold'" />
  <xsl:attribute name="line-height" select="'21pt'" />
  <xsl:attribute name="id" select="'article-title'" />
</xsl:attribute-set>

<xsl:attribute-set name="firstpage-subtitle" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'12pt'" />
  <xsl:attribute name="line-height" select="'15pt'" />
  <xsl:attribute name="font-style" select="'italic'" />
</xsl:attribute-set>

<xsl:attribute-set name="firstpage-alt-title" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'10pt'" />
  <xsl:attribute name="line-height" select="'15pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="firstpage-trans-title" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'10pt'" />
  <xsl:attribute name="line-height" select="'15pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="firstpage-trans-subtitle" use-attribute-sets="title">
  <xsl:attribute name="font-size" select="'8pt'" />
  <xsl:attribute name="line-height" select="'15pt'" />
  <xsl:attribute name="font-style" select="'italic'" />
</xsl:attribute-set>

<xsl:attribute-set name="section">
  <xsl:attribute name="space-before" select="'12pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="section-metadata" use-attribute-sets="panel"/>

<xsl:attribute-set name="back-section" use-attribute-sets="section"/>

<xsl:attribute-set name="app" use-attribute-sets="section"/>

<xsl:attribute-set name="paragraph">
  <xsl:attribute name="space-before" select="'0pt'" />
  <xsl:attribute name="text-align" select="'justify'" />
  <xsl:attribute name="text-indent" select="'1em'" />
</xsl:attribute-set>

<xsl:attribute-set name="paragraph-no-indent" use-attribute-sets="paragraph">
  <xsl:attribute name="text-indent" select="'0em'" />
</xsl:attribute-set>

<xsl:attribute-set name="paragraph-tight" use-attribute-sets="paragraph">
  <xsl:attribute name="space-before" select="'0pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="contrib-block">
  <xsl:attribute name="role" select="'contrib-block'" />
  <xsl:attribute name="font-size" select="'10pt'" />
  <xsl:attribute name="font-weight" select="'bold'" />
  <xsl:attribute name="line-height" select="'14pt'" />
  <xsl:attribute name="space-before" select="'14pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="contrib"/>

<xsl:attribute-set name="aff-block">
  <xsl:attribute name="role" select="'aff-block'" />
  <xsl:attribute name="text-align" select="'justify'" />
  <xsl:attribute name="space-before" select="'9pt'" />
  <xsl:attribute name="space-after" select="'10pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="aff" use-attribute-sets="contrib">
  <xsl:attribute name="font-size" select="'7pt'" />
  <xsl:attribute name="line-height" select="'10pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="aff-label">
  <xsl:attribute name="font-weight" select="'bold'" />
</xsl:attribute-set>

<xsl:attribute-set name="address">
  <xsl:attribute name="keep-together" select="'always'" />
</xsl:attribute-set>

<xsl:attribute-set name="address-line"/>

<xsl:attribute-set name="media-object">
  <xsl:attribute name="text-align" select="'center'"/>
</xsl:attribute-set>

<xsl:attribute-set name="email" />

<xsl:attribute-set name="link" use-attribute-sets="sans-serif">
  <xsl:attribute name="font-weight" select="'normal'" />
</xsl:attribute-set>

<xsl:attribute-set name="ext-link"/>

<xsl:attribute-set name="uri"/>

<xsl:attribute-set name="xref"/>

<xsl:attribute-set name="copyright-line"/>

<xsl:attribute-set name="funding-source"/>

<xsl:attribute-set name="inline-formula"/>

<xsl:attribute-set name="object-id" use-attribute-sets="sans-serif">
  <xsl:attribute name="role" select="'object-id'" />
  <xsl:attribute name="font-size" select="'75%'" />
  <xsl:attribute name="keep-with-previous" select="'always'" />
</xsl:attribute-set>

<xsl:attribute-set name="array"/>

<xsl:attribute-set name="author-notes" use-attribute-sets="panel"/>

<xsl:attribute-set name="disp-formula-group"/>

<xsl:attribute-set name="disp-quote" use-attribute-sets="panel">
  <xsl:attribute name="margin-left" select="'2pc'" />
  <xsl:attribute name="margin-right" select="'2pc'" />
  <xsl:attribute name="font-size" select="'9pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="fn-group" use-attribute-sets="section"/>

<xsl:attribute-set name="long-desc"/>

<xsl:attribute-set name="open-access"/>

<xsl:attribute-set name="sig-block"/>

<xsl:attribute-set name="attrib"/>

<xsl:attribute-set name="boxed-text" use-attribute-sets="box"/>

<xsl:attribute-set name="chem-struct-box" use-attribute-sets="panel"/>

<xsl:attribute-set name="chem-struct" use-attribute-sets="panel"/>

<xsl:attribute-set name="chem-struct-inline"/>

<xsl:attribute-set name="fig-box" use-attribute-sets="box">
  <xsl:attribute name="overflow" select="'repeat'" />
</xsl:attribute-set>

<xsl:attribute-set name="fig" use-attribute-sets="panel"/>

<xsl:attribute-set name="list" use-attribute-sets="panel"/>

<xsl:attribute-set name="sub-list"/>

<xsl:attribute-set name="def-list" use-attribute-sets="panel"/>

<xsl:attribute-set name="sub-def-list"/>

<xsl:attribute-set name="list-item" use-attribute-sets="paragraph"/>

<xsl:attribute-set name="def-item"/>

<xsl:attribute-set name="def-list-head"/>

<xsl:attribute-set name="term-head" use-attribute-sets="label">
  <xsl:attribute name="width">
    <xsl:value-of select="$mainindent"/>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="def-head" use-attribute-sets="label"/>

<xsl:attribute-set name="def-list-term">
  <xsl:attribute name="font-weight" select="'bold'" />
  <xsl:attribute name="keep-with-next" select="'always'" />
</xsl:attribute-set>

<xsl:attribute-set name="def-list-def">
  <xsl:attribute name="margin-left">
    <xsl:value-of select="$mainindent"/>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="list-item-label">
  <xsl:attribute name="text-align" select="'end'" />
  <xsl:attribute name="text-indent" select="'0pt'" />
  <!--<xsl:attribute name="font-weight" select="'bold'" />-->
</xsl:attribute-set>

<xsl:attribute-set name="preformat-box" use-attribute-sets="panel"/>

<xsl:attribute-set name="preformat">
  <xsl:attribute name="white-space-treatment" select="'preserve'" />
  <xsl:attribute name="white-space-collapse" select="'false'" />
  <xsl:attribute name="linefeed-treatment" select="'preserve'" />
  <xsl:attribute name="font-family" select="'monospace'" />
  <xsl:attribute name="font-size" select="'8pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="speech"/>

<xsl:attribute-set name="supplementary" use-attribute-sets="box"/>

<xsl:attribute-set name="table-box" use-attribute-sets="box">
</xsl:attribute-set>

<xsl:attribute-set name="table-wrap" use-attribute-sets="panel">
  <xsl:attribute name="font-size" select="$textsize-table" />
  <xsl:attribute name="start-indent" select="'0pc'" />
</xsl:attribute-set>

<xsl:attribute-set name="table">
  <xsl:attribute name="font-size">
    <xsl:value-of select="$textsize-table" />
  </xsl:attribute>
  <xsl:attribute name="width">100%</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="caption"/>

<xsl:attribute-set name="textual-form"/>

<xsl:attribute-set name="disp-formula" use-attribute-sets="panel">
  <xsl:attribute name="role" select="'disp-formula'" />
  <xsl:attribute name="line-stacking-strategy" select="'max-height'" />
  <xsl:attribute name="text-align" select="'center'" />
</xsl:attribute-set>

<xsl:attribute-set name="mml:math-display">
  <!-- Heuristic to account for width of equation number text until
       such time as label width is measured in 'sizer' processing. -->
  <xsl:attribute name="width" select="'100% - 27pt'" />
  <xsl:attribute name="content-width" select="'scale-down-to-fit'" />
  <xsl:attribute name="keep-together.within-line" select="'always'" />
</xsl:attribute-set>

<xsl:attribute-set name="statement" use-attribute-sets="panel"/>

<xsl:attribute-set name="table-wrap-foot">
  <xsl:attribute name="role" select="'table-wrap-foot'" />
  <xsl:attribute name="font-size" select="$textsize-table" />
</xsl:attribute-set>

<xsl:attribute-set name="table-footnote">
</xsl:attribute-set>

<xsl:attribute-set name="verse" use-attribute-sets="panel">
  <xsl:attribute name="space-before" select="'4pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="verse-line">
  <xsl:attribute name="start-indent" select="'2pc'" />
  <xsl:attribute name="text-indent" select="'-2pc'" />
</xsl:attribute-set>

<xsl:attribute-set name="ref-list-section" use-attribute-sets="section"/>

<xsl:attribute-set name="ref-list-block" use-attribute-sets="panel">
  <xsl:attribute name="font-size" select="'7pt'" />
  <xsl:attribute name="provisional-distance-between-starts" select="'17pt'" />
  <xsl:attribute name="provisional-label-separation" select="'3pt'" />
  <xsl:attribute name="text-indent" select="'0pt'" />
  <xsl:attribute name="line-height" select="'8.125pt'" />
  <xsl:attribute name="line-height.maximum" select="'8.125pt * 1.1'" />
</xsl:attribute-set>

<xsl:attribute-set name="ref-list-item" use-attribute-sets="paragraph-no-indent">
  <xsl:attribute name="relative-align" select="'baseline'" />
</xsl:attribute-set>

<xsl:attribute-set name="ref" />

<xsl:attribute-set name="citation" use-attribute-sets="paragraph-no-indent" />

<xsl:attribute-set name="endnote"/>

<xsl:attribute-set name="footnote-body">
  <xsl:attribute name="space-before" select="'4pt'" />
  <xsl:attribute name="font-family">
    <xsl:value-of select="$textfont"/>
  </xsl:attribute>
  <xsl:attribute name="font-size" select="'9pt'" />
  <xsl:attribute name="font-weight" select="'normal'" />
  <xsl:attribute name="line-height" select="'10pt'" />
</xsl:attribute-set>

<xsl:attribute-set name="footnote-ref" use-attribute-sets="superscript"/>

<xsl:attribute-set name="float">
  <xsl:attribute name="axf:float" select="'auto-next top'" />
  <xsl:attribute name="axf:float-margin-y" select="'10pt'" />
  <xsl:attribute name="margin-bottom" select="'4pt'" />
</xsl:attribute-set>


<!-- ============================================================= -->
<!-- TOP-LEVEL TEMPLATES                                           -->
<!-- ============================================================= -->


<xsl:template match="/">
  <xsl:if test="debug.table">
    <xsl:sequence select="pf:list-tables(/, $area-tree-doc)" />
  </xsl:if>
  <fo:root>
    <fo:layout-master-set>
      <xsl:call-template name="define-simple-page-masters"/>
      <xsl:call-template name="define-page-sequences"/>
    </fo:layout-master-set>
    <xsl:apply-templates/>
  </fo:root>
</xsl:template>

<xsl:template match="article">
  <xsl:param name="split" select="false()" as="xs:boolean" tunnel="yes" />

  <xsl:message select="concat('column width: ', $page-column-width-inches, 'in : ', $page-column-width-inches * 72, 'pt')" />
  <xsl:message select="concat('page width: ', $page-page-width-inches, 'in : ', $page-page-width-inches * 72, 'pt')" />
  <xsl:message select="concat('page height: ', $page-page-height-inches, 'in : ', $page-page-height-inches * 72, 'pt')" />
  <xsl:call-template name="bookmarks"/>
  <!-- Populate the content sequence -->
  <fo:page-sequence master-reference="title-sequence"
    initial-page-number="1">

    <fo:static-content flow-name="first-header">
      <fo:block xsl:use-attribute-sets="page-header"
                border-bottom="solid black 0.5pt">
        <fo:external-graphic src="../open-access.svg" />
        <fo:leader leader-length.minimum="60%" leader-length.optimum="90%" leader-length.maximum="100%" />
        <fo:external-graphic src="../plos-one.svg" />
      </fo:block>
    </fo:static-content>
    <fo:static-content flow-name="recto-header">
      <fo:block xsl:use-attribute-sets="page-header">
        <xsl:call-template name="make-page-header">
          <xsl:with-param name="face" select="'recto'"/>
        </xsl:call-template>
      </fo:block>
    </fo:static-content>
    <fo:static-content flow-name="verso-header">
      <fo:block xsl:use-attribute-sets="page-header">
        <xsl:call-template name="make-page-header">
          <xsl:with-param name="face" select="'verso'"/>
        </xsl:call-template>
      </fo:block>
    </fo:static-content>
    <fo:static-content flow-name="verso-footer">
      <fo:block xsl:use-attribute-sets="page-header">
        <xsl:call-template name="make-page-footer">
          <xsl:with-param name="center-cell">
            <fo:block text-align="center">
              <fo:page-number/>
            </fo:block>
          </xsl:with-param>
        </xsl:call-template>
      </fo:block>
    </fo:static-content>
    <xsl:call-template name="define-footnote-separator"/>
    <fo:flow flow-name="body" xsl:use-attribute-sets="fo:flow">

        <!-- set the article opener, body, and backmatter -->
        <xsl:call-template name="set-article-opener"/>

        <xsl:apply-templates select="/article/body"/>
        <xsl:choose>
          <xsl:when test="not($split)">
            <xsl:apply-templates select="/article/back"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Force columns to balance if not processing back. -->
            <fo:block span="all" />
          </xsl:otherwise>
        </xsl:choose>
        <!--<xsl:apply-templates select="/article/floats-group"/>-->

    </fo:flow>
  </fo:page-sequence>

  <xsl:if test="$split">
    <xsl:message select="'split'" />

    <fo:page-sequence master-reference="continuation-sequence">

      <fo:static-content flow-name="first-header">
        <fo:block xsl:use-attribute-sets="page-header"
                  border-bottom="solid black 0.5pt">
          <fo:external-graphic src="../open-access.svg" />
          <fo:leader leader-length.minimum="60%" leader-length.optimum="90%" leader-length.maximum="100%" />
          <fo:external-graphic src="../plos-one.svg" />
        </fo:block>
      </fo:static-content>
      <fo:static-content flow-name="recto-header">
        <fo:block xsl:use-attribute-sets="page-header">
          <xsl:call-template name="make-page-header">
            <xsl:with-param name="face" select="'recto'"/>
          </xsl:call-template>
        </fo:block>
      </fo:static-content>
      <fo:static-content flow-name="verso-header">
        <fo:block xsl:use-attribute-sets="page-header">
          <xsl:call-template name="make-page-header">
            <xsl:with-param name="face" select="'verso'"/>
          </xsl:call-template>
        </fo:block>
      </fo:static-content>
      <fo:static-content flow-name="verso-footer">
        <fo:block xsl:use-attribute-sets="page-header">
          <xsl:call-template name="make-page-footer">
            <xsl:with-param name="center-cell">
              <fo:block text-align="center">
                <fo:page-number/>
              </fo:block>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:static-content>
      <xsl:call-template name="define-footnote-separator"/>
      <fo:flow flow-name="body" xsl:use-attribute-sets="fo:flow">
        <xsl:apply-templates select="/article/back"/>
      </fo:flow>
    </fo:page-sequence>
  </xsl:if>
  <!-- produce document diagnostics after the end of the article; this
       has a page sequence in it and all else needed -->
  <!--<xsl:call-template name="run-diagnostics"/>-->
</xsl:template>

<xsl:template name="define-footnote-separator">
  <fo:static-content flow-name="xsl-footnote-separator">
    <fo:block end-indent="4in" margin-top="12pt" space-after="8pt"
      border-width="0.5pt" border-bottom-style="solid"/>
  </fo:static-content>
</xsl:template>

<xsl:template name="define-page-sequences">

  <!-- title-sequence master is:
     first, verso+ -->
  <fo:page-sequence-master master-name="title-sequence">
    <fo:single-page-master-reference master-reference="first"/>
    <fo:repeatable-page-master-reference
        master-reference="verso"/>
  </fo:page-sequence-master>

  <!-- continuation-sequence master is:
       verso+ -->
  <fo:page-sequence-master master-name="continuation-sequence">
    <fo:repeatable-page-master-reference
        master-reference="verso"/>
  </fo:page-sequence-master>
</xsl:template>

<xsl:template name="define-simple-page-masters">

  <fo:simple-page-master master-name="blank" page-height="{$page-height}"
    page-width="{$page-width}" margin-top="0.5in" margin-bottom="1.0in"
    margin-left="{$page-margin-left}" margin-right="{$page-margin-right}">
    <fo:region-body region-name="body" margin-top="24pt" margin-bottom="0in"
      margin-left="0in" margin-right="0in"/>
  </fo:simple-page-master>

  <!-- first page -->
  <fo:simple-page-master master-name="first" page-height="{$page-height}"
    page-width="{$page-width}" margin-top="0.5in" margin-bottom="36pt"
    margin-left="{$page-margin-left}" margin-right="{$page-margin-right}">
    <fo:region-body region-name="body" margin-top="24pt" margin-bottom="36pt"
      margin-left="0in" margin-right="0in"
      column-count="{$page-column-count}" column-gap="{$page-column-gap}" />
    <fo:region-before region-name="first-header" extent="36pt"
      display-align="before"/>
    <fo:region-after region-name="verso-footer" extent="24pt"
      display-align="after"/>
  </fo:simple-page-master>

  <!-- verso page -->
  <fo:simple-page-master master-name="verso" page-height="{$page-height}"
                         page-width="{$page-width}"
                         margin-top="{$page-margin-top}"
                         margin-bottom="{$page-margin-bottom}"
                         margin-left="{$page-margin-left}"
                         margin-right="{$page-margin-right}">
    <fo:region-body region-name="body"
                    margin-top="{$region-body-margin-top}"
                    margin-bottom="{$region-body-margin-bottom}"
                    margin-left="0in" margin-right="0in"
      column-count="{$page-column-count}" column-gap="{$page-column-gap}" />
    <fo:region-before region-name="verso-header" display-align="before"
      extent="36pt"/>
    <fo:region-after region-name="verso-footer" display-align="after"
      extent="24pt"/>
  </fo:simple-page-master>

  <!-- recto page -->
  <fo:simple-page-master master-name="recto" page-height="{$page-height}"
                         page-width="{$page-width}"
                         margin-top="{$page-margin-top}"
                         margin-bottom="{$page-margin-bottom}"
                         margin-left="{$page-margin-left}"
                         margin-right="{$page-margin-right}">
    <fo:region-body region-name="body"
                    margin-top="{$region-body-margin-top}"
                    margin-bottom="{$region-body-margin-bottom}"
                    margin-left="0in" margin-right="0in"
      column-count="{$page-column-count}" column-gap="{$page-column-gap}"/>
    <fo:region-before region-name="recto-header" extent="36pt"
      display-align="before"/>
    <fo:region-after region-name="recto-footer" display-align="after"
      extent="24pt"/>
  </fo:simple-page-master>
</xsl:template>


<xsl:template name="make-page-header">
  <!-- Pass $face in as 'recto' or 'verso' to get titles and page nos
       on facing pages -->
  <xsl:param name="face"/>
  <xsl:param name="center-cell">
    <fo:block/>
  </xsl:param>
    <fo:table border-style="none" width="100%">
      <fo:table-body>
        <fo:table-row>
          <xsl:choose>
            <xsl:when test="$face='recto'">
              <fo:table-cell xsl:use-attribute-sets="page-header-title-cell">
                <fo:block text-align="left">
                  <xsl:call-template name="page-header-title"/>
                </fo:block>
              </fo:table-cell>
            </xsl:when>
            <xsl:when test="$face='verso'">
              <fo:table-cell xsl:use-attribute-sets="page-header-pageno-cell">
                <!--<fo:block text-align="left">
                  <fo:page-number/>
                </fo:block>-->
              </fo:table-cell>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
          <fo:table-cell>
            <xsl:copy-of select="$center-cell"/>
          </fo:table-cell>
          <xsl:choose>
            <xsl:when test="$face='verso'">
              <fo:table-cell xsl:use-attribute-sets="page-header-title-cell">
                <fo:block text-align="right">
                  <xsl:call-template name="page-header-title"/>
                </fo:block>
              </fo:table-cell>
            </xsl:when>
            <xsl:when test="$face='recto'">
              <fo:table-cell xsl:use-attribute-sets="page-header-pageno-cell">
                <fo:block text-align="right">
                  <fo:page-number/>
                </fo:block>
              </fo:table-cell>

            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
</xsl:template>


<xsl:template name="make-page-footer">
  <xsl:param name="center-cell">
    <fo:block/>
  </xsl:param>
  <fo:table border-style="none" width="100%">
    <fo:table-body>
      <fo:table-row>
        <fo:table-cell xsl:use-attribute-sets="page-header-title-cell">
          <fo:block text-align="left">
            <xsl:text>PLOS ONE | www.plosone.org</xsl:text>
          </fo:block>
        </fo:table-cell>
        <fo:table-cell>
          <xsl:copy-of select="$center-cell"/>
        </fo:table-cell>
        <fo:table-cell xsl:use-attribute-sets="page-header-title-cell">
          <fo:block text-align="right">
            <xsl:apply-templates
                select="/article/front/article-meta/pub-date[@pub-type eq 'epub']/month"
                mode="map" />
            <xsl:text> </xsl:text>
            <xsl:apply-templates
                select="/article/front/article-meta/pub-date[@pub-type eq 'epub']/year"
                mode="map" />
            <xsl:text> | Volume </xsl:text>
            <xsl:value-of
                select="/article/front/article-meta/volume" />
            <xsl:text> | Issue </xsl:text>
            <xsl:value-of
                select="/article/front/article-meta/issue" />
            <xsl:text> | </xsl:text>
            <xsl:value-of
                select="/article/front/article-meta/elocation-id" />
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
    </fo:table-body>
  </fo:table>
</xsl:template>

<xsl:template name="set-article-opener">
  <fo:block-container span="all">

    <!-- Change the context just to make the XPaths shorter. -->
    <xsl:for-each select="/article/front/article-meta">
      <fo:block span="all">
        <xsl:apply-templates select="title-group"/>
        <xsl:call-template name="set-correspondence-note"/>
      </fo:block>

      <fo:block xsl:use-attribute-sets="contrib-block">
        <xsl:apply-templates
            select="contrib-group[contrib[@contrib-type eq 'author']]"/>
      </fo:block>

      <fo:block xsl:use-attribute-sets="aff-block aff">
        <xsl:apply-templates
            select="aff[starts-with(@id, 'aff')] |
                    aff-alternatives/aff[starts-with(@id, 'aff')]"
            mode="contrib"/>
      </fo:block>

      <fo:block xsl:use-attribute-sets="po:abstract-box">
        <xsl:variable
            name="abstracts"
            select="abstract[not(@abstract-type='toc')] |
                    trans-abstract[not(@abstract-type='toc')]"/>

        <xsl:apply-templates select="$abstracts"/>

        <!-- Other metadata.  Depending on whether a block is
             formatted from a single element or several, either
             process the element in a particular mode or call a named
             template that does the (often detailed) work from the
             current context.  Mode names correspond (mostly) to the
             titles that are added in the formatted output. -->
        <xsl:call-template name="po:citation" />
        <xsl:apply-templates
            select="contrib-group[contrib[@contrib-type eq 'editor']]"/>
        <xsl:call-template name="po:history" />
        <xsl:apply-templates select="permissions" mode="po:copyright" />
        <xsl:apply-templates select="funding-group" mode="po:funding" />
        <xsl:apply-templates
            select="author-notes/fn[@fn-type eq 'conflict']"
            mode="po:competing" />
        <xsl:apply-templates
            select="author-notes/corresp"
            mode="po:email" />
        <xsl:if
            test="exists(contrib-group/contrib[@contrib-type eq 'author']
                                              [@equal-contrib eq 'yes'])">
          <fo:block xsl:use-attribute-sets="po:other-metadata">
            <xsl:text>&#x262F; These authors contributed equally to this work.</xsl:text>
          </fo:block>
        </xsl:if>
        <xsl:apply-templates select="author-notes/fn[@fn-type eq 'current-aff']" mode="po:other" />
        <xsl:if test="exists(contrib-group/contrib[@contrib-type eq 'author'][@deceased eq 'yes'])">
          <xsl:choose>
            <xsl:when test="exists(author-notes/fn[@fn-type eq 'deceased'])">
              <xsl:apply-templates select="author-notes/fn[@fn-type eq 'deceased']" mode="po:deceased" />
            </xsl:when>
            <xsl:otherwise>
              <fo:block xsl:use-attribute-sets="po:other-metadata">
                <xsl:text>† Deceased.</xsl:text>
              </fo:block>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:apply-templates select="author-notes/fn[@fn-type eq 'other']" mode="po:other" />
      </fo:block>
    </xsl:for-each>
    <fo:block space-before="16pt" space-before.precedence="force" />
  </fo:block-container>
</xsl:template>

<xsl:template name="page-header-title">
  <xsl:for-each select="/article/front/article-meta/title-group/alt-title
                        [@alt-title-type='running-head']">
    <xsl:apply-templates mode="page-header-text"/>
  </xsl:for-each>
  <xsl:if test="empty(/article/front/article-meta/title-group/alt-title
                        [@alt-title-type='running-head'])">
    <xsl:for-each
      select="/article/front/article-meta/title-group/article-title">
    <xsl:apply-templates mode="page-header-text"/>
  </xsl:for-each>
  </xsl:if>
</xsl:template>


<xsl:template match="break" mode="page-header-text">
  <!-- in page headers, line breaks are rendered as plain spaces -->
  <xsl:text> </xsl:text>
</xsl:template>


<xsl:template match="*" mode="page-header-text">
  <!-- inline elements are handled as usual, except their contents
       are processed in mode page-header-text -->
  <xsl:apply-templates select="." mode="format">
    <xsl:with-param name="contents">
      <xsl:apply-templates mode="cover-page"/>
    </xsl:with-param>
  </xsl:apply-templates>
</xsl:template>


<xsl:template match="fn | xref" mode="page-header-text"/>
<!-- footnotes and cross-references are not processed in page-header-text
     mode (used for displaying titles and subtitles on the cover
     page) -->


<!-- ============================================================= -->
<!-- SPECIALIZED FRONT PAGE TEMPLATES                              -->
<!-- ============================================================= -->


<xsl:template match="title-group | trans-title-group">
  <!-- title-group: (article-title, subtitle*, trans-title-group*,
                     alt-title*, fn-group?) -->
  <!-- trans-title-group: (trans-title, trans-subtitle*) -->
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="title-group/article-title">
  <fo:block xsl:use-attribute-sets="firstpage-title">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="title-group/subtitle">
  <fo:block xsl:use-attribute-sets="firstpage-subtitle">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="title-group/alt-title">
  <fo:block xsl:use-attribute-sets="firstpage-alt-title">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template priority="2"
  match="title-group/alt-title[@alt-title-type='running-head']">
  <!-- a running head title is suppressed -->
</xsl:template>


<xsl:template match="trans-title">
  <fo:block xsl:use-attribute-sets="firstpage-trans-title">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="trans-subtitle">
  <fo:block xsl:use-attribute-sets="firstpage-trans-subtitle">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="contrib-group[contrib[@contrib-type eq 'author']]">
  <xsl:apply-templates select="contrib[@contrib-type eq 'author']" />
</xsl:template>

<xsl:template match="contrib[@contrib-type eq 'author']">
  <xsl:if test="position() > 1">
    <xsl:text>, </xsl:text>
  </xsl:if>
  <xsl:apply-templates select="name | collab" />
  <xsl:apply-templates select="xref" />
  <!-- Yin-Yang symbol if equal contributor. -->
  <xsl:if test="@equal-contrib eq 'yes'">
    <fo:inline xsl:use-attribute-sets="superscript">&#x262F;</fo:inline>
  </xsl:if>
  <!-- Show a cross if author is deceased. -->
  <xsl:if test="@deceased eq 'yes'">
    <fo:inline xsl:use-attribute-sets="superscript">†</fo:inline>
  </xsl:if>
  <xsl:apply-templates select="on-behalf-of" />
</xsl:template>

<xsl:template match="on-behalf-of">
  <xsl:text>, </xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<!-- A collaboration following an author working on behalf of the
     collaboration. -->
<xsl:template match="contrib[@contrib-type eq 'author']
                [exists(collab)]
          [preceding-sibling::*[1][self::contrib]
                                  [exists(on-behalf-of)]]"
        priority="5">
  <xsl:apply-templates select="xref" />
</xsl:template>

<!-- PLOS ONE citation.  Expected context is 'article-meta'. -->
<xsl:template name="po:citation">
  <fo:block xsl:use-attribute-sets="po:other-metadata">
    <fo:inline font-weight="bold">Citation:</fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates
        select="contrib-group/contrib[@contrib-type eq 'author']
                                     [position() &lt;= 5]"
        mode="po:citation" />
    <xsl:if
        test="count(contrib-group/contrib[@contrib-type eq 'author']) > 5">, et al.</xsl:if>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="pub-date[@pub-type eq 'collection']/year" />
    <xsl:text>) </xsl:text>
    <xsl:apply-templates select="title-group/article-title" mode="po:citation" />
    <xsl:if test="not(matches(title-group/article-title, '[.?!]$'))">
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:value-of select="../journal-meta/journal-id[@journal-id-type eq 'nlm-ta']" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="volume" />
    <xsl:text>(</xsl:text>
    <xsl:value-of select="issue" />
    <xsl:text>): </xsl:text>
    <xsl:value-of select="elocation-id" />
    <xsl:text>. doi:</xsl:text>
    <xsl:value-of select="article-id[@pub-id-type eq 'doi']" />
  </fo:block>
</xsl:template>

<xsl:template match="contrib" mode="po:citation">
  <xsl:if test="position() > 1">, </xsl:if>
  <xsl:value-of select="name/surname" />
  <xsl:text> </xsl:text>
  <!-- XSLT wants to helpfully put spaces between items in the
       sequence of initials, so explicitly join them with zero-length
       string. -->
  <xsl:value-of
      select="string-join(for $name in tokenize(name/given-names, ' ')
                            return string-join(for $part in tokenize($name, '-')
                                                 return substring($part, 1, 1),
                                               '-'),
             '')" />
</xsl:template>

<xsl:template match="article-title" mode="po:citation">
  <!-- Switch to 'format' mode to handle <italic>, etc. -->
  <xsl:apply-templates mode="format" />
</xsl:template>

<xsl:template match="contrib-group[contrib[@contrib-type eq 'editor']]">
  <fo:block xsl:use-attribute-sets="po:other-metadata">
    <fo:inline font-weight="bold">Editor:</fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="contrib[@contrib-type eq 'editor']" mode="editor" />
  </fo:block>
</xsl:template>

<xsl:template match="contrib" mode="editor">
  <xsl:apply-templates select="name" />
  <xsl:text>, </xsl:text>
  <xsl:value-of
      select="key('element-by-id',
                  xref/@rid)" />
</xsl:template>

<!-- PLOS ONE received, accepted, and published dates.  Expected
     context is 'article-meta'. -->
<xsl:template name="po:history">
  <fo:block xsl:use-attribute-sets="po:other-metadata">
    <fo:inline font-weight="bold">Received</fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates
        select="history/date[@date-type eq 'received']"
        mode="format-date" />
    <xsl:text>; </xsl:text>
    <fo:inline font-weight="bold">Accepted</fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates
        select="history/date[@date-type eq 'accepted']"
        mode="format-date" />
    <xsl:text>; </xsl:text>
    <fo:inline font-weight="bold">Published</fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates
        select="pub-date[@pub-type eq 'epub']"
        mode="format-date" />
  </fo:block>
</xsl:template>

<xsl:template match="anonymous" mode="contrib">
  <fo:block>
    <xsl:text>Anonymous</xsl:text>
    <xsl:call-template name="contrib-amend">
      <xsl:with-param name="last-contrib"
                      select="not(../following-sibling::contrib)"/>
      <!-- passes Boolean false if we are inside the last
           contrib -->
    </xsl:call-template>
  </fo:block>
</xsl:template>

<!-- PLOS ONE copyright and license information. -->
<xsl:template match="permissions" mode="po:copyright">
  <fo:block xsl:use-attribute-sets="po:other-metadata">
    <xsl:if test="exists(copyright-holder)">
      <fo:inline font-weight="bold">Copyright:</fo:inline>
      <xsl:text> ©</xsl:text>
      <xsl:for-each select="copyright-year, copyright-holder">
        <xsl:text> </xsl:text>
        <xsl:apply-templates />
      </xsl:for-each>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:apply-templates
        select="license" />
  </fo:block>
</xsl:template>

<!-- PLOS ONE funding information. -->
<xsl:template match="funding-group" mode="po:funding">
  <fo:block xsl:use-attribute-sets="po:other-metadata">
    <fo:inline font-weight="bold">Funding:</fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="funding-statement" />
  </fo:block>
</xsl:template>

<!-- PLOS ONE 'Competing interests' text. -->
<xsl:template match="fn" mode="po:competing">
  <fo:block xsl:use-attribute-sets="po:other-metadata">
    <fo:inline font-weight="bold">Competing interests:</fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="p/node()" />
  </fo:block>
</xsl:template>

<!-- PLOS ONE contact email address(es). -->
<xsl:template match="corresp" mode="po:email">
  <fo:block xsl:use-attribute-sets="po:other-metadata">
    <xsl:call-template name="assign-id"/>
    <xsl:apply-templates />
  </fo:block>
</xsl:template>

<!-- PLOS ONE 'deceased' and 'other' footnote. -->
<xsl:template match="fn" mode="po:other po:deceased">
  <fo:block xsl:use-attribute-sets="po:other-metadata">
    <xsl:call-template name="assign-id"/>
    <xsl:if test="@fn-type eq 'current-aff' and
                  position() > 1">
      <xsl:attribute name="space-before" select="'0pt'" />
      <xsl:attribute name="space-before.precedence" select="'force'" />
    </xsl:if>
    <xsl:if test="exists(label)">
      <xsl:apply-templates select="label/node()" />
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="p/node()" />
  </fo:block>
</xsl:template>

<xsl:template match="anonymous" mode="contrib">
  <fo:block>
    <xsl:text>Anonymous</xsl:text>
    <xsl:call-template name="contrib-amend">
      <xsl:with-param name="last-contrib"
                      select="not(../following-sibling::contrib)"/>
      <!-- passes Boolean false if we are inside the last
           contrib -->
    </xsl:call-template>
  </fo:block>
</xsl:template>


<xsl:template match="collab" mode="contrib">
  <fo:block>
    <xsl:apply-templates/>
    <xsl:call-template name="contrib-amend">
      <xsl:with-param name="last-contrib"
                      select="not(../following-sibling::contrib)"/>
      <!-- passes Boolean false if we are inside the last
           contrib -->
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template match="collab-alternatives/*" mode="contrib">
  <fo:block>
    <xsl:apply-templates/>
    <xsl:call-template name="contrib-amend">
      <xsl:with-param name="last-contrib"
                      select="not(../following-sibling::*)
                              and not(../../following-sibling::contrib)"/>
      <!-- passes Boolean false if we are inside the last
           contrib -->
    </xsl:call-template>
  </fo:block>
</xsl:template>


<xsl:template match="contrib/name" mode="contrib">
  <fo:block>
    <!-- (surname, given-names?, prefix?, suffix?) -->
    <xsl:call-template name="write-name"/>
    <xsl:call-template name="contrib-amend">
      <xsl:with-param name="last-contrib"
                      select="not(../following-sibling::contrib)"/>
      <!-- passes Boolean false if we are inside the last
           contrib -->
    </xsl:call-template>
  </fo:block>
</xsl:template>


<xsl:template match="contrib/name-alternatives/name" mode="contrib">
  <fo:block>
    <!-- (surname, given-names?, prefix?, suffix?) -->
    <xsl:call-template name="write-name"/>
    <xsl:call-template name="contrib-amend">
      <xsl:with-param name="last-contrib"
                      select="not(../following-sibling::*)
                              and not(../../following-sibling::contrib)"/>
      <!-- passes Boolean false if we are inside the last
           contrib -->
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template match="contrib/name-alternatives/string-name" mode="contrib">
  <fo:block>
    <xsl:apply-templates select="."/>
    <xsl:call-template name="contrib-amend">
      <xsl:with-param name="last-contrib"
                      select="not(../following-sibling::*)
                              and not(../../following-sibling::contrib)"/>
      <!-- passes Boolean false if we are inside the last
           contrib -->
    </xsl:call-template>
  </fo:block>
</xsl:template>


<xsl:template match="contrib/name-alternatives/string-name" mode="contrib">
  <fo:block>
    <!-- (surname, given-names?, prefix?, suffix?) -->
    <xsl:apply-templates/>
    <xsl:call-template name="contrib-amend">
      <xsl:with-param name="last-contrib"
                      select="not(../following-sibling::*)
                              and not(../following-sibling::contrib)"/>
      <!-- passes Boolean false if we are inside the last
           contrib -->
    </xsl:call-template>
  </fo:block>
</xsl:template>


<xsl:template name="contrib-amend">
  <!-- the context will be a contrib/anonymous, contrib/collab,
       contrib/collab-alternatives/collab, contrib/name, or
       contrib/name-alternatives/*; this template adds
       contrib/degrees and contrib/xref siblings to the last of
       these available within the contrib -->
  <xsl:param name="last-contrib" select="false()"/>
  <!-- passed as 'true' for the last contrib only -->
  <xsl:variable name="contrib" select="ancestor::contrib"/>
  <xsl:variable name="last-in-contrib"
                select="generate-id() = generate-id(
                        ($contrib/anonymous | $contrib/collab | $contrib/collab-alternatives/collab |
                        $contrib/name | $contrib/name-alternatives/*)[last()] )"/>
  <xsl:if test="$last-in-contrib">
    <xsl:apply-templates select="$contrib/degrees | $contrib/xref" mode="contrib"/>
    <xsl:if test="$last-contrib">
      <xsl:apply-templates select="$contrib/following-sibling::xref"/>
    </xsl:if>
  </xsl:if>
</xsl:template>


<xsl:template match="degrees" mode="contrib">
  <xsl:text>, </xsl:text>
  <xsl:apply-templates/>
</xsl:template>


  <xsl:template match="xref" mode="contrib">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <!-- inside journal-meta/contrib-group, xref elements don't
       generate footnotes -->
  <xsl:template match="journal-meta/contrib-group//xref" mode="contrib">
    <!--<xsl:message>Warning xref not being handled right</xsl:message>-->
    <fo:inline xsl:use-attribute-sets="footnote-ref">
      <xsl:if test="preceding-sibling::*[1]/self::xref">,</xsl:if>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- PLOS ONE includes xref/sup, so ignore sup since adding
       superscripts already. -->
  <xsl:template match="contrib-group//xref/sup">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="contrib-id" mode="contrib">
  <xsl:text> [</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template name="contrib-info">
  <fo:block xsl:use-attribute-sets="contrib">
    <xsl:apply-templates mode="contrib"
      select="address | aff | aff-alternatives/aff | author-comment | email |
              ext-link | on-behalf-of | role | uri"/>
  </fo:block>
</xsl:template>


<xsl:template mode="contrib"
  match="address[empty(addr-line) or empty(*[2])]">
  <!-- when we have no addr-line or a single child, we generate
       a single unlabelled line -->
  <fo:block xsl:use-attribute-sets="address-line">
     <xsl:apply-templates mode="inline"/>
  </fo:block>
</xsl:template>


<xsl:template mode="contrib" match="address">
  <!-- when we have an addr-line we generate an unlabelled block -->
  <fo:block xsl:use-attribute-sets="address">
      <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template mode="contrib" priority="2" match="address/*">
  <!-- being sure to override other templates for these
       element types -->
  <fo:block xsl:use-attribute-sets="address-line">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template mode="contrib" match="aff">
  <xsl:if test="position() > 1">
    <xsl:text>, </xsl:text>
  </xsl:if>
  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label-text"/>
  </xsl:variable>
  <xsl:copy-of select="$label"/>
  <xsl:if test="normalize-space(string($label))">
    <xsl:text>&#xA0;</xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="aff">
   <fo:block xsl:use-attribute-sets="paragraph aff">
     <xsl:variable name="label">
       <xsl:apply-templates select="." mode="label-text"/>
     </xsl:variable>
     <xsl:copy-of select="$label"/>
     <xsl:if test="normalize-space(string($label))">
       <xsl:text> </xsl:text>
     </xsl:if>
     <xsl:apply-templates mode="inline"/>
   </fo:block>
</xsl:template>


<xsl:template match="author-comment | bio" mode="contrib">
  <!-- these elements are not supported in this version -->
</xsl:template>



<xsl:template match="role" mode="contrib">
  <fo:block xsl:use-attribute-sets="contrib">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="email" mode="contrib">
  <fo:block xsl:use-attribute-sets="contrib">
    <xsl:apply-templates select="."/>
  </fo:block>
</xsl:template>


<xsl:template match="ext-link | uri" mode="contrib">
  <fo:block>
    <xsl:apply-templates select="."/>
  </fo:block>
</xsl:template>


<xsl:template match="abstract | trans-abstract">
  <fo:block xsl:use-attribute-sets="abstract">
    <xsl:apply-templates select="." mode="label"/>
    <xsl:if test="empty(title)">
      <xsl:call-template name="main-title">
        <xsl:with-param name="contents">
          <fo:inline xsl:use-attribute-sets="generated">
            <xsl:if test="self::trans-abstract">Translated </xsl:if>
            <xsl:text>Abstract</xsl:text>
          </fo:inline>
        </xsl:with-param>
  <xsl:with-param name="attributes"
      select="pf:abstract-title-attributes(.)"
      as="attribute()*" />
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template name="set-correspondence-note">
  <!-- context node is article-meta -->
  <xsl:if test="contrib-group/contrib[@corresp='yes']">
      <xsl:call-template name="make-footnote">
        <xsl:with-param name="contents">
          <fo:block space-before="0pt" space-after="0pt">
            <xsl:text>Correspondence to: </xsl:text>
          <xsl:for-each select="contrib-group/contrib[@corresp='yes']">
            <xsl:call-template name="name-sequence">
              <xsl:with-param name="names"
                select="name | name-alternatives/name |
                        collab | collab-alternatives/collab"/>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="email">
                <xsl:text>, </xsl:text>
                <fo:inline xsl:use-attribute-sets="email">
                  <xsl:apply-templates select="email"/>
                </fo:inline>
              </xsl:when>
              <xsl:when test="address">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="address"/>
              </xsl:when>
            </xsl:choose>
            <xsl:if test="not(position()=last())">; </xsl:if>
          </xsl:for-each>
          <xsl:text>.</xsl:text>
          </fo:block>
        </xsl:with-param>
      </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- ============================================================= -->
<!-- DEFAULT TEMPLATES (mostly in no mode)                         -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!-- Titles                                                        -->
<!-- ============================================================= -->


<xsl:template match="ref-list/title" priority="5">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:param name="attributes" as="attribute()*" />
  <!-- Default to spanning ref-list/title. -->
  <xsl:param name="title-span" select="'all'" tunnel="yes" as="xs:string" />
  <xsl:call-template name="main-title">
    <xsl:with-param name="contents" select="$contents" />
    <xsl:with-param name="attributes" select="$attributes" as="attribute()*" />
    <xsl:with-param name="title-span" select="$title-span" tunnel="yes" as="xs:string" />
  </xsl:call-template>
</xsl:template>

<xsl:template name="main-title"
  match="body/*/title |
  back/title | back[empty(title)]/*/title" priority="2">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:param name="attributes" as="attribute()*" />
  <xsl:param name="title-span" select="'none'" tunnel="yes" as="xs:string" />
  <xsl:if test="normalize-space(string($contents))">
    <fo:block xsl:use-attribute-sets="main-title" span="{$title-span}">
      <xsl:copy-of select="$attributes"/>
      <xsl:copy-of select="$contents"/>
    </fo:block>
  </xsl:if>
</xsl:template>


<xsl:template name="section-title"
  match="abstract/title | notes/title | body/*/*/title |
         back[title]/*/title | back[empty(title)]/*/*/title">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:param name="title-span" select="'none'" tunnel="yes" as="xs:string" />
  <xsl:if test="normalize-space(string($contents))">
    <fo:block xsl:use-attribute-sets="section-title" span="{$title-span}">
      <xsl:copy-of select="$contents"/>
    </fo:block>
  </xsl:if>
</xsl:template>


<xsl:template name="subsection-title"
  match="body/*/*/*/title |
         back[title]/*/*/title | back[empty(title)]/*/*/*/title">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:if test="normalize-space(string($contents))">
    <fo:block xsl:use-attribute-sets="subsection-title">
      <xsl:copy-of select="$contents"/>
    </fo:block>
  </xsl:if>
</xsl:template>


<xsl:template name="block-title" priority="2"
  match="abstract/*/*/title | author-notes/title |
         list/title | def-list/title | boxed-text/title |
         verse-group/title | glossary/title |
         gloss-group/title | kwd-group/title">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:if test="normalize-space(string($contents))">
    <fo:block xsl:use-attribute-sets="block-title">
      <xsl:copy-of select="$contents"/>
    </fo:block>
  </xsl:if>
</xsl:template>


<xsl:template match="title">
<!-- default template for any other titles found -->
  <xsl:if test="normalize-space(string(.))">
    <fo:block xsl:use-attribute-sets="title">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:if>
</xsl:template>

<xsl:template match="subtitle">
  <xsl:if test="normalize-space(string(.))">
    <fo:block xsl:use-attribute-sets="subtitle">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:if>
</xsl:template>

<xsl:template match="label">
  <!-- label is suppressed in default traversal; where
       labels are wanted they are provided by matching
       elements in mode 'label' -->
</xsl:template>

<!-- Drop from normal processing. -->
<xsl:template match="sec[supplementary-material]" />

<!-- Process as part of the back matter. -->
<xsl:template match="sec[supplementary-material]" mode="back">
  <fo:block xsl:use-attribute-sets="section" role="supplementary-material">
    <xsl:call-template name="set-outset-label"/>
    <xsl:apply-templates select="title"/>
    <xsl:apply-templates select="sec-meta"/>
    <xsl:apply-templates select="* except (title, sec-meta, label)"/>
  </fo:block>
</xsl:template>

<xsl:template match="sec">
  <fo:block xsl:use-attribute-sets="section">
    <xsl:if test="exists(@sec-type)">
      <xsl:attribute name="role" select="@sec-type" />
    </xsl:if>
    <xsl:call-template name="set-outset-label"/>
    <xsl:apply-templates select="title"/>
    <xsl:apply-templates select="sec-meta"/>
    <xsl:apply-templates select="* except (title, sec-meta, label)"/>
  </fo:block>
</xsl:template>

<xsl:template match="body/sec/sec/sec">
  <xsl:apply-templates mode="run-in-title" />
</xsl:template>

<xsl:template match="body/sec/sec/sec[empty(*[2][self::p])]"
	      priority="5">
  <xsl:call-template name="run-in-title">
    <xsl:with-param name="title" select="title" as="element(title)?" />
    <xsl:with-param name="children" select="()" />
  </xsl:call-template>
  <xsl:apply-templates select="* except title" />
</xsl:template>


<xsl:template match="sec-meta">
 <fo:block xsl:use-attribute-sets="section-metadata">
   <!-- content model: (contrib-group*, kwd-group*, permissions?) -->
   <xsl:apply-templates/>
 </fo:block>
</xsl:template>


<xsl:template match="sec-meta/kwd-group">
  <fo:block xsl:use-attribute-sets="paragraph">
    <fo:inline xsl:use-attribute-sets="generated">
      <xsl:text>Keyword</xsl:text>
      <xsl:if test="count(kwd) &gt; 1">s</xsl:if>
      <xsl:text>:</xsl:text>
    </fo:inline>
    <xsl:for-each select="kwd">
    <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each>
  </fo:block>
</xsl:template>


<xsl:template match="p">
  <fo:block xsl:use-attribute-sets="paragraph">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="abstract/sec">
  <xsl:apply-templates select="* except title" />
</xsl:template>

<xsl:template match="abstract/p">
  <fo:block xsl:use-attribute-sets="abstract-paragraph">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="abstract/sec/p[1]">
  <fo:block xsl:use-attribute-sets="abstract-paragraph">
    <fo:inline xsl:use-attribute-sets="abstract-section-title">
      <xsl:apply-templates select="preceding-sibling::*[1]/node()" />
      <xsl:text>:</xsl:text>
    </fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="def[empty(preceding-sibling::def)]/p[1]">
  <!-- matching the first p inside a first def -->
  <fo:block xsl:use-attribute-sets="paragraph-tight">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="permissions" name="permissions">
  <!-- allowed inside:
    app, array, article-meta, boxed-text, chem-struct-wrap,
    disp-quote, fig, front-stub, graphic, media, preformat,
    sec-meta, statement, supplementary-material, table-wrap,
    table-wrap-foot, verse-group
    -->
  <!-- content model:
    (copyright-statement*, copyright-year*, copyright-holder*,
     license*) -->
  <fo:block>
    <xsl:apply-templates select="copyright-statement"/>
    <xsl:if test="copyright-year | copyright-holder">
      <fo:block>
        <fo:inline xsl:use-attribute-sets="generated">Copyright </fo:inline>
        <xsl:for-each select="copyright-year | copyright-holder">
          <xsl:apply-templates/>
          <xsl:if test="position() &lt; last()">
            <fo:inline xsl:use-attribute-sets="generated">, </fo:inline>
          </xsl:if>
        </xsl:for-each>
      </fo:block>
    </xsl:if>
    <!-- Assuming only one license/license-p. -->
    <xsl:apply-templates select="license"/>
  </fo:block>
</xsl:template>


<xsl:template name="notes">
  <xsl:call-template name="subsection-title">
    <xsl:with-param name="contents">
      <fo:wrapper xsl:use-attribute-sets="generated">Notes</fo:wrapper>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="copyright-statement">
  <fo:block xsl:use-attribute-sets="copyright-line">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<!-- ============================================================= -->
<!-- Figures, lists and block-level objects                        -->
<!-- ============================================================= -->


<xsl:template match="address">
  <xsl:choose>
    <!-- address appears as a sequence of inline elements if
         it has no addr-line and the parent may contain text -->
    <xsl:when
      test="empty(addr-line) and
      (parent::collab | parent::p | parent::license-p |
       parent::named-content | parent::styled-content)">
      <xsl:call-template name="inline-address"/>
    </xsl:when>
    <xsl:otherwise>
      <fo:block xsl:use-attribute-sets="address">
        <xsl:apply-templates/>
      </fo:block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="inline-address">
  <!-- emits element children in a simple comma-delimited sequence -->
  <xsl:for-each select="*">
    <xsl:if test="position() &gt; 1">, </xsl:if>
    <xsl:apply-templates/>
  </xsl:for-each>
</xsl:template>


<xsl:template match="address/*" priority="2">
  <fo:block xsl:use-attribute-sets="address-line">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="address/email" priority="3">
  <fo:block xsl:use-attribute-sets="email address-line">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="address/ext-link" priority="3">
  <fo:block xsl:use-attribute-sets="ext-link address-line">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="address/uri" priority="3">
  <fo:block xsl:use-attribute-sets="address-line uri">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="alternatives">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="array">
  <fo:block xsl:use-attribute-sets="array">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="disp-formula-group">
  <fo:block xsl:use-attribute-sets="disp-formula-group">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="inline-graphic">
  <xsl:variable name="href" select="pf:resolve-href(.)" as="xs:string" />
  <fo:external-graphic src="url('{$href}')" content-width="auto"
    content-height="100%" scaling="uniform"/>
</xsl:template>


<xsl:template match="graphic | media">
  <xsl:param name="allow-float" select="true()" tunnel="yes" as="xs:boolean" />
  <xsl:param name="caption-height" select="'0pt'" as="xs:string" tunnel="yes" />
  <xsl:variable name="href" select="pf:resolve-href(.)" as="xs:string" />
  <xsl:if test="$debug.figure">
    <xsl:message select="tokenize(@xlink:href, '/')[last()]" />
  </xsl:if>
  <xsl:if test="unparsed-text-available(replace($href, '\.tif$', '.identify'))">
    <xsl:variable
        name="tokens"
        select="tokenize(normalize-space(unparsed-text(replace($href, '\.tif$', '.identify'))), ':')"
        as="xs:string+" />
    <xsl:if test="$debug.figure">
      <xsl:message
          select="normalize-space(unparsed-text(replace($href, '\.tif$', '.identify')))" />
      <xsl:message
          select="concat('Intrinsic width: ',
                         xs:integer($tokens[1]) div
                          (xs:double(substring-before($tokens[3], ' ')) *
                          (if (substring-after($tokens[3], ' ') eq 'PixelsPerCentimeter')
                             then 2.54
                           else 1)),
                         'in')" />
    </xsl:if>
  </xsl:if>
  <xsl:call-template name="set-float">
    <!-- graphics and media are only allowed to float
         when they appear outside the named elements -->
    <xsl:with-param name="allow-float"
      select="$allow-float and
              empty(ancestor::boxed-text |
                    ancestor::chem-struct-wrap |
                    ancestor::chem-struct-wrapper |
                    ancestor::disp-formula |
                    ancestor::fig | ancestor::fig-group |
                    ancestor::preformat |
                    ancestor::supplementary-material |
                    ancestor::table-wrap |
                    ancestor::table-wrap-group)"
      tunnel="yes"
      as="xs:boolean" />
    <xsl:with-param name="contents">
      <fo:block-container xsl:use-attribute-sets="media-object">
        <xsl:apply-templates select="@orientation"/>
        <fo:wrapper start-indent="0pc">
  <xsl:attribute name="max-height" select="'100%'" />
          <fo:block line-stacking-strategy="max-height">
            <fo:external-graphic src="url('{$href}')"
              content-width="scale-down-to-fit"
              scaling="uniform" width="100%" max-height="100% - {$caption-height}" />
            <xsl:apply-templates select="." mode="label"/>
            <xsl:apply-templates/>
          </fo:block>
        </fo:wrapper>
      </fo:block-container>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="alt-text">
  <!-- not handled with graphic or inline-graphic -->
</xsl:template>


<xsl:template match="author-notes">
  <fo:block xsl:use-attribute-sets="author-notes">
    <xsl:apply-templates select="." mode="label"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="fn-group">
  <fo:block xsl:use-attribute-sets="fn-group">
    <xsl:apply-templates select="." mode="label"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="long-desc">
  <fo:block xsl:use-attribute-sets="long-desc">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="open-access">
  <fo:block xsl:use-attribute-sets="open-access">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="sig-block">
  <fo:block xsl:use-attribute-sets="sig-block">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="attrib">
  <fo:block xsl:use-attribute-sets="attrib">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<!-- floating objects include
   boxed-text, chem-struct-wrap, fig, fig-group, graphic,
   media, preformat, supplementary-material, table-wrap,
   table-wrap-group -->


<xsl:template match="boxed-text">
  <xsl:call-template name="set-float">
    <xsl:with-param name="contents">
      <fo:block-container xsl:use-attribute-sets="boxed-text">
        <xsl:apply-templates select="@orientation"/>
        <fo:wrapper start-indent="0pc" end-indent="0pc">
          <xsl:apply-templates select="." mode="label"/>
          <xsl:apply-templates/>
        </fo:wrapper>
      </fo:block-container>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="chem-struct-wrap">
  <xsl:call-template name="set-float">
    <xsl:with-param name="contents">
      <fo:block-container xsl:use-attribute-sets="chem-struct-box">
        <xsl:apply-templates select="@orientation"/>
        <fo:wrapper start-indent="0pc">
          <xsl:apply-templates select="." mode="label"/>
          <xsl:apply-templates/>
        </fo:wrapper>
      </fo:block-container>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="chem-struct-wrap/chem-struct |
                     chem-struct-wrapper/chem-struct">
  <fo:block xsl:use-attribute-sets="chem-struct">
    <xsl:apply-templates select="." mode="label"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="fig | fig-group">
  <xsl:variable name="href" select="pf:resolve-href(graphic)" as="xs:string" />
  <xsl:variable name="column-wide" select="pf:is-column-wide(graphic)"/>
  <xsl:if test="$debug.figure">
    <xsl:message select="tokenize($href, '/')[last()]" />
  </xsl:if>
  <xsl:if test="unparsed-text-available(replace($href, '\.tif$', '.identify'))">
    <xsl:if test="$debug.figure">
      <xsl:message
          select="normalize-space(unparsed-text(replace($href, '\.tif$', '.identify')))" />
    </xsl:if>
  </xsl:if>
  <xsl:call-template name="set-float">
    <xsl:with-param name="column-wide" select="$column-wide" />
    <xsl:with-param name="contents">
      <fo:block-container xsl:use-attribute-sets="fig-box">
        <xsl:apply-templates select="@orientation"/>
        <xsl:call-template name="assign-id"/>
        <fo:wrapper start-indent="0pc">
          <xsl:apply-templates
              select="(disp-formula | disp-formula-group | chem-struct-wrap |
                      disp-quote | speech | statement | verse-group | table-wrap | p |
                      def-list | list | alternatives | array | graphic | media | preformat)">
            <xsl:with-param name="caption-height"
                            select="pf:caption-height(., $column-wide)"
                            as="xs:string"
                            tunnel="yes" />
          </xsl:apply-templates>
          <xsl:if test="$debug.figure">
            <xsl:message select="concat('column-wide: ', @id, ' : ', $column-wide)" />
            <xsl:message select="concat('caption length: ', @id, ' : ', string-length(caption))" />
            <xsl:message select="concat('caption height: ', @id, ' : ', pf:caption-height(., $column-wide))" />
          </xsl:if>
          <xsl:apply-templates select="caption" mode="run-in-title"/>
          <xsl:apply-templates select="object-id" />
        </fo:wrapper>
      </fo:block-container>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="fig-group/fig">
  <fo:block xsl:use-attribute-sets="fig">
    <xsl:apply-templates/>
    <xsl:apply-templates select="." mode="label"/>
  </fo:block>
</xsl:template>

<xsl:template match="supplementary-material">
  <fo:block-container xsl:use-attribute-sets="supplementary">
    <xsl:call-template name="assign-id"/>
    <xsl:apply-templates mode="run-in-title" />
  </fo:block-container>
</xsl:template>

<xsl:template match="caption[empty(p)]" mode="run-in-title">
  <xsl:call-template name="run-in-title">
    <xsl:with-param name="label" select="../label" as="element(label)?" />
    <xsl:with-param name="title" select="title" as="element(title)?" />
    <xsl:with-param name="children" select="()" />
  </xsl:call-template>
  <xsl:apply-templates select="* except title" />
</xsl:template>

<!-- Do not process label or title where they occur. -->
<xsl:template match="label | title" mode="run-in-title" />

<xsl:template match="caption/p[1] | sec/p[1]"
	      name="run-in-title"
	      mode="run-in-title" priority="5">
  <xsl:param name="label" select="../../label" as="element(label)?" />
  <xsl:param name="title" select="../title" as="element(title)?" />
  <xsl:param name="children" select="node()" as="node()*" />
  <fo:block xsl:use-attribute-sets="paragraph">
    <xsl:if test="parent::caption">
      <xsl:attribute name="space-before" select="'5pt'" />
      <xsl:attribute name="text-indent" select="'0pt'" />
    </xsl:if>
    <xsl:apply-templates select="$label, $title" mode="run-in-title-title" />
    <xsl:apply-templates select="$children" />
  </fo:block>
</xsl:template>

<!-- Fallback to default mode for other nodes. -->
<xsl:template match="node()" mode="run-in-title">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="caption" mode="run-in-title">
  <xsl:apply-templates mode="#current" />
</xsl:template>

<!-- A title 'run-in' in the same block as the caption looks a lot
     like the label. -->
<xsl:template match="label | title" mode="run-in-title-title">
  <fo:inline xsl:use-attribute-sets="label">
    <xsl:apply-templates />
    <xsl:if test="not(ends-with(., '.'))">
      <xsl:text>.</xsl:text>
    </xsl:if>
  </fo:inline>
  <xsl:text>&#xA0;&#xA0;</xsl:text>
</xsl:template>

<xsl:template match="caption/p" mode="run-in-title">
  <fo:block xsl:use-attribute-sets="paragraph-no-indent">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="table-wrap | table-wrap-group"
              name="table-wrap">
  <xsl:param name="table-wrap" select="." as="element(table-wrap)" />
  <xsl:param name="float-attributes"
             as="attribute()*">
    <xsl:attribute name="axf:float-reference" select="'page'" />
    <xsl:attribute name="axf:float-move" select="'auto-next'" />
    <xsl:attribute name="axf:float-margin-y" select="'10pt'" />
  </xsl:param>
  <xsl:param name="table-attributes"
             as="attribute()*">
    <xsl:attribute name="width" select="'100%'" />
    <xsl:attribute name="reference-orientation" select="'0'" />
    <xsl:attribute name="height" select="'auto'" />
    <xsl:sequence
        select="if (exists($area-tree-doc))
                  then pf:table-attributes($table-wrap, $area-tree-doc)
                else ()" />
  </xsl:param>
  <xsl:call-template name="set-float">
    <xsl:with-param name="float-attributes"
                    select="$float-attributes"
                    as="attribute()*"/>
    <xsl:with-param name="contents">
      <fo:block-container>
        <xsl:sequence select="$table-attributes" />
        <fo:block-container
            xsl:use-attribute-sets="table-box" border-left="1pt solid black">
          <xsl:if test="$table-wrap//table[@width='100%']">
            <xsl:attribute name="start-indent" select="'0pc'" />
          </xsl:if>
          <xsl:apply-templates select="@orientation"/>
          <fo:wrapper start-indent="0pc">
            <xsl:call-template name="assign-id">
              <xsl:with-param name="node" select="$table-wrap" />
            </xsl:call-template>
            <xsl:apply-templates select="$table-wrap" mode="label"/>
            <xsl:apply-templates select="$table-wrap/(* except object-id)"/>
            <xsl:apply-templates
                mode="footnote"
                select="$table-wrap//fn[empty(ancestor::table-wrap-foot)]"/>
            <xsl:apply-templates select="$table-wrap/object-id"/>
          </fo:wrapper>
        </fo:block-container>
      </fo:block-container>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="table-wrap-group/table-wrap">
  <fo:block xsl:use-attribute-sets="table-wrap">
    <xsl:call-template name="assign-id"/>
    <xsl:apply-templates select="." mode="label"/>
    <xsl:apply-templates/>
    <xsl:apply-templates mode="footnote"
      select=".//fn[empty(ancestor::table-wrap-foot)]"/>
  </fo:block>
</xsl:template>


<xsl:template match="table-wrap-foot">
  <fo:block xsl:use-attribute-sets="table-wrap-foot">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="caption">
  <fo:block xsl:use-attribute-sets="caption">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- Drop any graphic alternative. -->
<xsl:template match="table-wrap/alternatives/graphic" />

<xsl:template match="disp-formula">
  <fo:block xsl:use-attribute-sets="disp-formula">
    <xsl:call-template name="assign-id"/>
    <fo:leader leader-length.optimum="50%"/>
    <!-- Current PLOS XML includes a TAB character between mml:math
         and label that interferes with keeping on one line. -->
    <xsl:apply-templates select="*"/>
    <fo:leader leader-length.optimum="50%"/>
    <xsl:apply-templates select="." mode="label"/>
  </fo:block>
</xsl:template>


<xsl:template match="disp-quote">
  <fo:block xsl:use-attribute-sets="disp-quote">
    <xsl:call-template name="assign-id"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="preformat">
  <!-- note that per the DTD (and therefore whenever processed with a
       DTD) this element has @position='float' by default. -->
  <xsl:param name="allow-float" select="true()" tunnel="yes" as="xs:boolean"/>
  <xsl:call-template name="set-float">
    <xsl:with-param name="allow-float"
      select="$allow-float and
        empty(ancestor::bio | ancestor::boxed-text | ancestor::chem-struct |
            ancestor::chem-struct-wrap | ancestor::chem-struct-wrapper |
            ancestor::disp-formula |  ancestor::disp-quote |
            ancestor::fig | ancestor::glossary | ancestor::gloss-group |
            ancestor::supplementary-material |
            ancestor::disp-formula | ancestor::table-wrap)"
      tunnel="yes"
      as="xs:boolean" />
    <xsl:with-param name="contents">
      <fo:block-container xsl:use-attribute-sets="preformat-box">
        <xsl:apply-templates select="@orientation"/>
        <fo:wrapper start-indent="0pc">
          <fo:block xsl:use-attribute-sets="preformat">
        <xsl:apply-templates/>
          </fo:block>
        </fo:wrapper>
      </fo:block-container>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="@orientation">
  <xsl:if test=".='landscape'">
    <xsl:attribute name="reference-orientation" select="'90'" />
    <xsl:attribute name="width" select="'4in'" />
  </xsl:if>
</xsl:template>


<xsl:template match="table-wrap-group/@orientation |
  table-wrap/@orientation">
  <xsl:if test=".='landscape'">
    <xsl:attribute name="reference-orientation" select="'90'" />
    <xsl:attribute name="width" select="'6in'" />
  </xsl:if>
</xsl:template>


<xsl:template match="textual-form">
  <fo:block xsl:use-attribute-sets="textual-form">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="speech">
  <fo:block xsl:use-attribute-sets="speech">
    <xsl:apply-templates mode="speech"/>
  </fo:block>
</xsl:template>


<xsl:template match="speech/speaker" mode="speech"/>


<xsl:template match="speech/p" mode="speech">
  <fo:block xsl:use-attribute-sets="paragraph">
    <xsl:apply-templates
      select="self::p[empty(preceding-sibling::p)]/../speaker"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="speech/speaker">
  <xsl:call-template name="bold"/>
  <fo:inline xsl:use-attribute-sets="generated">: </fo:inline>
</xsl:template>


<xsl:template match="statement">
  <fo:block xsl:use-attribute-sets="statement">
    <xsl:apply-templates select="." mode="label"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="verse-group">
  <fo:block-container xsl:use-attribute-sets="verse">
    <fo:wrapper start-indent="0pc">
      <xsl:call-template name="assign-id"/>
      <xsl:apply-templates/>
    </fo:wrapper>
  </fo:block-container>
</xsl:template>


<xsl:template match="verse-line">
  <fo:block xsl:use-attribute-sets="verse-line">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="def-list">
  <fo:block xsl:use-attribute-sets="def-list">
    <xsl:apply-templates select="." mode="label"/>
    <!-- content model is
       (label?, title?, term-head?, def-head?, def-item*, def-list*)-->
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="def-list/def-list">
  <fo:block xsl:use-attribute-sets="sub-def-list">
    <xsl:apply-templates select="." mode="label"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="term-head">
  <xsl:call-template name="def-list-head"/>
</xsl:template>


<xsl:template match="def-head">
  <!-- def-head makes a line only if it is not accompanied
       by a term-head; if it is, it's already been done -->
  <xsl:if test="empty(preceding-sibling::term-head)">
    <xsl:call-template name="def-list-head"/>
  </xsl:if>
</xsl:template>


<xsl:template name="def-list-head">
  <!-- The calling context is either a term-head or a def-head
       (the latter only if there is no term-head); this
       makes a line containing either or both, positioning
       each correctly -->
  <fo:block xsl:use-attribute-sets="def-list-head">
    <fo:inline xsl:use-attribute-sets="term-head">
      <xsl:apply-templates mode="def-list-head" select="self::term-head"/>
    </fo:inline>
    <fo:inline xsl:use-attribute-sets="def-head">
      <xsl:apply-templates mode="def-list-head"
        select="self::def-head | following-sibling::def-head"/>
    </fo:inline>
  </fo:block>
</xsl:template>


<xsl:template match="term-head | def-head" mode="def-list-head">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="def-item">
  <fo:block xsl:use-attribute-sets="def-item">
    <!-- content model is (term, def*) -->
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="term">
  <fo:block xsl:use-attribute-sets="def-list-term">
    <xsl:apply-templates select="parent::def-item" mode="label-text"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="def">
  <fo:block xsl:use-attribute-sets="def-list-def">
    <!-- content model is (term, def*) -->
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="list">
  <fo:block xsl:use-attribute-sets="list">
    <xsl:call-template name="make-list"/>
  </fo:block>
</xsl:template>


<xsl:template match="list//list">
  <fo:block xsl:use-attribute-sets="sub-list">
    <xsl:call-template name="make-list"/>
  </fo:block>
</xsl:template>


<xsl:template name="make-list">
  <xsl:call-template name="assign-id"/>
  <xsl:apply-templates select="." mode="label"/>
  <xsl:apply-templates select="title"/>

  <xsl:variable name="start-to-start">
    <xsl:variable name="marker-allowance">
      <xsl:choose>
        <xsl:when test="@list-type='simple'">0</xsl:when>
        <xsl:when test="@list-type='bullet' or empty(@list-type)">10</xsl:when>
        <xsl:when test="@list-type='roman-upper' or @list-type='roman-lower'"
          >36</xsl:when>
        <xsl:otherwise>17</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="prefix-allowance"
      select="string-length(@prefix-word) * 6"/>
    <xsl:value-of select="$marker-allowance + $prefix-allowance"/>
  </xsl:variable>
  <xsl:variable name="end-to-start">
    <xsl:choose>
      <xsl:when test="empty(@list-type='simple')">6</xsl:when>
      <xsl:otherwise>3</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <fo:list-block provisional-distance-between-starts="{$start-to-start}pt"
    provisional-label-separation="{$end-to-start}pt">
    <xsl:apply-templates select="list-item"/>
  </fo:list-block>
</xsl:template>


<xsl:template match="list-item">
  <fo:list-item xsl:use-attribute-sets="list-item">
    <xsl:call-template name="assign-id"/>
    <fo:list-item-label end-indent="label-end()">
      <fo:block xsl:use-attribute-sets="list-item-label">
        <xsl:apply-templates select="." mode="label-text"/>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <xsl:apply-templates/>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>


<!-- ============================================================= -->
<!-- Tables                                                        -->
<!-- ============================================================= -->


<xsl:include href="xhtml-tables-fo.xsl"/>


<!-- ============================================================= -->
<!-- Inline elements                                               -->
<!-- ============================================================= -->


<xsl:template match="abbrev">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="abbrev/def">
  <xsl:text>[</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template
  match="p/address | license-p/address |
  named-content/p | styled-content/p">
  <xsl:apply-templates mode="inline"/>
</xsl:template>


<xsl:template match="address/*" mode="inline">
  <xsl:if test="preceding-sibling::*">
    <fo:inline xsl:use-attribute-sets="generated">, </fo:inline>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="addr-line | country | fax |
                       institution | phone">
  <xsl:if test="preceding-sibling::* and empty(parent::aff)">
    <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="award-id">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="break">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="email">
  <fo:inline xsl:use-attribute-sets="email">
    <xsl:apply-templates/>
  </fo:inline>
</xsl:template>


<xsl:template
  match="article-meta/email | contrib-group/email |
                contrib/email | array/email |
                chem-struct-wrap/email | chem-struct-wrapper/email |
                fig-group/email |
                fig/email | graphic/email | media/email |
                supplementary-material/email |
                table-wrap-group/email | table-wrap/email |
                disp-formula-group/email | front-stub/email">
  <fo:block xsl:use-attribute-sets="email">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="ext-link | uri | inline-supplementary-material">
  <xsl:call-template name="make-external-link"/>
</xsl:template>


  <xsl:template match="array/ext-link |
                     chem-struct-wrap/ext-link | chem-struct-wrapper/ext-link |
                     fig-group/ext-link | fig/ext-link |
                     graphic/ext-link | media/ext-link |
                     supplementary-material/ext-link |
                     table-wrap-group/ext-link | table-wrap/ext-link |
                     disp-formula-group/ext-link">
  <fo:block xsl:use-attribute-sets="ext-link">
    <xsl:call-template name="make-external-link"/>
  </fo:block>
</xsl:template>


  <xsl:template match="array/uri |
                     chem-struct-wrapper/uri | chem-struct-wrap/uri |
                     fig-group/uri | fig/uri |
                     graphic/uri | media/uri |
                     supplementary-material/uri |
                     table-wrap-group/uri |
                     table-wrap/uri | disp-formula-group/uri">
  <fo:block xsl:use-attribute-sets="uri">
    <xsl:call-template name="make-external-link"/>
  </fo:block>
</xsl:template>


<xsl:template match="funding-source">
  <fo:inline xsl:use-attribute-sets="funding-source">
    <xsl:apply-templates/>
  </fo:inline>
</xsl:template>


<xsl:template match="hr">
  <fo:block border-top="thin solid black"/>
</xsl:template>


<xsl:template match="inline-formula">
  <fo:inline xsl:use-attribute-sets="inline-formula">
    <xsl:apply-templates/>
  </fo:inline>
</xsl:template>


<xsl:template match="milestone-start | milestone-end"/>
<!-- suppressed in this application -->


<xsl:template match="object-id">
  <fo:block xsl:use-attribute-sets="object-id">
    <fo:inline xsl:use-attribute-sets="generated">doi: </fo:inline>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="sig">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="target">
  <fo:inline>
    <xsl:call-template name="assign-id"/>
  </fo:inline>
</xsl:template>


<xsl:template match="private-char">
  <fo:inline xsl:use-attribute-sets="generated">[Private character</fo:inline>
  <xsl:for-each select="@name">
    <xsl:text> </xsl:text>
    <xsl:value-of select="."/>
  </xsl:for-each>
  <fo:inline xsl:use-attribute-sets="generated">]</fo:inline>
</xsl:template>


<xsl:template match="glyph-data | glyph-ref">
  <fo:inline xsl:use-attribute-sets="generated">(Glyph not
    rendered)</fo:inline>
</xsl:template>


<xsl:template match="related-article">
  <fo:inline xsl:use-attribute-sets="generated">[Related article:] </fo:inline>
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="related-object">
  <fo:inline xsl:use-attribute-sets="generated">[Related object:] </fo:inline>
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="bold">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="chem-struct">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="italic">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="monospace">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="named-content">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="overline">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="roman">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="sans-serif">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="sc">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="strike">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="styled-content">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="sub">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="sup">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<xsl:template match="underline">
  <xsl:apply-templates select="." mode="format"/>
</xsl:template>


<!-- ============================================================= -->
<!-- Back matter                                                   -->
<!-- ============================================================= -->

<!-- 'supplementary-material' counts as 'back' because it has to come
     after any figures or tables. -->
<xsl:template match="back">
  <xsl:apply-templates
      select="/article/body/sec[supplementary-material]"
      mode="back" />
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="ack">
  <fo:block space-before="8pt">
    <xsl:call-template name="backmatter-section">
      <xsl:with-param name="generated-title">Acknowledgements</xsl:with-param>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template match="ack/p">
  <fo:block xsl:use-attribute-sets="paragraph-no-indent">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="app-group">
  <xsl:call-template name="backmatter-section">
    <xsl:with-param name="generated-title">Appendices</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="app">
  <fo:block xsl:use-attribute-sets="app">
    <xsl:call-template name="assign-id"/>
    <xsl:apply-templates select="." mode="label"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="ref-list">
  <fo:block span="all" />
  <fo:block xsl:use-attribute-sets="ref-list-section" span="all">
    <xsl:call-template name="assign-id"/>
    <xsl:apply-templates select="." mode="label"/>
    <xsl:for-each-group
        select="*"
        group-adjacent="self::ref">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <fo:list-block xsl:use-attribute-sets="ref-list-block">
            <xsl:apply-templates select="current-group()" />
          </fo:list-block>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </fo:block>
  <fo:block span="all" />
</xsl:template>

<xsl:template match="ref">
  <fo:list-item xsl:use-attribute-sets="ref-list-item">
    <xsl:call-template name="assign-id"/>
    <fo:list-item-label end-indent="label-end()">
      <fo:block xsl:use-attribute-sets="list-item-label">
        <xsl:apply-templates select="." mode="label"/>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block-container>
        <!-- extra circumlocutions are necessary to redefine
             the reference area for indenting -->
        <fo:wrapper start-indent="0pc">
          <fo:block xsl:use-attribute-sets="ref">
            <xsl:apply-templates/>
          </fo:block>
        </fo:wrapper>
      </fo:block-container>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>


<xsl:template match="back/bio">
  <xsl:call-template name="backmatter-section">
    <xsl:with-param name="generated-title">Biography</xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="back/fn-group">
  <xsl:call-template name="backmatter-section">
    <xsl:with-param name="generated-title">End notes</xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="back/glossary">
  <xsl:call-template name="backmatter-section">
    <xsl:with-param name="generated-title">Glossary</xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="back/ref-list">
  <xsl:for-each select="key('fn-by-type', 'con')">
    <fo:block space-before="8pt" role="author-contributions" id="{@id}">
      <xsl:call-template name="backmatter-section">
        <xsl:with-param name="generated-title">Author Contributions</xsl:with-param>
        <xsl:with-param name="contents">
          <xsl:apply-templates select="*" />
        </xsl:with-param>
      </xsl:call-template>
    </fo:block>
  </xsl:for-each>
  <fo:block span="all" />
  <fo:block span="all" space-before="12pt" role="references" />
  <xsl:call-template name="backmatter-section">
    <xsl:with-param name="generated-title">References</xsl:with-param>
    <xsl:with-param name="contents">
      <xsl:apply-templates select="." mode="label"/>
      <xsl:apply-templates select="title"/>
      <!-- Empty spanning block to force space-after of title to work. -->
      <fo:block span="all" />
      <xsl:for-each-group
          select="* except title"
          group-adjacent="if (self::ref) then true() else false()">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <fo:list-block xsl:use-attribute-sets="ref-list-block">
              <xsl:apply-templates select="current-group()" />
            </fo:list-block>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:with-param>
    <xsl:with-param name="title-span" select="'all'" tunnel="yes" as="xs:string" />
  </xsl:call-template>
  <!-- Empty spanning block to force ref-list to balance. -->
  <fo:block span="all" />
</xsl:template>


<xsl:template match="back/notes">
  <xsl:call-template name="backmatter-section">
    <xsl:with-param name="generated-title">Notes</xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template name="backmatter-section">
  <xsl:param name="generated-title"/>
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>

  <xsl:if test="empty(title) and $generated-title">
    <xsl:choose>
      <!-- The level of title depends on whether the back matter
           itself has a title -->
      <xsl:when test="ancestor::back/title">
        <xsl:call-template name="section-title">
          <xsl:with-param name="contents" select="$generated-title"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="main-title">
          <xsl:with-param name="contents" select="$generated-title"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <xsl:copy-of select="$contents"/>
</xsl:template>


<!-- ============================================================= -->
<!-- Floats group                                                  -->
<!-- ============================================================= -->

<xsl:template match="floats-group | floats-wrap">
  <xsl:apply-templates mode="floats"/>
</xsl:template>


<xsl:template match="alternatives" mode="floats">
  <xsl:apply-templates mode="floats"/>
</xsl:template>


<xsl:template match="*" mode="floats">
  <!-- floats are rendered in place unless they are both
       cross-referenced somewhere by an xref, and they have
       do not have @position != "float", in which case
       they have been floated to near the point of the xref -->
  <xsl:variable name="xrefs" select="key('xref-by-rid',@id)"/>
  <xsl:choose>
     <xsl:when test="boolean($xrefs) and not(@position != 'float')"/>
     <xsl:otherwise>
       <xsl:apply-templates select=".">
         <xsl:with-param name="allow-float" select="false()"
                         tunnel="yes" as="xs:boolean"/>
       </xsl:apply-templates>
     </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<!-- ============================================================= -->
<!-- Citation content                                              -->
<!-- ============================================================= -->
<!-- Citations should have been pre-processed; citation formatting
   is not supported by this stylesheet.                          -->

<xsl:template match="citation-alternatives">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="mixed-citation | element-citation |
                     nlm-citation | related-article |
                     related-object | product">
  <fo:block xsl:use-attribute-sets="citation">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

  <xsl:template match="mixed-citation//* |
                     citation//* |
                     related-article//* |
                     product//* |
                     related-object//*"
  priority="-0.25">
  <!-- descendants of these elements with better matches will be
       processed by their regular templates due to the priority -->
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="element-citation//*" priority="1">
  <!-- this template, however, overrides other templates matching
       the same elements -->
  <xsl:apply-templates/>
  <xsl:if
    test="not(generate-id() =
    generate-id(ancestor::element-citation/descendant::*[last()]))">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>



<!-- ============================================================= -->
<!-- Footnotes and cross-references                                -->
<!-- ============================================================= -->
<!-- Cross-references are passed through except when they
   have no content, in which case:

   1. if they point to an fn-group/fn, or to an fn that appears
      before them, they acquire the footnote label
   2. if not, they acquire the label of the element to which they
      point
   3. if no such label is available, they generate an error label -->


<xsl:template match="fn-group/fn | author-notes/fn |
                     author-notes/corresp">
  <fo:block xsl:use-attribute-sets="endnote">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="table-wrap-foot//fn">
  <fo:block xsl:use-attribute-sets="table-footnote">
    <xsl:call-template name="assign-id"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="fn">
  <!-- matching fn elements not inside fn-group or author-notes -->
  <xsl:variable name="xrefs" select="key('xref-by-rid',@id)"/>
  <xsl:choose>
    <!-- if the fn is referenced only by xrefs that appear after
         it, we generate the footnote here -->
    <xsl:when test="generate-id() = generate-id((.|$xrefs)[1])">
      <xsl:apply-templates select="." mode="format"/>
    </xsl:when>
    <xsl:otherwise>
      <fo:inline xsl:use-attribute-sets="footnote-ref">
        <xsl:apply-templates mode="fn-ref-punctuate"
          select="preceding-sibling::node()[1]"/>
        <xsl:apply-templates select="." mode="label-text">
          <!-- we want a warning only if an xref exists -->
          <xsl:with-param name="warning" select="true()"/>
        </xsl:apply-templates>
      </fo:inline>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="fn | aff | corresp" mode="fn-ref-punctuate">
  <!-- if a footnote ref is directly preceded by a footnote
       ref, we need punctuation -->
  <xsl:text>,</xsl:text>
</xsl:template>


<xsl:template match="xref" mode="fn-ref-punctuate">
  <xsl:variable name="target" select="key('element-by-id',@rid)"/>
  <!-- likewise if it is directly preceded by an xref
  to a footnote -->
  <xsl:if test="$target[self::fn | self::aff | self::corresp]">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="* | text()" mode="fn-ref-punctuate"/>
<!-- no punctuation for any other directly preceding sibling -->


  <xsl:template match="text()[not(normalize-space(string(.)))] |
                     comment() | processing-instruction()"
              mode="fn-ref-punctuate">
  <!-- but for whitespace-only text nodes, comments and
       PIs, we have to keep looking -->
  <xsl:apply-templates mode="fn-ref-punctuate"
          select="preceding-sibling::node()[1]"/>
</xsl:template>


<xsl:template name="fn-xref">
  <xsl:param name="target" select="key('element-by-id',@rid)"/>
  <xsl:param name="xrefs" select="key('xref-by-rid',@rid)"/>
  <xsl:param name="prefix" as="xs:string?" tunnel="yes" />
  <xsl:variable name="symbol">
    <xsl:if test=". castable as xs:integer">
      <xsl:apply-templates mode="fn-ref-punctuate"
                           select="preceding-sibling::node()[1]"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="not(normalize-space(string(.)))">
      <xsl:apply-templates select="$target" mode="label-text">
        <xsl:with-param name="warning" select="true()"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <!-- Any of several conditions result in placing a
         footnote reference but not an actual footnote here;
         if all fail, we place a footnote along with
         the xref that references it. -->
    <!-- We have only the reference if the fn target has a
         parent fn-group or table-wrap-foot (the footnote
         text appears at the point of the fn). -->
    <xsl:when test="$target/parent::fn-group |
                    $target[ancestor::table-wrap-foot]">
      <fo:basic-link internal-destination="{$prefix}{@rid}">
        <fo:inline xsl:use-attribute-sets="footnote-ref">
          <xsl:copy-of select="$symbol"/>
        </fo:inline>
      </fo:basic-link>
    </xsl:when>
    <!-- We have only the reference if the fn target is
         inside article-meta (the footnote text appears
         elsewhere). -->
    <xsl:when test="$target/ancestor::article-meta">
      <fo:basic-link internal-destination="{$prefix}{@rid}">
        <fo:inline xsl:use-attribute-sets="footnote-ref">
          <xsl:copy-of select="$symbol"/>
        </fo:inline>
      </fo:basic-link>
    </xsl:when>
    <!-- We have only the reference if the fn target is
         also targetted by an earlier xref (the footnote
         should appear there), or if the footnote itself
         appears earlier (and not inside fn-group or
         table-wrap-foot, caught above). -->
    <xsl:when test="not(generate-id() = generate-id(($target|$xrefs)[1]))">
      <fo:basic-link internal-destination="{$prefix}{@rid}">
        <fo:inline xsl:use-attribute-sets="footnote-ref">
          <xsl:copy-of select="$symbol"/>
        </fo:inline>
      </fo:basic-link>
    </xsl:when>
    <!-- Otherwise we get the reference and the footnote. -->
    <xsl:otherwise>
      <xsl:call-template name="make-footnote">
        <xsl:with-param name="symbol">
          <xsl:copy-of select="$symbol"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Show affiliation markers only when more than one affiliation in
     use. -->
<xsl:template
    match="contrib[@contrib-type eq 'author']
            [count(distinct-values(../contrib[@contrib-type eq 'author']/xref[@ref-type eq 'aff']/@rid)) &lt; 2]/xref[@ref-type eq 'aff']" />

<xsl:template match="table-wrap" mode="label">
  <xsl:param name="contents">
    <xsl:apply-templates select="." mode="label-text">
      <!-- we place a warning for missing labels if this element is ever
           cross-referenced with an empty xref -->
      <xsl:with-param name="warning"
        select="boolean(key('xref-by-rid',@id)[not(normalize-space(string(.)))])"/>
    </xsl:apply-templates>
  </xsl:param>

  <fo:block xsl:use-attribute-sets="table-wrap-label-block">
    <fo:inline xsl:use-attribute-sets="label">
      <xsl:copy-of select="$contents"/>
      <xsl:text>.</xsl:text>
    </fo:inline>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="caption/title/node()" />
  </fo:block>
</xsl:template>

<!-- A copy of the original template, since can't leave current mode
     if tried to run original template by xsl:apply-imports. -->
<xsl:template match="table-wrap/caption" mode="label">
  <fo:block xsl:use-attribute-sets="caption">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- Override default template since caption being handled in table
     with label. -->
<xsl:template match="table-wrap/caption" />

<xsl:template match="xref">
  <xsl:param name="prefix" as="xs:string?" tunnel="yes" />
  <xsl:variable name="target" select="key('element-by-id',@rid)"/>
  <xsl:variable name="xrefs" select="key('xref-by-rid',@rid)"/>
  <xsl:choose>
    <!-- if the xref points to an fn, aff or corresp we
         call out to 'fn-xref' -->
    <xsl:when test="$target[self::fn | self::aff | self::corresp]">
      <xsl:call-template name="fn-xref">
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="xrefs" select="$xrefs"/>
      </xsl:call-template>
    </xsl:when>
    <!-- otherwise, we place either the xref content, or an
         acquired label (if we have no content) here -->
    <xsl:otherwise>
      <fo:basic-link internal-destination="{$prefix}{@rid}">
        <fo:inline xsl:use-attribute-sets="xref">
          <xsl:choose>
            <xsl:when test="normalize-space(string(.))">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="$target" mode="label-text">
                <xsl:with-param name="warning" select="true()"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </fo:inline>
      </fo:basic-link>
      <!-- now, if the target is directly inside floats-group,
           does not have @position or @position='float', and
           this is the first xref to it, we grab it and place it here -->
      <xsl:if
        test="($target[not(@position != 'float')]
               /parent::*[self::floats-group | self::floats-wrap])
          and generate-id() = generate-id($xrefs[1])">
        <xsl:apply-templates select="$target"/>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Drop the leading and/or trailing square bracket when in a series
     of bibliographic cross-references. -->
<xsl:template match="xref[@ref-type eq 'bibr'][matches(., '\[\d+\]')]/text()">
  <xsl:variable name="number"
                select="translate(., '[]', '')"
                as="xs:string" />

  <xsl:if
      test="not(../preceding-sibling::node()[1][self::text()][. = (', ', '&#x2013;')] and
                ../preceding-sibling::node()[2][self::xref[@ref-type eq 'bibr']])">
    <xsl:text>[</xsl:text>
  </xsl:if>
  <xsl:value-of select="$number" />
  <xsl:if
      test="not(../following-sibling::node()[1][self::text()][. = (', ', '&#x2013;')] and
                ../following-sibling::node()[2][self::xref[@ref-type eq 'bibr']])">
    <xsl:text>]</xsl:text>
  </xsl:if>
</xsl:template>

<!-- Drop the space character in ', ' when between bibliographic
     cross-references and also bracket with U+2060, WORD JOINER, so
     sequnce of xrefs won't break across a line.. -->
<xsl:template match="text()[. eq ', ']
                           [preceding-sibling::node()[1][self::xref[@ref-type eq 'bibr']]]
                           [following-sibling::node()[1][self::xref[@ref-type eq 'bibr']]]">
  <xsl:text>&#x2060;,&#x2060;</xsl:text>
</xsl:template>

<!-- Bracket en-dash between bibliographic cross-references with
     U+2060, WORD JOINER, so sequnce of xrefs won't break across a
     line. -->
<xsl:template match="text()[. eq '&#x2013;']
                           [preceding-sibling::node()[1][self::xref[@ref-type eq 'bibr']]]
                           [following-sibling::node()[1][self::xref[@ref-type eq 'bibr']]]">
  <xsl:text>&#x2060;&#x2013;&#x2060;</xsl:text>
</xsl:template>

<xsl:template match="fn" mode="format">
  <xsl:call-template name="make-footnote">
    <xsl:with-param name="symbol">
      <xsl:apply-templates select="." mode="label-text">
        <xsl:with-param name="warning" select="true()"/>
      </xsl:apply-templates>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template name="make-footnote">
  <xsl:param name="symbol"/>
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:footnote>
    <fo:inline xsl:use-attribute-sets="footnote-ref">
      <xsl:apply-templates mode="fn-ref-punctuate"
          select="preceding-sibling::node()[1]"/>
        <xsl:copy-of select="$symbol"/>
    </fo:inline>
    <fo:footnote-body xsl:use-attribute-sets="footnote-body">
      <xsl:copy-of select="$contents"/>
    </fo:footnote-body>
  </fo:footnote>
</xsl:template>


<xsl:template match="fn/p">
  <fo:block xsl:use-attribute-sets="paragraph">
    <xsl:call-template name="assign-id"/>
    <xsl:if test="empty(preceding-sibling::p)">
      <xsl:apply-templates select="parent::fn" mode="label-text"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<xsl:template match="fn-group/fn/p | author-notes/fn/p |
  table-wrap//fn/p" priority="2">
  <xsl:variable name="empty-xrefs"
    select="key('xref-by-rid',../@id)[not(normalize-space(string(.)))]"/>
  <fo:block xsl:use-attribute-sets="paragraph">
    <xsl:call-template name="assign-id"/>
    <xsl:if test="empty(preceding-sibling::p)">
      <xsl:attribute name="text-indent" select="'0pt'" />
      <xsl:variable name="label">
        <xsl:apply-templates select="parent::fn" mode="label-text">
          <!-- we want a warning only if an empty xref exists -->
          <xsl:with-param name="warning" select="boolean($empty-xrefs)"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:copy-of select="$label"/>
      <xsl:if test="normalize-space(string($label))">
        <xsl:if test="not(contains(string($label),']'))">.</xsl:if>
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>


<!-- ============================================================= -->
<!-- Mode "format"                                                 -->
<!-- ============================================================= -->
<!-- Provides for generic formatting of inline elements.
     Templates in this mode are also named, so they may be
     called for other elements as well.                           -->


<xsl:template match="*" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:copy-of select="$contents"/>
</xsl:template>


<xsl:template name="bold" match="bold" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline font-weight="bold">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="break" match="break" mode="format">
  <fo:block/>
</xsl:template>

<xsl:template name="chem-struct" match="chem-struct" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline xsl:use-attribute-sets="chem-struct-inline">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="italic" match="italic" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline font-style="italic">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="monospace" match="monospace" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline xsl:use-attribute-sets="monospace">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="named-content" match="named-content" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:copy-of select="$contents"/>
</xsl:template>


<xsl:template name="overline" match="overline" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline text-decoration="overline">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="roman" match="roman" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline font-style="normal">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="sans-serif" match="sans-serif" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline xsl:use-attribute-sets="sans-serif">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="sc" match="sc" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline font-variant="small-caps">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="strike" match="strike" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline text-decoration="line-through">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="styled-content" match="styled-content" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline>
    <xsl:call-template name="process-style">
      <xsl:with-param name="style" select="@style"/>
    </xsl:call-template>
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="sub" match="sub" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline xsl:use-attribute-sets="subscript">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="sup" match="sup" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline xsl:use-attribute-sets="superscript">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>


<xsl:template name="underline" match="underline" mode="format">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:inline text-decoration="underline">
    <xsl:copy-of select="$contents"/>
  </fo:inline>
</xsl:template>



<!-- ============================================================= -->
<!-- Mode "label"                                                  -->
<!-- ============================================================= -->
<!-- Acquires or generates a label for any object.                 -->


<xsl:template mode="label" match="disp-formula" name="inline-label">
  <xsl:param name="contents">
    <xsl:apply-templates select="." mode="label-text">
      <!-- we place a warning for missing labels if this element is ever
           cross-referenced with an empty xref -->
      <xsl:with-param name="warning"
        select="boolean(key('xref-by-rid',@id)[not(normalize-space(string(.)))])"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:if test="normalize-space(string($contents))">
    <fo:inline xsl:use-attribute-sets="label">
      <xsl:copy-of select="$contents"/>
    </fo:inline>
  </xsl:if>
</xsl:template>

<xsl:template mode="label" match="*" name="block-label">
  <xsl:param name="contents">
    <xsl:apply-templates select="." mode="label-text">
      <!-- we place a warning for missing labels if this element is ever
           cross-referenced with an empty xref -->
      <xsl:with-param name="warning"
        select="boolean(key('xref-by-rid',@id)[not(normalize-space(string(.)))])"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:if test="normalize-space(string($contents))">
    <fo:block xsl:use-attribute-sets="label">
      <xsl:copy-of select="$contents"/>
    </fo:block>
  </xsl:if>
</xsl:template>

<xsl:template mode="label" match="ref">
  <!-- labels for 'ref' are formatted as run-ins -->
  <xsl:param name="contents">
    <xsl:apply-templates select="." mode="label-text"/>
  </xsl:param>
  <xsl:if test="normalize-space(string($contents))">
    <!-- we're already in a p -->
    <fo:inline xsl:use-attribute-sets="ref-label">
      <xsl:copy-of select="$contents"/>
    </fo:inline>
  </xsl:if>
</xsl:template>


<xsl:template name="set-outset-label">
  <!-- labels for sections and occasionally other stuff
       need to be set outside the body column -->
  <xsl:variable name="empty-xrefs"
    select="key('xref-by-rid',@id)[not(normalize-space(string(.)))]"/>
  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label-text">
      <xsl:with-param name="warning" select="boolean($empty-xrefs)"/>
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:if test="normalize-space(string($label))">
    <fo:block xsl:use-attribute-sets="label">
      <xsl:copy-of select="$label"/>
    </fo:block>
  </xsl:if>
</xsl:template>


<!-- ============================================================= -->
<!-- Mode "label-text"                                             -->
<!-- ============================================================= -->
<!-- Generates label text for elements and their cross-references


      This mode is to support auto-numbering for any elements
      by the stylesheet.

      Code is left in place (although not used) to autonumber
      several elements, such as figures and tables. -->


<!-- Variable declarations switch autonumbering on and off.
     In some cases, elements are autolabeled on a case-by-case
     basis (such as footnotes, which are allowed to be
     unlabeled in some cases but require autolabeling in others;
     these variables, in contrast, are intended to switch
     labelling for entire element classes. -->

<xsl:variable name="auto-label-app" select="false()"/>
<xsl:variable name="auto-label-boxed-text" select="false()"/>
<xsl:variable name="auto-label-chem-struct-wrap" select="false()"/>
<xsl:variable name="auto-label-disp-formula" select="false()"/>
<xsl:variable name="auto-label-fig" select="false()"/>
<xsl:variable name="auto-label-sec" select="false()"/>

<xsl:variable name="auto-label-ref" select="empty(//ref[label])"/>
<!-- ref elements are labeled unless any ref already has a label -->

<xsl:variable name="auto-label-statement" select="false()"/>
<xsl:variable name="auto-label-supplementary" select="false()"/>
<xsl:variable name="auto-label-table-wrap" select="false()"/>

<!--
  The following (commented) variable assignments show how
    autolabeling can be configured conditionally.
  For example: "label figures if no figures have labels" translates to
    "empty(//fig[label])", which will resolve to Boolean true() when the set of
  all fig elements with labels is empty.

<xsl:variable name="auto-label-app" select="empty(//app[label])"/>
<xsl:variable name="auto-label-boxed-text" select="empty(//boxed-text[label])"/>
<xsl:variable name="auto-label-chem-struct-wrap" select="empty(//chem-struct-wrap[label])"/>
<xsl:variable name="auto-label-disp-formula" select="empty(//disp-formula[label])"/>
<xsl:variable name="auto-label-fig" select="empty(//fig[label])"/>
<xsl:variable name="auto-label-ref" select="empty(//ref[label])"/>
<xsl:variable name="auto-label-statement" select="empty(//statement[label])"/>
<xsl:variable name="auto-label-supplementary"
  select="empty(//supplementary-material[empty(ancestor::front)][label])"/>
<xsl:variable name="auto-label-table-wrap" select="empty(//table-wrap[label])"/>

-->

<!-- Mode "label-text" templates follow a pattern. Parameters (which
     may be assigned by default but are occasionally overridden by
     calling templates) determine:
       - Whether an element may be autolabeled;
       - If so, how to construct its label;
       - Whether to emit a warning label if no label is available.

     In all cases, a label given with an element (or in the case
     of 'fn', a @symbol) will be used in preference to a generated
     label. A warning will be generated only if $warning is
     true, $auto-label-x if false, and there is no label or
     @symbol available in the source document. -->

<xsl:template match="aff" mode="label-text">
  <xsl:param name="warning" select="false()"/>
  <!-- pass $warning in as false() if a warning string is not wanted
       (for example, if generating autonumbered labels) -->
  <fo:inline xsl:use-attribute-sets="aff-label">
    <xsl:call-template name="assign-id"/>
    <xsl:call-template name="make-label-text">
      <xsl:with-param name="auto" select="false()"/>
      <xsl:with-param name="warning" select="$warning"/>
    </xsl:call-template>
  </fo:inline>
</xsl:template>


<xsl:template match="app" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-app"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Appendix </xsl:text>
      <xsl:number format="A"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="boxed-text" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-boxed-text"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Box </xsl:text>
      <xsl:number level="any"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="disp-formula" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-disp-formula"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Formula </xsl:text>
      <xsl:number level="any"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="chem-struct-wrap" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-chem-struct-wrap"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Formula (chemical) </xsl:text>
      <xsl:number level="any"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="fig" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-fig"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Figure </xsl:text>
      <xsl:number level="any"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="fn" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <!-- autonumber all fn elements outside fn-group
       author-notes and table-wrap only if none of them
       have labels or @symbols (to keep numbering
       orderly) -->
  <xsl:variable name="in-scope-notes"
    select="ancestor::article//fn[empty(parent::fn-group
                                | parent::author-notes
                                | ancestor::table-wrap)]"/>
  <xsl:variable name="auto-number-fn"
    select="empty($in-scope-notes/label |
                $in-scope-notes/@symbol)"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-number-fn"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>[</xsl:text>
      <xsl:number level="any" count="fn[empty(parent::fn-group)]"
        from="article | sub-article | response"/>
      <xsl:text>]</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="table-wrap//fn" mode="label-text" priority="2">
  <xsl:param name="warning" select="false()"/>
  <xsl:variable name="empty-xrefs"
    select="key('xref-by-rid',@id)[not(normalize-space(string(.)))]"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="boolean($empty-xrefs)"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>[</xsl:text>
      <xsl:number level="any" count="fn" from="table-wrap" format="i"/>
      <xsl:text>]</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="fn-group/fn | author-notes/fn"
              mode="label-text">
  <!-- this template does not apply to footnotes inside
       table-wrap -->
  <xsl:param name="warning" select="true()"/>
  <!-- pass $warning in as false() if a warning string is not wanted
       (for example, if generating autonumbered labels) -->
  <xsl:variable name="empty-xrefs"
    select="key('xref-by-rid',@id)[not(normalize-space(string(.)))]"/>
  <!-- auto-number this fn if it has any empty xrefs, unless we're
       in a table-wrap-foot -->
  <xsl:variable name="auto-number-fn" select="boolean($empty-xrefs)
    and empty(label|@symbol)"/>

  <xsl:variable name="number-format">
    <xsl:choose>
      <xsl:when test="parent::author-notes">a</xsl:when>
      <xsl:when test="ancestor::boxed-text | ancestor::bio">i</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-number-fn"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <!-- count only footnotes that have xrefs -->
      <xsl:number level="single" format="{$number-format}"
        count="fn[key('xref-by-rid',@id)][not(normalize-space(string(.)))]"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="sec" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-sec"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Section </xsl:text>
      <xsl:number level="multiple" from="article" format="1.1."/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="ref" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-ref"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:number level="any"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="statement" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-statement"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Statement </xsl:text>
      <xsl:number level="any"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="supplementary-material" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-supplementary"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Supplementary Material </xsl:text>
      <xsl:number level="any" format="A"
        count="supplementary-material[empty(ancestor::front)]"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="table-wrap" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="auto" select="$auto-label-table-wrap"/>
    <xsl:with-param name="warning" select="$warning"/>
    <xsl:with-param name="auto-text">
      <xsl:text>Table </xsl:text>
      <xsl:number level="any" format="1"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template match="def-item" mode="label-text">
  <xsl:call-template name="item-mark"/>
  <xsl:text> </xsl:text>
</xsl:template>


<xsl:template match="list/list-item" mode="label-text">
  <xsl:variable name="given-label">
    <xsl:apply-templates select="label" mode="label-text"/>
  </xsl:variable>
  <xsl:copy-of select="$given-label"/>
  <xsl:if test="not(string($given-label))">
    <!-- a marker is generated only if the item has no
         label given -->
    <xsl:call-template name="item-mark"/>
  </xsl:if>
</xsl:template>


<xsl:template match="*" mode="label-text">
  <xsl:param name="warning" select="true()"/>
  <!-- pass $warning in as false() if a warning string is not wanted
       (for example, if generating autonumbered labels) -->
  <xsl:call-template name="make-label-text">
    <xsl:with-param name="warning" select="$warning"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="label" mode="label-text">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ref/label" mode="label-text">
  <xsl:next-match/>
  <xsl:text>.</xsl:text>
</xsl:template>


<!-- ============================================================= -->
<!-- MathML handling                                               -->
<!-- ============================================================= -->


<xsl:template match="mml:math">
  <xsl:choose>
    <xsl:when test="$mathml-support">
      <fo:instream-foreign-object
          xsl:use-attribute-sets="mml:math-display">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <!-- Set mml:math/@mathsize to stylesheet default, even if
               it's already present on mml:math element. -->
          <xsl:attribute name="mathsize" select="$mathsize" />
          <xsl:apply-templates/>
        </xsl:copy>
      </fo:instream-foreign-object>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="inline-formula/mml:math">
  <xsl:choose>
    <xsl:when test="$mathml-support">
      <fo:instream-foreign-object>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </fo:instream-foreign-object>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="mml:*">
  <xsl:choose>
    <xsl:when test="$mathml-support">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ============================================================= -->
<!-- Writing a name                                                -->
<!-- ============================================================= -->
<!-- Called when displaying structured names in metadata  -->

<xsl:template name="write-name" match="name">
  <xsl:apply-templates select="prefix" mode="inline-name"/>
  <xsl:apply-templates select="surname[../@name-style='eastern']" mode="inline-name"/>
  <xsl:apply-templates select="given-names" mode="inline-name"/>
  <xsl:apply-templates select="surname[not(../@name-style='eastern')]" mode="inline-name"/>
  <xsl:apply-templates select="suffix" mode="inline-name"/>
</xsl:template>

<xsl:template match="mixed-citation/name">
  <xsl:apply-templates select="prefix" mode="inline-name"/>
  <xsl:apply-templates select="surname" mode="inline-name"/>
  <xsl:apply-templates select="given-names" mode="inline-name"/>
  <xsl:apply-templates select="suffix" mode="inline-name"/>
</xsl:template>


<xsl:template match="prefix" mode="inline-name">
  <xsl:apply-templates/>
  <xsl:if test="../surname | ../given-names | ../suffix">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="given-names" mode="inline-name">
  <xsl:if test="exists(../parent::mixed-citation) and
                exists(../surname)">
    <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
  <xsl:if test="(empty(../parent::mixed-citation) and
                 exists(../surname[not(../@name-style='eastern')])) or
                 exists(../suffix)">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="contrib/name/surname" mode="inline-name">
  <xsl:apply-templates/>
  <xsl:if test="../given-names[../@name-style='eastern'] | ../suffix">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="surname" mode="inline-name">
  <xsl:apply-templates/>
  <xsl:if test="../given-names[../@name-style='eastern'] | ../suffix">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="suffix" mode="inline-name">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="name-alternatives | collab-alternatives">
  <xsl:call-template name="name-sequence"/>
</xsl:template>


<xsl:template name="name-sequence">
  <!-- Given a list of name or collab elements, presents them in order
  with members after the first in parentheses -->
  <xsl:param name="names" select="*"/>
  <xsl:apply-templates select="$names[1]"/>
  <xsl:if test="$names[2]"> (</xsl:if>
  <xsl:for-each select="$names[position() &gt; 1]">
    <xsl:apply-templates select="."/>
    <xsl:if test="position() &lt; last()">, </xsl:if>
  </xsl:for-each>
  <xsl:if test="$names[2]">)</xsl:if>
</xsl:template>
<!-- string-name elements are written as is -->

<xsl:template match="string-name">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="string-name/*">
  <xsl:apply-templates/>
</xsl:template>


<!-- ============================================================= -->
<!-- UTILITY TEMPLATES                                             -->
<!-- ============================================================= -->


<xsl:template name="make-label-text">
  <xsl:param name="auto" select="false()"/>
  <xsl:param name="warning" select="false()"/>
  <xsl:param name="auto-text"/>
  <xsl:choose>
    <xsl:when test="$auto">
      <fo:inline xsl:use-attribute-sets="generated">
        <xsl:copy-of select="$auto-text"/>
      </fo:inline>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="label-text" select="label | @symbol"/>
      <xsl:if test="$warning and empty(label|@symbol)">
        <fo:inline xsl:use-attribute-sets="warning">
          <xsl:text>{ label</xsl:text>
          <xsl:if test="self::fn"> (or @symbol)</xsl:if>
          <xsl:text> needed for </xsl:text>
          <xsl:value-of select="local-name()"/>
          <xsl:for-each select="@id">
            <xsl:text>[@id='</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>']</xsl:text>
          </xsl:for-each>
          <xsl:text> }</xsl:text>
        </fo:inline>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="make-external-link">
  <xsl:param name="href" select="@xlink:href"/>
  <xsl:param name="contents">
    <xsl:choose>
      <xsl:when test="normalize-space(string(.))">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@xlink:href"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <fo:basic-link external-destination="{normalize-space(string($href))}"
    show-destination="new" xsl:use-attribute-sets="link">
    <xsl:copy-of select="$contents"/>
  </fo:basic-link>
</xsl:template>


<xsl:function name="pf:resolve-href" as="xs:string">
  <xsl:param name="graphic" as="element()" />

  <!-- prepends an @xlink:href value with the $base-dir
       parameter, if it is given, plus a '/' delimiter:
       for locating graphics -->
  <xsl:sequence
      select="concat($graphics-dir,
                     tokenize($graphic/@xlink:href, '/')[last()],
                     '.tif')" />
</xsl:function>


<xsl:template name="set-float">
  <!-- A float may be prohibited by passing $allow-float as false() -->
  <xsl:param name="allow-float" select="true()" tunnel="yes" as="xs:boolean" />
  <xsl:param name="column-wide" select="false()" as="xs:boolean" />
  <xsl:param name="float-attributes" select="()" as="attribute()*" />
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:variable name="please-float"
    select="$allow-float and
            not(@position != 'float') and
            empty(ancestor::*[@position][@position='float'])"/>
  <!-- assuming $allow-float is true(), the test respects
         @position='float' as the default, and sets float to 'before'
         but *only* if no ancestors with @position have a value of
         'float' -->
  <xsl:choose>
    <xsl:when test="$please-float">
      <fo:float xsl:use-attribute-sets="float"
                axf:float-reference="{if ($column-wide) then 'column' else 'page'}">
        <xsl:copy-of select="$float-attributes" />
        <xsl:copy-of select="$contents"/>
      </fo:float>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$contents"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="metadata-entry-cell">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:call-template name="make-metadata-cell">
    <xsl:with-param name="contents">
      <xsl:copy-of select="$contents"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template name="metadata-labeled-entry-cell">
  <xsl:param name="label"/>
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:call-template name="metadata-entry-cell">
    <xsl:with-param name="contents">
      <xsl:if test="normalize-space(string($label))">
        <fo:inline xsl:use-attribute-sets="metadata-label">
          <xsl:copy-of select="$label"/>
          <xsl:text>: </xsl:text>
        </fo:inline>
      </xsl:if>
      <xsl:copy-of select="$contents"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template name="metadata-area-cell">
  <xsl:param name="label"/>
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:call-template name="make-metadata-cell">
    <xsl:with-param name="contents">
      <xsl:if test="normalize-space(string($label))">
        <fo:block xsl:use-attribute-sets="metadata-label">
          <xsl:copy-of select="$label"/>
        </fo:block>
      </xsl:if>
      <fo:block start-indent="1em">
        <xsl:copy-of select="$contents"/>
      </fo:block>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template name="metadata-block">
  <xsl:param name="label"/>
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:block xsl:use-attribute-sets="metadata-line">
    <xsl:if test="normalize-space(string($label))">
      <fo:block xsl:use-attribute-sets="metadata-label">
        <xsl:copy-of select="$label"/>
      </fo:block>
    </xsl:if>
    <fo:block margin-left="1em">
      <xsl:copy-of select="$contents"/>
    </fo:block>
  </fo:block>

</xsl:template>


<xsl:template name="metadata-line">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:block xsl:use-attribute-sets="metadata-line">
    <xsl:copy-of select="$contents"/>
  </fo:block>
</xsl:template>


<xsl:template name="metadata-labeled-line">
  <xsl:param name="label"/>
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:call-template name="metadata-line">
    <xsl:with-param name="contents">
      <xsl:if test="normalize-space(string($label))">
        <fo:inline xsl:use-attribute-sets="metadata-label">
          <xsl:copy-of select="$label"/>
          <xsl:text>: </xsl:text>
        </fo:inline>
      </xsl:if>
      <xsl:copy-of select="$contents"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<xsl:template name="make-metadata-cell">
  <xsl:param name="contents">
    <xsl:apply-templates/>
  </xsl:param>
  <fo:table-row>
    <fo:table-cell padding-top="2pt" padding-left="0.1in" border-style="solid"
      border-width="1pt">
      <fo:block xsl:use-attribute-sets="metadata-line">
        <xsl:copy-of select="$contents"/>
      </fo:block>
    </fo:table-cell>
  </fo:table-row>
</xsl:template>


<xsl:template name="append-pub-type">
  <!-- adds a value mapped for @pub-type, enclosed in parenthesis,
       to a string -->
  <xsl:for-each select="@pub-type">
    <xsl:text> (</xsl:text>
    <fo:inline xsl:use-attribute-sets="data">
      <xsl:choose>
        <xsl:when test=".='epub'">electronic</xsl:when>
        <xsl:when test=".='ppub'">print</xsl:when>
        <xsl:when test=".='epub-ppub'">print and electronic</xsl:when>
        <xsl:when test=".='epreprint'">electronic preprint</xsl:when>
        <xsl:when test=".='ppreprint'">print preprint</xsl:when>
        <xsl:when test=".='ecorrected'">corrected, electronic</xsl:when>
        <xsl:when test=".='pcorrected'">corrected, print</xsl:when>
        <xsl:when test=".='eretracted'">retracted, electronic</xsl:when>
        <xsl:when test=".='pretracted'">retracted, print</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </fo:inline>
    <xsl:text>)</xsl:text>
  </xsl:for-each>
</xsl:template>


<!-- Template "item-mark" generates a bullet or number for a
     list-item or to appear with a def-list/term -->

<xsl:template name="item-mark">
  <!-- the context is a list/list-item or a def-list/def-item -->
  <xsl:if test="../@list-type='bullet' or parent::list[empty(@list-type)]">
    <xsl:call-template name="get-bullet"/>
    <xsl:if test="../@prefix-word">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:if>
  <xsl:value-of select="../@prefix-word"/>
  <xsl:if test="../@list-type[not(.='simple' or .='bullet')]">
    <!-- for an item with an explicit list type other than 'simple'
      or 'bullet', we generate a number -->
    <xsl:variable name="number-format">
      <xsl:call-template name="list-number-format"/>
    </xsl:variable>
    <xsl:variable name="number">
      <xsl:call-template name="list-item-number"/>
    </xsl:variable>
    <xsl:text> </xsl:text>
    <xsl:number value="$number" format="{$number-format}"/>
  </xsl:if>
</xsl:template>


<!-- Template 'get-bullet' assigns a bullet character based on the
     depth of the list containing the item -->

<xsl:template name="get-bullet">
  <xsl:variable name="list-depth"
    select="count(ancestor::*
            [@list-type='bullet' or self::list[empty(@list-type)]])"/>
  <xsl:choose>
    <xsl:when test="$list-depth mod 5 = 1">
      <!-- bullet -->
      <xsl:text>&#x2022;</xsl:text>
    </xsl:when>
    <xsl:when test="$list-depth mod 5 = 2">
      <!-- disc -->
      <xsl:text>&#x25E6;</xsl:text>
    </xsl:when>
    <xsl:when test="$list-depth mod 5 = 3">
      <!-- square -->
      <xsl:text>&#x25AA;</xsl:text>
    </xsl:when>
    <xsl:when test="$list-depth mod 5 = 4">
      <!-- white square -->
      <xsl:text>&#x25AB;</xsl:text>
    </xsl:when>
    <xsl:when test="$list-depth mod 5 = 0">
      <!-- dash -->
      <xsl:text>&#x2013;</xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:template>


<!-- Template 'list-number-format' designates a format to be used
     for numbering a list item, based on settings on its list parent
     and (sometimes) ancestors -->

<xsl:template name="list-number-format">
  <!-- the context is the item -->
  <xsl:choose>
    <xsl:when test="../@list-type='order'">
      <xsl:variable name="list-depth"
        select="count(ancestor::*[@list-type='order'])"/>
      <xsl:choose>
        <xsl:when test="$list-depth mod 6 = 1">1.</xsl:when>
        <xsl:when test="$list-depth mod 6 = 2">a.</xsl:when>
        <xsl:when test="$list-depth mod 6 = 3">1)</xsl:when>
        <xsl:when test="$list-depth mod 6 = 4">a)</xsl:when>
        <xsl:when test="$list-depth mod 6 = 5">i.</xsl:when>
        <xsl:when test="$list-depth mod 6 = 0">i)</xsl:when>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="../@list-type='alpha-lower'">a.</xsl:when>
    <xsl:when test="../@list-type='alpha-upper'">A.</xsl:when>
    <xsl:when test="../@list-type='roman-lower'">i.</xsl:when>
    <xsl:when test="../@list-type='roman-upper'">I.</xsl:when>
    <!-- the otherwise case will catch values of @list-type
         not recognized by the stylesheet -->
    <xsl:otherwise>1.</xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Template 'list-item-number' determines a number for a list
     item, accounting for @continued-from on its parent -->

<xsl:template name="list-item-number">
  <xsl:param name="here" select="parent::list|parent::def-list"/>
  <xsl:param name="item-number">
    <!-- the first time through, this is the number of the item -->
    <xsl:number/>
  </xsl:param>
  <xsl:choose>
    <!-- if this list is not continued from another, the item
         number is returned -->
    <xsl:when
      test="empty(key('element-by-id',$here/@continued-from)
                        [self::list|self::def-list])">
      <xsl:value-of select="$item-number"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- otherwise, we call this template recursively,
           adding in the count of the continued list -->
      <xsl:call-template name="list-item-number">
        <xsl:with-param name="here"
          select="key('element-by-id',$here/@continued-from)"/>
        <xsl:with-param name="item-number"
          select="$item-number + count($here/list-item|$here/def-item)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Template "process-style" maps arbitrary CSS into FO, with
     some provision for mapping table-related values  -->
<!-- Modified from AntennaHouse code -->

<xsl:template name="process-style">
  <xsl:param name="style"/>
  <!-- e.g., style="text-align: center; color: red"
  converted to text-align="center" color="red" -->
  <xsl:variable name="okay-properties"
    select="' color; background-color; font-size; font-weight;
              font-style; font-family; text-decoration; text-align'"/>
  <xsl:variable name="name"
    select="normalize-space(substring-before(string($style), ':'))"/>
  <xsl:if test="$name">
    <xsl:variable name="value-and-rest"
      select="normalize-space(substring-after(string($style), ':'))"/>
    <xsl:variable name="value">
      <xsl:choose>
        <xsl:when test="contains($value-and-rest, ';')">
          <xsl:value-of
            select="normalize-space(substring-before(
                      string($value-and-rest), ';'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$value-and-rest"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$name = 'width' and (self::col or self::colgroup)">
        <xsl:attribute name="column-width">
          <xsl:value-of select="$value"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when
        test="$name = 'vertical-align' and (
                               self::table or self::caption or
                               self::thead or self::tfoot or
                               self::tbody or self::colgroup or
                               self::col or self::tr or
                               self::th or self::td)">
        <xsl:choose>
          <xsl:when test="$value = 'top'">
            <xsl:attribute name="display-align" select="'before'" />
          </xsl:when>
          <xsl:when test="$value = 'bottom'">
            <xsl:attribute name="display-align" select="'after'" />
          </xsl:when>
          <xsl:when test="$value = 'middle'">
            <xsl:attribute name="display-align" select="'center'" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="display-align" select="'auto'" />
            <xsl:attribute name="relative-align" select="'baseline'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="contains($okay-properties,concat(' ',$name,';'))">
          <xsl:attribute name="{$name}">
            <xsl:value-of select="$value"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <xsl:variable name="rest"
    select="normalize-space(substring-after(string($style), ';'))"/>
  <xsl:if test="$rest">
    <xsl:call-template name="process-style">
      <xsl:with-param name="style" select="$rest"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- ============================================================= -->
<!-- Stylesheeet diagnostics                                       -->
<!-- ============================================================= -->
<!-- For generating warnings to be reported due to processing
     anomalies. -->

<xsl:template name="run-diagnostics">
  <xsl:variable name="diagnostics">
    <xsl:call-template name="process-warnings"/>
  </xsl:variable>
  <xsl:if test="string($diagnostics)">
    <fo:page-sequence master-reference="diagnostics-sequence">
      <fo:static-content flow-name="recto-header">
        <fo:block xsl:use-attribute-sets="page-header">
          <xsl:call-template name="make-page-header">
            <xsl:with-param name="center-cell">
              <fo:block text-align="center">Process Warnings</fo:block>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:static-content>
      <fo:static-content flow-name="verso-header">
        <fo:block xsl:use-attribute-sets="page-header">
          <xsl:call-template name="make-page-header">
            <xsl:with-param name="center-cell">
              <fo:block text-align="center">Process Warnings</fo:block>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:static-content>
      <xsl:call-template name="define-footnote-separator"/>
      <fo:flow flow-name="body" xsl:use-attribute-sets="fo:flow">
        <!-- set the article opener, body, and backmatter -->
        <xsl:copy-of select="$diagnostics"/>
      </fo:flow>
    </fo:page-sequence>
  </xsl:if>
</xsl:template>


<xsl:template name="process-warnings">
  <!-- returns an RTF containing all the warnings -->
  <xsl:variable name="xref-warnings">
    <xsl:for-each select="//xref[not(normalize-space(string(.)))]">
      <!-- we only check an xref that is first to reference its
           target -->
      <xsl:if test="generate-id(.) =
                    generate-id(key('xref-by-rid',@rid)[1])">
        <xsl:variable name="target-label">
          <xsl:apply-templates select="key('element-by-id',@rid)"
            mode="label-text">
            <xsl:with-param name="warning" select="false()"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="not(normalize-space(string($target-label)))">
          <!-- if we failed to get a label with no warning
               we ask again to get the warning -->
          <fo:list-item xsl:use-attribute-sets="list-item">
            <fo:list-item-label end-indent="label-end()">
              <fo:block xsl:use-attribute-sets="list-item-label">
                <xsl:text>&#x2022;</xsl:text>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
              <fo:block>
                <xsl:apply-templates select="key('element-by-id',@rid)"
                  mode="label-text">
                  <xsl:with-param name="warning" select="true()"/>
                </xsl:apply-templates>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:if test="normalize-space(string($xref-warnings))">
    <xsl:call-template name="section-title">
      <xsl:with-param name="contents">
        <xsl:text>Elements cross-referenced without labels</xsl:text>
      </xsl:with-param>
    </xsl:call-template>

    <fo:block xsl:use-attribute-sets="paragraph">
      <xsl:text>Either the element should be provided a label, </xsl:text>
      <xsl:text>or their cross-reference(s) should have </xsl:text>
      <xsl:text>literal text content.</xsl:text>
    </fo:block>
    <fo:list-block provisional-distance-between-starts="12pt"
      provisional-label-separation="6pt">
      <xsl:copy-of select="$xref-warnings"/>
    </fo:list-block>
  </xsl:if>

  <xsl:variable name="alternatives-warnings">
    <!-- for reporting any element with a @specific-use different
           from a sibling -->
    <xsl:for-each select="//*[@specific-use != ../*/@specific-use]/..">
      <fo:list-item xsl:use-attribute-sets="list-item">
        <fo:list-item-label end-indent="label-end()">
          <fo:block xsl:use-attribute-sets="list-item-label">
            <xsl:text>&#x2022;</xsl:text>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block>
            <xsl:text>In </xsl:text>
            <fo:inline xsl:use-attribute-sets="monospace">
              <xsl:apply-templates select="." mode="xpath"/>
            </fo:inline>
          </fo:block>
            <fo:list-block provisional-distance-between-starts="12pt"
              provisional-label-separation="6pt">
              <xsl:for-each select="*[@specific-use != ../*/@specific-use]">
            <fo:list-item xsl:use-attribute-sets="list-item">
              <fo:list-item-label end-indent="label-end()">
                <fo:block xsl:use-attribute-sets="list-item-label">
                  <xsl:text>&#x2218;</xsl:text>
                </fo:block>
              </fo:list-item-label>
              <fo:list-item-body start-indent="body-start()">
                <fo:block xsl:use-attribute-sets="monospace">
                  <xsl:apply-templates select="." mode="pattern"/>
                </fo:block>
              </fo:list-item-body>
            </fo:list-item>
          </xsl:for-each>
            </fo:list-block>
        </fo:list-item-body>
      </fo:list-item>
    </xsl:for-each>
  </xsl:variable>
    <xsl:if test="normalize-space(string($alternatives-warnings))">
      <xsl:call-template name="section-title">
        <xsl:with-param name="contents">
          <xsl:text>Elements with different 'specific-use' assignments appearing together</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
      <fo:list-block provisional-distance-between-starts="12pt" provisional-label-separation="6pt">
        <xsl:copy-of select="$alternatives-warnings"/>
      </fo:list-block>
    </xsl:if>
</xsl:template>


<!-- ============================================================= -->
<!-- Date formatting                                               -->
<!-- ============================================================= -->
<!-- Maps a structured date element to a string -->

<xsl:template name="format-date"
        match="date | pub-date" mode="format-date">
  <!-- formats date in DD Month YYYY format -->
  <!-- context must be 'date', with content model:
       (((day?, month?) | season)?, year) -->
  <xsl:for-each select="month, day, season">
    <xsl:apply-templates select="." mode="map"/>
    <xsl:text> </xsl:text>
  </xsl:for-each>
  <xsl:apply-templates select="year" mode="map"/>
</xsl:template>


<xsl:template match="day" mode="map">
  <xsl:apply-templates/>
  <xsl:text>,</xsl:text>
</xsl:template>

<xsl:template match="season | year" mode="map">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="month" mode="map">
  <!-- maps numeric values to English months -->
  <xsl:choose>
    <xsl:when test="number() = 1">January</xsl:when>
    <xsl:when test="number() = 2">February</xsl:when>
    <xsl:when test="number() = 3">March</xsl:when>
    <xsl:when test="number() = 4">April</xsl:when>
    <xsl:when test="number() = 5">May</xsl:when>
    <xsl:when test="number() = 6">June</xsl:when>
    <xsl:when test="number() = 7">July</xsl:when>
    <xsl:when test="number() = 8">August</xsl:when>
    <xsl:when test="number() = 9">September</xsl:when>
    <xsl:when test="number() = 10">October</xsl:when>
    <xsl:when test="number() = 11">November</xsl:when>
    <xsl:when test="number() = 12">December</xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ============================================================= -->
<!-- ID assignment                                                 -->
<!-- ============================================================= -->
<!-- An id can be derived for any element. If an @id is given,
     it is presumed unique and copied. If not, one is generated.   -->

<xsl:template name="assign-id">
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
  <!--  Utility templates for generating warnings and reports        -->
  <!-- ============================================================= -->

  <!--  <xsl:template name="report-warning">
    <xsl:param name="when" select="false()"/>
    <xsl:param name="msg"/>
    <xsl:if test="$verbose and $when">
      <xsl:message>
        <xsl:copy-of select="$msg"/>
      </xsl:message>
    </xsl:if>
  </xsl:template>-->


  <!--<xsl:template name="list-elements">
    <xsl:param name="elements" select="/.."/>
    <xsl:if test="$elements">
      <ol>
        <xsl:for-each select="*">
          <li>
            <xsl:apply-templates select="." mode="element-pattern"/>
          </li>
        </xsl:for-each>
      </ol>
    </xsl:if>
  </xsl:template>-->


  <xsl:template match="*" mode="pattern">
    <xsl:value-of select="name(.)"/>
    <xsl:for-each select="@*">
      <xsl:text>[@</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>='</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>']</xsl:text>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="node()" mode="xpath">
    <xsl:apply-templates mode="xpath" select=".."/>
    <xsl:apply-templates mode="xpath-step" select="."/>
  </xsl:template>


  <xsl:template match="/" mode="xpath"/>


  <xsl:template match="*" mode="xpath-step">
    <xsl:variable name="name" select="name(.)"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:if test="count(../*[name(.) = $name]) > 1">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(.|preceding-sibling::*[name(.) = $name])"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@*" mode="xpath-step">
    <xsl:text>/@</xsl:text>
    <xsl:value-of select="name(.)"/>
  </xsl:template>


  <xsl:template match="comment()" mode="xpath-step">
    <xsl:text>/comment()</xsl:text>
    <xsl:if test="count(../comment()) > 1">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(.|preceding-sibling::comment())"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="processing-instruction()" mode="xpath-step">
    <xsl:text>/processing-instruction()</xsl:text>
    <xsl:if test="count(../processing-instruction()) > 1">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(.|preceding-sibling::processing-instruction())"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="text()" mode="xpath-step">
    <xsl:text>/text()</xsl:text>
    <xsl:if test="count(../text()) > 1">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(.|preceding-sibling::text())"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>


<!-- ============================================================= -->
<!-- 'bookmarks' MODE                                              -->
<!-- ============================================================= -->

<xsl:template name="bookmarks">
  <fo:bookmark-tree>
    <fo:bookmark
        internal-destination="article-title">
      <fo:bookmark-title font-weight="bold">
        <xsl:value-of select="front/article-meta/title-group/article-title"/>
      </fo:bookmark-title>
      <xsl:apply-templates select="body | back" mode="bookmarks"/>
    </fo:bookmark>
  </fo:bookmark-tree>
</xsl:template>

<xsl:template match="body" mode="bookmarks">
  <xsl:apply-templates select="sec" mode="bookmarks"/>
</xsl:template>

<xsl:template match="sec" mode="bookmarks">
    <fo:bookmark starting-state="hide">
      <xsl:attribute name="internal-destination" select="@id"/>
      <fo:bookmark-title font-style="italic">
        <xsl:value-of select="title"/>
      </fo:bookmark-title>
      <xsl:apply-templates select="sec" mode="bookmarks"/>
    </fo:bookmark>
</xsl:template>

<xsl:template match="sec/sec | ref-list | ack | fn" mode="bookmarks">
    <fo:bookmark>
      <xsl:attribute name="internal-destination" select="pf:get-id(.)"/>
      <fo:bookmark-title>
        <xsl:value-of
            select="(title, $generated-titles[@name eq local-name(current())])[1]"/>
      </fo:bookmark-title>
    </fo:bookmark>
</xsl:template>

<xsl:template match="back" mode="bookmarks">
  <xsl:apply-templates
      select="ack, key('fn-by-type', 'con'), ref-list" mode="bookmarks"/>
</xsl:template>


<!-- ============================================================= -->
<!-- END OF STYLESHEET                                             -->
<!-- ============================================================= -->

</xsl:stylesheet>
