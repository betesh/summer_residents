require 'test_helper'

module SummerResidents
  class ResidentTest < ActiveSupport::TestCase
    setup do
      @model = residents(:mom)
    end

    getter_test :email
    assert_present_and_valid :user
    assert_not_blank :first_name
    assert_not_blank :last_name
    assert_phone :cell, :allow_blank => true
    getter_test :family

    test "delegates email to user" do
      @model.user.email = "123"
      assert @model.invalid?
      @errors = @model.errors
      there_should_be_errors 1
      there_should_be_errors_on_column :email, 1
      should_fail_validation_because :email, "does not appear to be valid"
    end
  end
  class MotherTest < ParentTest
    setup do
      @model = residents(:mom)
    end
    full_name_test
    assert_nullifies_family_dependency :mother
    test "family getter is reset when family is modified" do
      when_i_save_another_family_as :husband_and_kids
      assert_nil @old_family.mother_id
      @uncached_model = residents(:mom)
      assert_new_family_is_saved
    end
    test "cannot be a father" do
      assert_raise ActiveRecord::RecordNotSaved do
        @model.wife_and_kids = @new_family
      end
    end
  end
  class FatherTest < ParentTest
    setup do
      @model = residents(:dad)
    end
    full_name_test
    assert_nullifies_family_dependency :father
    test "family getter is reset when family is modified" do
      when_i_save_another_family_as :wife_and_kids
      assert_nil @old_family.father_id
      @uncached_model = residents(:dad)
      assert_new_family_is_saved
    end
    test "cannot be a mother" do
      assert_raise ActiveRecord::RecordNotSaved do
        @model.husband_and_kids = @new_family
      end
    end
  end
end
