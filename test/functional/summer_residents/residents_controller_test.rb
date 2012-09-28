require 'test_helper'

module SummerResidents
  class ResidentsControllerTest < ActionController::TestCase
    setup do
      @resident = residents(:dad)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:residents)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create resident" do
      @resident.destroy
      assert_difference('Resident.count') do
        post :create, :resident => { :cell => @resident.cell, :first_name => @resident.first_name, :last_name => @resident.last_name, :user_id => @resident.user_id }
      end
  
      assert_redirected_to resident_path(assigns(:resident))
    end
  
    test "should show resident" do
      get :show, :id => @resident
      assert_response :success
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
  
      assert_redirected_to residents_path
    end
  end
end
