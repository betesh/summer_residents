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

  def all_args_but col
    if col.is_a?(Array)
      all_args.delete_if { |k, v| col.include?(k) }
    else
      all_args.delete_if { |k, v| col == k }
    end
  end

  def all_args_but_replace key, val
    args = all_args
    args[key] = val
    args
  end

  def assert_assigned_instance_matches expected
    instance = assigns(:instance)
    @controller.model_attributes.each {|attr|
      assert_equal expected.__send__(attr), instance.__send__(attr), "mismatch on #{self.class.model_name}.#{attr}"
    }
  end

  def assert_assigned_family_matches expected
    assert_equal expected, assigns(:instance).family
  end

  def expect_validation_failure_due_to_phone action, phone, errors
    send("when_#{action}_fails", all_args_but_replace(:phone, phone))
    @instance.phone = phone
    expect_validation_failure_due_to :phone, errors
  end

  def expect_validation_failure_on_create_due_to_phone phone, errors=1
    expect_validation_failure_due_to_phone :creating, phone, errors
  end

  def expect_validation_failure_on_update_due_to_phone phone, errors=1
    expect_validation_failure_due_to_phone :updating, phone, errors
  end

  def self.model_name
    (self.to_s.gsub /.*::(.*)sControllerTest/, '\1')
  end

  def model
    "SummerResidents::#{self.class.model_name}".constantize
  end

  def self.create_should_succeed_with_missing attr
    test "should create #{model_name.downcase} with missing #{attr}" do
      @instance.__send__("#{attr}=",nil)
      create_should_succeed_with all_args_but attr
    end
  end

  def self.update_should_succeed_with_missing attr
    test "should update #{model_name.downcase} with missing #{attr}" do
      @instance.__send__("#{attr}=",nil)
      update_should_succeed_with all_args_but attr
    end
  end

  def record_count
    "SummerResidents::#{self.class.model_name}.count"
  end

  def expect_template_when_getting action, expected_template, args
    get action, ({format: :js}).merge(args)
    assert_response :success
    assert_template expected_template
  end

  def create_should_succeed_with args
    assert_difference(record_count) do
      post :create, ({format: :js}).merge(args)
    end
    assert_response :success
    assert_template :show
    assert_assigned_instance_matches @instance
    assert_assigned_family_matches @instance.family
  end

  def when_creating_fails args
    assert_no_difference(record_count) do
      post :create, ({format: :js}).merge(args)
    end
    assert_response :success
    assert_template :errors
  end

  def update_record args
    assert_no_difference(record_count) do
      put :update, ({format: :js, id: @instance}).merge(args)
    end
    assert_response :success
  end

  def should_fail_validation_because_phone_is_the_wrong_length
    should_fail_validation_because :phone, "is the wrong length (should be 10 characters)"
  end

  def update_should_succeed_with args
    update_record args
    assert_template :show
    assert_assigned_instance_matches @instance
    assert_equal @instance.id, assigns(:instance).id
    assert_assigned_family_matches @instance.family
  end

  def when_updating_fails args
    update_record args
    assert_template :errors
    assert_equal @instance.id, assigns(:instance).id
  end

  def expect_validation_failure_due_to col, errors=1
    assert_assigned_instance_matches @instance
    assert_assigned_family_matches @instance.family
    @errors = assigns(:instance).errors
    there_should_be_errors errors
    there_should_be_errors_on_column col, errors
  end

  def self.destroy_test
    test "should destroy record" do
      assert_difference(record_count, -1) do
        delete :destroy, id: @instance, format: :js
      end
      assert_response :success
      assert_template nil
    end
  end

  def self.test_failure_to_update_because_phone_is_invalid
    test "update should fail if phone contains alpha" do
      expect_validation_failure_on_update_due_to_phone "abcdef1234", 2
      should_fail_validation_because :phone, "is not a number"
      should_fail_validation_because_phone_is_the_wrong_length
    end

    test "update should fail if phone too short" do
      expect_validation_failure_on_update_due_to_phone "123456789"
      should_fail_validation_because_phone_is_the_wrong_length
    end

    test "update should fail if phone too long" do
      expect_validation_failure_on_update_due_to_phone "12345678901"
      should_fail_validation_because_phone_is_the_wrong_length
    end
  end

  def self.test_failure_to_create_because_phone_is_invalid
    test "create should fail if phone contains alpha" do
      expect_validation_failure_on_create_due_to_phone "abcdef1234", 2
      should_fail_validation_because :phone, "is not a number"
      should_fail_validation_because_phone_is_the_wrong_length
    end

    test "create should fail if phone too short" do
      expect_validation_failure_on_create_due_to_phone "123456789"
      should_fail_validation_because_phone_is_the_wrong_length
    end

    test "create should fail if phone too long" do
      expect_validation_failure_on_create_due_to_phone "12345678901"
      should_fail_validation_because_phone_is_the_wrong_length
    end
  end

  def self.test_edit_action
    test "should get edit" do
      expect_template_when_getting :edit, :edit, id: @instance
      assert_equal @instance, assigns(:instance)
    end

    test "edit should render show template when cancelling" do
      expect_template_when_getting :edit, :show, id: @instance, cancel: "2"
      assert_equal @instance, assigns(:instance)
    end
  end

  def self.test_new_action
    test "should get new" do
      expect_template_when_getting :new, :edit, fam_id: @family.id
      assert_assigned_instance_matches model.new
      assert_assigned_family_matches @family
    end

    test "new should render blank template when cancelling" do
      expect_template_when_getting :new, :blank, fam_id: @family.id, cancel: "2"
      assert_assigned_instance_matches model.new
      assert_assigned_family_matches @family
    end
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
