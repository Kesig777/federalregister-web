<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template mode="footnotes" match="FTNT">
    <xsl:variable name="number">
      <xsl:value-of select="descendant::SU/text()"/>
    </xsl:variable>

    <div class="footnote">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('footnote-', $number)"/>
      </xsl:attribute>

      <xsl:apply-templates />

      <a class="back">
        <xsl:attribute name="href">
          <xsl:text>#citation-</xsl:text>
          <xsl:value-of select="$number"/>
        </xsl:attribute>
        Back to Citation
      </a>
    </div>
  </xsl:template>


  <xsl:template match="E[@T=51 and following-sibling::*[1][self::FTREF]]
    | SU[following-sibling::FTREF]">
    <xsl:copy-of select="fr:footnotes(text())"/>
  </xsl:template>


  <xsl:template match="SU[ancestor::FTNT]">
    <xsl:apply-templates />.
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template name="footnotes">
    <xsl:if test="count(//FTNT) &gt; 0">
      <xsl:call-template name="manual_header">
        <xsl:with-param name="id" select="'footnotes'"/>
        <xsl:with-param name="name" select="'Footnotes'"/>
        <xsl:with-param name="level" select="1"/>
      </xsl:call-template>
      <div class="footnotes">
        <xsl:apply-templates select="//FTNT" mode="footnotes"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
