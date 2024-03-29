class Activity
  include DataMapper::Resource

  belongs_to :story

  property :id,               Serial
  property :created_at,       DateTime,   :required => true
  property :updated_at,       DateTime,   :required => true
  property :latitude,         Float
  property :longitude,        Float
  property :category,         String
  property :duration,         Integer
  property :rating,           Float
  property :source_category,  Json
  property :name,             String,     :length => 200
  property :start_time,       DateTime
  property :end_time,         DateTime
  property :source_venue_id,  String,     :length => 200
  property :image_url,        String,     :length => 200
  property :category_image_name, String,  :length => 200
  property :business_url,     String,     :length => 200
  property :phone,            String
  property :address,          String
  property :city,             String
  property :system,           String
end
