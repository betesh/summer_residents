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
      resident = assigns(:resident)
      assert resident, "@resident should have been assigned"
      @errors = resident.errors
    end

    test "should get edit" do
      get :edit, :id => @new_resident, format: :js
      assert_response :success
      assert_template :edit
    end
  
    test "should update resident" do
      update_resident :cell => @resident.cell, :first_name => @resident.first_name, :last_name => @resident.last_name, :email => @resident.email, :type => :Father
      assert_response :success
      assert_template :show
      resident = assigns(:resident)
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
      there_should_be_errors 2
      there_should_be_errors_on_column :email, 2
      should_fail_validation_because :email, "does not appear to be valid"
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
      there_should_be_errors 2
      there_should_be_errors_on_column :email, 2
      should_fail_validation_because :email, "does not appear to be valid"
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
