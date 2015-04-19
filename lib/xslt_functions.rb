class XsltFunctions
  # GPO will occassionally include multiple footnotes in a single node
  # we need to break them out in order to link them properly.
  def multiple_footnotes(nodes)
    footnotes = nodes.first.content.split(' ')

    Nokogiri::XML::Builder.with(doc) do |doc|
      doc.text "["
      doc.sup {
        footnotes.each do |footnote|
          doc.a(
            class: "footnote-reference",
            href: "#footnote-#{footnote}"
          ) {
            doc.text footnote
          }
        end
      }
      doc.text "]"
    end

    doc.children
  end

  def list_of_subjects(nodes)
    topics = nodes.first.content.split(',').map{|t| t.strip.gsub('.', '')}

    Nokogiri::XML::Builder.with(doc) do |doc|
      doc.ul {
        topics.each do |topic|
          doc.li {
            doc.a(
              href: "/topics/#{topic.downcase.gsub(' ', '-')}"
            ) {
              doc.text topic
            }
          }
        end
      }
    end

    doc.children
  end

  private

  def doc
    @doc ||= Nokogiri::XML::DocumentFragment.parse ""
  end
end
