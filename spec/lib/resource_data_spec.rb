require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResourceData do

  describe "" do
  end
  
  it "should return the title 'Sources_family_history' when given an URL of 'www.parliament.uk/documents/upload/Sources_family_history.pdf' and a blank title"
  
  it "should return the title 'rp01-077' when given an URL of 'www.parliament.uk/commons/lib/research/rp2001/rp01-077.pdf' and a blank title"
  
  it "should return the title 'HofCCommunicationsAllowanceBooklet' when given an URL of 'www.parliament.uk/documents/upload/HofCCommunicationsAllowanceBooklet.pdf' and a blank title"

  it "should return the title 'UNTITLED' when given a title of 'UNTITLED'"
  
  it "should not return the title 'UNTITLED' when given a blank title"
  
  it "should return a title of 256 characters and the character '…' when given a title of more than 256 characters"

end
