require 'test_helper'

module SummerResidents
  class HomeTest < ActiveSupport::TestCase
    setup do
      @model = homes(:white_shul)
    end

    assert_nullifies_family_dependency

    assert_not_blank :address
    assert_not_blank :city
    assert_not_blank :state

    assert_numeric_with_fixed_length :zip, 5, :allow_nil => true
    assert_phone :allow_blank => true

    getter_test :apartment
    getter_test :country
  end
end
