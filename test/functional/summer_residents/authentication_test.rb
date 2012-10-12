require 'test_helper'

module SummerResidents
  class AuthenticationTest < ActionController::TestCase
    setup do
      @target_user = users(:dad_user)
      @spouse_of_target_user = users(:mom_user)
      @spouse_of_target_user.admin = false
      @spouse_of_target_user.save!
      
      @plain_user = users(:hadassah_user)
      @controller.log_in_as @plain_user
    end

    def when_target_user
      @controller.log_in_as @target_user
    end

    def when_spouse_of_target_user
      @controller.log_in_as @spouse_of_target_user
    end

    def assert_redirected_to_login_path
      assert_redirected_to @controller.login_path
    end
  end

  class FamiliesAuthenticationTest < AuthenticationTest
    tests SummerResidents::FamiliesController

    setup do
      @id = @target_user.resident.family
    end

    def when_getting_index
      get :index
    end

    def when_getting_new
      get :new
    end

    def when_creating
      father_hash = { first_name: @target_user.first_name, last_name: @target_user.last_name, email: @target_user.email }
      mother_hash = { first_name: @spouse_of_target_user.first_name, last_name: @spouse_of_target_user.last_name, email: @spouse_of_target_user.email }
      post :create, father: father_hash, mother: mother_hash
    end

    def when_destroying
      delete :destroy, id: @id, format: :js
    end

    def when_showing
      get :show, id: @id
    end

    def expect_redirect_to_login_when_getting_index
      when_getting_index
      assert_redirected_to_login_path
    end

    def expect_redirect_to_login_when_getting_new
      when_getting_new
      assert_redirected_to_login_path
    end

    def expect_redirect_to_login_when_creating
      when_creating
      assert_redirected_to_login_path
    end

    def expect_redirect_to_login_when_destroying
      when_destroying
      assert_redirected_to_login_path
    end

    def expect_redirect_to_login_when_showing
      when_showing
      assert_redirected_to_login_path
    end
    
    def expect_no_redirect_to_login_when_showing
      when_showing
      assert_response :success
      assert_template :show
    end

    test "index should redirect to login when not admin" do
      expect_redirect_to_login_when_getting_index
    end

    test "index should redirect to login when not admin even when target user" do
      when_target_user
      expect_redirect_to_login_when_getting_index
    end

    test "index should redirect to login when not admin even when spouse of target user" do
      when_spouse_of_target_user
      expect_redirect_to_login_when_getting_index
    end

    test "new should redirect to login when not admin" do
      expect_redirect_to_login_when_getting_new
    end

    test "new should redirect to login when not admin even when target user" do
      when_target_user
      expect_redirect_to_login_when_getting_new
    end

    test "new should redirect to login when not admin even when spouse of target user" do
      when_spouse_of_target_user
      expect_redirect_to_login_when_getting_new
    end

    test "create should redirect to login when not admin" do
      expect_redirect_to_login_when_creating
    end

    test "create should redirect to login when not admin even when target user" do
      when_target_user
      expect_redirect_to_login_when_creating
    end

    test "create should redirect to login when not admin even when spouse of target user" do
      when_spouse_of_target_user
      expect_redirect_to_login_when_creating
    end

    test "destroy should redirect to login when not admin" do
      expect_redirect_to_login_when_destroying
    end

    test "destroy should redirect to login when not admin even when target user" do
      when_target_user
      expect_redirect_to_login_when_destroying
    end

    test "destroy should redirect to login when not admin even when spouse of target user" do
      when_spouse_of_target_user
      expect_redirect_to_login_when_destroying
    end

    test "show should redirect to login when not current user or spouse or admin" do
      expect_redirect_to_login_when_showing
    end

    test "show should not redirect to login when target user" do
      when_target_user
      expect_no_redirect_to_login_when_showing
    end

    test "show should not redirect to login when spouse of target user" do
      when_spouse_of_target_user
      expect_no_redirect_to_login_when_showing
    end
  end
  class ResidentsAuthenticationTest < AuthenticationTest
    tests SummerResidents::ResidentsController

    setup do
      @id = @target_user.resident
    end

    def expect_redirect_to_login_when_destroying
      delete :destroy, id: @id, format: :js
      assert_redirected_to_login_path
    end

    def when_editing
      get :edit, id: @id, format: :js
    end

    def when_updating
      r = @target_user.resident
      put :update, id: @id, cell: @id.cell, first_name: @id.first_name, last_name: @id.last_name, email: @id.email, type: :Father, format: :js
    end

    def expect_redirect_to_login_when_editing
      when_editing
      assert_redirected_to_login_path
    end

    def expect_redirect_to_login_when_updating
      when_updating
      assert_redirected_to_login_path
    end

    def expect_no_redirect_to_login_when_editing
      when_editing
      assert_response :success
      assert_template :edit
    end

    def expect_no_redirect_to_login_when_updating
      when_updating
      assert_response :success
      assert_template :show
    end

    test "destroy should redirect to login when not admin" do
      expect_redirect_to_login_when_destroying
    end

    test "destroy should redirect to login when not admin even when target user" do
      when_target_user
      expect_redirect_to_login_when_destroying
    end

    test "destroy should redirect to login when not admin even when spouse of target user" do
      when_spouse_of_target_user
      expect_redirect_to_login_when_destroying
    end

    test "edit should redirect to login when not current user or spouse or admin" do
      expect_redirect_to_login_when_editing
    end

    test "edit should not redirect to login when target user" do
      when_target_user
      expect_no_redirect_to_login_when_editing
    end

    test "edit should not redirect to login when spouse of target user" do
      when_spouse_of_target_user
      expect_no_redirect_to_login_when_editing
    end

    test "update should redirect to login when not current user or spouse or admin" do
      expect_redirect_to_login_when_updating
    end

    test "update should not redirect to login when target user" do
      when_target_user
      expect_no_redirect_to_login_when_updating
    end

    test "update should not redirect to login when spouse of target user" do
      when_spouse_of_target_user
      expect_no_redirect_to_login_when_updating
    end
  end
end
