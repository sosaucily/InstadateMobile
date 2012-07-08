# encoding: utf-8
class Upcoming
  API_KEY = ENV['UPCOMING_API_KEY']
  ENDPOINT = "http://upcoming.yahooapis.com/services/rest/"

  def query(params = {})
    InstadateMobile::Logger.info "Querying Upcoming API"
    check_parameters(params)
    upcoming_params = build_params(params)
    InstadateMobile::Logger.debug "Upcoming parameters: #{params.inspect}"
    response = RestClient.get(ENDPOINT, :params => params)
    InstadateMobile::Logger.debug "Upcoming query number of responses: #{JSON.parse(response)["rsp"]["event"].size.to_s}"
    JSON.parse(response)["rsp"]['event'].each {|event| 
      InstadateMobile::Logger.debug event.inspect
    }
    InstadateMobile::Logger.debug "Upcoming query response: #{response.inspect}" 
    return build_events(response)
  rescue RestClient::ResourceNotFound => e
    InstadateMobile::Logger.error "Upcoming API error: #{e.response}"
    error = e.response
    raise JSON.parse(error)["rsp"]["error"]["msg"]
  end

  private

  def check_parameters(params)
    raise ArgumentError, "Please enter a location or latitude and longitude" if !params.has_key?(:location) && (!params.has_key?(:lat) || !params.has_key?(:lng))
    raise ArgumentError, "Please enter a date" if !params.has_key?(:date)
    return true
  end

  def build_params(params)
    categories = get_categories

    if params.has_key?(:lat) && params.has_key?(:lng)
      params[:location] = "#{params[:lat]},#{params[:lng]}"
      params.delete(:lat)
      params.delete(:lng)
    end

    if params.has_key?(:category_filter)
      category_ids = []
      params[:category_filter].each do |category|
        category_ids << categories.detect { |cat| cat["name"] == category }["id"]
      end
      params[:category_id] = category_ids.join(",")
      params.delete(:category_filter)
    end

    params[:min_date] = Date.parse(params[:date].to_s).strftime("%Y-%m-%d")
    params[:max_date] = Date.parse(params[:date].to_s).strftime("%Y-%m-%d")
    params.delete(:date)
    
    #params[:variety] = 1 #This would be cool, but doesn't seem to work.. It always returns only 1 hit, and it's always the same hit!
    
    params[:per_page] = 100 #Upcoming doesn't randomize it's results, so we have to do it.

    params.merge!({:api_key => API_KEY, :method => "event.search", :format => "json", :flags => "I"})
    return params
  end

  def get_categories
    @categories ||= begin
      response = RestClient.get(ENDPOINT, :params => { :api_key => API_KEY, :method => "category.getList", :format => "json" })
      categories = JSON.parse(response)["rsp"]["category"]
      categories
    end
  end

  def build_events(response)
    activities = []
    categories = get_categories
    events = JSON.parse(response)["rsp"]["event"]

    events.each do |event|
      business_url_key = ["url","venue_url","ticket_url"].detect {|attr| !event[attr].nil? and event[attr] != ""}
      InstadateMobile::Logger.debug "Using url key: " + business_url_key if !business_url_key.nil?
      
      
      activity_info = { :latitude => event["latitude"], :longitude => event["longitude"], :name => event["name"],
                        :source_venue_id => event["id"], :business_url => event[business_url_key], :system => "upcoming", :address => event["venue_address"]}
                              
      activity_info[:source_category] = categories.select{ |cat| cat["id"] == event["category_id"].to_i }.map{ |cat| cat["name"] }

      if !event["start_date"].empty? && event["start_time"] != -1
        activity_info[:start_time] = Time.parse("#{event["start_date"]} #{event["start_time"]}")
      end

      if !event["end_date"].empty? && event["end_time"] != -1
        activity_info[:end_time] = Time.parse("#{event["end_date"]} #{event["end_time"]}")
      end

      if event["total_images"] != 0
        activity_info[:image_url] = event["image"].first["url"]
      else
        activity_info[:image_url] = ""
      end

      activities << activity_info
    end
    
    return activities
  end
end
