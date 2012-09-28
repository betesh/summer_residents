require 'test_helper'

module SummerResidents
  class BungalowTest < ActiveSupport::TestCase
    setup do
      @model = bungalows(:acres)
    end

    assert_nullifies_family_dependency
    assert_not_blank :name
    assert_phone :allow_blank => true

    getter_test :unit
  end
end
