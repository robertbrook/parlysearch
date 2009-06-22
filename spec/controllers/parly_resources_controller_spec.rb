require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParlyResourcesController do
  describe "handling search" do

    before(:each) do
      @parly_resource = mock_model(ParlyResource)
      ParlyResource.stub!(:search).and_return([[@parly_resource], 1])
    end

    def do_get
      get :search, :q => 'term'
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('search')
    end

    it "should find all parly_resources" do
      ParlyResource.should_receive(:search).with('term', 0, 10, nil, nil).and_return([[@parly_resource], 1])
      do_get
    end

    it "should assign the found parly_resources for the view" do
      do_get
      assigns[:parly_resources].should == [@parly_resource]
    end
  end

  describe "handling GET /parly_resources/1" do

    before(:each) do
      @parly_resource = mock_model(ParlyResource)
      ParlyResource.stub!(:find).and_return(@parly_resource)
    end

    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render show template" do
      do_get
      response.should render_template('show')
    end

    it "should find the parly_resource requested" do
      ParlyResource.should_receive(:find).with("1").and_return(@parly_resource)
      do_get
    end

    it "should assign the found parly_resource for the view" do
      do_get
      assigns[:parly_resource].should equal(@parly_resource)
    end
  end

  describe "handling GET /parly_resources/new" do

    before(:each) do
      @parly_resource = mock_model(ParlyResource)
      ParlyResource.stub!(:new).and_return(@parly_resource)
    end

    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render new template" do
      do_get
      response.should render_template('new')
    end

    it "should create an new parly_resource" do
      ParlyResource.should_receive(:new).and_return(@parly_resource)
      do_get
    end

    it "should not save the new parly_resource" do
      @parly_resource.should_not_receive(:save)
      do_get
    end

    it "should assign the new parly_resource for the view" do
      do_get
      assigns[:parly_resource].should equal(@parly_resource)
    end
  end

  describe "handling GET /parly_resources/1/edit" do

    before(:each) do
      @parly_resource = mock_model(ParlyResource)
      ParlyResource.stub!(:find).and_return(@parly_resource)
    end

    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end

    it "should find the parly_resource requested" do
      ParlyResource.should_receive(:find).and_return(@parly_resource)
      do_get
    end

    it "should assign the found ParlyResources for the view" do
      do_get
      assigns[:parly_resource].should equal(@parly_resource)
    end
  end

  describe "handling POST /parly_resources" do

    before(:each) do
      @parly_resource = mock_model(ParlyResource, :to_param => "1")
      ParlyResource.stub!(:new).and_return(@parly_resource)
    end

    describe "with successful save" do

      def do_post
        @parly_resource.should_receive(:save).and_return(true)
        post :create, :parly_resource => {}
      end

      it "should create a new parly_resource" do
        ParlyResource.should_receive(:new).with({}).and_return(@parly_resource)
        do_post
      end

      it "should redirect to the new parly_resource" do
        do_post
        response.should redirect_to(parly_resource_url("1"))
      end

    end

    describe "with failed save" do

      def do_post
        @parly_resource.should_receive(:save).and_return(false)
        post :create, :parly_resource => {}
      end

      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end

    end
  end

  describe "handling PUT /parly_resources/1" do

    before(:each) do
      @parly_resource = mock_model(ParlyResource, :to_param => "1")
      ParlyResource.stub!(:find).and_return(@parly_resource)
    end

    describe "with successful update" do

      def do_put
        @parly_resource.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the parly_resource requested" do
        ParlyResource.should_receive(:find).with("1").and_return(@parly_resource)
        do_put
      end

      it "should update the found parly_resource" do
        do_put
        assigns(:parly_resource).should equal(@parly_resource)
      end

      it "should assign the found parly_resource for the view" do
        do_put
        assigns(:parly_resource).should equal(@parly_resource)
      end

      it "should redirect to the parly_resource" do
        do_put
        response.should redirect_to(parly_resource_url("1"))
      end

    end

    describe "with failed update" do

      def do_put
        @parly_resource.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /parly_resources/1" do

    before(:each) do
      @parly_resource = mock_model(ParlyResource, :destroy => true)
      ParlyResource.stub!(:find).and_return(@parly_resource)
    end

    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the parly_resource requested" do
      ParlyResource.should_receive(:find).with("1").and_return(@parly_resource)
      do_delete
    end

    it "should call destroy on the found parly_resource" do
      @parly_resource.should_receive(:destroy).and_return(true)
      do_delete
    end

    it "should redirect to the parly_resources list" do
      do_delete
      response.should redirect_to(parly_resources_url)
    end
  end
end
