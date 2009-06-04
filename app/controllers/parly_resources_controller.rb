class ParlyResourcesController < ResourceController::Base

  def search
    @parly_resources = ParlyResource.find_by_solr(params[:q]).results
    render :template => 'parly_resources/index'
  end
end
