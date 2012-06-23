require 'spec_helper'

describe Upcoming do
  let(:upcoming) { Upcoming.new }

  def upcoming_categories
    [
      {"id"=>1, "name"=>"Music", "description"=>"Concerts, nightlife, raves"},
      {"id"=>2, "name"=>"Performing/Visual Arts", "description"=>"Theatre, dance, opera, exhibitions"},
      {"id"=>3, "name"=>"Media", "description"=>"Film, book readings"},
      {"id"=>4, "name"=>"Social", "description"=>"Rallies, gatherings, user groups"},
      {"id"=>5, "name"=>"Education", "description"=>"Lectures, workshops"},
      {"id"=>6, "name"=>"Commercial", "description"=>"Conventions, expos, flea markets"},
      {"id"=>7, "name"=>"Festivals", "description"=>"Big events, often multiple days"},
      {"id"=>8, "name"=>"Sports", "description"=>"Sporting events, recreation"},
      {"id"=>10, "name"=>"Other", "description"=>"Who knows?"},
      {"id"=>11, "name"=>"Comedy", "description"=>"Stand-up, improv, comic theatre"},
      {"id"=>12, "name"=>"Politics", "description"=>"Rallies, fundraisers, meetings"},
      {"id"=>13, "name"=>"Family", "description"=>"Family/kid-oriented music, shows, theatre"},
      {"id"=>14, "name"=>"Conferences", "description"=>"Conferences & Tradeshows"},
      {"id"=>15, "name"=>"Community", "description"=>"Neighborhood & Community"},
      {"id"=>16, "name"=>"Technology", "description"=>"Technology"}
    ]
  end

  before(:all) do
    @settings = load_settings("upcoming")
  end

  describe ".query" do
    context "parameter checks" do
      it "should raise an ArgumentError if the location param is not passed" do
        expect {
          upcoming.query(:date => Time.now)
        }.to raise_error(ArgumentError)
      end

      it "should raise an ArgumentError if the latitude param is set, but not the longitude" do
        expect {
          upcoming.query(:date => Time.now, :lat => 37.91)
        }.to raise_error(ArgumentError)
      end

      it "should raise an ArgumentError if the longitude param is set, but not the latitude" do
        expect {
          upcoming.query(:date => Time.now, :lng => -122.07)
        }.to raise_error(ArgumentError)
      end

      it "should raise an ArgumentError if the date param is set" do
        expect {
          upcoming.query(:lat => 37.91, :lng => -122.07)
        }.to raise_error(ArgumentError)
      end
    end

    context "response" do
      before(:each) do
        Upcoming.any_instance.stub(:get_categories).and_return(upcoming_categories)
      end

      it "should raise an error if Upcoming returns a 404 response" do
        stub_request(:get, /#{@settings["endpoint"]}/).to_return(:body => read_fixture("upcoming_error.json"), :status => 404)

        expect {
          upcoming.query(:lat => 37.91, :lng => -122.07, :date => Time.now)
          }.to raise_error
      end

      it "should parse the incoming response" do
        stub_request(:get, /#{@settings["endpoint"]}/).to_return(:body => read_fixture("upcoming_response.json"), :status => 200)

        query = upcoming.query(:lat => 37.91, :lng => -122.07, :date => Time.now)
        query.size.should == 2
      end
    end
  end
end
