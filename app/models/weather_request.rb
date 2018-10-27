class WeatherRequest < ApplicationRecord
  belongs_to :location

  STATUSES = [PROCESSING = 'Processing',
              ERROR      = 'Error',
              SUCCESS    = 'Success']

  validates :status, inclusion: { in: STATUSES }
  
end
