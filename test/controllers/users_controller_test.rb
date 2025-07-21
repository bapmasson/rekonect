require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get settings" do
    get users_settings_url
    assert_response :success
  end
end
