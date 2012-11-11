require 'test_helper'

module SummerResidents
  class BungalowsController
    alias_method :protected_ma, :model_attributes
    def model_attributes
      protected_ma
    end
  end

  class BungalowsControllerTest < ActionController::TestCase
    setup do
      @instance = bungalows(:estate)
      @family = @instance.family
    end

    def all_args
      { name: @instance.name, phone: @instance.phone, unit: @instance.unit, fam_id: @family.id }
    end

    def expect_validation_failure_because_name_cant_be_blank
      expect_validation_failure_due_to :name
      should_fail_validation_because :name, "can't be blank"
    end

    test_new_action

    test "should create bungalow" do
      create_should_succeed_with all_args
    end

    [:phone, :unit].each { |attr|
      create_should_succeed_with_missing attr
      update_should_succeed_with_missing attr
    }

    test "create should fail if no name" do
      when_creating_fails all_args_but(:name)
      @instance.name = nil
      expect_validation_failure_because_name_cant_be_blank
    end

    test "create should fail if blank name" do
      when_creating_fails all_args_but_replace(:name, "")
      @instance.name = ""
      expect_validation_failure_because_name_cant_be_blank
    end

    test_failure_to_create_because_phone_is_invalid

    test_edit_action

    test "should update bungalow" do
      update_should_succeed_with all_args
    end

    test "update should fail if no name" do
      when_updating_fails all_args_but(:name)
      @instance.name = nil
      expect_validation_failure_because_name_cant_be_blank
    end

    test "update should fail if blank name" do
      when_updating_fails all_args_but_replace(:name, "")
      @instance.name = ""
      expect_validation_failure_because_name_cant_be_blank
    end

    test_failure_to_update_because_phone_is_invalid

    destroy_test
  end
end
