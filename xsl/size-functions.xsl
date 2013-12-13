<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:aat="http://www.antennahouse.com/names/XSL/AreaTree"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:pf="http://plos.org/namespace/function"
    xmlns:po="http://plos.org/namespace/plos-one"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="aat mml pf po xlink xs">

<!-- ============================================================= -->
<!--  MODULE:    PLOS ONE size functions stylesheet                -->
<!--  VERSION:   1.0                                               -->
<!--  DATE:      April 2013                                        -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--  SYSTEM:    PLoS                                              -->
<!--                                                               -->
<!--  PURPOSE:   Functions for determining sizes of areas in an    -->
<!--             Antenna House area tree                           -->
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
<!-- KEYS                                                          -->
<!-- ============================================================= -->

<!-- 'table-wrap' elements in source XML. -->
<xsl:key name="table-wraps"
         match="table-wrap"
         use="true()" />

<xsl:key name="float-by-id"
         match="aat:FlowReferenceArea"
         use="aat:BlockArea/@id" />

<xsl:key name="block-by-id"
         match="aat:BlockViewportArea"
         use="@id" />


<!-- ============================================================= -->
<!-- FUNCTIONS                                                     -->
<!-- ============================================================= -->


<xsl:function name="pf:list-tables">
  <xsl:param name="source-doc" as="document-node()" />
  <xsl:param name="area-tree-doc" as="document-node()?" />

  <xsl:if test="empty($area-tree-doc)">
    <xsl:message select="concat('No area tree at ''', $area-tree, '''')"/>
  </xsl:if>

  <xsl:if test="exists($area-tree-doc)">
    <xsl:message select="base-uri($source-doc)" />
    <xsl:message select="base-uri($area-tree-doc)" />

    <xsl:for-each select="key('table-wraps', true(), $source-doc)">
      <xsl:message select="pf:get-id(.)" />
      <xsl:for-each
          select="for $prefix in ('column-wide-', 'page-wide-', 'page-high-')
                    return concat($prefix, pf:get-id(.))">
        <xsl:choose>
          <xsl:when test="exists(key('float-by-id',
                                     .,
                                     $area-tree-doc))">
            <xsl:variable
                name="float"
                select="key('float-by-id',
                            .,
                            $area-tree-doc)"
                as="element(aat:FlowReferenceArea)" />
            <xsl:variable
                name="height"
                select="$float/@height"
                as="xs:string" />
            <xsl:message select="." />
            <xsl:message
                select="concat('  width: ', $float/@width)" />
            <xsl:message
                select="concat('  height: ', $height)" />
            <xsl:message
                select="concat('  area: ', pf:area($float))" />
            <xsl:message
                select="concat('  overflow width: ',
                        pf:overflow-width($float/aat:TableAndCaptionArea[1]))" />
            <xsl:message
                select="concat('  overflow height: ',
                               if (starts-with(., 'page-high-'))
                                 then pf:overflow-height($float/aat:TableAndCaptionArea[1],
                                                         $page-page-width-inches * 72)
                               else pf:overflow-height($float/aat:TableAndCaptionArea[1]))" />
            <xsl:if test="pf:overflow-height($float/aat:TableAndCaptionArea[1]) and
                          not(pf:overflow-width($float/aat:TableAndCaptionArea[1]))">
              <xsl:message>Overflow height but not overflow width</xsl:message>
              <xsl:message select="concat('Height: ', $height)" />
              <xsl:message select="concat('Caption height: ', $float/aat:BlockArea[1]/@height)" />
              <xsl:message select="concat('Table height: ', $float/aat:TableAndCaptionArea[1]/@height)" />
              <xsl:message select="concat('Table head height: ', pf:sum-lengths-to-pt($float/aat:TableAndCaptionArea[1]/aat:TableViewportArea/aat:TableArea/aat:TableRowArea[@row-group-type eq 'table-header']/@height), 'pt')" />
              <xsl:for-each select="$float/aat:TableAndCaptionArea[1]/aat:TableViewportArea/aat:TableArea/aat:TableRowArea[@row-group-type eq 'table-body']">
                <xsl:message select="concat('Row ', position(), ':: id: ', @id, '; height: ', pf:length-to-pt(@height), 'pt; cumulative height: ', pf:sum-lengths-to-pt((@height, preceding-sibling::aat:TableRowArea[@row-group-type eq 'table-body']/@height)), 'pt')" />
              </xsl:for-each>
              <xsl:message select='concat("Table foot height: ", pf:sum-lengths-to-pt($float/aat:BlockArea[contains(@role, "table-wrap-foot")]/@height), "pt")' />
              <xsl:message select='concat("Object ID height: ", pf:sum-lengths-to-pt($float/aat:BlockArea[contains(@role, "object-id")]/@height), "pt")' />
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message
                select="concat('No area for ', .)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:if>
</xsl:function>

<xsl:function name="pf:table-attributes" as="attribute()*">
  <xsl:param name="table-wrap" as="element()" />
  <xsl:param name="area-tree-doc" as="document-node()" />

  <xsl:variable name="id" select="pf:get-id($table-wrap)" />

  <xsl:variable name="page-wide"
                select="key('float-by-id',
                            concat('page-wide-', $id),
                            $area-tree-doc)"
                as="element(aat:FlowReferenceArea)?" />
  <xsl:variable name="column-wide"
                select="key('float-by-id',
                            concat('column-wide-', $id),
                            $area-tree-doc)"
                as="element(aat:FlowReferenceArea)?" />
  <xsl:variable name="page-high"
                select="key('float-by-id',
                            concat('page-high-', $id),
                            $area-tree-doc)"
                as="element(aat:FlowReferenceArea)?" />

  <xsl:choose>
    <xsl:when
        test="exists($column-wide) and
              not(pf:overflow($column-wide/aat:TableAndCaptionArea[1])) and
              (empty($page-wide) or
               pf:overflow($page-wide/aat:TableAndCaptionArea[1]) or
               pf:area($column-wide) &lt;= pf:area($page-wide)) and
              (empty($page-high) or
               pf:overflow($page-high/aat:TableAndCaptionArea[1]) or
               pf:area($column-wide) &lt;= pf:area($page-high))">
      <xsl:attribute name="width" select="'1gr'" />
    </xsl:when>
    <xsl:when
        test="exists($page-wide) and
              not(pf:overflow($page-wide/aat:TableAndCaptionArea[1])) and
              (empty($page-high) or
               pf:overflow($page-high/aat:TableAndCaptionArea[1]) or
               pf:area($page-wide) &lt;= pf:area($page-high))">
      <xsl:attribute name="width" select="'3gr'" />
    </xsl:when>
    <xsl:when
        test="exists($page-high) and
              not(pf:overflow($page-wide/aat:TableAndCaptionArea[1])) and
              (empty($page-high) or
               pf:overflow($page-high/aat:TableAndCaptionArea[1]) or
               pf:area($page-wide) &lt;= pf:area($page-high))">
      <xsl:attribute name="width" select="'3gr'" />
      <xsl:attribute name="reference-orientation" select="'90'" />
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!-- pf:preferred-table-width($table-wrap as element(),
                              $area-tree-doc as document-node()?) -->
<!-- Returns 'column-wide', 'page-wide', 'page-high' or
     'page-high-column-deep' depending on which width is calculated as
     'best' for $table-wrap.  Returns 'page-wide' when can't determine
     a preferred width, including when $area-tree-doc does not
     exist. -->
<xsl:function name="pf:preferred-table-width" as="xs:string">
  <xsl:param name="table-wrap" as="element()" />
  <xsl:param name="area-tree-doc" as="document-node()?" />

  <xsl:choose>
    <xsl:when test="exists($area-tree-doc)">
      <xsl:variable name="id" select="pf:get-id($table-wrap)" />

      <xsl:variable name="page-wide"
                    select="key('float-by-id',
                                concat('page-wide-', $id),
                                $area-tree-doc)"
                    as="element(aat:FlowReferenceArea)?" />
      <xsl:variable name="column-wide"
                    select="key('float-by-id',
                                concat('column-wide-', $id),
                                $area-tree-doc)"
                    as="element(aat:FlowReferenceArea)?" />
      <xsl:variable name="page-high"
                    select="key('float-by-id',
                                concat('page-high-', $id),
                                $area-tree-doc)"
                    as="element(aat:FlowReferenceArea)?" />
      <xsl:message
          select="concat('pf:preferred-table-width():: ', $id)" />
      <xsl:message
          select="concat('Page-wide table overflow: ',
                         pf:overflow($page-wide/aat:TableAndCaptionArea[1]))" />
      <xsl:message
          select="concat('Page-high table overflow: ',
                         pf:overflow($page-high/aat:TableAndCaptionArea[1]))" />
      <xsl:choose>
        <xsl:when
            test="exists($column-wide) and
                  not(pf:overflow-width($column-wide/aat:TableAndCaptionArea[1])) and
                  (empty($page-wide) or
                   pf:overflow($page-wide/aat:TableAndCaptionArea[1]) or
                   pf:area($column-wide) &lt;= pf:area($page-wide)) and
                  (empty($page-high) or
                   pf:overflow($page-high/aat:TableAndCaptionArea[1]) or
                   pf:area($column-wide) &lt;= pf:area($page-high))">
          <xsl:sequence select="'column-wide'" />
        </xsl:when>
        <xsl:when
            test="exists($page-wide) and
                  not(pf:overflow-width($page-wide/aat:TableAndCaptionArea[1])) and
                  (empty($page-high) or
                   pf:overflow-height($page-high/aat:TableAndCaptionArea[1],
                                      $page-page-width-inches * 72) or
                   pf:area($page-wide) &lt;= pf:area($page-high))">
          <xsl:sequence select="'page-wide'" />
        </xsl:when>
        <xsl:when
            test="exists($page-high) and
                  not(pf:overflow-width($page-high/aat:TableAndCaptionArea[1]))">
          <xsl:choose>
            <xsl:when test="not(pf:overflow-height($page-high/aat:TableAndCaptionArea[1],
                                                   $page-column-width-inches * 72))">
              <xsl:sequence select="'page-high-column-deep'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="'page-high'" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="'Couldn''t determine best table width.'" />
          <xsl:sequence select="'page-wide'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="'page-wide'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="pf:caption-height" as="xs:string">
  <xsl:param name="fig" as="element()" />
  <xsl:param name="is-column-wide" as="xs:boolean" />

  <xsl:variable name="id" select="pf:get-id($fig)" />
  <xsl:if test="$debug.figure">
    <xsl:message select="$id"/>
  </xsl:if>
  <xsl:variable name="page-wide"
                select="key('block-by-id',
                            concat('page-wide-', $id),
                            $area-tree-doc)"
                as="element(aat:BlockViewportArea)?" />
  <xsl:variable name="column-wide"
                select="key('block-by-id',
                            concat('column-wide-', $id),
                            $area-tree-doc)"
                as="element(aat:BlockViewportArea)?" />

  <xsl:sequence
      select="if ($is-column-wide) then $column-wide/@height else $page-wide/@height" />
</xsl:function>

<!-- pf:area($area as element()) as xs:double -->
<!-- Returns the area (in square pt) of $area. -->
<xsl:function name="pf:area" as="xs:double">
  <xsl:param name="area" as="element()" />

  <xsl:sequence
      select="xs:double(replace($area/@width, 'pt', '')) *
              xs:double(replace($area/@height, 'pt', ''))" />
</xsl:function>

<!-- pf:overflow($area as element(aat:TableAndCaptionArea)) as xs:boolean -->
<!-- Returns true() if $area is wider than its ancestor reference
     area.  -->
<xsl:function name="pf:overflow" as="xs:boolean">
  <xsl:param name="area" as="element(aat:TableAndCaptionArea)?" />

  <xsl:sequence
      select="pf:overflow-width($area) or pf:overflow-height($area)" />
</xsl:function>

<!-- pf:overflow-width($area as element(aat:TableAndCaptionArea)) as xs:boolean -->
<!-- Returns true() if $area is wider than its ancestor reference
     area.  -->
<xsl:function name="pf:overflow-width" as="xs:boolean">
  <xsl:param name="area" as="element(aat:TableAndCaptionArea)?" />

  <xsl:sequence
      select="empty($area) or
              (xs:double(replace($area/aat:TableViewportArea/@width, 'pt', '')) >
               xs:double(replace($area/ancestor::aat:RegionReferenceArea/@width, 'pt', '')))" />
</xsl:function>

<!-- pf:overflow-height($area as element(aat:TableAndCaptionArea)) as xs:boolean -->
<!-- Returns true() if $area is wider than its ancestor reference
     area.  -->
<xsl:function name="pf:overflow-height" as="xs:boolean">
  <xsl:param name="area" as="element(aat:TableAndCaptionArea)?" />

  <xsl:sequence
      select="pf:overflow-height($area,
                                 $page-page-height-inches * 72)" />
</xsl:function>

<!-- pf:overflow-height($area as element(aat:TableAndCaptionArea)?,
                        $pt as xs:double) as xs:boolean -->
<!-- Returns true() if $area is higher than $pt.  -->
<xsl:function name="pf:overflow-height" as="xs:boolean">
  <xsl:param name="area" as="element(aat:TableAndCaptionArea)?" />
  <xsl:param name="pt" as="xs:double" />

  <xsl:sequence
      select="empty($area) or
              (xs:double(replace($area/ancestor::aat:AbsoluteFloatArea/@height, 'pt', '')) >
               $pt)" />
</xsl:function>

<xsl:function name="pf:area-full-width" as="xs:double">
  <xsl:param name="area" as="element()" />

  <xsl:sequence
      select="pf:sum-lengths-to-pt(($area/@border-start-width,
                                    $area/@padding-start,
                                    $area/@width,
                                    $area/@padding-end,
                                    $area/@border-end-width))" />
</xsl:function>

<xsl:function name="pf:area-full-height" as="xs:double">
  <xsl:param name="area" as="element()" />

  <xsl:sequence
      select="pf:sum-lengths-to-pt(($area/@space-before,
                                    $area/@border-before-width,
                                    $area/@padding-before,
                                    $area/@height,
                                    $area/@padding-after,
                                    $area/@border-after-width,
                                    $area/@space-after))" />
</xsl:function>

<!-- ============================================================= -->
<!-- END OF STYLESHEET                                             -->
<!-- ============================================================= -->

</xsl:stylesheet>
