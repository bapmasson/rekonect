require "test_helper"

class BadgesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get badges_show_url
    assert_response :success
  end
end
