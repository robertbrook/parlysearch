class SortOrder
  OPTIONS = {
"newest_first" => "Newest",
"oldest_first" => "Oldest"
}

  class << self
    def get_display_order(sort_code)
      if sort_code.blank?
        ""
      else
        begin
          OPTIONS[sort_code]
        rescue
          ""
        end
      end
    end
  end

end