require 'test_helper'

module SummerResidents
  class BungalowsControllerTest < ActionController::TestCase
    setup do
      @bungalow = bungalows(:estate)
    end

    def assert_assigned_instance_matches expected
      instance = assigns(:instance)
      [:name, :phone, :unit].each {|attr|
        assert_equal expected.__send__(attr), instance.__send__(attr), "mismatch on bungalow.#{attr}"
      }
    end

    def expect_template_when_getting action, expected_template, args
      get action, ({format: :js}).merge(args)
      assert_response :success
      assert_template expected_template
    end 

    def create_should_succeed_with args
      assert_difference('Bungalow.count') do
        post :create, ({format: :js}).merge(args)
      end
      assert_response :success
      assert_template :show
      assert_assigned_instance_matches @bungalow
      assert_assigned_family_matches @bungalow.family
    end

    def when_creating_bungalow_fails args
      assert_no_difference('Bungalow.count') do
        post :create, ({format: :js}).merge(args)
      end
      assert_response :success
      assert_template :errors
    end

    def expect_validation_failure_due_to col, errors=1
      assert_assigned_instance_matches @bungalow
      assert_assigned_family_matches @bungalow.family
      @errors = assigns(:instance).errors
      there_should_be_errors errors
      there_should_be_errors_on_column col, errors
    end

    def expect_validation_failure_due_to_phone phone, errors=1
      when_creating_bungalow_fails name: @bungalow.name, phone: phone, unit: @bungalow.unit, fam_id: @bungalow.family.id
      @bungalow.phone = phone
      expect_validation_failure_due_to :phone, errors
    end

    def should_fail_validation_because_phone_is_the_wrong_length
      should_fail_validation_because :phone, "is the wrong length (should be 10 characters)"
    end

    def update_bungalow args
      assert_no_difference('Bungalow.count') do
        put :update, ({format: :js, id: @bungalow}).merge(args)
      end
      assert_response :success
    end
 
    def update_should_succeed_with args
      update_bungalow args
      assert_template :show
      assert_assigned_instance_matches @bungalow
      assert_equal @bungalow.id, assigns(:instance).id
      assert_assigned_family_matches @bungalow.family
    end

    def when_updating_bungalow_fails args
      update_bungalow args
      assert_template :errors
      assert_equal @bungalow.id, assigns(:instance).id
    end

    def expect_validation_failure_because_name_cant_be_blank
      expect_validation_failure_due_to :name
      should_fail_validation_because :name, "can't be blank"
    end

    def expect_validation_failure_due_to_phone phone, errors=1
      when_updating_bungalow_fails name: @bungalow.name, phone: phone, unit: @bungalow.unit, fam_id: @bungalow.family.id
      @bungalow.phone = phone
      expect_validation_failure_due_to :phone, errors
    end

    test "should get new" do
      expect_template_when_getting :new, :edit, fam_id: @bungalow.family.id
      assert_assigned_instance_matches Bungalow.new
      assert_assigned_family_matches @bungalow.family
    end

    test "new should render show template when cancelling" do
      expect_template_when_getting :new, :show, fam_id: @bungalow.family.id, cancel: "2"
      assert_assigned_instance_matches Bungalow.new
      assert_assigned_family_matches @bungalow.family
    end
  
    test "should create bungalow" do
      create_should_succeed_with name: @bungalow.name, phone: @bungalow.phone, unit: @bungalow.unit, fam_id: @bungalow.family.id
    end

    test "should create bungalow with missing unit" do
      @bungalow.unit = nil
      create_should_succeed_with name: @bungalow.name, phone: @bungalow.phone, fam_id: @bungalow.family.id
    end

    test "should create bungalow with missing phone" do
      @bungalow.phone = nil
      create_should_succeed_with name: @bungalow.name, unit: @bungalow.unit, fam_id: @bungalow.family.id
    end

    test "create should fail if no name" do
      when_creating_bungalow_fails phone: @bungalow.phone, unit: @bungalow.unit, fam_id: @bungalow.family.id
      @bungalow.name = nil
      expect_validation_failure_because_name_cant_be_blank
    end

    test "create should fail if blank name" do
      when_creating_bungalow_fails name: "", phone: @bungalow.phone, unit: @bungalow.unit, fam_id: @bungalow.family.id
      @bungalow.name = ""
      expect_validation_failure_because_name_cant_be_blank
    end

    test "create should fail if phone contains alpha" do
      expect_validation_failure_due_to_phone "abcdef1234", 2
      should_fail_validation_because :phone, "is not a number"
      should_fail_validation_because_phone_is_the_wrong_length
    end
  
    test "create should fail if phone too short" do
      expect_validation_failure_due_to_phone "123456789"
      should_fail_validation_because_phone_is_the_wrong_length
    end
  
    test "create should fail if phone too long" do
      expect_validation_failure_due_to_phone "12345678901"
      should_fail_validation_because_phone_is_the_wrong_length
    end
  
    test "should get edit" do
      expect_template_when_getting :edit, :edit, :id => @bungalow
      assert_equal @bungalow, assigns(:instance)
    end

    test "edit should render show template when cancelling" do
      expect_template_when_getting :edit, :show, :id => @bungalow, cancel: "2"
      assert_equal @bungalow, assigns(:instance)
    end
 
    test "should update bungalow" do
      update_should_succeed_with name: @bungalow.name, phone: @bungalow.phone, unit: @bungalow.unit, fam_id: @bungalow.family.id
    end

    test "should update bungalow with missing unit" do
      @bungalow.unit = nil
      update_should_succeed_with name: @bungalow.name, phone: @bungalow.phone, fam_id: @bungalow.family.id
    end

    test "should update bungalow with missing phone" do
      @bungalow.phone = nil
      update_should_succeed_with name: @bungalow.name, unit: @bungalow.unit, fam_id: @bungalow.family.id
    end

    test "update should fail if no name" do
      when_updating_bungalow_fails phone: @bungalow.phone, unit: @bungalow.unit, fam_id: @bungalow.family.id
      @bungalow.name = nil
      expect_validation_failure_because_name_cant_be_blank
    end

    test "update should fail if blank name" do
      when_updating_bungalow_fails name: "", phone: @bungalow.phone, unit: @bungalow.unit, fam_id: @bungalow.family.id
      @bungalow.name = ""
      expect_validation_failure_because_name_cant_be_blank
    end

    test "update should fail if phone contains alpha" do
      expect_validation_failure_due_to_phone "abcdef1234", 2
      should_fail_validation_because :phone, "is not a number"
      should_fail_validation_because_phone_is_the_wrong_length
    end
  
    test "update should fail if phone too short" do
      expect_validation_failure_due_to_phone "123456789"
      should_fail_validation_because_phone_is_the_wrong_length
    end
  
    test "update should fail if phone too long" do
      expect_validation_failure_due_to_phone "12345678901"
      should_fail_validation_because_phone_is_the_wrong_length
    end
  
    test "should destroy bungalow" do
      assert_difference('Bungalow.count', -1) do
        delete :destroy, :id => @bungalow, format: :js
      end
      assert_response :success
      assert_template nil
    end
  end
end
