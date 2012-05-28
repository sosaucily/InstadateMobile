# encoding: utf-8
class Story
	include DataMapper::Resource

	has n, :activities

	property :id,			Serial
	property :created_at,	DateTime,	:required => true
	property :updated_at,	DateTime,	:required => true
	property :start_time,	DateTime
	property :end_time,		DateTime
	property :include_meal,	Boolean,	:default  => false
	property :latitude, 	Float
	property :longitude, 	Float
	property :zip,		 	Integer
	property :city,			String
	property :story_date,	DateTime
	property :indoor,		String
	property :daypart,		String

  
  after :create, :generate_story

  private
  
    #Create the story based on the inputs from the user.
    def generate_story
      #Rules engine takes our requirements (which are attributes on this object) and decides who many activities, and of what type, to create
      
      if InstadateMobile::MOCK_API_REQUESTS
        #InstadateMobile::LOGGER.info "MOCK_API_REQUESTS is set to true - Returning mock data."
        mock_results
        return
      end


      #Create a list of activity requests
      activity_requests = get_activity_requests
      activity_results = []
      #InstadateMobile::LOGGER.info ("activity_requests = " + activity_requests.inspect)
      
      has_timed_event = false
      #InstadateMobile::LOGGER.info ("\n\n")
      if (zip.nil? or zip == "")
        location_parameters = { :lat => latitude, :long => longitude }
      else
        location_parameters = { :location => zip }
      end
      
      puts "Querying for activities in the following categories: " + activity_requests.inspect
      activity_requests.each do |act|
        case act
        when 'day_eat'
          the_system = ['Yelp'].shuffle.first
          query_parameters = VenueHelpers.get_day_eat_query_options.merge location_parameters
          #InstadateMobile::LOGGER.info 'schedule = day_eat, indoor = ' + indoor
          #InstadateMobile::LOGGER.info "Running API Command: " + options.shuffle[0].to_s + ".query(" + query_parameters.to_s + ")).shuffle[0]\n"
          activity_results << fetch_random_result(the_system, query_parameters, "eat")
        when 'evening_eat'
          the_system = ['Yelp'].shuffle.first
          query_parameters = VenueHelpers.get_evening_eat_query_options().merge location_parameters
          #InstadateMobile::LOGGER.info 'schedule = evening_eat, indoor = ' + indoor
          #InstadateMobile::LOGGER.info "Running API Command: " + options.shuffle[0].to_s + ".query(" + query_parameters.to_s + ")).shuffle[0]\n"
          activity_results << fetch_random_result(the_system, query_parameters, "eat")
        when 'day_do'
          the_system = ['Yelp'].shuffle.first
          query_parameters = VenueHelpers.get_day_do_query_options(indoor).merge location_parameters
          #InstadateMobile::LOGGER.info 'schedule = day_do, indoor = ' + indoor
          #InstadateMobile::LOGGER.info "Running API Command: " + options.shuffle[0].to_s + ".query(" + query_parameters.to_s + ")).shuffle[0]\n"
          activity_results << fetch_random_result(the_system, query_parameters, "do")
        when 'day_see'
          the_system = ['Yelp'].shuffle.first
          query_parameters = VenueHelpers.get_day_see_query_options(indoor).merge location_parameters
          #InstadateMobile::LOGGER.info 'schedule = day_see, indoor = ' + indoor
          #InstadateMobile::LOGGER.info "Running API Command: " + options.shuffle[0].to_s + ".query(" + query_parameters.to_s + ")).shuffle[0]\n"
          activity_results << fetch_random_result(the_system, query_parameters, "see")
        when 'evening_do'
          the_system = ['Yelp'].shuffle.first
          query_parameters = VenueHelpers.get_evening_do_query_options(indoor).merge location_parameters
          #InstadateMobile::LOGGER.info 'schedule = evening_do, indoor = ' + indoor
          #InstadateMobile::LOGGER.info "Running API Command: " + options.shuffle[0].to_s + ".query(" + query_parameters.to_s + ")).shuffle[0]\n"
          activity_results << fetch_random_result(the_system, query_parameters, "do")
        when 'evening_see'
          #options = ['Upcoming','Upcoming','Yelp'] #Upcoming will happen 2/3 times
          the_system = ['Yelp'].shuffle.first #Only Yelp for now
          query_parameters = VenueHelpers.get_evening_see_query_options(indoor).merge location_parameters
          if the_system == 'Upcoming'
            has_timed_event = true
            query_parameters[:date] = story_date
          end
          #InstadateMobile::LOGGER.info 'schedule = evening_see, indoor = ' + indoor
          #InstadateMobile::LOGGER.info "Running API Command: " + options.shuffle[0].to_s + ".query(" + query_parameters.to_s + ")).shuffle[0]\n"
          activity_results << fetch_random_result(the_system, query_parameters, "see")
        when 'night_do'
          the_system = ['Yelp'].shuffle.first
          #InstadateMobile::LOGGER.info ("Total List is : " + VenueHelpers::NIGHT_DO.inspect)
          query_parameters = VenueHelpers.get_night_do_query_options(indoor).merge location_parameters
          #InstadateMobile::LOGGER.info 'schedule = night_do, indoor = ' + indoor
          #InstadateMobile::LOGGER.info "Running API Command: " + options.shuffle[0].to_s + ".query(" + query_parameters.to_s + ")).shuffle[0]\n"
          activity_results << fetch_random_result(the_system, query_parameters, "do")
        end
      end      
      #InstadateMobile::LOGGER.info ("\n\n")

      activity_results.flatten!
      
      #InstadateMobile::LOGGER.info "Activity Results = " + activity_results.inspect
      
      #Coming Soon!
      #build_schedule(activity_results)
      #query upcoming
      
      #query other systems
      
      #From each 
      create_activities(activity_results)
      
    end
      
    #Create a set of activtiies for this date.
    def create_activities(activity_results)
      #InstadateMobile::LOGGER.info("Creating Activities")
      #Create an activity based on the quantity of activities
      activity_results.each do |act_data|
      	#InstadateMobile::LOGGER.info("Creating activity " + act_data.inspect)
        #Also need to make sure the result is part of this request type?
        act_data[:created_at] = Time.now
        act_data[:updated_at] = Time.now
        act_data[:story] = self
        @new_act = Activity.new(act_data)
        if @new_act.save
        	#InstadateMobile::LOGGER.info("Activity Saved!")
        	#self.activities << @new_act
        else
        	@new_act.errors.each do |e|
		 	      puts e
      		end
      	end
      end
      #self.save
	  #InstadateMobile::LOGGER.info("Updated story with activities")
    end
    
    def get_activity_requests
      case daypart
      when "day"
        activity_requests = [['day_do','day_eat','day_see'],['day_see','day_eat','day_do']].shuffle[0]
        #activity_requests = ['evening_see']
      when "evening"
        activity_requests = [['evening_see','evening_eat','night_do'],['evening_do','evening_eat','night_do']].shuffle[0]
        #activity_requests = ['evening_see']
      end
      activity_requests
    end

    def fetch_random_result(the_system, query_params, category)
      puts "Querying #{the_system} with params #{query_params.inspect}"
      service = Kernel.const_get(the_system).new
      results = service.query(query_params)
      #if (results.empty?)
      #  return nil
      #end
      puts "Results of query has length #{results.length}"
      query_result = results.shuffle[0]
      query_result[:category] = category
      puts "Returning result #{query_result}"
      return query_result
    end

    def mock_results
    	#InstadateMobile::LOGGER.info ("In Mock Results")
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
		#InstadateMobile::LOGGER.info ("Done")
    end

end