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
  end

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
    if @story.save
      InstadateMobile::Logger.info "Story saved! #{@story.inspect}"
      return @story.to_json(:methods => [:activities])
    else
      InstadateMobile::Logger.error "Story not saved: #{@story.inspect}"
      error = { "error" => { "message" => "There was an error saving the record. Please try again." } }
      return [404, error.to_json]
    end
  end

  get "/stories/:id" do
    @story = Story.get(params[:id])
    redirect to("/") if @story.nil?
    erb :permalink
  end
end
