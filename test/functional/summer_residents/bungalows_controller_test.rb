require 'test_helper'

module SummerResidents
  class BungalowsControllerTest < ActionController::TestCase
    setup do
      @bungalow = bungalows(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:bungalows)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create bungalow" do
      assert_difference('Bungalow.count') do
        post :create, :bungalow => { :name => @bungalow.name, :phone => @bungalow.phone, :unit => @bungalow.unit }
      end
  
      assert_redirected_to bungalow_path(assigns(:bungalow))
    end
  
    test "should show bungalow" do
      get :show, :id => @bungalow
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, :id => @bungalow
      assert_response :success
    end
  
    test "should update bungalow" do
      put :update, :id => @bungalow, :bungalow => { :name => @bungalow.name, :phone => @bungalow.phone, :unit => @bungalow.unit }
      assert_redirected_to bungalow_path(assigns(:bungalow))
    end
  
    test "should destroy bungalow" do
      assert_difference('Bungalow.count', -1) do
        delete :destroy, :id => @bungalow
      end
  
      assert_redirected_to bungalows_path
    end
  end
end
