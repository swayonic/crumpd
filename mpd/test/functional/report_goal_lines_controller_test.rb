require 'test_helper'

class ReportGoalLinesControllerTest < ActionController::TestCase
  setup do
    @report_goal_line = report_goal_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_goal_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report_goal_line" do
    assert_difference('ReportGoalLine.count') do
      post :create, report_goal_line: {  }
    end

    assert_redirected_to report_goal_line_path(assigns(:report_goal_line))
  end

  test "should show report_goal_line" do
    get :show, id: @report_goal_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report_goal_line
    assert_response :success
  end

  test "should update report_goal_line" do
    put :update, id: @report_goal_line, report_goal_line: {  }
    assert_redirected_to report_goal_line_path(assigns(:report_goal_line))
  end

  test "should destroy report_goal_line" do
    assert_difference('ReportGoalLine.count', -1) do
      delete :destroy, id: @report_goal_line
    end

    assert_redirected_to report_goal_lines_path
  end
end
