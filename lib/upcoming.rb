# encoding: utf-8
class Upcoming
  def query(params = {})
    Rails.logger.debug "Querying Upcoming API: #{params.inspect}"
    check_parameters(params)
    upcoming_params = build_params(params)
    response = RestClient.get(settings["endpoint"], :params => params)
    return build_events(response)
  rescue RestClient::ResourceNotFound => e
    error = e.response
    raise JSON.parse(error)["rsp"]["error"]["msg"]
  end

  private

  def check_parameters(params)
    raise ArgumentError, "Please enter a location or latitude and longitude" if !params.has_key?(:location) && (!params.has_key?(:lat) || !params.has_key?(:long))
    raise ArgumentError, "Please enter a date" if !params.has_key?(:date)
    return true
  end

  def build_params(params)
    categories = get_categories

    if params.has_key?(:lat) && params.has_key?(:long)
      params[:location] = "#{params[:lat]},#{params[:long]}"
      params.delete(:lat)
      params.delete(:long)
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

    params.merge!({:api_key => settings["api_key"], :method => "event.search", :format => "json", :flags => "I"})
    return params
  end

  def get_categories
    @categories ||= begin
      response = RestClient.get(settings["endpoint"], :params => { :api_key => settings["api_key"], :method => "category.getList", :format => "json" })
      categories = JSON.parse(response)["rsp"]["category"]
      categories
    end
  end

  def build_events(response)
    activities = []
    categories = get_categories
    events = JSON.parse(response)["rsp"]["event"]

    events.each do |event|
      activity_info = { :latitude => event["latitude"], :longitude => event["longitude"], :name => event["name"],
                        :source_venue_id => event["id"], :business_url => event["url"] }
      activity_info[:source_category] = categories.detect{ |cat| cat["id"] == event["category_id"].to_i }["name"]

      if !event["start_date"].blank? && event["start_time"] != -1
        activity_info[:start_time] = Time.parse("#{event["start_date"]} #{event["start_time"]}")
      end

      if !event["end_date"].blank? && event["end_time"] != -1
        activity_info[:end_time] = Time.parse("#{event["end_date"]} #{event["end_time"]}")
      end

      if event["total_images"] != 0
        activity_info[:image_url] = event["image"].first["url"]
      end

      activities << activity_info
    end
    
    return activities
  end

  def settings
    @settings ||= begin
                    settings_file = File.join(File.dirname(__FILE__), '..', '..', 'settings.yml')
                    YAML::load(File.open(settings_file))["upcoming"]
                  end
  end
end
