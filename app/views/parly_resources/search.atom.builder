atom_feed('xmlns:openSearch' => 'http://a9.com/-/spec/opensearch/1.1/') do |feed|
  feed.title(@title, :type => 'html')
  feed.updated((Time.now))
  feed.openSearch(:totalResults, @paginator.total_entries)
  feed.openSearch(:startIndex, @paginator.offset+1)
  feed.openSearch(:itemsPerPage, @paginator.per_page)
  feed.openSearch(:Query, :role => 'request', :searchTerms => @search_query, :startPage => @paginator.current_page)
  
  atom_link(feed, 'first', first_results_url.gsub('amp;', ''))
  atom_link(feed, 'previous',  previous_results_url(@paginator).gsub('amp;', '')) if @paginator.current_page > 1
  atom_link(feed, 'next',  next_results_url(@paginator).gsub('amp;', '')) if @paginator.current_page < @paginator.total_pages
  atom_link(feed, 'last', last_results_url(@paginator).gsub('amp;', ''))
  
  feed.link(:rel => 'search', :href => "http://#{request.host_with_port}/search.xml", :type => 'application/opensearchdescription+xml')  
  
  for result in @parly_resources
    feed.entry(result, :url => result.url, :updated => Time.now, :published => result.date) do |entry|
      entry.title(result.short_title, :type => 'html')
      entry.content(excerpts(result.text, @search_query), :type => 'html')
      entry.author do |author|
        author.name("Millbank Systems")
      end
    end
  end
end