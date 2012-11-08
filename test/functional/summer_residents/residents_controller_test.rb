require 'test_helper'

module SummerResidents
  class ResidentsControllerTest < ActionController::TestCase
    setup do
      @resident = residents(:dad)
      @new_resident = residents(:joe)
      @resident.user.destroy
    end
  
    def update_resident options
      put :update, options.merge({:id => @new_resident, format: :js })
    end

    def expect_resident_was_not_updated
      assert_response :success
      assert_template :errors
      resident = assigns(:instance)
      assert resident, "@resident should have been assigned"
      @errors = resident.errors
    end

    test "should get edit" do
      get :edit, :id => @new_resident, format: :js
      assert_response :success
      assert_template :edit
    end

    test "edit should render show template when cancelling" do
      get :edit, :id => @new_resident, format: :js, cancel: "1"
      assert_response :success
      assert_template :show
    end

    def single_parent
      @single_parent = users(:mom_user)
      @single_parent.admin = false
      @single_parent.save!
      @single_parent.family.id
    end

    def when_creating_resident options
      post :create, options.merge({format: :js })
    end

    def create_resident options
      assert_difference('Resident.count') do
        assert_difference('User.count') do
          assert_difference('ActionMailer::Base.deliveries.size') do
            when_creating_resident options
          end
        end
      end
    end

    test "should get new" do
      get :new, format: :js, type: :Mother, fam_id: single_parent
      assert_response :success
      assert_template :edit
    end

    test "should get new as single parent" do
      single_parent
      @controller.log_in_as @single_parent
      get :new, format: :js, type: :Mother, fam_id: single_parent
      assert_response :success
      assert_template :edit
    end

    test "new should render show template when cancelling" do
      get :new, format: :js, cancel: "2", type: :Mother, fam_id: single_parent
      assert_response :success
      assert_template :show
    end
  
    def create_spouse
      create_resident :cell => @resident.cell, :first_name => @resident.first_name, :last_name => @resident.last_name, :email => @resident.email, :type => :Father, fam_id: single_parent
      assert_response :success
      assert_template :show
      resident = assigns(:instance)
      [:first_name, :last_name, :cell, :email].each { |e|
        assert_equal @resident.__send__(e), resident.__send__(e)
      }
      assert_equal @single_parent, resident.family.mother.user
    end

    test "should create resident in correct family" do
      create_spouse
    end

    test "should create spouse as single parent" do
      single_parent
      @controller.log_in_as @single_parent
      create_spouse
    end

    test "create should fail and render errors if missing first_name" do
      when_creating_resident :cell => @resident.cell, :first_name => "", :last_name => @resident.last_name, :email => @resident.email, :type => :Father, fam_id: single_parent
      expect_resident_was_not_updated
      there_should_be_errors 1
      there_should_be_errors_on_column :"first_name", 1
      should_fail_validation_because :"first_name", "can't be blank"
    end

    test "should update resident" do
      update_resident :cell => @resident.cell, :first_name => @resident.first_name, :last_name => @resident.last_name, :email => @resident.email, :type => :Father
      assert_response :success
      assert_template :show
      resident = assigns(:instance)
      [:first_name, :last_name, :cell, :email].each { |e|
        assert_equal @resident.__send__(e), resident.__send__(e)
      }
      assert_equal @new_resident.id, resident.id
    end

    test "should not update resident missing first_name" do
      update_resident :cell => @resident.cell, :last_name => @resident.last_name, :email => @resident.email, :type => :Father
      expect_resident_was_not_updated
      there_should_be_errors 1
      there_should_be_errors_on_column :"first_name", 1
      should_fail_validation_because :"first_name", "can't be blank"
    end

    test "should not update resident if missing last_name" do
      update_resident :cell => @resident.cell, :first_name => @resident.first_name, :email => @resident.email, :type => :Father
      expect_resident_was_not_updated
      there_should_be_errors 1
      there_should_be_errors_on_column :"last_name", 1
      should_fail_validation_because :"last_name", "can't be blank"
    end

    test "should not update resident if missing email" do
      update_resident :cell => @resident.cell, :first_name => @resident.first_name, :last_name => @resident.last_name, :type => :Father
      expect_resident_was_not_updated
      there_should_be_errors 1
      there_should_be_errors_on_column :email, 1
      should_fail_validation_because :email, "can't be blank"
    end

    test "should not update resident if first_name is blank" do
      update_resident :cell => @resident.cell, :first_name => "", :last_name => @resident.last_name, :email => @resident.email, :type => :Father
      expect_resident_was_not_updated
      there_should_be_errors 1
      there_should_be_errors_on_column :"first_name", 1
      should_fail_validation_because :"first_name", "can't be blank"
    end

    test "should not update resident if last_name is blank" do
      update_resident :cell => @resident.cell, :first_name => @resident.first_name, :last_name => "", :email => @resident.email, :type => :Father
      expect_resident_was_not_updated
      there_should_be_errors 1
      there_should_be_errors_on_column :"last_name", 1
      should_fail_validation_because :"last_name", "can't be blank"
    end

    test "should not update resident if email is blank" do
      update_resident :cell => @resident.cell, :first_name => @resident.first_name, :last_name => @resident.last_name, :email => "", :type => :Father
      expect_resident_was_not_updated
      there_should_be_errors 1
      there_should_be_errors_on_column :email, 1
      should_fail_validation_because :email, "can't be blank"
    end
  
    test "should destroy resident" do
      assert_difference('Resident.count', -1) do
        delete :destroy, :id => @new_resident, format: :js
      end
  
      assert_response :success
    end
  end
end
