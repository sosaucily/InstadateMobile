require 'spec_helper'

describe Yelp do
  let(:yelp) { Yelp.new }

  def settings
    @settings = load_settings()[:yelp]
  end

  describe ".query" do
    context "parameter checks" do
      it "should raise an ArgumentError if the category_filter param is not passed" do
        expect {
          yelp.query(:location => "Walnut Creek, CA")
        }.to raise_error(ArgumentError)
      end

      it "should raise an ArgumentError if the category_filter param is not an array" do
        expect {
          yelp.query(:category_filter => "restaurants", :location => "Walnut Creek, CA")
        }.to raise_error(ArgumentError)
      end

      it "should raise an ArgumentError if the location param is not passed" do
        expect {
          yelp.query(:category_filter => ["restaurants", "shopping"])
        }.to raise_error(ArgumentError)
      end

      it "should raise an ArgumentError if the latitude param is set, but not the longitude" do
        expect {
          yelp.query(:category_filter => ["restaurants", "shopping"], :lat => 37.91)
        }.to raise_error(ArgumentError)
      end

      it "should raise an ArgumentError if the longitude param is set, but not the latitude" do
        expect {
          yelp.query(:category_filter => ["restaurants", "shopping"], :long => -122.07)
        }.to raise_error(ArgumentError)
      end
    end
  end

  context "response" do
    it "should raise an error if Yelp returns a 400 response" do
      stub_request(:get, /#{settings["endpoint"]}/).to_return(:body => read_fixture("yelp_error.json"), :status => 400)

      expect {      
        yelp.query(:category_filter => ["restaurants"], :lat => 0.00, :long => 0.00)
      }.to raise_error
    end

    it "should parse the incoming response" do
      stub_request(:get, /#{settings["endpoint"]}/).to_return(:body => read_fixture("yelp_response.json"), :status => 200)

      query = yelp.query(:category_filter => ["restaurants"], :lat => 37.90, :long => -122.97)
      query.size.should == 2
    end

    it "should exclude businesses with a rating lower than the specified threshold" do
      stub_request(:get, /#{settings["endpoint"]}/).to_return(:body => read_fixture("yelp_response.json"), :status => 200)

      query = yelp.query(:category_filter => ["restaurants"], :lat => 37.90, :long => -122.97)
      business_names = query.map{ |business| business[:name] }
      business_names.should include("Olema Inn & Restaurant", "Vita Collage")
      business_names.should_not include("Station House Cafe")
    end
  end
end
