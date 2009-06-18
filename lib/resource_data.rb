require 'morph'
require 'hpricot'
require 'iconv'

class ResourceData
  include Morph

  def initialize url, response
    self.url = url
    self.body = is_pdf?(url) ? get_pdf_text(url, response) : response.body
    doc = Hpricot(body)
    add_page_title(doc)
    add_response_header_attributes(response)
    add_html_meta_attributes(doc)
    parse_time_attributes

    attributes = morph_attributes
    delete_uneeded_attributes(attributes)
    collapse_array_attribute_values(attributes)
    self.attributes = attributes
  end

  def out_of_date? existing
    existing && (existing.date && date && existing.date < date)
  end

  private

  def is_pdf? url
    url[/(pdf)$/]
  end

  def get_pdf_text url, response
    name = url.sub('http://','').gsub('/','_').gsub('.','-').sub(/-pdf$/,'.pdf')
    pdf = "#{RAILS_ROOT}/data/pdfs/#{name}"

    text = get_pdf_text_from_response(pdf, response)
    text = get_pdf_text_from_web(pdf, url) unless text

    text = convert_utf8_to_ascii(text)
    text = HTMLEntities.new.encode(text, :decimal)
    text = ParlyResource.strip_control_chars(text)
    text = HTMLEntities.new.decode(text)
    text
  end

  def convert_utf8_to_ascii text
    begin
      Iconv.iconv('ascii//translit', 'utf-8', text).to_s
    rescue Exception => e
      puts "#{e.class.name}: #{e.to_s}"
      puts "Trying iconv conversion again, this time discarding unconvertible characters"
      `iconv -c -f ascii//translit -t utf-8 #{pdf.sub('.pdf','.html')}`
    end
  end

  def get_pdf_text_from_web pdf, url
    File.delete(pdf) unless File.exist?(pdf)
    `curl -o #{pdf} #{url}`
    get_html_from_pdf(pdf)
  end

  def get_pdf_text_from_response pdf, response
    File.open(pdf,'wb') { |f| f.write response.body } unless File.exist?(pdf)
    get_html_from_pdf(pdf)
  end

  def get_html_from_pdf pdf
    html = pdf.sub('.pdf','.html')
    `pdftotext -htmlmeta -enc UTF-8 #{pdf}` unless File.exist?(html)

    File.exist?(html) ? IO.read(html) : nil
  end

  def delete_uneeded_attributes attributes
    [:connection, :x_aspnetmvc_version, :x_aspnet_version,
    :viewport, :version, :originator, :generator, :x_pingback, :pingback,
    :content_location, :progid, :otheragent, :form, :robots,
    :columns, :vs_targetschema, :vs_defaultclientscript, :code_language,
    :x_n].each do |x|
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

  def add_page_title doc
    self.title = doc.at('/html/head/title/text()').to_s
    self.title = doc.at('//title/text()').to_s if title.blank?

    if title.blank?
      self.title = "UNTITLED"
    elsif title == "Broadband Link - Error"
      raise "Router caching error, indexing aborted"
    end
  end

  def add_response_header_attributes response
    response.header.each { |key, value| morph(key, value) }

    if date
      self.response_date = date
      self.date = nil
    end
  end

  def add_html_meta_attributes doc
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
