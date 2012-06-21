class InstadateMobile < Sinatra::Base

  InstadateMobile::root = File.dirname(__FILE__)
  
  configure :development do
    register Sinatra::Reloader
  end

  configure :production, :development do
    #LOGGER = Logger.new("sinatra.log")
    #InstadateMobile::LOGGER = LOGGER
    #enable :logging, :dump_errors
    #set :raise_errors, true
  end

  error do
    e = request.env['sinatra.error']
    puts e.to_s
    puts e.backtrace.join("\n")
    "Application Error!"
  end

  configure :production do
    InstadateMobile::MOCK_API_REQUESTS = false
  end

  configure :development do
    InstadateMobile::MOCK_API_REQUESTS = false
  end

  #helpers do
  #  def InstadateMobile::logger
  #    LOGGER
  #  end
  #end

  # If you want the logs displayed you have to do this before the call to setup
  #DataMapper::Logger.new($stdout, :debug)


  # An in-memory Sqlite3 connection:
  #DataMapper.setup(:default, 'sqlite::memory:')

  # A Sqlite3 connection to a persistent database
  DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3:db/instadate.db")

  #Drop and create all the ORM tables
  DataMapper.auto_migrate!

  #Create or Update ORM tables if needed
  #DataMapper.auto_upgrade!

  #set :views, settings.root + '/'
  set :public_folder, File.dirname(__FILE__) + '/www'
  
  before do
    user_agent =  request.env['HTTP_USER_AGENT'].downcase
    @on_mobile = (user_agent =~ /(iphone|ipod|ipad|android|blackberry)/ ? true : false)
  end

  get "/" do
    if (@on_mobile)
      send_file File.join(settings.public_folder, 'index.html')
    else
      erb :index
    end
  end

  post "/story/create" do
    #logger.info "params: " + params.inspect
    puts ("request params: " + params.inspect)
    #startts - endts - zip - lat - lon
    if (!params[:story_date] || params[:story_date] == "")
      #logger.info "Couldn't find a date parameter, default to today"
      params[:story_date] = Date.today.strftime('%Y-%m-%d')
    end

    #logger.info "Creating Story!"
    if (params[:zip_search].nil? or params[:zip_search] == "")
      return "invalid location, please try again"
    end

    @story = Story.new(params)
    #logger.info "base story results: " + @story.inspect
    if @story.save
      #logger.info "Story Saved!" + @story.inspect
      puts "Story has " + @story.activities.count.to_s + " activities"
      return_story = @story.to_json(:methods => [:activities])
      #logger.info "Returning " + return_story.to_s
      return return_story
    else
      @story.errors.each do |e|
        #logger.info e
      end
    end
  end

end
