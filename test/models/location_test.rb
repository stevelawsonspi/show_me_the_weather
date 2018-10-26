require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  def setup
    @location = Location.new(name: "Example", yahoo_id: "1234567890")
  end

  test "should be valid" do
    assert @location.valid?
  end
  
  test "should be able to save" do
    assert_difference 'Location.count', 1 do
      @location.save
    end
  end
  
  test "should be able to destroy" do
    @location.save
    assert_difference 'Location.count', -1 do
      @location.destroy
    end
  end
end
