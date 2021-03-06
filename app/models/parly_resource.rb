require 'htmlentities'

class ParlyResource < ActiveRecord::Base

  validates_presence_of :title

  acts_as_solr :fields => [:short_title,
      :unique_description,
      :text,
      {:resource_date => :date},
      {:file_type => :facet}],
      :facets => [:file_type]

  def file_type
    if content_type.include?('html')
      'html'
    elsif content_type.include?('pdf')
      'pdf'
    elsif content_type.include?('word')
      'word'
    else
      raise "unrecognized content type: #{content_type}"
    end
  end

  def file_format
    if content_type.include?('text/html')
      return 'HTML'
    elsif content_type[/pdf/]
      return 'PDF'
    elsif content_type[/word/]
      return 'DOC'
    else
      return content_type
    end
  end

  class << self

    def reindex
      find_each do |item|
        begin
          item.save!
          print '.'
          $stdout.flush
        rescue Exception => e
          puts item.inspect
          puts e.class.name
          puts e.to_s
        end
      end
    end

    def search term, offset, limit, sort=nil, file_type=nil
      if term.blank?
        []
      else
        options = sort_options(sort).merge(:offset => offset, :limit => limit)
        term = "#{term} AND file_type:#{file_type}" if file_type && file_type[/^(pdf|html|word)$/]
        options = options.merge(:facets=>{:zeros=>false,:fields=>[:unique_description]})
        solr_results = find_by_solr(term, options)
        return [solr_results.results, solr_results.total]
      end
    end

    def page_start(results_per_page, current_page=1)
      current_page = 1 if current_page.nil?
      current_page = current_page.to_i

      (current_page - 1) * results_per_page + 1
    end

    def page_end(total_results, results_per_page, current_page=1)
      current_page = 1 if current_page.nil?
      current_page = current_page.to_i

      page_start = page_start(results_per_page, current_page)
      if page_start + results_per_page - 1 > total_results
        total_results
      else
        page_start + results_per_page - 1
      end
    end

    def strip_control_chars text
      text.gsub!('&#00;', ' ') #  null character
      text.gsub!('&#1;', ' ') # 	start of header
      text.gsub!('&#2;', ' ') # 	start of text
      text.gsub!('&#3;', ' ') # 	end of text
      text.gsub!('&#4;', ' ') # 	end of transmission
      text.gsub!('&#5;', ' ') # 	enquiry
      text.gsub!('&#6;', ' ') # 	acknowledge
      text.gsub!('&#7;', ' ') # 	bell (ring)
      text.gsub!('&#8;', ' ') # 	backspace
      text.gsub!('&#9;', ' ') # 	horizontal tab
      text.gsub!('&#01;', ' ') # 	start of header
      text.gsub!('&#02;', ' ') # 	start of text
      text.gsub!('&#03;', ' ') # 	end of text
      text.gsub!('&#04;', ' ') # 	end of transmission
      text.gsub!('&#05;', ' ') # 	enquiry
      text.gsub!('&#06;', ' ') # 	acknowledge
      text.gsub!('&#07;', ' ') # 	bell (ring)
      text.gsub!('&#08;', ' ') # 	backspace
      text.gsub!('&#09;', ' ') # 	horizontal tab
      text.gsub!('&#10;', ' ') # 	line feed
      text.gsub!('&#11;', ' ') # 	vertical tab
      text.gsub!('&#12;', ' ') # 	form feed
      text.gsub!('&#13;', ' ') # 	carriage return
      text.gsub!('&#14;', ' ') # 	shift out
      text.gsub!('&#15;', ' ') # 	shift in
      text.gsub!('&#16;', ' ') # 	data link escape
      text.gsub!('&#17;', ' ') # 	device control 1
      text.gsub!('&#18;', ' ') # 	device control 2
      text.gsub!('&#19;', ' ') # 	device control 3
      text.gsub!('&#20;', ' ') # 	device control 4
      text.gsub!('&#21;', ' ') # 	negative acknowledge
      text.gsub!('&#22;', ' ') # 	synchronize
      text.gsub!('&#23;', ' ') # 	end transmission block
      text.gsub!('&#24;', ' ') # 	cancel
      text.gsub!('&#25;', ' ') # 	end of medium
      text.gsub!('&#26;', ' ') # 	substitute
      text.gsub!('&#27;', ' ') # 	escape
      text.gsub!('&#28;', ' ') # 	file separator
      text.gsub!('&#29;', ' ') # 	group separator
      text.gsub!('&#30;', ' ') # 	record separator
      text.gsub!('&#31;', ' ') # 	unit separator
      text.gsub!('&#127;', ' ') # 	delete (rubout)
      text
    end

    private
      def sort_options sort
        case sort
          when 'newest_first'
            { :order => 'resource_date desc' }
          when 'oldest_first'
            { :order => 'resource_date asc'}
          else
            {}
          end
      end
  end

  def resource_date
    date ? date.to_date : nil
  end

  def short_title
    text = title.sub('UK Parliament - ','').sub('www.parliament.uk | ','').sub('www.parliament.uk |','')
    convert_entities(text)
  end

  def unique_description
    text = (description && short_title != description) ? description : ''
    convert_entities(text)
  end

  def unique_description?
    unique_description && !unique_description.empty?
  end

  def text
    return nil unless body
    text = String.new(body)

    text.gsub!(/<(script|style|noscript)/i, 'XXX\1')
    text.gsub!(/<\/(script|style|noscript)/i, 'XXX/\1')
    text.gsub!('<','^^^')
    text.gsub!(/XXX(script|style|noscript)/i, '<\1')
    text.gsub!(/XXX\/(script|style|noscript)/i, '</\1')

    text.gsub!(/<noscript[^>]?>([^<]+)<\/noscript>/i,'')
    text.gsub!(/<script[^>]+>([^<]+)<\/script>/i,'')
    text.gsub!(/<style[^>]+>([^<]+)<\/style>/i,'')
    text.gsub!('^^^','<')

    text.sub!(/<\?xml [^>]+>/, '')
    text.sub!(/<!DOCTYPE [^>]+>/, '')
    convert_entities(text)
  end

  private

    def convert_entities text
      text = RailsSanitize.sanitize(text)
      begin
        text = Iconv.iconv('ascii//translit', 'utf-8', text).to_s
      rescue Exception => e
        puts "#{e.class.name} #{e.to_s}: cannot convert encoding"
      end
      text = ParlyResource.strip_control_chars(text)
      text = HTMLEntities.new.encode(text, :decimal)
      text = ParlyResource.strip_control_chars(text)
      HTMLEntities.new.decode(text)
    end
end
