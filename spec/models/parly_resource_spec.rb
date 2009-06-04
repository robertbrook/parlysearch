require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParlyResource do
  before(:each) do
    @parly_resource = ParlyResource.new
  end

  it "should be valid" do
    @parly_resource.should be_valid
  end
end
