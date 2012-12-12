# encoding: utf-8

class StoryGenerationError < StandardError; end
class ActivityError < StandardError; end

class Story
  include DataMapper::Resource

  has n, :activities

  property :id,           Serial
  property :created_at,   DateTime, :required => true
  property :updated_at,   DateTime, :required => true
  property :start_time,   DateTime
  property :end_time,     DateTime
  property :include_meal, Boolean,  :default  => false
  property :latitude,     Float
  property :longitude,    Float
  property :zip,          Integer
  property :city,         String
  property :story_date,   DateTime
  property :indoor,       String
  property :daypart,      String
  property :distance,     Integer

  after :create, :generate_story

  TRIES = 5

  def initialize(params)
    InstadateMobile::Logger.info "Initializing story: #{params.inspect}"
    self.zip = params[:zip_search]
    self.latitude = (params[:lat_search] == "" ? nil : params[:lat_search].to_f)
    self.longitude = (params[:lng_search] == "" ? nil : params[:lng_search].to_f)
    self.story_date = Date.parse(params[:story_date])
    self.daypart = params[:daypart]
    self.indoor = params[:activity]
    self.created_at = Time.now
    self.updated_at = Time.now
    self.distance = params[:story_distance].to_i || 5
    InstadateMobile::Logger.debug("setting story distance to #{params[:story_distance].to_i || 5}" )
  end
  
  def generate_story
    
    if InstadateMobile::MOCK_API_REQUESTS
      InstadateMobile::Logger.info "MOCK_API_REQUESTS is set to true - Returning mock data."
      mock_results
      return
    end

    activity_requests = get_activity_requests
    activity_results = []
    
    # has_timed_event = false
    
    activity_requests.each do |act|
      the_system = get_system(act)
      if the_system == 'Upcoming'
        # has_timed_event = true
        query_parameters = { date: story_date }
      else
        options = { indoor: indoor }
        query_parameters = VenueHelpers.get_query_options_for_activity_type(act, options)
      end
      query_parameters.merge!(location_parameters)
      
      shuffled_results = fetch_shuffled_results(the_system, query_parameters)
      result_act = create_activity(shuffled_results)
      # InstadateMobile::Logger.info  "results for system #{the_system} are: #{result_act.inspect}"
      if !result_act && the_system != 'Yelp'
        InstadateMobile::Logger.info  "BOOO didn't work, trying again with yelp"
        the_system = 'Yelp'
        options = { indoor: indoor }
        query_parameters = VenueHelpers.get_query_options_for_activity_type(act, options)
        query_parameters.merge! location_parameters
        query_parameters.delete(:date)
        shuffled_results = fetch_shuffled_results(the_system, query_parameters)
        result_act = create_activity(shuffled_results)
      end

      result_act.category = act[act.rindex('_')+1..-1] #Either eat, see, or do
      result_act.save!
      activity_results << result_act
    end      
    
    # InstadateMobile::Logger.info "Activity Results: " + activity_results.inspect
  end
    
  #Create a set of activtiies for this date.
  def create_activity(activity_options)
    # InstadateMobile::Logger.info  "Creating activity with options = #{activity_options.inspect}"
    activity_options.each do |act|
      act.merge!( {created_at: Time.now, updated_at: Time.now, story: self} )
      new_act = Activity.new(act)
      if new_act.save
        InstadateMobile::Logger.info "Saving Activity: #{new_act.inspect}"
        return new_act
      else
        InstadateMobile::Logger.error "Activity Errors: #{new_act.errors.inspect}"
      end
    end
    false
  end
  
  def get_activity_requests
    case daypart
    when "day"
      activity_requests = [['day_do','day_eat','day_see'],['day_see','day_eat','day_do']].shuffle[0]
    when "evening"
      activity_requests = ['evening_see','evening_eat','night_do']
    end
    activity_requests
  end

  def fetch_shuffled_results(the_system, query_params)
    service = Kernel.const_get(the_system).new
    results = service.query(query_params)
    if (results.empty?)
      return []
    end
    results.shuffle
  rescue StoryGenerationError
    InstadateMobile::Logger.info "No results for you!"
    []
  end

  private
  
    def get_system(activity_type)
      case activity_type
      when 'day_eat'
        the_system = ['Yelp'].shuffle.first
      when 'evening_eat'
        the_system = ['Yelp'].shuffle.first
      when 'day_do'
        the_system = ['Yelp'].shuffle.first
      when 'evening_do'
        the_system = ['Yelp'].shuffle.first
      when 'day_see'
        the_system = ['Upcoming','Upcoming','Yelp'].shuffle.first #Upcoming will happen 2/3 times
      when 'evening_see'
        the_system = ['Upcoming','Upcoming','Yelp'].shuffle.first #Upcoming will happen 2/3 times
      when 'night_do'
        the_system = ['Yelp'].shuffle.first
      end
      return the_system
    end
  
    def location_parameters
      return @location_parameters if @location_parameters
      if (zip.nil? or zip == "")
        @location_parameters = { :lat => latitude, :long => longitude }
      else
        @location_parameters = { :location => zip }
      end
      @location_parameters.merge!({ :radius => distance })
      @location_parameters
    end
      
  
    def mock_results
      activity_results = []

      food_results = [{:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.9018083, :longitude=>-122.0632224, :rating=>4.5, :source_category=>["Beer, Wine & Spirits", "Wine Bars"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"Residual Sugar", :source_venue_id=>"XB5zw_qGoR2orqvFh98UHA"},
      {:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.9020544, :longitude=>-122.0628793, :rating=>4.5, :source_category=>["Beer, Wine & Spirits", "Pubs"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"ØL Beercafe & Bottle Shop", :source_venue_id=>"OrWtR9raFDI-Q2q1TwUZBA"},
      {:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.919111, :longitude=>-122.064571, :rating=>3.5, :source_category=>["Restaurants", "Lounges"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"Spoontonic Lounge", :source_venue_id=>"HRV3GRYmx_gFtT3YhuIFUQ"}]
      
      see_results = [{:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.9018083, :longitude=>-122.0632224, :rating=>4.5, :source_category=>["museums"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"Residual Sugar", :source_venue_id=>"XB5zw_qGoR2orqvFh98UHA"},
      {:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.9020544, :longitude=>-122.0628793, :rating=>4.5, :source_category=>["sportsteams"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"ØL Beercafe & Bottle Shop", :source_venue_id=>"OrWtR9raFDI-Q2q1TwUZBA"},
      {:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.919111, :longitude=>-122.064571, :rating=>3.5, :source_category=>["socialclubs"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"Spoontonic Lounge", :source_venue_id=>"HRV3GRYmx_gFtT3YhuIFUQ"}]
      
      do_results = [{:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.9303016662598, :longitude=>-122.040000915527, :rating=>3.5, :source_category=>["skatingrinks"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"Artie's Countrywood Lounge", :source_venue_id=>"aGogc3FvZ_vJk-E4chUCYA"},
      {:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.9006996154785, :longitude=>-122.060997009277, :rating=>3.5, :source_category=>["skydiving"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"The Stadium Pub", :source_venue_id=>"wE0edbI3-bG9UDXEtcU8Og"},
      {:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.9119991, :longitude=>-122.0457072, :rating=>4.0, :source_category=>["football"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"The Greenery Restaurant", :source_venue_id=>"Yf2jv15DdxtDzY1Wskg2iQ"}]
      
      night_results = [{:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.9107848, :longitude=>-122.0602269, :rating=>3.5, :source_category=>["musicvenues"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"Club 1220", :source_venue_id=>"5HM6-H5B_ICa9Hlv0IXS3A"},
      {:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.8972698, :longitude=>-122.0600967, :rating=>4.0, :source_category=>["opera"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"Va de Vi Bistro & Wine Bar", :source_venue_id=>"KuXUzgbt6w5sbMF33Y8LoQ"},
      {:phone => "+1-415-908-3801", :address => "706 Mission St", :city => "Walnut Creek", :latitude=>37.901798248291, :longitude=>-122.061996459961, :rating=>3.0, :source_category=>["theater"], :image_url=>'http://s3-media2.ak.yelpcdn.com/bphoto/ymEbmXmX-3QxebCa_KK-Tw/60s.jpg', :name=>"Dan's Irish Sports Bar", :source_venue_id=>"FbPqp_IGEVXh6t9nHIfWUA"}]

      food = food_results.shuffle[0]
      food[:category] = "eat"
      activity_results << food
      see = see_results.shuffle[0]
      see[:category] = "see"
      activity_results << see
      do_do = do_results.shuffle[0]
      do_do[:category] = "do"
      activity_results << do_do

      #InstadateMobile::LOGGER.info ("Creating Activities in mock results")

      create_activities(activity_results)
    end
end
