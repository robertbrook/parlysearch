require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParlyResource do
  before(:each) do
    @parly_resource = ParlyResource.new :title => 'Hansard debates'
  end

  it "should be valid" do
    @parly_resource.should be_valid
  end

  describe "when preparing text to send to solr" do

    before do
      @parly_resource.body = 'some test text with a <col>34</col> tag &amp; <b>another</b> tag'
    end

    it 'should remove any col tags and their contents' do
      @parly_resource.text.should_not include('<col>')
    end

    it 'should strip any html tags' do
      @parly_resource.text.should_not include('<b>')
    end

    it 'should decode any html entities' do
      @parly_resource.text.should include('&')
    end
  end
end
