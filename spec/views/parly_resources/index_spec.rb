require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/parly_resources/index.html.haml" do
  include ParlyResourcesHelper
  
  before(:each) do
    parly_resource_98 = mock_model(ParlyResource)
    parly_resource_98.should_receive(:title).and_return("MyString")
    parly_resource_98.should_receive(:description).and_return("MyText")
    parly_resource_98.should_receive(:body).and_return("MyText")
    parly_resource_98.should_receive(:accept_ranges).and_return("MyString")
    parly_resource_98.should_receive(:cache_control).and_return("MyString")
    parly_resource_98.should_receive(:connection).and_return("MyString")
    parly_resource_98.should_receive(:content_length).and_return("MyString")
    parly_resource_98.should_receive(:content_type).and_return("MyString")
    parly_resource_98.should_receive(:date).and_return(Time.now)
    parly_resource_98.should_receive(:etag).and_return("MyString")
    parly_resource_98.should_receive(:expires).and_return("MyString")
    parly_resource_98.should_receive(:last_modified).and_return(Time.now)
    parly_resource_98.should_receive(:pragma).and_return("MyString")
    parly_resource_98.should_receive(:server).and_return("MyString")
    parly_resource_98.should_receive(:set_cookie).and_return("MyString")
    parly_resource_98.should_receive(:transfer_encoding).and_return("MyString")
    parly_resource_98.should_receive(:url).and_return("MyString")
    parly_resource_98.should_receive(:x_powered_by).and_return("MyString")
    parly_resource_99 = mock_model(ParlyResource)
    parly_resource_99.should_receive(:title).and_return("MyString")
    parly_resource_99.should_receive(:description).and_return("MyText")
    parly_resource_99.should_receive(:body).and_return("MyText")
    parly_resource_99.should_receive(:accept_ranges).and_return("MyString")
    parly_resource_99.should_receive(:cache_control).and_return("MyString")
    parly_resource_99.should_receive(:connection).and_return("MyString")
    parly_resource_99.should_receive(:content_length).and_return("MyString")
    parly_resource_99.should_receive(:content_type).and_return("MyString")
    parly_resource_99.should_receive(:date).and_return(Time.now)
    parly_resource_99.should_receive(:etag).and_return("MyString")
    parly_resource_99.should_receive(:expires).and_return("MyString")
    parly_resource_99.should_receive(:last_modified).and_return(Time.now)
    parly_resource_99.should_receive(:pragma).and_return("MyString")
    parly_resource_99.should_receive(:server).and_return("MyString")
    parly_resource_99.should_receive(:set_cookie).and_return("MyString")
    parly_resource_99.should_receive(:transfer_encoding).and_return("MyString")
    parly_resource_99.should_receive(:url).and_return("MyString")
    parly_resource_99.should_receive(:x_powered_by).and_return("MyString")

    assigns[:parly_resources] = [parly_resource_98, parly_resource_99]

    template.stub!(:object_url).and_return(parly_resource_path(parly_resource_99))
    template.stub!(:new_object_url).and_return(new_parly_resource_path) 
    template.stub!(:edit_object_url).and_return(edit_parly_resource_path(parly_resource_99))
  end

  it "should render list of parly_resources" do
    render "/parly_resources/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyText", 2)
    response.should have_tag("tr>td", "MyText", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
  end
end

