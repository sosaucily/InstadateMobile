require 'spec_helper'

describe Story do
  let(:params) {
    { :zip_search => 94704, :lat_search => 37.87, :lng_search => -122.27, :story_date => "2012-6-21",
      :daypart => daypart, :activity => "indoor" }
  }
  
  describe "#initialize" do
    let(:daypart) { "evening" }
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
    
    it "should have three activites", :vcr do
      story = Story.new(params)
      story.save
      story.should be_valid
      story.activities.length.should == 3
    end
    
    
  end
  
  describe "#get_activity_requests" do
    let(:story) { Story.new(params) }
    subject { story.get_activity_requests }
    context "for the day" do
      let(:daypart) { "day" }
      it "should get three activity requests" do
        subject.should =~ ['day_eat','day_see','day_do']
      end
    end
    
    context "for the evening" do
      let(:daypart) { "evening" }
      it "should get three activity requests" do
        subject.should =~ ['evening_eat','evening_see','night_do']
      end
    end
  end
end