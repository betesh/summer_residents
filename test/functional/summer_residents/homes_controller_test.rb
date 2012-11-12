require 'test_helper'

module SummerResidents
  class HomesController
    alias_method :protected_ma, :model_attributes
    def model_attributes
      protected_ma
    end
  end

  class HomesControllerTest < ActionController::TestCase
    setup do
      @instance = @home = homes(:white_shul)
      @family = @instance.family
    end

    def all_args
      { address: @instance.address, apartment: @instance.apartment, city: @instance.city, country: @instance.country, phone: @instance.phone, state: @instance.state, zip: @instance.zip, fam_id: @family.id }
    end

    def expect_validation_failure_due_to_zip action, zip
      send("when_#{action}_fails", all_args_but_replace(:zip, zip))
      @instance.zip = zip
      expect_validation_failure_due_to :zip
    end

    def expect_validation_failure_on_create_due_to_zip zip
      expect_validation_failure_due_to_zip :creating, zip
    end

    def expect_validation_failure_on_update_due_to_zip zip
      expect_validation_failure_due_to_zip :updating, zip
    end

    def should_fail_validation_because_zip_is_the_wrong_length
      should_fail_validation_because :zip, "is the wrong length (should be 5 characters)"
    end

    def self.create_should_fail_if_blank_or_missing attr
      test "create should fail if blank #{attr}" do
        when_creating_fails all_args_but_replace(attr, "")
        @instance.__send__("#{attr}=","")
        expect_validation_failure_due_to attr
        should_fail_validation_because attr, "can't be blank"
      end

      test "create should fail if missing #{attr}" do
        when_creating_fails all_args_but(attr)
        @instance.__send__("#{attr}=",nil)
        expect_validation_failure_due_to attr
        should_fail_validation_because attr, "can't be blank"
      end
    end

    def self.update_should_fail_if_blank_or_missing attr
      test "update should fail if blank #{attr}" do
        when_updating_fails all_args_but_replace(attr, "")
        @instance.__send__("#{attr}=","")
        expect_validation_failure_due_to attr
        should_fail_validation_because attr, "can't be blank"
      end

      test "update should fail if missing #{attr}" do
        when_updating_fails all_args_but(attr)
        @instance.__send__("#{attr}=",nil)
        expect_validation_failure_due_to attr
        should_fail_validation_because attr, "can't be blank"
      end
    end

    test_new_action

    test "should create home" do
      create_should_succeed_with all_args
    end

    test "should update home" do
      update_should_succeed_with all_args
    end

    [:address, :city, :state].each { |attr|
      create_should_fail_if_blank_or_missing attr
      update_should_fail_if_blank_or_missing attr
    }

    [:apartment, :zip, :phone].each { |attr|
      create_should_succeed_with_missing attr
      update_should_succeed_with_missing attr
    }

    test "update should fail if zip contains alpha" do
      expect_validation_failure_on_update_due_to_zip "abc12"
      should_fail_validation_because :zip, "is not a number"
    end

    test "update should fail if zip too short" do
      expect_validation_failure_on_update_due_to_zip "1234"
      should_fail_validation_because_zip_is_the_wrong_length
    end

    test "update should fail if zip too long" do
      expect_validation_failure_on_update_due_to_zip "123456"
      should_fail_validation_because_zip_is_the_wrong_length
    end

    test "create should fail if zip contains alpha" do
      expect_validation_failure_on_create_due_to_zip "abc12"
      should_fail_validation_because :zip, "is not a number"
    end

    test "create should fail if zip too short" do
      expect_validation_failure_on_create_due_to_zip "1234"
      should_fail_validation_because_zip_is_the_wrong_length
    end

    test "create should fail if zip too long" do
      expect_validation_failure_on_create_due_to_zip "123456"
      should_fail_validation_because_zip_is_the_wrong_length
    end


    test_failure_to_create_because_phone_is_invalid
    test_failure_to_update_because_phone_is_invalid

    test_edit_action

    destroy_test
  end
end
