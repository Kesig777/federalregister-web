<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- return the appropriate level for a header element - xml nodes are HED, HD1, HD2, etc -->
  <xsl:template name="header_level">
    <xsl:param name="source" />
    <xsl:choose>
      <xsl:when test="$source = 'HED'">1</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number(translate($source, 'HD', '')) + 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Returns an 'h-#' id for a header element, where # is an incremented
    number.
    This number is based off the preceeding number of headers in the XML not
    the preceeding number of headers we end up displaying in the html - so
    while they will be increasing, some numbers may be missing -->
  <xsl:template name="header_id">
    <xsl:value-of select="concat('h-', count(preceding::HD)+1)" />
  </xsl:template>

  <!-- generate h1, h2, etc elements -->
  <xsl:template name="header">
    <xsl:param name="class" select="''"/>

    <xsl:variable name="level">
      <xsl:call-template name="header_level">
        <xsl:with-param name="source" select="@SOURCE"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:element name="{concat('h', $level)}">
      <xsl:attribute name="id">
        <xsl:call-template name="header_id" />
      </xsl:attribute>

        <xsl:if test="$class">
          <xsl:attribute name="class">
            <xsl:value-of select="$class"/>
          </xsl:attribute>
        </xsl:if>

      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <!-- Manually build a header by passing in variables for name, level, and
       class. Used to create headers for things like List of Subjects, etc. -->
  <xsl:template name="manual_header">
    <xsl:param name="name"/>
    <xsl:param name="level" value="1"/>

    <xsl:param name="id">
      <xsl:call-template name="header_id" />
    </xsl:param>

    <xsl:param name="class" select="''"/>
      <xsl:element name="{concat('h', $level)}">
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>

        <xsl:if test="$class">
          <xsl:attribute name="class">
            <xsl:value-of select="$class"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:copy-of select="$name"/>
      </xsl:element>
  </xsl:template>

</xsl:stylesheet>
