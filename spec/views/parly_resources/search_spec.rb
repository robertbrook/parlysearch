require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/parly_resources/index.html.haml" do
  include ParlyResourcesHelper

  before(:each) do
    parly_resource_98 = mock_model(ParlyResource)
    parly_resource_98.should_receive(:short_title).and_return("Short")
    parly_resource_98.should_receive(:unique_description?).and_return(true)
    parly_resource_98.should_receive(:unique_description).times.and_return("Unique")
    parly_resource_98.should_receive(:text).and_return("text")
    parly_resource_98.should_receive(:url).exactly(3).times.and_return("MyString")
    parly_resource_98.should_receive(:file_format).and_return("HTML")
    parly_resource_98.should_receive(:date).any_number_of_times.and_return(Time.now)
    parly_resource_99 = mock_model(ParlyResource)
    parly_resource_99.should_receive(:short_title).and_return("Short")
    parly_resource_99.should_receive(:unique_description?).and_return(false)
    # parly_resource_99.should_receive(:unique_description).twice.and_return("")
    parly_resource_99.should_receive(:text).and_return("text")
    parly_resource_99.should_receive(:url).exactly(3).times.and_return("MyString")
    parly_resource_99.should_receive(:file_format).and_return("HTML")
    parly_resource_99.should_receive(:date).any_number_of_times.and_return(Time.now)
    parly_resource_100 = mock_model(ParlyResource)
    parly_resource_100.should_receive(:short_title).and_return("")
    parly_resource_100.should_receive(:unique_description?).and_return(false)
    # parly_resource_100.should_receive(:unique_description).and_return(nil)
    parly_resource_100.should_receive(:text).and_return("text")
    parly_resource_100.should_receive(:url).exactly(3).times.and_return("MyString")
    parly_resource_100.should_receive(:file_format).and_return("HTML")
    parly_resource_100.should_receive(:date).and_return(nil)

    assigns[:paginator] = mock('WillPaginate::Collection')
    assigns[:parly_resources] = [parly_resource_98, parly_resource_99, parly_resource_100]

    template.stub!(:object_url).and_return(parly_resource_path(parly_resource_99))
    template.stub!(:will_paginate).and_return 'pagination nav bar'
    template.stub!(:excerpts).and_return 'text with search term highlighted'
  end

  it "should render list of parly_resources" do
    render "/parly_resources/search.html.haml"
  end
end

