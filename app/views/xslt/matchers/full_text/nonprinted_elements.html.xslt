<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--  These are elements that are marked up by OFR/GPO and
        delineate particular sections of the document, but are
        not printed. We offer these as an enhancement to aid the
        user in understanding the document. -->

  <xsl:template match="PREAMB">
    <span class="unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="preamble unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip">
        <xsl:attribute name="data-tooltip">
          <xsl:value-of select="'Start Preamble'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>

    <xsl:apply-templates />

    <span class="unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="preamble unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip">
        <xsl:attribute name="data-tooltip">
          <xsl:value-of select="'End Preamble'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>
  </xsl:template>
</xsl:stylesheet>

