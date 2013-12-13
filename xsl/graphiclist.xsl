<!-- ============================================================= -->
<!--  MODULE:     graphiclist.xsl                                  -->
<!--  VERSION:    1                                                -->
<!--  DATE:       16 December 2010                                 -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!-- SYSTEM:      PLoS                                             -->
<!--                                                               -->
<!-- PURPOSE:     Populate a list of the graphic files referred to -->
<!--              in a particular article.                         -->
<!--                                                               -->
<!-- INPUT FILE:  Journal XML file.                                -->
<!--                                                               -->
<!-- OUTPUT FILE: List of filenames, one per line.                 -->
<!--                                                               -->
<!-- CREATED FOR: Public Library of Science (PLoS)                 -->
<!--                                                               -->
<!-- CREATED BY:  Mentea                                           -->
<!--              13 Kelly's Bay Beach                             -->
<!--              Skerries, Co. Dublin                             -->
<!--              Ireland                                          -->
<!--              http://www.mentea.net/                           -->
<!--              info@mentea.net                                  -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--              16 December 2012                                 -->
<!--                                                               -->
<!-- CREATED BY:  Tony Graham (tkg)                                -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--              VERSION HISTORY                                  -->
<!-- ============================================================= -->
<!--
 1.  ORIGINAL VERSION                                 tkg 20101004
                                                                   -->

<!-- ============================================================= -->
<!--                    DESIGN CONSIDERATIONS                      -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    XSL STYLESHEET INVOCATION                  -->
<!-- ============================================================= -->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xlink xs">


<!-- ============================================================= -->
<!--                    OUTPUT SERIALIZATION                       -->
<!-- ============================================================= -->

<xsl:output method="xml" indent="yes" />
  

<!-- ============================================================= -->
<!--                    KEYS                                       -->
<!-- ============================================================= -->

<xsl:key name="graphics"
         match="graphic | inline-graphic"
         use="true()" />


<!-- ============================================================= -->
<!--                    STYLESHEET PARAMETERS                      -->
<!-- ============================================================= -->

<xsl:param name="prefix"
           as="xs:string?" />

<xsl:param name="suffix"
           as="xs:string?" />

<!-- ============================================================= -->
<!--                    TEMPLATE RULES                             -->
<!-- ============================================================= -->

<xsl:template match="/">
  <project name="plosone-graphics" basedir="." default="get">
    <xsl:text>&#xA;</xsl:text>
    <description>Tasks for PLOS ONE processing.</description>
    <xsl:text>&#xA;</xsl:text>
    <target name="get">
      <xsl:text>&#xA;</xsl:text>
      <xsl:if test="exists(key('graphics', true())[1])">
        <get dest="downloads"
             skipexisting="true"
             verbose="true"
	     ignoreerrors="true">
          <xsl:text>&#xA;</xsl:text>
          <chainedmapper>
            <xsl:text>&#xA;</xsl:text>
            <globmapper from="*{$suffix}" to="*.tif" />
            <xsl:text>&#xA;</xsl:text>
            <flattenmapper />
            <xsl:text>&#xA;</xsl:text>
          </chainedmapper>
          <xsl:text>&#xA;</xsl:text>
          <xsl:for-each
              select="distinct-values(key('graphics',
                                          true())/@xlink:href)">
            <url url="{concat($prefix, ., $suffix)}" />
            <xsl:text>&#xA;</xsl:text>
          </xsl:for-each>
        </get>
        <xsl:text>&#xA;</xsl:text>
      </xsl:if>
    </target>
    <xsl:text>&#xA;</xsl:text>
  </project>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>

</xsl:stylesheet>

<!-- ============================================================= -->
<!--                    End of graphiclist.xsl                     -->
<!-- ============================================================= -->
