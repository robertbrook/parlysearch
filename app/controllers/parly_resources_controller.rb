class ParlyResourcesController < ResourceController::Base

  def index
  end

  def search
    if params[:commit]
      redirect_to :action => 'search', :q => params[:q]
    else
      @parly_resources = ParlyResource.find_by_solr(params[:q]).results
    end
  end
end
