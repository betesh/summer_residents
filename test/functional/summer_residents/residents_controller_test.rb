require 'test_helper'

module SummerResidents
  class ResidentsControllerTest < ActionController::TestCase
    setup do
      @resident = residents(:dad)
      @instance = @new_resident = residents(:joe)
      @resident.user.destroy
    end
  
    def all_args
      { cell: @resident.cell, first_name: @resident.first_name, last_name: @resident.last_name, email: @resident.email, type: :Father, fam_id: single_parent }
    end

    def assert_assigned_instance_matches expected
      instance = assigns(:instance)
      [:first_name, :last_name, :cell, :email].each {|attr|
        assert_equal expected.__send__(attr), instance.__send__(attr), "mismatch on resident.#{attr}"
      }
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

    test_edit_action

    def single_parent
      @single_parent = users(:mom_user)
      @single_parent.toggle! :admin
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

    def when_creating_resident_fails options
      assert_no_difference('Resident.count') do
        assert_no_difference('User.count') do
          assert_no_difference('ActionMailer::Base.deliveries.size') do
            when_creating_resident options
          end
        end
      end
    end

    def expected_getting_new_to_succeed_with expected_view, args
      expect_template_when_getting :new, expected_view, args
      expected = Resident.new
      expected.user = User.new
      assert_assigned_instance_matches expected
      assert_assigned_family_matches @single_parent.family
    end

    def when_logged_in_as_single_parent
      single_parent
      @controller.log_in_as @single_parent
    end

    test "should get new" do
      expected_getting_new_to_succeed_with :edit, type: :Mother, fam_id: single_parent
    end

    test "should get new as single parent" do
      when_logged_in_as_single_parent
      expected_getting_new_to_succeed_with :edit, type: :Mother, fam_id: single_parent
    end

    test "new should render blank template when cancelling" do
      expected_getting_new_to_succeed_with :blank, cancel: "2", type: :Mother, fam_id: single_parent
    end
  
    def create_spouse
      create_resident all_args
      assert_response :success
      assert_template :show
      assert_assigned_instance_matches @resident
      assert_equal @single_parent, assigns(:instance).family.mother.user
    end

    def expect_cant_be_blank_failure_on_column col
      expect_resident_was_not_updated
      there_should_be_errors 1
      there_should_be_errors_on_column col, 1
      should_fail_validation_because col, "can't be blank"
    end

    test "should create resident in correct family" do
      create_spouse
    end

    test "should create spouse as single parent" do
      when_logged_in_as_single_parent
      create_spouse
    end

    test "should update resident" do
      update_resident all_args_but(:fam_id)
      assert_response :success
      assert_template :show
      assert_assigned_instance_matches @resident
      assert_equal @new_resident.id, assigns(:instance).id
    end

    def self.should_not_create_or_update_if_blank_or_missing attr
      test "should not create resident missing #{attr}" do
        when_creating_resident_fails all_args_but(attr)
        expect_cant_be_blank_failure_on_column attr
      end

      test "should not create resident if #{attr} is blank" do
        when_creating_resident_fails all_args_but_replace(attr, "")
        expect_cant_be_blank_failure_on_column attr
      end

      test "should not update resident missing #{attr}" do
        update_resident all_args_but([attr, :fam_id])
        expect_cant_be_blank_failure_on_column attr
      end

      test "should not update resident if #{attr} is blank" do
        update_resident all_args_but_replace(attr, "").delete_if { |k,v| :fam_id == k }
        expect_cant_be_blank_failure_on_column attr
      end
    end

    should_not_create_or_update_if_blank_or_missing :"first_name"
    should_not_create_or_update_if_blank_or_missing :"last_name"
    should_not_create_or_update_if_blank_or_missing :email

    destroy_test
  end
end
