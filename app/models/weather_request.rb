class WeatherRequest < ApplicationRecord
  belongs_to :location
  has_one    :weather_info

  STATUSES = [
    PROCESSING = 'Processing',
    ERROR      = 'Error',
    SUCCESS    = 'Success'
  ].freeze

  validates :status, inclusion: { in: STATUSES }

  def successful?
    status == SUCCESS
  end
  
  def error?
    status == ERROR
  end

end
