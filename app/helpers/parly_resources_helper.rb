module ParlyResourcesHelper

  def excerpts text, term, part_match=true
    text = text.gsub(/<p id='[\d\.]*[a-z]*'>/, ' ').gsub('<p>',' ').gsub('</p>',' ').gsub('<i>','').gsub('</i>','')
    excerpts = nil

    if text.include? term
      text = tidy_excerpt(text, term, 120)
      excerpts = highlight(text, term)
    elsif text.include? term.titlecase
      text = tidy_excerpt(text, term.titlecase, 120)
      excerpts = highlight(text, term.titlecase)
    elsif text.include? term.upcase
      text = tidy_excerpt(text, term.upcase, 120)
      excerpts = highlight(text, term.titlecase)
    elsif part_match
      terms = term.split
      terms.delete_if { |word| IGNORE.include? word }
      count = 0
      terms.each { |term| count += 1 if text.include?(term) }

      char_count = (([1,12-(count*2)].max / 12.0) * 120).to_i #/
      texts = []

      terms.each do |term|
        if !add_term(text, texts, char_count, term)
          if !add_term(text, texts, char_count, term.downcase)
            add_term text, texts, char_count, term.titlecase
          end
        end
      end

      terms.each do |term|
        texts = texts.collect do |text|
          if text.include?(' '+term) || text.include?(' '+term.titlecase) || text.include?(' '+term.downcase)
            highlight(text, ' '+term)
          else
            text
          end
        end
      end
      excerpts = texts.join("<br></br>")
    else
      excerpts = ''
    end

    excerpts
  end

  def excerpt_words text, phrase, words=20, omission="..."
    if text && phrase
      phrase = Regexp.escape(phrase)
      start_phrase = ""
      end_phrase = ""

      if found_pos = text.mb_chars =~ /(#{phrase})/i
        before = text[0..found_pos-1].split(' ')
        after = text[found_pos + phrase.mb_chars.length..text.mb_chars.length].split(' ')

        i=0
        before.reverse!
        while i < words
          start_phrase << before[i] << " " unless before[i].nil?
          end_phrase << after[i] << " " unless after[i].nil?
          i+=1
        end
        
        start_phrase << phrase << " " << end_phrase.strip << omission
      else
        ""
      end
    end
  end

  def tidy_excerpt text, term, chars
    excerpt_words(text, term) << "<br/>"
  end

  def add_term text, texts, char_count, term
    present = text.include?(' '+term)
    texts << tidy_excerpt(text, ' '+term, char_count) if present
    present
  end

  IGNORE = ['and', 'the', 'is', 'of']

  def highlights text, term
    if term
      terms = term.split
      terms.delete_if { |word| IGNORE.include? word }
      terms.each do |term|
        if text.include?(' '+term) || text.include?(' '+term.titlecase) || text.include?(' '+term.downcase)
          text = highlight(text, ' '+term)
        end
      end
    end
    text
  end

end
