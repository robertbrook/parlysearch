require 'will_paginate'

class ParlyResourcesController < ResourceController::Base

  def index
  end

  def search
    @search_query = params[:q]
    @file_type = params[:t]
    @search_query = RailsSanitize.sanitize(@search_query).sub(';',' ') unless @search_query.blank?
    @sort = params[:sort]

    if @search_query.blank?
      redirect_to root_url
    elsif params[:commit]
      options = @file_type ? {:t => @file_type} : {}
      redirect_to options.merge(:action => 'search', :q => @search_query)
    else
      params[:page] ||= '1'
      @title = "Search results for: #{@search_query}"

      @paginator = WillPaginate::Collection.create(params[:page], 10) do |pager|
        @parly_resources, total = ParlyResource.search(@search_query, pager.offset, pager.per_page, @sort, @file_type)
        pager.replace(@parly_resources)
        pager.total_entries = total
        @total = total
        @current_start = ParlyResource.page_start(pager.per_page , params[:page])
        @current_end = ParlyResource.page_end(total, pager.per_page, params[:page])
      end
      
      # respond_to do |format|
      #               format.atom do
      #                 render :template => 'parly_resources/search.atom.builder', :layout => false and return false
      #               end
      #             end
    end
  end
end
