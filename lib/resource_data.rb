require 'morph'
require 'hpricot'
require 'iconv'

module ResourceData

  class << self
    def is_pdf? url
      url[/(pdf)$/]
    end

    def is_word? url
      url[/(doc)$/]
    end

    def create url, response
      if is_pdf?(url)
        PdfResourceData.new(url, response)
      elsif is_word?(url)
        WordResourceData.new(url, response)
      else
        HtmlResourceData.new(url, response)
      end
    end
  end

  module GeneralMethods
    def initialize url, response
      self.url = url

      self.body = get_body url, response
      if body
        doc = Hpricot(body)
        add_page_title(doc)
        add_response_header_attributes(response)
        add_meta_attributes(doc)
        parse_time_attributes

        attributes = morph_attributes
        delete_uneeded_attributes(attributes)
        collapse_array_attribute_values(attributes)
        self.attributes = attributes
      end
    end

    def out_of_date? existing
      existing && (existing.date && date && existing.date < date)
    end

    protected

    def create_file_name url, ext
      url.sub('http://','').gsub('/','_').gsub('.','-').sub(/-#{ext}$/,".#{ext}")
    end

    def write_response_body file, response
      File.open(file,'wb') { |f| f.write response.body } unless File.exist?(file)
    end

    def prepare_text text, file_name
      text = convert_utf8_to_ascii(text, file_name)
      text = HTMLEntities.new.encode(text, :decimal)
      text = ParlyResource.strip_control_chars(text)
      text = HTMLEntities.new.decode(text)
      text
    end

    def convert_utf8_to_ascii text, file_name
      begin
        Iconv.iconv('ascii//translit', 'utf-8', text).to_s
      rescue Exception => e
        puts "#{e.class.name}: #{e.to_s}"
        puts "Trying iconv conversion again, this time discarding unconvertible characters"
        `iconv -c -f ascii//translit -t utf-8 #{file_name}`
      end
    end

    def delete_uneeded_attributes attributes
      corpname = attributes.delete(:corpname)
      attributes[:publisher] = corpname if corpname
      [:connection, :x_aspnetmvc_version, :x_aspnet_version,
      :viewport, :version, :originator, :generator, :x_pingback, :pingback,
      :content_location, :progid, :otheragent, :form, :robots,
      :columns, :vs_targetschema, :vs_defaultclientscript, :code_language,
      :x_n, :verify_v1, :contenttypes, :x_runtime, :status, :vary].each do |x|
        attributes.delete(x)
      end
    end

    def collapse_array_attribute_values attributes
      attributes.each do |key, value|
        if value.is_a?(Array)
          attributes[key] = value.inspect
        end
      end
    end

    def add_response_header_attributes response
      response.header.each { |key, value| morph(key, value) }

      if date
        self.response_date = date
        self.date = nil
      end
    end

    def parse_time_attributes
      begin
        self.date = Time.parse(date) if date
      rescue Exception => e
        puts "cannot parse date: #{date}"
        puts e.class.name
        puts e.to_s
        puts e.backtrace.join("\n")
      end
      self.response_date = Time.parse(response_date) if response_date
      self.last_modified = Time.parse(last_modified) if respond_to?(:last_modified) && last_modified
      self.coverage = Time.parse(coverage) if respond_to?(:coverage) && coverage
    end
  end

  module HtmlParseMethods
    def add_page_title doc
      self.title = doc.at('/html/head/title/text()').to_s
      self.title = doc.at('//title/text()').to_s if !respond_to?(:title) || title.blank?

      if !respond_to?(:title) || title.blank?
        self.title = "UNTITLED"
      elsif title == "Broadband Link - Error"
        raise "Router caching error, indexing aborted"
      end
    end

    def add_meta_attributes doc
      meta = (doc/'/html/head/meta')
      meta = (doc/'//meta') if meta.empty?

      meta_attributes = meta.each do |meta|
        name = meta['name']
        content = meta['content'].to_s
        if name && !content.blank? && !name[/^(title)$/i]
          if respond_to?(name.downcase.to_sym) && (value = send(name.downcase.to_sym))
            value = [value] unless value.is_a?(Array)
            value << content
            morph(name, value)
          else
            morph(name, content)
          end
        end
      end
    end
  end
end


class WordResourceData

  include Morph
  include ResourceData::GeneralMethods

  def get_body url, response
    name = create_file_name url, 'doc'
    file_path = "#{RAILS_ROOT}/data/word_docs/#{name}"
    write_response_body(file_path, response)

    xml_path = file_path.sub('.doc','.xml')

    check = `which antiword`
    unless check.blank?
      `antiword -x db #{file_path} > #{xml_path}`
      text = File.exist?(xml_path) ? IO.read(xml_path) : nil
      text = prepare_text(text, xml_path)
      text
    else
      puts 'to index Word docs install antiword: e.g. sudo port install antiword'
      nil
    end
  end

  def add_page_title doc
    self.title = doc.at('/book/title/text()').to_s
  end

  def add_meta_attributes(doc)
    meta = (doc/'/book/bookinfo/*').select(&:elem?)

    meta_attributes = meta.each do |meta|
      name = meta.name
      content = meta.inner_text.to_s.strip
      if name && !content.blank? && !name[/^(title)$/i]
        if respond_to?(name.downcase.to_sym) && (value = send(name.downcase.to_sym))
          value = [value] unless value.is_a?(Array)
          value << content
          morph(name, value)
        else
          morph(name, content)
        end
      end
    end
  end
end


class HtmlResourceData

  include Morph
  include ResourceData::GeneralMethods
  include ResourceData::HtmlParseMethods

  def get_body url, response
    response.body
  end

end


class PdfResourceData

  include Morph
  include ResourceData::GeneralMethods
  include ResourceData::HtmlParseMethods

  def get_body url, response
    name = create_file_name url, 'pdf'
    file_path = "#{RAILS_ROOT}/data/pdfs/#{name}"

    write_response_body(file_path, response)

    html = file_path.sub('.pdf','.html')
    `pdftotext -htmlmeta -enc UTF-8 #{file_path}` unless File.exist?(html)
    text = File.exist?(html) ? IO.read(html) : nil
    text = get_pdf_text_from_web(file_path, url) unless text
    text = prepare_text(text, html)
    text
  end

  def get_pdf_text_from_web file_path, url
    File.delete(file_path) unless File.exist?(file_path)
    `curl -o #{file_path} #{url}`
    html = file_path.sub('.pdf','.html')
    `pdftotext -htmlmeta -enc UTF-8 #{file_path}` unless File.exist?(html)

    File.exist?(html) ? IO.read(html) : nil
  end

end
