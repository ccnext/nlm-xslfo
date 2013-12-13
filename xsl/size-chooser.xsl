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
    exclude-result-prefixes="#all">

<!-- ============================================================= -->
<!--  MODULE:    PLOS ONE Table Size chooser stylesheet            -->
<!--  VERSION:   1.0                                               -->
<!--  DATE:      April 2013                                        -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--  SYSTEM:    PLOS                                              -->
<!--                                                               -->
<!--  PURPOSE:   Decides which size table to use when formatting   -->
<!--             a PLOS document                                   -->
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
<!--             AntennaHouse 6.1                                  -->
<!--                                                               -->
<!--  ORGANIZATION OF THIS STYLESHEET:                             -->
<!--             IMPORTS                                           -->
<!--             STYLESHEET PARAMETERS                             -->
<!--             GLOBAL VARIABLES                                  -->
<!--             TOP-LEVEL TEMPLATES                               -->
<!--             'no-id' MODE                                      -->
<!--                                                               -->
<!--  CREATED FOR:                                                 -->
<!--             Public Library of Science (PLOS)                  -->
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

<!-- IDs of tables to be forced to be page-high. -->
<xsl:param name="page-high"
           select="()"
           as="xs:string?" />


<!-- ============================================================= -->
<!-- GLOBAL VARIABLES                                              -->
<!-- ============================================================= -->

<xsl:variable name="page-high-ids"
              select="tokenize($page-high, ',\s*')"
              as="xs:string*" />


<!-- ============================================================= -->
<!-- TOP-LEVEL TEMPLATES                                           -->
<!-- ============================================================= -->

<xsl:template match="table-wrap | table-wrap-group">
  <xsl:variable
      name="preferred-table-width"
      select="if (@id = $page-wide-ids)
                then 'page-wide'
              else if (@id = $page-high-ids)
                then 'page-high'
              else pf:preferred-table-width(., $area-tree-doc)"
      as="xs:string" />
  <xsl:message select="concat(pf:get-id(.),
                              ':: preferred table width: ''',
                              $preferred-table-width,
                              '''')" />
  <xsl:choose>
    <xsl:when test="$preferred-table-width eq 'column-wide'">
      <xsl:call-template
          name="do-table-wrap">
        <xsl:with-param
            name="sizer-table-id"
            select="concat('column-wide-', pf:get-id(.))"
            as="xs:string" />
        <xsl:with-param
            name="float-reference"
            select="'column'"
            as="xs:string" />
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$preferred-table-width eq 'page-wide'">
      <xsl:call-template
          name="do-table-wrap">
        <xsl:with-param
            name="sizer-table-id"
            select="concat('page-wide-', pf:get-id(.))"
            as="xs:string" />
        <xsl:with-param
            name="float-reference"
            select="'page'"
            as="xs:string" />
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$preferred-table-width eq 'page-high-column-deep'">
      <xsl:call-template name="page-high-column-deep-table-wrap" />
    </xsl:when>
    <xsl:when test="$preferred-table-width eq 'page-high'">
      <xsl:call-template
          name="do-table-wrap">
        <xsl:with-param
            name="sizer-table-id"
            select="concat('page-high-', pf:get-id(.))"
            as="xs:string" />
        <xsl:with-param
            name="float-reference"
            select="'page'"
            as="xs:string" />
        <xsl:with-param
            name="reference-orientation"
            select="'90'"
            as="xs:string"
            tunnel="yes"/>
        <xsl:with-param
            name="available-height"
            select="concat($page-page-width-inches, 'in')"
            as="xs:string"
            tunnel="yes" />
        <xsl:with-param
            name="height"
            select="'100%'"
            as="xs:string"
            tunnel="yes" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes"
                   select="concat('Unknown preferred table width: ''',
                                  $preferred-table-width,
                                  '''')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="page-high-column-deep-table-wrap">
  <xsl:message select="concat(pf:get-id(.),
                              ':: page-high-column-deep table.')" />
  <xsl:call-template name="table-wrap">
    <xsl:with-param name="float-attributes"
                    as="attribute()*">
      <xsl:attribute name="axf:float-reference" select="'column'" />
      <xsl:attribute name="axf:float-move" select="'auto-next'" />
      <xsl:attribute name="axf:float-margin-y" select="'10pt'" />
    </xsl:with-param>
    <xsl:with-param
        name="table-attributes"
        as="attribute()*">
      <xsl:sequence
          select="pf:table-attributes(., $area-tree-doc)" />
      <xsl:attribute name="height" select="concat($page-column-width-inches, 'in')" />
      <xsl:attribute name="reference-orientation" select="'90'" />
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- Process a <table-wrap>.  Context is <table-wrap> to process.

     If formatted table from 'sizer' area tree is too high for
     available height, generates FO for two or more subtables in
     separatee fo:float to fake appearance of floated table
     breaking. -->
<xsl:template name="do-table-wrap">
  <xsl:param name="sizer-table-id"
             as="xs:string" />
  <xsl:param name="float-reference"
             as="xs:string" />
  <xsl:param name="reference-orientation"
             select="'0'"
             as="xs:string"
             tunnel="yes"/>
  <xsl:param name="height"
             select="'auto'"
             as="xs:string"
             tunnel="yes" />
  <xsl:param name="available-height"
             select="concat($page-page-height-inches, 'in')"
             as="xs:string"
             tunnel="yes" />

  <xsl:message select="pf:get-id(.)" />
  <xsl:choose>
    <xsl:when test="exists($area-tree-doc) and
                    exists(key('float-by-id',
                               $sizer-table-id,
                               $area-tree-doc))">
      <xsl:variable
          name="float"
          select="key('float-by-id',
                      $sizer-table-id,
                      $area-tree-doc)"
          as="element(aat:FlowReferenceArea)" />
      <xsl:variable
          name="float-height"
          select="$float/@height"
          as="xs:string" />
      <xsl:variable
          name="float-padding-before"
          select="$float/../@padding-before"
          as="xs:string" />
      <xsl:message
          select="concat($sizer-table-id,
                         ' : ', $float/@width,
                         ' : ', $float-height,
                         ' : ', pf:area($float),
                         ' : ', pf:overflow($float/aat:TableAndCaptionArea[1]))" />
      <xsl:choose>
        <xsl:when
            test="pf:sum-lengths-to-inches(($float-height, $float-padding-before)) >
                  pf:length-to-inches($available-height)">
          <xsl:message>Table too high</xsl:message>
          <xsl:variable name="table"
                        select="(table | alternatives/table)[1]"
                        as="element(table)" />
          <xsl:if test="$debug.table">
            <xsl:message
                select="concat('  Height: ', $float-height)" />
            <xsl:message
                select="concat('  Padding-before: ', $float-padding-before)" />
            <xsl:message
                select="concat('  Caption height: ',
                               pf:area-full-height($float/aat:BlockArea[1]),
                               'pt')" />
            <xsl:message
                select="concat('  Table height: ',
                               $float/aat:TableAndCaptionArea[1]/@height)" />
            <xsl:message
                select="concat('Table head height: ',
                               pf:sum-lengths-to-pt($float/
                                                      aat:TableAndCaptionArea[1]/
                                                        aat:TableViewportArea/
                                                          aat:TableArea/
                                                            aat:TableRowArea[@row-group-type eq 'table-header']/@height),
                               'pt')" />
            <xsl:message
                select="concat('  tbody rows: ',
                               count($table/tbody/tr))" />
          </xsl:if>
          <xsl:variable
              name="padding-caption-head-height"
              select="pf:area-full-height($float/aat:BlockArea[1]) +
                      pf:sum-lengths-to-pt(($float-padding-before,
                                            $float/
                                              aat:TableAndCaptionArea[1]/
                                                aat:TableViewportArea/
                                                  aat:TableArea/
                                                    aat:TableRowArea[@row-group-type eq 'table-header']/
                                                      @height))"
              as="xs:double" />
          <xsl:variable
              name="available-tbody-height"
              select="pf:length-to-pt($available-height) -
                      $padding-caption-head-height"
              as="xs:double" />
          <xsl:variable
              name="first-subtable-row-count"
              select="count($float/
                        aat:TableAndCaptionArea[1]/
                          aat:TableViewportArea/
                            aat:TableArea/
                              aat:TableRowArea[@row-group-type eq 'table-body']
                                              [pf:sum-lengths-to-pt((@height,
                                                                     preceding-sibling::aat:TableRowArea[@row-group-type eq 'table-body']/@height)) &lt;
                                               $available-tbody-height])"
              as="xs:integer" />
          <xsl:variable
              name="first-subtable-rows-height"
              select="pf:sum-lengths-to-pt($float/
                                             aat:TableAndCaptionArea[1]/
                                               aat:TableViewportArea/
                                                 aat:TableArea/
                                                   aat:TableRowArea[@row-group-type eq 'table-body']
                                                                   [$first-subtable-row-count]/
                                                     (@height, preceding-sibling::aat:TableRowArea[@row-group-type eq 'table-body']/@height))"
              as="xs:double" />
          <!-- Get the column widths from the area tree so they are
               the same on every page and so the automatic table
               layout doesn't optimise each table and produce shorter
               subtables on individual pages, but make sure there's no
               spans in the area tree row used to get the widths. -->
          <xsl:variable
              name="column-count"
              select="count($table/colgroup/col)"
              as="xs:integer" />
          <xsl:variable
              name="every-cell-row"
              select="$float/
                        aat:TableAndCaptionArea[1]/
                          aat:TableViewportArea/
                            aat:TableArea/aat:TableRowArea[count(aat:TableCellArea) eq
                                                           $column-count]
                                                          [1]"
              as="element(aat:TableRowArea)?" />
          <xsl:variable
              name="column-widths"
              select="for $cell-area in $every-cell-row/aat:TableCellArea
                        return pf:area-full-width($cell-area)"
              as="xs:double*" />
          <xsl:choose>
            <xsl:when test="exists($column-widths)">
              <xsl:message>
                <xsl:value-of
                    select="('Column widths:', $column-widths)" />
              </xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message select="'Couldn''t determine column widths for table.'" />
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="$debug.table">
            <xsl:message select="'first subtable:'" />
            <xsl:message
                select="concat('  padding-caption-head-height: ',
                               $padding-caption-head-height,
                               'pt')" />
            <xsl:message
                select="concat('  available-tbody-height: ',
                               $available-tbody-height,
                               'pt')" />
            <xsl:message
                select="concat('  first-subtable-row-count: ',
                               $first-subtable-row-count)" />
            <xsl:message
                select="concat('  first-subtable-rows-height: ',
                               $first-subtable-rows-height,
                               'pt')" />
          </xsl:if>
          <xsl:variable name="first-subtable">
            <xsl:copy>
              <xsl:copy-of select="@* | label | caption" />
              <table>
                <xsl:copy-of select="$table/(@* except @class)"/>
                <xsl:attribute
                    name="class"
                    select="string-join(($table/@class, 'first-subtable'), ' ')"/>
                <colgroup>
                  <xsl:copy-of select="@*" />
                  <xsl:for-each select="$table/colgroup/col">
                    <xsl:variable name="column-number" select="position()" />
                    <xsl:copy>
                      <xsl:copy-of select="@*" />
                      <xsl:attribute
                          name="width"
                          select="concat($column-widths[$column-number], 'pt')" />
                    </xsl:copy>
                  </xsl:for-each>
                </colgroup>
                <xsl:copy-of select="$table/thead"/>
                <tbody>
                  <xsl:copy-of select="$table/tbody/tr[position() &lt;= $first-subtable-row-count]" />
                </tbody>
              </table>
            </xsl:copy>
          </xsl:variable>
          <xsl:call-template name="table-wrap">
            <xsl:with-param name="table-wrap"
                            select="$first-subtable/table-wrap"
                            as="element(table-wrap)"/>
            <xsl:with-param name="float-attributes"
                       as="attribute()*">
              <xsl:attribute name="axf:float-reference" select="$float-reference" />
              <xsl:attribute name="axf:float-move" select="'auto-next'" />
              <xsl:attribute name="axf:float-margin-y" select="'10pt'" />
            </xsl:with-param>
            <xsl:with-param
                name="table-attributes"
                as="attribute()*">
              <xsl:attribute name="width" select="'100%'" />
              <xsl:attribute name="reference-orientation"
                             select="$reference-orientation" />
              <xsl:attribute name="height"
                             select="$height" />
            </xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="following-subtable">
            <!-- The original table from source XML. -->
            <xsl:with-param name="table"
                            select="$table"
                            as="element(table)"
                            tunnel="yes" />
            <xsl:with-param name="sizer-table-id"
                            select="$sizer-table-id"
                            as="xs:string"
                            tunnel="yes" />
            <xsl:with-param name="float"
                            select="$float"
                            as="element(aat:FlowReferenceArea)"
                            tunnel="yes"/>
            <xsl:with-param name="previous-rows-height"
                            select="$first-subtable-rows-height"
                            as="xs:double" />
            <xsl:with-param name="previous-rows-count"
                            select="$first-subtable-row-count"
                            as="xs:integer" />
            <xsl:with-param name="float-reference"
                            select="$float-reference"
                            as="xs:string"
                            tunnel="yes" />
            <xsl:with-param name="column-widths"
                            select="$column-widths"
                            as="xs:double*"
                            tunnel="yes" />
            <xsl:with-param name="available-height"
                            select="$available-height"
                            as="xs:string"
                            tunnel="yes" />
            <xsl:with-param name="height"
                            select="'auto'"
                            as="xs:string"
                            tunnel="yes" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat(pf:get-id(.),
                                      ':: *-wide table.')" />
          <xsl:call-template name="table-wrap">
            <xsl:with-param name="float-attributes"
                            as="attribute()*">
              <xsl:attribute name="axf:float-reference" select="$float-reference" />
              <xsl:attribute name="axf:float-move" select="'auto-next'" />
              <xsl:attribute name="axf:float-margin-y" select="'10pt'" />
            </xsl:with-param>
            <xsl:with-param
                name="table-attributes"
                as="attribute()*">
              <xsl:attribute name="width" select="'100%'" />
              <xsl:attribute name="reference-orientation"
                             select="$reference-orientation" />
              <xsl:attribute name="height"
                             select="$height" />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="concat(pf:get-id(.),
                                  ':: no sizer.fo table; defaulting to page-wide.')" />
      <xsl:call-template name="table-wrap">
        <xsl:with-param name="float-attributes"
                        as="attribute()*">
          <xsl:attribute name="axf:float-reference" select="'page'" />
          <xsl:attribute name="axf:float-move" select="'auto-next'" />
          <xsl:attribute name="axf:float-margin-y" select="'10pt'" />
        </xsl:with-param>
        <xsl:with-param
            name="table-attributes"
            as="attribute()*">
          <xsl:attribute name="width" select="'100%'" />
          <xsl:attribute name="reference-orientation"
                         select="$reference-orientation" />
          <xsl:attribute name="height"
                         select="$height" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Process subtables after the first.  Generates a 'Table n
     (continued)' label and a <table> containing only the rows that
     will fit in availble height.  Will also copy table footnotes if
     there's room.  Calls itself recursively while there's still rows
     to be placed in further subtables and/or table footnotes to be
     placed. -->
<xsl:template name="following-subtable">
  <!-- The original table from source XML. -->
  <xsl:param name="table"
             as="element(table)"
             tunnel="yes" />
  <!-- ID of the right-width table from the 'sizer' area tree. -->
  <xsl:param name="sizer-table-id"
             as="xs:string"
             tunnel="yes" />
  <!-- Float area from the 'sizer' area tree. -->
  <xsl:param name="float"
             as="element(aat:FlowReferenceArea)"
             tunnel="yes"/>
  <!-- Height of all rows placed so far. -->
  <xsl:param name="previous-rows-height"
             as="xs:double" />
  <!-- Number of rows placed so far. -->
  <xsl:param name="previous-rows-count"
             as="xs:integer" />
  <!-- Value for generated @axf:float-reference.  Usually 'column' or
       'page'. -->
  <xsl:param name="float-reference"
             as="xs:string"
             tunnel="yes" />
  <!-- Sequence of column widths calculated from area tree to use in
       generated <table>. -->
  <xsl:param name="column-widths"
             as="xs:double*"
             tunnel="yes" />
  <!-- Height available for the subtable (and any following
       subtables). -->
  <xsl:param name="available-height"
             as="xs:string"
             tunnel="yes" />
  <!-- Value to use for generated @reference-orientation. -->
  <xsl:param name="reference-orientation"
             select="'0'"
             as="xs:string"
             tunnel="yes"/>
  <!-- Value to use for generated @height.  Usually 'auto' but may be
       a length to stop text from the normal flow appearing after a
       table that doesn't fill its column, column width, or page. -->
  <xsl:param name="height"
             as="xs:string"
             tunnel="yes"/>

  <xsl:variable
      name="label-float"
      select="key('float-by-id',
                  concat('label-', $sizer-table-id),
                  $area-tree-doc)"
      as="element(aat:FlowReferenceArea)" />

  <xsl:variable
      name="label-height"
      select="pf:area-full-height($label-float/aat:BlockArea[1])"
      as="xs:double" />
  <xsl:variable
      name="label-head-height"
      select="$label-height +
              pf:sum-lengths-to-pt(($float/../@padding-before,
                                    $float/aat:TableAndCaptionArea[1]/
                                      aat:TableViewportArea/
                                        aat:TableArea/
                                          aat:TableRowArea[@row-group-type eq
                                                           'table-header']/
                                            @height))"
      as="xs:double" />
  <xsl:variable
      name="available-tbody-height"
      select="pf:length-to-pt($available-height) -
              $label-head-height"
      as="xs:double" />
  <xsl:variable
      name="subtable-row-count"
      select="if ($previous-rows-count &lt; count($table/tbody/tr))
                then count($float/
                           aat:TableAndCaptionArea[1]/
                           aat:TableViewportArea/
                           aat:TableArea/
                           aat:TableRowArea[@row-group-type eq 'table-body']
                                           [position() > $previous-rows-count]
                                           [pf:sum-lengths-to-pt((@height,
                                                                  preceding-sibling::aat:TableRowArea[@row-group-type eq 'table-body']/@height)) -
                                            $previous-rows-height &lt;
                                            $available-tbody-height])
              else 0"
      as="xs:integer" />
  <xsl:variable
      name="subtable-rows-height"
      select="if ($subtable-row-count ne 0)
                then pf:sum-lengths-to-pt($float/
                                          aat:TableAndCaptionArea[1]/
                                          aat:TableViewportArea/
                                          aat:TableArea/
                                          aat:TableRowArea[@row-group-type eq 'table-body']
                                                          [$previous-rows-count + $subtable-row-count]/
                                          (@height,
                                           preceding-sibling::aat:TableRowArea[@row-group-type eq 'table-body']/@height)) -
                     $previous-rows-height
               else 0"
          as="xs:double" />
  <xsl:variable
      name="placed-all-rows"
      select="count($table/tbody/tr) eq $previous-rows-count + $subtable-row-count"
      as="xs:boolean" />
  <xsl:if test="$debug.table">
    <xsl:message select="'following-subtable:'" />
    <xsl:message
        select="concat('  previous-rows-count: ',
                       $previous-rows-count)" />
    <xsl:message
        select="concat('  previous-rows-height: ',
                       $previous-rows-height,
                       'pt')" />
    <xsl:message
        select="concat('  label-height: ',
                       $label-height,
                       'pt')" />
    <xsl:message
        select="concat('  label-head-height: ',
                       $label-head-height,
                       'pt')" />
    <xsl:message
        select="concat('  available-tbody-height: ',
                       $available-tbody-height,
                       'pt')" />
    <xsl:message
        select="concat('  subtable-row-count: ',
                       $subtable-row-count)" />
    <xsl:message
        select="concat('  subtable-rows-height: ',
                       $subtable-rows-height,
                       'pt')" />
  </xsl:if>
  <xsl:variable
      name="subtable"
      as="element(table)?">
    <xsl:if test="$subtable-row-count > 0">
      <table>
        <xsl:copy-of select="$table/(@* except (@id, @class))"/>
        <xsl:attribute
            name="class"
            select="string-join(($table/@class,
                                 if ($placed-all-rows)
                                   then 'last-subtable'
                                 else 'intermediate-subtable'),
                                ' ')"/>
        <colgroup>
          <xsl:copy-of select="@* except @id" />
          <xsl:for-each select="$table/colgroup/col">
            <xsl:variable name="column-number" select="position()" />
            <xsl:copy>
              <xsl:copy-of select="@*" />
              <xsl:attribute
                  name="width"
                  select="concat($column-widths[$column-number], 'pt')" />
            </xsl:copy>
          </xsl:for-each>
        </colgroup>
        <xsl:apply-templates select="$table/thead" mode="no-id" />
        <tbody>
          <xsl:copy-of
              select="$table/tbody/tr[position() > $previous-rows-count and
                                      position() &lt;= $previous-rows-count + $subtable-row-count]" />
        </tbody>
      </table>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="subtable-wrap">
    <xsl:copy>
      <xsl:copy-of select="@* except @id" />
      <label>
        <xsl:value-of select="label" />
        <xsl:text> (continued)</xsl:text>
      </label>
      <xsl:sequence select="$subtable"/>
      <xsl:variable
          name="table-foot-height"
          select='pf:sum-lengths-to-pt($float/aat:BlockArea[contains(@role, "table-wrap-foot")]/@height)'
          as="xs:double" />
      <xsl:variable
          name="object-id-height"
          select='pf:sum-lengths-to-pt($float/aat:BlockArea[contains(@role, "object-id")]/@height)'
          as="xs:double" />
      <xsl:if
          test="$placed-all-rows">
        <xsl:if test="$debug.table">
          <xsl:message select="'Placed all tbody rows.'" />
          <xsl:message select='concat("  Table foot height: ", $table-foot-height, "pt")' />
          <xsl:message select='concat("  Object ID height: ", $object-id-height, "pt")' />
        </xsl:if>
        <xsl:variable
            name="total-height"
            select="$subtable-rows-height + $table-foot-height + $object-id-height"
            as="xs:double" />
        <xsl:if test="$debug.table">
          <xsl:message
              select="concat('  Total: ', $total-height, 'pt')" />
        </xsl:if>
        <xsl:if
            test="$total-height &lt;= $available-tbody-height">
          <xsl:if test="$debug.table">
            <xsl:message select="'Room to spare.'" />
          </xsl:if>
          <xsl:copy-of
              select="table-wrap-foot, object-id" />
        </xsl:if>
      </xsl:if>
    </xsl:copy>
  </xsl:variable>
  <xsl:call-template name="table-wrap">
    <xsl:with-param name="table-wrap"
                    select="$subtable-wrap/table-wrap"
                    as="element(table-wrap)"/>
    <xsl:with-param name="float-attributes"
                    as="attribute()*">
      <xsl:attribute name="axf:float-reference" select="$float-reference" />
      <xsl:attribute name="axf:float-move" select="'auto-next'" />
      <xsl:attribute name="axf:float-margin-y" select="'10pt'" />
    </xsl:with-param>
    <xsl:with-param
        name="table-attributes"
        as="attribute()*">
      <xsl:attribute name="width" select="'100%'" />
      <xsl:attribute name="reference-orientation"
                     select="$reference-orientation" />
      <xsl:attribute name="height"
                     select="$height" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:if
      test="count($table/tbody/tr) > $previous-rows-count + $subtable-row-count">
    <xsl:call-template name="following-subtable">
      <xsl:with-param name="previous-rows-height"
                      select="$previous-rows-height + $subtable-rows-height"
                      as="xs:double" />
      <xsl:with-param name="previous-rows-count"
                      select="$previous-rows-count + $subtable-row-count"
                      as="xs:integer" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- ============================================================= -->
<!-- 'no-id' MODE                                                  -->
<!-- ============================================================= -->

<xsl:template match="@id" mode="no-id" />

<xsl:template match="@*|node()" mode="no-id">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="#current" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
