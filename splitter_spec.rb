require_relative 'splitter'

describe Splitter do
  before :each do
    @hr = Splitter.new 
  end

  describe "#split" do
    it "should split on plaintext and preserve tags" do
      testHtml = "<p>We want <span style=\"font-weight: bold\">this: and then</span> this on the other side</p>"
      preferred_output = ["<p>We want <span style=\"font-weight: bold\">this</span></p>", "<p><span style=\"font-weight: bold\">and then</span> this on the other side</p>"]
      @hr.split(':', testHtml).should == preferred_output
    end

    it "should not fail if given only plaintext" do
      testHtml = "Hypertension: etiologies (2)"
      preferred_output = ["Hypertension", "etiologies (2)"]
      @hr.split(':', testHtml).should == preferred_output
    end

    it "should return given html and empty string if target not found" do
      testHtml = "<p>You won't find a colon in here.</p>"
      preferred_output = [testHtml, '']
      @hr.split(':', testHtml).should == preferred_output
    end

    it "should handle being an unwrapped html fragment" do
      html = "<img src=\"something.jpg\">: is it something?"
      out = ["<img src=\"something.jpg\">", 'is it something?']
      @hr.split(':', html).should == out
    end
  end
end
