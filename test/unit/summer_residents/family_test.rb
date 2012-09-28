require 'test_helper'

module SummerResidents
  class FamilyTest < ActiveSupport::TestCase
    def self.attr_klass attr
      SummerResidents.const_get(attr.capitalize)
    end

    def self.destroyed_unique_dependency_test  attr, klass=self.attr_klass(attr)
      dependency_test attr
      test "#{attr} is destroyed when family is destroyed" do
        object = @model.__send__(attr)
        @model.destroy
        assert object
        assert !klass.find_by_id(object.id)
      end
    end

    def self.dependency_test attr, klass=self.attr_klass(attr)
      klass_name = klass.to_s
      test "family.#{attr} is a #{klass_name} object" do
        assert @model.__send__(attr).is_a?(klass)
      end
      test "#{attr}_id is unique" do
        object = @model.__send__(attr)
        @other_family.__send__("#{attr}=", object)
        assert_raise ActiveRecord::StatementInvalid do
          @other_family.save
        end
      end
    end

    setup do
      @model = families(:lieberman)
      @other_family = families(:green)
    end

    destroyed_unique_dependency_test :bungalow
    destroyed_unique_dependency_test :home
    dependency_test :father, SummerResidents::Resident
    dependency_test :mother, SummerResidents::Resident
    assert_valid :father
    assert_valid :mother

    test "father cannot be a mother" do
      @model.father = @other_family.mother
      @model.save
    end

    test "mother cannot be a father" do
      @model.mother = @other_family.father
      @model.save
    end
  end
end
