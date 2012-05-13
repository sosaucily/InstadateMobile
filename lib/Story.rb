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

end