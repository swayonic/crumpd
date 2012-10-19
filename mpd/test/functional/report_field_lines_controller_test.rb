require 'test_helper'

class ReportFieldLinesControllerTest < ActionController::TestCase
  setup do
    @report_field_line = report_field_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_field_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report_field_line" do
    assert_difference('ReportFieldLine.count') do
      post :create, report_field_line: {  }
    end

    assert_redirected_to report_field_line_path(assigns(:report_field_line))
  end

  test "should show report_field_line" do
    get :show, id: @report_field_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report_field_line
    assert_response :success
  end

  test "should update report_field_line" do
    put :update, id: @report_field_line, report_field_line: {  }
    assert_redirected_to report_field_line_path(assigns(:report_field_line))
  end

  test "should destroy report_field_line" do
    assert_difference('ReportFieldLine.count', -1) do
      delete :destroy, id: @report_field_line
    end

    assert_redirected_to report_field_lines_path
  end
end
