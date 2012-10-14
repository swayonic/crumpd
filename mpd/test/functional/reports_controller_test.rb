require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @report = reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report" do
    assert_difference('Report.count') do
      post :create, report: { account_balance: @report.account_balance, assignment_id: @report.assignment_id, had_coach_convo: @report.had_coach_convo, letter_hours: @report.letter_hours, monthly_inhand: @report.monthly_inhand, mpd_hours: @report.mpd_hours, new_monthly_amt: @report.new_monthly_amt, new_monthly_count: @report.new_monthly_count, new_monthly_pledged: @report.new_monthly_pledged, new_onetime_amt: @report.new_onetime_amt, new_onetime_count: @report.new_onetime_count, new_referrals: @report.new_referrals, num_contacts: @report.num_contacts, num_phone_convos: @report.num_phone_convos, num_phone_dials: @report.num_phone_dials, num_precall_letters: @report.num_precall_letters, num_support_letters: @report.num_support_letters, onetime_inhand: @report.onetime_inhand, onetime_pledged: @report.onetime_pledged, phone_hours: @report.phone_hours, prayer_requests: @report.prayer_requests }
    end

    assert_redirected_to report_path(assigns(:report))
  end

  test "should show report" do
    get :show, id: @report
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report
    assert_response :success
  end

  test "should update report" do
    put :update, id: @report, report: { account_balance: @report.account_balance, assignment_id: @report.assignment_id, had_coach_convo: @report.had_coach_convo, letter_hours: @report.letter_hours, monthly_inhand: @report.monthly_inhand, mpd_hours: @report.mpd_hours, new_monthly_amt: @report.new_monthly_amt, new_monthly_count: @report.new_monthly_count, new_monthly_pledged: @report.new_monthly_pledged, new_onetime_amt: @report.new_onetime_amt, new_onetime_count: @report.new_onetime_count, new_referrals: @report.new_referrals, num_contacts: @report.num_contacts, num_phone_convos: @report.num_phone_convos, num_phone_dials: @report.num_phone_dials, num_precall_letters: @report.num_precall_letters, num_support_letters: @report.num_support_letters, onetime_inhand: @report.onetime_inhand, onetime_pledged: @report.onetime_pledged, phone_hours: @report.phone_hours, prayer_requests: @report.prayer_requests }
    assert_redirected_to report_path(assigns(:report))
  end

  test "should destroy report" do
    assert_difference('Report.count', -1) do
      delete :destroy, id: @report
    end

    assert_redirected_to reports_path
  end
end
