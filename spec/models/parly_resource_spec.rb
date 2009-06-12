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
      @parly_resource.body = "<html>
        <head>
          <title>Title</title>
          <style type=\"text/css\">
          .tree {display:block;font:bold 1.6em Arial, sans-serif;line-height:2em;}
          <!--[if IE 6]>
          #space {width:300px !important; overflow:hidden !important;}
          <![endif]-->
        </style>
  <script type=\"text/javascript\">
     displayClock();
  </script>
            <SCRIPT LANGUAGE=\"JavaScript1.1\" type=\"text/javascript\">
                        var gDomain=\"www.stats.tso.co.uk\";
            </SCRIPT>
            <NOSCRIPT>
              no script
            </NOSCRIPT>
  </head>
          <body>
            <p>Just
              <script type=\"text/javascript\">js</script>
              some test text with a <col>34</col> tag &amp; <b>another</b> tag</p>
              <!-- a comment -->
          </body>
          </html>"
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

    it 'should remove contents of script tags' do
      @parly_resource.text.should_not include('tree')
      @parly_resource.text.should_not include('displayClock')
      @parly_resource.text.should_not include('space')
      @parly_resource.text.should_not include('js')
      @parly_resource.text.should_not include('var')
      @parly_resource.text.should_not include('no script')
      @parly_resource.text.should include('Just')
    end

    it 'should keep head/title text' do
      @parly_resource.text.should include('Title')
    end

    it 'should remove comment text' do
      @parly_resource.text.should_not include('comment')
    end

  end
end
