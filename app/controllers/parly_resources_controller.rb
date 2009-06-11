require 'will_paginate'

class ParlyResourcesController < ResourceController::Base

  def index
  end

  def search
    @search_query = params[:q]
    @sort = params[:sort]

    if @search_query.blank?
      redirect_to root_url
    elsif params[:commit]
      redirect_to :action => 'search', :q => @search_query
    else
      params[:page] ||= '1'
      @paginator = WillPaginate::Collection.create(params[:page], 10) do |pager|
        @parly_resources, total = ParlyResource.search(@search_query, pager.offset, pager.per_page, @sort)
        pager.replace(@parly_resources)
        pager.total_entries = total
      end
    end
  end
end
