require 'test_helper'

class LocationsIndexTest < ActionDispatch::IntegrationTest

  test "index (root)" do
    get root_url
    assert_template 'location/index'
    locations = Location.all
    locations.each do |location|
      assert_select 'li', text: location.name
    end
  end
end