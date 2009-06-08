class ParlyResourcesController < ResourceController::Base

  def index
  end

  def search
    if params[:commit]
      redirect_to :action => 'search', :q => params[:q]
    else
      @parly_resources = ParlyResource.search(params[:q])
    end
  end
end
