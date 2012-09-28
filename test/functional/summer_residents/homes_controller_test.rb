require 'test_helper'

module SummerResidents
  class HomesControllerTest < ActionController::TestCase
    setup do
      @home = homes(:white_shul)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create home" do
      assert_difference('Home.count') do
        post :create, :home => { :address => @home.address, :apartment => @home.apartment, :city => @home.city, :country => @home.country, :phone => @home.phone, :state => @home.state, :zip => @home.zip }
      end
  
      assert_redirected_to home_path(assigns(:home))
    end
  
    test "should get edit" do
      get :edit, :id => @home
      assert_response :success
    end
  
    test "should update home" do
      put :update, :id => @home, :home => { :address => @home.address, :apartment => @home.apartment, :city => @home.city, :country => @home.country, :phone => @home.phone, :state => @home.state, :zip => @home.zip }
      assert_redirected_to home_path(assigns(:home))
    end
  
    test "should destroy home" do
      assert_difference('Home.count', -1) do
        delete :destroy, :id => @home
      end
  
      assert_response :success
    end
  end
end
