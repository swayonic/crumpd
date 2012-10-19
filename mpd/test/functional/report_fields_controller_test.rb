require 'test_helper'

class ReportFieldsControllerTest < ActionController::TestCase
  setup do
    @report_field = report_fields(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_fields)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report_field" do
    assert_difference('ReportField.count') do
      post :create, report_field: {  }
    end

    assert_redirected_to report_field_path(assigns(:report_field))
  end

  test "should show report_field" do
    get :show, id: @report_field
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report_field
    assert_response :success
  end

  test "should update report_field" do
    put :update, id: @report_field, report_field: {  }
    assert_redirected_to report_field_path(assigns(:report_field))
  end

  test "should destroy report_field" do
    assert_difference('ReportField.count', -1) do
      delete :destroy, id: @report_field
    end

    assert_redirected_to report_fields_path
  end
end
