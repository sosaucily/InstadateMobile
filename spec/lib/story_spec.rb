require 'spec_helper'

describe Story do
  let(:daypart) { "evening" }
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
  
  describe "#fetch_random_result" do
    context "Upcoming" do
      let(:date_time) { DateTime.now }
      let(:the_system) { "Upcoming" }
      let(:result_name) {"[{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}]"}
      let(:query_params) { {
        date: date_time,
        location: 94103,
        radius: 1
      } }
      
      let(:upcoming_result) { [{:latitude=>37.7853, :longitude=>-122.423, :name=>result_name, :source_venue_id=>10389458, :business_url=>nil, :system=>"upcoming", :address=>"1187 Franklin Street", :city=>"San Francisco", :source_category=>["Sports"], :start_time=>date_time, :image_url=>"", :category_image_name=>"sports.jpg", :category=>"see"}, {:latitude=>37.7853, :longitude=>-122.423, :name=>"A GREAT EVENT", :source_venue_id=>90389458, :business_url=>nil, :system=>"upcoming", :address=>"1187 Franklin Street", :city=>"San Francisco", :source_category=>["Sports"], :start_time=>date_time, :image_url=>"", :category_image_name=>"sports.jpg", :category=>"see"}] }

      before do
        upcoming = double('upcoming')
        upcoming.stub(:query).with(query_params) { upcoming_result }
        Upcoming.stub(:new) { upcoming }
        upcoming_result.stub(:shuffle) { upcoming_result } #Just return them in the order above
      end

      it "queries and returns one activity for Upcoming" do
        story = Story.new(params)
        results = story.fetch_random_result(the_system, query_params)
        results.should include( {:source_venue_id=>10389458} )
      end
      
      context "When the name has over 200 characters" do
        let(:result_name) {"[{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}][{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}][{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}][{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}][{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}]"}
        
        it "queries and returns one activity for Upcoming" do
          story = Story.new(params)
          results = story.fetch_random_result(the_system, query_params)
          results.should include( {:source_venue_id=>90389458} )
        end
      end
    end
    
    context "Yelp" do
      let(:date_time) { DateTime.now }
      let(:the_system) { "Yelp" }
      let(:result_name) {"Needles & Pens"}
      let(:query_params) {
        {:category_filter=>"jazzandblues,magicians,psychic_astrology,comedyclubs,galleries", :location=>94103, :radius=>1}
      }
      
      let(:yelp_result) { [ {:latitude=>37.7646102, :longitude=>-122.4252166, :rating=>4.5, :source_category=>["Art Galleries"], :name=>result_name, :source_venue_id=>"needles-and-pens-san-francisco", :image_url=>"http://s3-media4.ak.yelpcdn.com/bphoto/3lJAK_qEEF8lBp3G1rQnOA/ms.jpg", :business_url=>"http://m.yelp.com/biz/needles-and-pens-san-francisco", :phone=>"+1-415-255-1534", :address=>"3253 16th St", :city=>"San Francisco", :system=>"yelp", :category=>"see"}, {:latitude=>37.7646102, :longitude=>-122.4252166, :rating=>4.5, :source_category=>["Art Galleries"], :name=>"Great Event", :source_venue_id=>"needles-and-pens-san-francisco", :image_url=>"http://s3-media4.ak.yelpcdn.com/bphoto/3lJAK_qEEF8lBp3G1rQnOA/ms.jpg", :business_url=>"http://m.yelp.com/biz/needles-and-pens-san-francisco", :phone=>"+1-415-255-1534", :address=>"3253 16th St", :city=>"San Francisco", :system=>"yelp", :category=>"see"} ] }

      before do
        yelp = double('yelp')
        yelp.stub(:query).with(query_params) { yelp_result }
        Yelp.stub(:new) { yelp }
        yelp_result.stub(:shuffle) {yelp_result } #Just return them in the order above
      end

      it "queries and returns one activity for Yelp" do
        story = Story.new(params)
        results = story.fetch_random_result(the_system, query_params)
        results.should include( {:name=>"Needles & Pens"} )
      end
      
      context "When the name has over 200 characters" do
        let(:result_name) {"[{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}][{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}][{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}][{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}][{( EnJoY )}]A[{( Jackson State vs Saint Mary's live sports NCAA Basketball )}]"}
        
        it "queries and returns one activity for Yelp" do
          story = Story.new(params)
          results = story.fetch_random_result(the_system, query_params)
          results.should include( {:name=>"Great Event"} )
        end
        
      end
      
    end
  end
end