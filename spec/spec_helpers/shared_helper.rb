def read_fixture(filename)
  return File.read(File.join(File.dirname(__FILE__), '..', '..', 'spec', 'fixtures', filename))
end

def load_settings()
  yelp_settings = {
    OAUTH_CONSUMER_KEY: ENV['YELP_CONSUMER_KEY'],
    OAUTH_CONSUMER_SECRET: ENV['YELP_CONSUMER_SECRET'],
    OAUTH_ACCESS_TOKEN: ENV['YELP_ACCESS_TOKEN'],
    OAUTH_ACCESS_SECRET: ENV['YELP_ACCESS_SECRET']
  }
  upcoming_settings = {
    API_KEY: ENV['UPCOMING_API_KEY']
  }
  {yelp: yelp_settings, upcoming: upcoming_settings}
end
