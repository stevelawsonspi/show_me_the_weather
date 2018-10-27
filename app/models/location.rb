class Location < ApplicationRecord
  has_many :weather_request
  
  validates_presence_of :name
  validates_presence_of :yahoo_id
  
end
