require 'test_helper'

class LocationControllerTest < ActionDispatch::IntegrationTest
  test "root should get index" do
    get root_url
    assert_response :success
    assert_select "h3", "Select location:"
  end
end
