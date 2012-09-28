require 'test_helper'

module SummerResidents
  class ResidentsControllerTest < ActionController::TestCase
    setup do
      @resident = residents(:dad)
    end
  
    test "should get edit" do
      get :edit, :id => @resident
      assert_response :success
    end
  
    test "should update resident" do
      put :update, :id => @resident, :resident => { :cell => @resident.cell, :first_name => @resident.first_name, :last_name => @resident.last_name, :user_id => @resident.user_id }
      assert_redirected_to resident_path(assigns(:resident))
    end
  
    test "should destroy resident" do
      assert_difference('Resident.count', -1) do
        delete :destroy, :id => @resident
      end
  
      assert_response :success
    end
  end
end
