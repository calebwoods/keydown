require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Keydown::Slide do
  before :each do
    class Keydown
      def self.template_dir
        File.join(Keydown.source_root, 'templates', 'rocks')
      end
    end
  end

  shared_examples_for 'extracting slide data' do

    it "should set the classname to empty" do
      @slide.classnames.should == @classnames
    end

    it "should extract the content" do
      @slide.content.should match(/^# A Slide/)
    end

    it "should extract the notes" do
      @slide.notes.should match(/a simple note/)
    end
  end

  shared_examples_for "when generating HTML" do
    it "should assign the classname(s) to the section" do
      @doc.css(@slide_selector).should_not be_nil
    end

    it "should convert the content via Markdown" do
      @doc.css('section h1').text.should == 'A Slide'
    end

    it "should not include the notes in the HTML" do
      @doc.css('section p').each do |node|
        node.text.should_not match(/!NOTES/)
      end
    end
  end

  shared_examples_for "Pygmentizing code fragments" do
    it "should colorize the code fragments" do
      @doc.css('.highlight').length.should == 1
    end
  end

  describe 'without a CSS classname' do
    before :each do
      @slide_text       = <<-SLIDE

# A Slide
With some text

!NOTES
a simple note
      SLIDE

      @classnames       = 'slide'
      @slide            = Keydown::Slide.new(@slide_text)
    end

    it_should_behave_like "extracting slide data"

    describe "when generating HTML" do
      before :each do
        @html             = @slide.to_html
        @doc              = Nokogiri(@html)
        @slide_selector   = "div"
      end

      it_should_behave_like "when generating HTML"
    end
  end

  describe "with a single CSS classname" do
    before :each do
      @slide_text       = <<-SLIDE

# A Slide
With some text

!NOTES
a simple note
      SLIDE

      @classnames       = 'slide foo'
      @slide            = Keydown::Slide.new(@slide_text, 'foo')
    end

    it_should_behave_like "extracting slide data"

    describe "when generating HTML" do
      before :each do
        @html             = @slide.to_html
        @doc              = Nokogiri(@html)
        @slide_selector   = "div.#{@classnames}"
      end
      it_should_behave_like "when generating HTML"
    end
  end

  describe "with multiple CSS classnames" do
    before :each do
      @slide_text       = <<-SLIDE

# A Slide
With some text

!NOTES
a simple note
      SLIDE

      @classnames       = 'slide foo bar'
      @slide            = Keydown::Slide.new(@slide_text, 'foo bar')

    end

    it_should_behave_like "extracting slide data"

    describe "when generating HTML" do
      before :each do
        @html             = @slide.to_html
        @doc              = Nokogiri(@html)
        @slide_selector   = "div.#{@classnames}"
      end
      it_should_behave_like "when generating HTML"
    end
  end

  describe "with code to higlight" do

    describe "using the Slidedown syntax" do
      before :each do
        @slide_text       = <<-SLIDE

# A Slide
With some text

@@@ ruby
  def a_method(options)
    puts "I can has options " + options
  end
@@@
!NOTES
a simple note

        SLIDE

        @classnames       = 'slide'
        template_dir      = File.join(Keydown.source_root, 'templates', 'rocks')
        @slide            = Keydown::Slide.new(@slide_text)
      end

      it_should_behave_like "extracting slide data"

      describe "when generating HTML" do
        before :each do
          @html             = @slide.to_html
          @doc              = Nokogiri(@html)
          @slide_selector   = "div"
        end
        it_should_behave_like "when generating HTML"
        it_should_behave_like "Pygmentizing code fragments"
      end
    end

    describe "using the Github markup syntax" do
      before :each do
        @slide_text       = <<-SLIDE

# A Slide
With some text

``` ruby
  def a_method(options)
    puts "I can has options " + options
  end
```
!NOTES
a simple note

        SLIDE

        @classnames       = 'slide'
        @slide            = Keydown::Slide.new(@slide_text)
      end

      it_should_behave_like "extracting slide data"

      describe "when generating HTML" do
        before :each do
          @html             = @slide.to_html
          @doc              = Nokogiri(@html)
          @slide_selector   = "div"
        end

        it_should_behave_like "when generating HTML"
        it_should_behave_like "Pygmentizing code fragments"
      end
    end
  end

#  describe "with an image for a full-bleed background" do
#    before(:each) do
#      @slide_text       = <<-SLIDE
#
## A Slide
#With some text
#
#^^^ images/my_background.png
#
#!NOTES
#a simple note
#
#      SLIDE
#
#      @classnames       = 'slide full-background my_background'
#      @slide            = Keydown::Slide.new(@slide_text, 'full-background my_background')
#    end
#
#    it_should_behave_like "extracting slide data"
#
#    describe "when generating HTML" do
#      before :each do
#        @html             = @slide.to_html
#        @doc              = Nokogiri(@html)
#        @slide_selector   = "div"
#      end
#
#      it_should_behave_like "when generating HTML"
#
#      it "should remove any declaration of a background image" do
#        @doc.css(@slide_selector).text.should_not match(/\^\^\^\s+images\/my_background\.png/)
#      end
#    end
#  end
end
