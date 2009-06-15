require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/parly_resources/show.html.haml" do
  include ParlyResourcesHelper

  before(:each) do
    @parly_resource = mock_model(ParlyResource)
    @parly_resource.stub!(:title).and_return("MyString")
    @parly_resource.stub!(:description).and_return("MyText")
    @parly_resource.stub!(:body).and_return("MyText")
    @parly_resource.stub!(:date).and_return(Time.now)
    @parly_resource.stub!(:accept_ranges).and_return("MyString")
    @parly_resource.stub!(:cache_control).and_return("MyString")
    @parly_resource.stub!(:connection).and_return("MyString")
    @parly_resource.stub!(:content_length).and_return("MyString")
    @parly_resource.stub!(:content_type).and_return("MyString")
    @parly_resource.stub!(:date).and_return(Time.now)
    @parly_resource.stub!(:etag).and_return("MyString")
    @parly_resource.stub!(:expires).and_return("MyString")
    @parly_resource.stub!(:last_modified).and_return(Time.now)
    @parly_resource.stub!(:pragma).and_return("MyString")
    @parly_resource.stub!(:server).and_return("MyString")
    @parly_resource.stub!(:set_cookie).and_return("MyString")
    @parly_resource.stub!(:transfer_encoding).and_return("MyString")
    @parly_resource.stub!(:url).and_return("MyString")
    @parly_resource.stub!(:isbn).and_return("isbn")
    @parly_resource.stub!(:coverage).and_return(nil)
    @parly_resource.stub!(:author).and_return(nil)
    @parly_resource.stub!(:subject).and_return(nil)
    @parly_resource.stub!(:sitesectiontype).and_return(nil)
    @parly_resource.stub!(:pagesubject).and_return(nil)
    @parly_resource.stub!(:subsectiontype).and_return(nil)
    @parly_resource.stub!(:source).and_return(nil)
    @parly_resource.stub!(:report).and_return(nil)
    @parly_resource.stub!(:identifier).and_return(nil)
    @parly_resource.stub!(:keywords).and_return(nil)
    @parly_resource.stub!(:x_powered_by).and_return("MyString")

    assigns[:parly_resource] = @parly_resource

    template.stub!(:edit_object_url).and_return(edit_parly_resource_path(@parly_resource))
    template.stub!(:collection_url).and_return(parly_resources_path)
  end

  it "should render attributes in <p>" do
    render "/parly_resources/show.html.haml"
    response.should have_text(/MyString/)
    response.should have_text(/MyText/)
    response.should have_text(/MyText/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
  end
end

