require 'spec_helper'

describe Story do
  describe "initialize" do
    let(:params) {
      { :zip_search => 94704, :lat_search => 37.87, :lng_search => -122.27, :story_date => "2012-6-21",
        :daypart => "evening", :activity => "indoor" }
    }

    it "sets up the object's attribute from the hash" do
      story = Story.new(params)
      story.zip.should == 94704
      story.latitude.should == 37.87
      story.longitude.should == -122.27
      story.story_date.should == Date.new(2012, 6, 21)
      story.daypart.should == "evening"
      story.indoor.should == "indoor"
    end

    it "should set the latitude and longitude to nil if params have empty strings" do
      params[:lat_search] = ""
      params[:lng_search] = ""

      story = Story.new(params)
      story.latitude.should be_nil
      story.longitude.should be_nil
    end
  end
end