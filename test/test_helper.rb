# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

class ActiveSupport::TestCase
  fixtures :all
  [:bungalow, :home, :family, :resident].each { |m|
    alias_method m.to_s.pluralize, "summer_residents_#{m.to_s.pluralize}"
  }

  def self.table_name
    t = (self.to_s.gsub /.*::(.*)Test/, '\1').downcase
  end

  def self.getter_test attr
    test "has a#{"n" if "aeiou".include?(attr[0])} #{attr}" do
      assert @model.__send__(attr)
    end
  end

  def should_not_save(attr, char, length)
    @model.__send__("#{attr}=", char.to_s * length)
    assert !@model.save
  end

  def self.assert_nullifies_family_dependency foreign_key=nil
    getter_test :family

    record = foreign_key || self.table_name
    test "#{record}.family is a Family object" do
      assert @model.family.is_a?(SummerResidents::Family)
    end
    test "family.#{record}_id is nullified when #{record} is destroyed" do
      @model.destroy
      assert @model.family
      assert_nil @model.family.__send__ "#{record}_id"
    end
  end

  def self.assert_valid attr
    getter_test attr

    test "#{attr} cannot be invalid" do
      klass = [:mother, :father].include?(attr) ? SummerResidents::Resident : attr.to_s.camelize.constantize
      @model.__send__("#{attr}=", klass.new)
      assert !@model.save
    end
  end

  def self.assert_present_and_valid attr
    assert_valid attr

    test "#{attr} cannot be null" do
      @model.__send__("#{attr}=", nil)
      assert !@model.save
    end
  end

  def self.assert_not_blank attr
    getter_test attr

    test "#{attr} cannot be blank" do
      should_not_save attr, "", 1
    end
  end

  def self.assert_numeric_with_fixed_length attr, length, options
    if options[:allow_blank]
      getter_test attr

      test "#{attr} can be blank" do
        @model.__send__ "#{attr}=", ""
        assert @model.save, @model.errors.inspect
      end
    else
      assert_not_blank attr
    end

    test "#{attr} cannot be alpha" do
      should_not_save attr, "a", length
    end

    test "#{attr} length cannot be less than #{length.to_s}" do
      should_not_save attr, "9", length - 1
    end

    test "#{attr} length can be #{length.to_s}" do
      @model.__send__ "#{attr}=", "9" * length
      assert @model.save, @model.errors.inspect
    end

    test "#{attr} length cannot be greater than #{length.to_s}" do
      should_not_save attr, "9", length + 1
    end
  end

  def self.assert_phone model_or_options, options = {}
    model_present = !model_or_options.is_a?(Hash)
    self.assert_numeric_with_fixed_length (model_present ? model_or_options : :phone), 10, (model_present ? options : model_or_options)
  end

  def there_should_be_errors n
    assert_equal n, @errors.size, "Unexpected number of errors found.  Errors: #{@errors.inspect}"
  end

  def there_should_be_errors_on_column column, n
    assert_equal n, @errors[column].size, "Unexpected number of errors found for #{column}.  Errors: #{@errors.inspect}"
  end

  def should_fail_validation_because column, error
    assert @errors[column].include?(error), "Mismatch on errors.  Expecting errors[:#{column}] to include \"#{error}\".\nerrors:  #{@errors.messages.inspect}"
  end
end

module EasyRailsAuthentication
  module AuthenticationHelper
    alias_method :protected_log_in_as, :log_in_as
    def log_in_as user
      protected_log_in_as user
    end
  end
end

class ActionController::TestCase
  setup do
    @routes = SummerResidents::Engine.routes
    @controller.log_in_as users(:joe_user)
  end
end

module SummerResidents
  class ParentTest < ActiveSupport::TestCase
    setup do
      @new_family = families(:lieberman)
    end
    def resident
      @resident ||= @model.is_a?(SummerResidents::Resident) ? @model : @model.resident
    end
    def when_i_save_another_family_as attr
      @old_family = @model.family
      assert_not_equal @old_family, @new_family
      resident.__send__("#{attr}=", @new_family)
      @model.save!
    end
    def assert_new_family_is_saved
      assert_equal @new_family, @model.family
      assert_equal @new_family, @uncached_model.family
    end

    def self.full_name_test
      test "full name test" do
        assert_equal "#{@model.first_name} #{@model.last_name}", @model.full_name
      end

      test "full name is reset when first name changes" do
        resident.first_name = "Petunia"
        assert_equal "#{@model.first_name} #{@model.last_name}", @model.full_name
      end

      test "full name is reset when last name changes" do
        resident.last_name = "Dursley"
        assert_equal "#{@model.first_name} #{@model.last_name}", @model.full_name
      end
    end
  end
end
