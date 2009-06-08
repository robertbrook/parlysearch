require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/parly_resources/index.html.haml" do
  include ParlyResourcesHelper

  before(:each) do
    parly_resource_98 = mock_model(ParlyResource)
    parly_resource_98.should_receive(:short_title).and_return("Short")
    parly_resource_98.should_receive(:unique_description).exactly(3).times.and_return("Unique")
    parly_resource_98.should_receive(:url).twice.and_return("MyString")
    parly_resource_99 = mock_model(ParlyResource)
    parly_resource_99.should_receive(:short_title).and_return("Short")
    parly_resource_99.should_receive(:unique_description).twice.and_return("")
    parly_resource_99.should_receive(:url).twice.and_return("MyString")
    parly_resource_100 = mock_model(ParlyResource)
    parly_resource_100.should_receive(:short_title).and_return("")
    parly_resource_100.should_receive(:unique_description).and_return(nil)
    parly_resource_100.should_receive(:url).twice.and_return("MyString")

    assigns[:parly_resources] = [parly_resource_98, parly_resource_99, parly_resource_100]

    template.stub!(:object_url).and_return(parly_resource_path(parly_resource_99))
  end

  it "should render list of parly_resources" do
    render "/parly_resources/search.html.haml"
  end
end

