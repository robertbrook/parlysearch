require 'htmlentities'

class ParlyResource < ActiveRecord::Base

  extend ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::SanitizeHelper

  validates_presence_of :title

  acts_as_solr :fields => [:short_title, :unique_description, :text, {:date => :facet}]

  class << self
    def search term, offset, limit, sort=nil
      if term.blank?
        []
      else
        options = sort_options(sort).merge(:offset => offset, :limit => limit)
        solr_results = find_by_solr(term, options)
        return [solr_results.results, solr_results.total]
      end
    end

    private
      def sort_options sort
        case sort
          when  'date'
           { :order => 'date asc' }
          when 'reverse_date'
           { :order => 'date desc'}
          else
            {}
          end
      end
  end

  def short_title
    text = title.sub('UK Parliament - ','').sub('www.parliament.uk | ','').sub('www.parliament.uk |','')
    convert_entities(text)
  end

  def unique_description
    text = (description && short_title != description) ? description : ''
    convert_entities(text)
  end

  def meta_fields
    doc = Hpricot body
    meta = (doc/'/html/head/meta')
    meta.inject([]) do |list, x|
      if x['name'] && !x['content'].to_s.blank?
        list << [ x['name'], x['content'].to_s ]
      end
      list
    end

    # reload! ; y ParlyResource.all.collect{|x| x.meta_fields.collect{|b| b[0]} }.flatten.uniq.sort
    # ['pagesubject','sitesectiontype','subsectiontype','keywords']
  end

  def text
    return nil unless body
    text = String.new(body)
    text.gsub!('<!','$$$!')
    text.gsub!(/<script[^>]+>([^<]+)<\/script>/,'')
    text.gsub!(/<style[^>]+>([^<]+)<\/style>/,'')
    text.gsub!('$$$!','<!')
    text = strip_tags(text)
    convert_entities(text)
  end

  def file_format
    if content_type.include?('text/html')
      return 'HTML'
    elsif content_type.include?('PDF')
      return 'PDF / Adobe Acrobat'
    else
      return content_type
    end
  end

  private

    def convert_entities text
      text = strip_control_chars(text)
      HTMLEntities.new.decode(text)
    end

    def strip_control_chars text
      text.gsub!('&#00;', ' ') #  null character
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
end
