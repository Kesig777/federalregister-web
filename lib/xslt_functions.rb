class XsltFunctions
  include GpoImages::ImageIdentifierNormalizer

  # GPO will occassionally include multiple footnotes in a single node
  # we need to break them out in order to link them properly.
  def footnotes(nodes, page_number)
    footnotes = nodes.first
    # sometimes XML will have FTRF that follow blank nodes so just return
    return blank_document.children unless footnotes

    footnotes = footnotes.content.split(' ')
    document = blank_document
    Nokogiri::XML::Builder.with(document) do |doc|
      doc.sup {
        doc.text "["

        footnotes.each do |footnote|
          doc.a(
            class: "footnote-reference",
            href: "#footnote-#{footnote}-p#{page_number}",
            id: "citation-#{footnote}-p#{page_number}"
          ) {
            doc.text footnote
          }

          doc.text ", " if footnotes.last != footnote
        end
        doc.text "] "
      }
    end

    document.children
  end

  def list_of_subjects(nodes)
    topics = ListOfSubjectsTopicParser.parse(nodes.first.content)

    document = blank_document
    Nokogiri::XML::Builder.with(document) do |doc|
      doc.ul(
        class: 'subject-list'
      ) {
        topics.each do |topic|
          doc.li {
            # doc.a(
            #   href: "/topics/#{topic.downcase.gsub(' ', '-')}"
            # ) {
              doc.text topic
            # }
          }
        end
      }
    end

    document.children
  end

  def amendment_part(nodes)
    if nodes.first.class == Nokogiri::XML::Text
      node_text = nodes.first.content

      match = node_text.strip.match(/^(\d+\.) (.*)/)
      css_class = 'amendment-part-number'

      unless match
        match = node_text.strip.match(/^([a-z]\.) (.*)/)
        css_class = 'amendment-part-subnumber'
      end

      if match
        document = blank_document
        part_number, part_text = match[1], match[2]

        Nokogiri::XML::Builder.with(document) do |doc|
          doc.span(class: css_class) {
            doc.text "#{part_number} "
          }

          doc.text "#{part_text} "
        end

        # remove the first text node that we're replacing
        # with our marked up version
        nodes.shift
        nodes = prepend_nodes(nodes, document.children)
      end
    end

    nodes
  end

  def notify_missing_graphic(nodes, document_number, publication_date)
    document = blank_document
    node_text = nodes.first.content

    Honeybadger.notify(
      error_class: 'HTML::Compilator',
      error_message: "Missing Graphic #{node_text} for FR Doc #{document_number} on #{publication_date}",
      parameters: {
        graphic_identifier: node_text,
        document_number: document_number,
        publication_date: publication_date
      }
    )

    document.children
  end

  def gpo_image(nodes, link_id, image_class, data_width, data_height, images, document_number, publication_date)
    document = blank_document
    images = images.split(' ')

    graphic_identifier = URI.encode(nodes.first.content)
    image = images.find{|i| i.include?(graphic_identifier)}

    if image
      url = image.split(',').last
    else
      notify_missing_graphic(nodes, document_number, publication_date)
      # Stub out url with expected image such that when it's available
      # we don't need to reprocess. This will break if images url is not
      # the expected one (eg changes at some point in future)
      url = graphic_url('original', graphic_identifier)
    end

    Nokogiri::XML::Builder.with(document) do |doc|
      doc.a(
        class: "document-graphic-link",
        id: link_id,
        href: url,
        'data-col-width' => data_width,
        'data-height' => data_height
      ) {
        doc.img(
          :class => image_class,
          :src => url,
          :style => "max-height: #{(1.29 * data_height.to_i).to_i}px"
        )
      }
    end

    document.children
  end

  def capitalize(nodes)
    nodes.first.content.upcase
  end

  private

  def blank_document
    Nokogiri::XML::DocumentFragment.parse ""
  end

  def prepend_nodes(nodeset, nodes)
    # insert new nodes in reverse order (the only method we have is push)
    nodeset = nodeset.reverse
    nodes.reverse.each{|x| nodeset.push(x) }

    # reverse to get our desired order
    nodeset.reverse
  end

  def graphic_url(size, graphic_identifier)
    "https://s3.amazonaws.com/#{Settings.s3_buckets.public_images}/#{graphic_identifier}/#{size}.png"
  end
end
