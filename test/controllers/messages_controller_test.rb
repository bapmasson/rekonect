require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get suggestion_reply" do
    get messages_suggestion_reply_url
    assert_response :success
  end

  test "should get rekonect" do
    get messages_rekonect_url
    assert_response :success
  end

  test "should get create" do
    get messages_create_url
    assert_response :success
  end

  test "should get dismiss" do
    get messages_dismiss_url
    assert_response :success
  end
end
