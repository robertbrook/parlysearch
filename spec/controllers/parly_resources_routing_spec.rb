require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParlyResourcesController do
  describe "route generation" do

    it "should map { :controller => 'parly_resources', :action => 'index' } to /parly_resources" do
      route_for(:controller => "parly_resources", :action => "index").should == "/parly_resources"
    end
  
    it "should map { :controller => 'parly_resources', :action => 'new' } to /parly_resources/new" do
      route_for(:controller => "parly_resources", :action => "new").should == "/parly_resources/new"
    end
  
    it "should map { :controller => 'parly_resources', :action => 'show', :id => '1'} to /parly_resources/1" do
      route_for(:controller => "parly_resources", :action => "show", :id => "1").should == "/parly_resources/1"
    end
  
    it "should map { :controller => 'parly_resources', :action => 'edit', :id => '1' } to /parly_resources/1/edit" do
      route_for(:controller => "parly_resources", :action => "edit", :id => "1").should == "/parly_resources/1/edit"
    end
  
    it "should map { :controller => 'parly_resources', :action => 'update', :id => '1' } to /parly_resources/1" do
      route_for(:controller => "parly_resources", :action => "update", :id => "1").should == {:path => "/parly_resources/1", :method => :put}
    end
  
    it "should map { :controller => 'parly_resources', :action => 'destroy', :id => '1' } to /parly_resources/1" do
      route_for(:controller => "parly_resources", :action => "destroy", :id => "1").should == {:path => "/parly_resources/1", :method => :delete}
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'parly_resources', action => 'index' } from GET /parly_resources" do
      params_from(:get, "/parly_resources").should == {:controller => "parly_resources", :action => "index"}
    end
  
    it "should generate params { :controller => 'parly_resources', action => 'new' } from GET /parly_resources/new" do
      params_from(:get, "/parly_resources/new").should == {:controller => "parly_resources", :action => "new"}
    end
  
    it "should generate params { :controller => 'parly_resources', action => 'create' } from POST /parly_resources" do
      params_from(:post, "/parly_resources").should == {:controller => "parly_resources", :action => "create"}
    end
  
    it "should generate params { :controller => 'parly_resources', action => 'show', id => '1' } from GET /parly_resources/1" do
      params_from(:get, "/parly_resources/1").should == {:controller => "parly_resources", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'parly_resources', action => 'edit', id => '1' } from GET /parly_resources/1;edit" do
      params_from(:get, "/parly_resources/1/edit").should == {:controller => "parly_resources", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'parly_resources', action => 'update', id => '1' } from PUT /parly_resources/1" do
      params_from(:put, "/parly_resources/1").should == {:controller => "parly_resources", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'parly_resources', action => 'destroy', id => '1' } from DELETE /parly_resources/1" do
      params_from(:delete, "/parly_resources/1").should == {:controller => "parly_resources", :action => "destroy", :id => "1"}
    end
  end
end
