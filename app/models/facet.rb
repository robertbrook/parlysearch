class Facet
  OPTIONS = {
"html" => "HTML",
"pdf" => "PDFs",
"word" => "Word"
}

  class << self
    def get_display_facet(facet_code)
      if facet_code.blank?
        ""
      else
        begin
          OPTIONS[facet_code]
        rescue
          ""
        end
      end
    end
  end

end