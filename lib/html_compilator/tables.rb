class HtmlCompilator::Tables
  delegate :table_html_dir, :table_html_path, :table_xml_dir,
    to: :path_manager

  def self.compile(document_numbers, date_str)
    date = Date.parse(date_str)

    document_numbers.each do |document_number|
      new(document_number, date).perform
    end
  end

  attr_reader :document_number, :date

  def initialize(document_number, date)
    @document_number = document_number
    @date = date
  end

  def perform
    xml_paths = Dir.glob("#{table_xml_dir}/*.xml")
    return unless xml_paths.present?

    FileUtils.mkdir_p(table_html_dir)
    Dir.glob("#{table_html_dir}/*.html").each{|x| File.unlink(x) if File.exist?(x) }

    xml_paths.each do |xml_path|
      i = xml_path.split('/').last.to_i

      begin
        File.open(table_html_path(i), 'w') do |f|
          f.write HtmlCompilator::Tables::Table.compile(xml_path)
        end
      rescue StandardError => e
        Rails.logger.warn(e)
        Honeybadger.notify(e, :context => {:document_number => document_number, :table => i})
      end
    end
  end

  private

  def path_manager
    @path_manager ||= XsltPathManager.new(document_number, date)
  end
end
