require "test_helper"

class TimeSlotsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get time_slots_index_url
    assert_response :success
  end
end
