# encoding: utf-8
class Yelp
  OAUTH_CONSUMER_KEY = "xmQv-J8g98h40EjnUFkmIQ"
  OAUTH_CONSUMER_SECRET = "d0ZDmkuCGKWSSiS5-Fy99X7nn2c"
  OAUTH_ACCESS_TOKEN = "QzuSzvPavIuzkg2NqYfKSb3RMROfFDU9"
  OAUTH_ACCESS_SECRET = "h1QIIth-Qs2VCNGKlqpLjxKRqgU"
  ENDPOINT = "http://api.yelp.com/"
  RATING_THRESHOLD = 3.5
  REQUIRED_PARAMETERS = [:image_url,:address,:city]

  def query(params = {})
    #InstadateMobile::LOGGER.debug "Querying Yelp API: #{params.inspect}"
    check_parameters(params)
    yelp_params = build_params(params)
    
    consumer = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, { :site => ENDPOINT })
    access_token = OAuth::AccessToken.new(consumer, OAUTH_ACCESS_TOKEN, OAUTH_ACCESS_SECRET)
    #response = access_token.get("/v2/search?#{yelp_params.to_query}")
    yelp_params_as_query = URI.escape(yelp_params.collect{|k,v| "#{k}=#{v}"}.join('&'))
    response = access_token.get("/v2/search?#{yelp_params_as_query}")
    #InstadateMobile::LOGGER.debug "YELP Response: #{response.body}"

    return build_activities(response)
  end

  private

  def check_parameters(params)
    raise ArgumentError, "Please enter at least one category" if !params.has_key?(:category_filter)
    raise ArgumentError, "Categories should be an array" if !params[:category_filter].is_a?(Array)
    raise ArgumentError, "Please enter a location or latitude and longitude" if !params.has_key?(:location) && (!params.has_key?(:lat) || !params.has_key?(:long))
    return true
  end

  def build_params(params)
    yelp_params = {}
    yelp_params[:category_filter] = params[:category_filter].join(",")

    if params[:lat] && params[:long]
      yelp_params[:ll] = params[:lat].to_s + "," + params[:long].to_s
      params.delete(:lat)
      params.delete(:lng)
    elsif params[:location]
      yelp_params[:location] = params[:location]
    end

    return yelp_params
  end

  def build_activities(response)
    if response.code == "400"
      error = JSON.parse(response.body)["error"]
      error_string = "#{error["id"]} - #{error["text"]}"
      error_string += " - #{error["description"]}" if error.has_key?("description")
      raise "Invalid request to Yelp: #{error_string}"
    end

    activities = []
    businesses = JSON.parse(response.body)["businesses"]
    businesses.each do |business|
      next if business["rating"] < RATING_THRESHOLD
      activity_info = { :latitude => business["location"]["coordinate"]["latitude"], :longitude => business["location"]["coordinate"]["longitude"],
                        :rating => business["rating"], :source_category => business["categories"].map{ |cat| cat.first }, :name => business["name"],
                        :source_venue_id => business["id"], :image_url => business["image_url"], :business_url => business["mobile_url"], :phone => business["display_phone"], :address => business["location"]["address"][0], :city => business["location"]["city"] }
      activity_info[:address] = nil
      next if missing_required_param(activity_info)
      activities << activity_info
    end

    if (activities.empty?) then
      puts "Unable to return any yelp activities " + response.inspect
    end

    return activities
  end

  private

  def missing_required_param(test_activity)
    REQUIRED_PARAMETERS.each do |rqmt|
      if (test_activity[rqmt] == nil || test_activity[rqmt].empty?)
        return true
      end
    end
    return false
  end

end
