<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" omit-xml-declaration="yes" />

  <xsl:include href="app/views/xslt/matchers/text/all.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/ignored_nodes.html.xslt" />

  <xsl:include href="app/views/xslt/matchers/full_text/document_headings.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/preamble.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/end_matter.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/footnotes.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/headers.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/images.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/list_of_subjects.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/notes.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/paragraphs.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/section.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/signature.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/structural_elements.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/stars.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/tables.html.xslt" />

  <xsl:template match="/">
    <xsl:apply-templates />

    <xsl:call-template name="footnotes" />
    <xsl:call-template name="end_matter" />
  </xsl:template>
</xsl:stylesheet>
