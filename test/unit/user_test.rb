require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @model = users(:dad_user)
  end

  getter_test :resident
  getter_test :first_name
  getter_test :last_name

  test "user.resident is a Resident object" do
    assert @model.resident.is_a?(SummerResidents::Resident)
  end
  test "resident is destroyed when user is destroyed" do
    @model.destroy
    assert @model.resident
    assert !SummerResidents::Resident.find_by_id(@model.resident.id)
  end
end
class MotherUserTest < SummerResidents::ParentTest
  setup do
    @model = users(:mom_user)
  end
  getter_test :husband_and_kids
  full_name_test
  test "family getter is reset when family is modified" do
    when_i_save_another_family_as :husband_and_kids
    assert_nil @old_family.mother_id
    @uncached_model = users(:mom_user)
    assert_new_family_is_saved
  end
end
class FatherUserTest < SummerResidents::ParentTest
  setup do
    @model = users(:dad_user)
  end
  getter_test :wife_and_kids
  full_name_test
  test "family getter is reset when family is modified" do
    when_i_save_another_family_as :wife_and_kids
    assert_nil @old_family.father_id
    @uncached_model = users(:dad_user)
    assert_new_family_is_saved
  end
end
