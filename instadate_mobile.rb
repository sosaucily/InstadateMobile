class InstadateMobile < Sinatra::Base
  InstadateMobile::root = File.dirname(__FILE__)

  configure do
    InstadateMobile::Logger = Logger.new("log/#{ENV['RACK_ENV']}.log")
  end

  configure :development do
    register Sinatra::Reloader
    InstadateMobile::MOCK_API_REQUESTS = false
  end

  configure :test do
    InstadateMobile::MOCK_API_REQUESTS = true

  end

  configure :production do
    InstadateMobile::MOCK_API_REQUESTS = false
    require 'newrelic_rpm'
  end
  
  register Sinatra::Partial
  set :partial_template_engine, :erb
  
  InstadateMobile::Story_Pics = YAML.load_file('config/storypics.yml')

  # If you want the logs displayed you have to do this before the call to setup
  #DataMapper::Logger.new($stdout, :debug)

  # A Sqlite3 connection to a persistent database
  DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3:db/instadate.db")

  #Drop and create all the ORM tables
  DataMapper.auto_migrate!

  DataMapper.finalize

  set :public_folder, File.dirname(__FILE__) + '/www'
  
  before do
    user_agent = request.env['HTTP_USER_AGENT']
    @on_mobile = (user_agent.downcase =~ /(iphone|ipod|ipad|android|blackberry)/ ? true : false) unless user_agent.nil?
  end

  get "/" do
    if (@on_mobile)
      send_file File.join(settings.public_folder, 'index.html')
    else
      erb :index
    end
  end

  post "/story/create" do
    InstadateMobile::Logger.info "POST /story/create - params: #{params.inspect}"
    if (!params[:story_date] || params[:story_date] == "")
      params[:story_date] = Date.today.strftime('%Y-%m-%d')
    end

    if (params[:zip_search].nil? or params[:zip_search] == "")
      error = { "error" => { "message" => "Invalid location. Please try again." } }
      return [404, error.to_json]
    end

    @story = Story.new(params)
    InstadateMobile::Logger.info "Received Story: #{@story.inspect}"
    begin
      if @story.save
        InstadateMobile::Logger.info "Story saved! #{@story.inspect}"
        @results = @story.to_json(:methods => [:activities])
        return JSON.parse(@results).merge({story_id:@story.id}).to_json
      else
        InstadateMobile::Logger.error "Story not saved: #{@story.inspect}"
        error = { "error" => { "message" => "There was an error saving the record. Please try again." } }
        return [404, error.to_json]
      end
    rescue
      InstadateMobile::Logger.error "Story not saved: #{@story.inspect}"
      error = { "error" => { "message" => "There was an error building your Oyster. Please try again." } }
      return [404, error.to_json]
    end
  end

  get "/stories/:id" do
    InstadateMobile::Logger.debug "Getting story for story id #{params[:id]}"
    @story = Story.get(params[:id])
    @results = @story.to_json(:methods => [:activities])
    InstadateMobile::Logger.debug "got the following story #{@story}"
    #redirect to("/") if @story.nil?
    story_results = JSON.parse(@results).merge({story_id:@story.id}).to_json
    InstadateMobile::Logger.debug "Delivering story results #{story_results}"
    erb :permalink, :locals => { mypartial: 'story_partial', results: story_results}
  end
end
