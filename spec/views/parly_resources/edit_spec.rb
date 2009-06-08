require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/parly_resources/edit.html.haml" do
  include ParlyResourcesHelper

  before do
    @parly_resource = mock_model(ParlyResource)
    @parly_resource.stub!(:title).and_return("MyString")
    @parly_resource.stub!(:description).and_return("MyText")
    @parly_resource.stub!(:body).and_return("MyText")
    @parly_resource.stub!(:accept_ranges).and_return("MyString")
    @parly_resource.stub!(:cache_control).and_return("MyString")
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
    @parly_resource.stub!(:x_powered_by).and_return("MyString")
    assigns[:parly_resource] = @parly_resource

    template.should_receive(:object_url).twice.and_return(parly_resource_path(@parly_resource))
    template.should_receive(:collection_url).and_return(parly_resources_path)
  end

  it "should render edit form" do
    render "/parly_resources/edit.html.haml"

    response.should have_tag("form[action=#{parly_resource_path(@parly_resource)}][method=post]") do
      with_tag('input#parly_resource_title[name=?]', "parly_resource[title]")
      with_tag('textarea#parly_resource_description[name=?]', "parly_resource[description]")
      with_tag('textarea#parly_resource_body[name=?]', "parly_resource[body]")
      with_tag('input#parly_resource_accept_ranges[name=?]', "parly_resource[accept_ranges]")
      with_tag('input#parly_resource_cache_control[name=?]', "parly_resource[cache_control]")
      with_tag('input#parly_resource_content_length[name=?]', "parly_resource[content_length]")
      with_tag('input#parly_resource_content_type[name=?]', "parly_resource[content_type]")
      with_tag('input#parly_resource_etag[name=?]', "parly_resource[etag]")
      with_tag('input#parly_resource_expires[name=?]', "parly_resource[expires]")
      with_tag('input#parly_resource_pragma[name=?]', "parly_resource[pragma]")
      with_tag('input#parly_resource_server[name=?]', "parly_resource[server]")
      with_tag('input#parly_resource_set_cookie[name=?]', "parly_resource[set_cookie]")
      with_tag('input#parly_resource_transfer_encoding[name=?]', "parly_resource[transfer_encoding]")
      with_tag('input#parly_resource_url[name=?]', "parly_resource[url]")
      with_tag('input#parly_resource_x_powered_by[name=?]', "parly_resource[x_powered_by]")
    end
  end
end


