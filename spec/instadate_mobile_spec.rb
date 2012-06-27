require 'spec_helper'

describe InstadateMobile do
  include Rack::Test::Methods
  
  def app
    InstadateMobile
  end

  describe "GET /" do
    it "renders the mobile index.html file if the user agent is mobile" do
      header "User-Agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
      get '/'
      # TODO: Kind of a hacky way to distinguish mobile and desktop index.html files - find a better way.
      last_response.body.should_not include("Instadate - Date ideas, instantly!")
    end

    it "renders the desktop index.html file if the user agent is not mobile" do
      header "User-Agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5"
      get '/'
      # TODO: Kind of a hacky way to distinguish mobile and desktop index.html files - find a better way.
      last_response.body.should include("Instadate - Date ideas, instantly!")
    end
  end

  describe "POST /story/create" do
    let(:params) {
      { :zip_search => 94704, :lat_search => 37.87, :lng_search => -122.27, :story_date => "2012-6-21",
        :daypart => "evening", :activity => "indoor" }
    }

    it "creates a new Story in the database" do
      expect {
        post "/story/create", params
      }.to change(Story, :count).by(1)
      last_response.status.should == 200

      story = Story.last
      story.zip.should == 94704
      story.latitude.should == 37.87
      story.longitude.should == -122.27
      story.story_date.should == Date.new(2012, 6, 21)
      story.daypart.should == "evening"
      story.indoor.should == "indoor"
    end

    it "creates new Activities in the database for that story" do
      expect {
        post "/story/create", params
      }.to change(Activity, :count).by(3) # Returned by the mock response in the Story class.

      story = Story.last
      story.activities.should_not be_empty
    end

    it "returns JSON with the story and activities" do
      post "/story/create", params
      story = Story.last
      story_info = JSON.parse(last_response.body)
      story_info["id"].should == story.id
      story_info["activities"].size.should == 3
    end

    it "uses current date if story_date param is blank" do
      Timecop.freeze(Date.new(2012, 6, 26)) do
        params[:story_date] = ""
        post "/story/create", params
        story = Story.last
        story.story_date.should == Date.new(2012, 6, 26)
      end
    end

    it "returns JSON with an invalid location error if the zip_search param is blank" do
      params[:zip_search] = ""
      post "/story/create", params
      last_response.status.should == 404
      error_info = JSON.parse(last_response.body)
      error_info.should have_key("error")
      error_info["error"]["message"].should == "Invalid location. Please try again."
    end

    it "returns JSON with errors" do
      Story.any_instance.stub(:save).and_return(false)
      post "/story/create", params
      last_response.status.should == 404
      error_info = JSON.parse(last_response.body)
      error_info.should have_key("error")
      error_info["error"]["message"].should == "There was an error saving the record. Please try again."
    end
  end
end