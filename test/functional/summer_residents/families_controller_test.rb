require 'test_helper'

module SummerResidents
  class FamiliesControllerTest < ActionController::TestCase
    setup do
      @family = families(:lieberman)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:families)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create family" do
      assert_difference('Family.count') do
        post :create, family: { bungalow_id: @family.bungalow_id, father_id: @family.father_id, home_id: @family.home_id, mother_id: @family.mother_id }
      end
  
      assert_redirected_to family_path(assigns(:family))
    end
  
    test "should show family" do
      get :show, id: @family
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @family
      assert_response :success
    end
  
    test "should update family" do
      put :update, id: @family, family: { bungalow_id: @family.bungalow_id, father_id: @family.father_id, home_id: @family.home_id, mother_id: @family.mother_id }
      assert_redirected_to family_path(assigns(:family))
    end
  
    test "should destroy family" do
      assert_difference('Family.count', -1) do
        delete :destroy, id: @family
      end
  
      assert_redirected_to families_path
    end
  end
end
