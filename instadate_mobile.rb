class InstadateMobile < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
  end

	# If you want the logs displayed you have to do this before the call to setup
  DataMapper::Logger.new($stdout, :debug)

  # An in-memory Sqlite3 connection:
  #DataMapper.setup(:default, 'sqlite::memory:')

  # A Sqlite3 connection to a persistent database
  DataMapper.setup(:default, 'sqlite3:db/instadate.db')

  #Drop and create all the ORM tables
  #DataMapper.auto_migrate!

  #Create or Update ORM tables if needed
  DataMapper.auto_upgrade!

  #set :views, settings.root + '/'
  set :public_folder, File.dirname(__FILE__) + '/www'

  get "/" do
    #@activity = Activity.new(
	#  :name      => "My first DataMapper post",
	#  :created_at => Time.now,
	#  :updated_at => Time.now
	#)

	#if @activity.save
	#else
	#	@activity.errors.each do |e|
	#		puts e
	#	end
	#end

	send_file File.join(settings.public_folder, 'index.html')
	
  end
end