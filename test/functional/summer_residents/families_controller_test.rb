require 'test_helper'

module SummerResidents
  class FamiliesControllerTest < ActionController::TestCase
    setup do
      @family = families(:lieberman)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:families)
      assert_select "a.delete_family_link"
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should get add_user_info" do
      get :add_user_info
      assert_response :success
      family = assigns(:family)
      assert_template :new
      assert_nil family.mother
      assert family.father
      assert_nil family.father.id
      assert_equal users(:joe_user), family.father.user
      assert_select 'input#adding_user_info[value="1"]', 1
    end

    test "should show family" do
      get :show, id: @family
      assert_response :success
      assert_select "a.delete_family_link", false
    end
  
    test "should destroy family" do
      assert_difference('Family.count', -1) do
        delete :destroy, id: @family, format: :js
      end
  
      assert_response :success
    end
  end

  class FamiliesControllerCreateTest < ActionController::TestCase
    tests FamiliesController
    setup do
      @family = families(:lieberman)
      @mother = @family.mother
      @mother.user.destroy
      @father = @family.father
      @father.user.destroy
      @controller.log_in_as users(:mom_user)
      @father_hash = { first_name: @father.first_name, last_name: @father.last_name, email: @father.email }
      @mother_hash = { first_name: @mother.first_name, last_name: @mother.last_name, email: @mother.email }
    end

    EMAIL_LINE_INTRO = "Before you can log into your account, you must set your password by following this link: http://#{Rails.application.config.action_mailer.default_url_options[:host]}/reset_password\\?uuid="

    def verify_expected_email parent, email
      assert_equal [parent.email], email.to
      assert_email_contains /^#{EMAIL_LINE_INTRO}#{User.find_by_email(parent.email).password_recovery.reset_link}\.$/, email
    end

    def given_a_user_with_no_family_info
      @user = users(:jose_user)
      @controller.log_in_as @user
    end

    def when_creating_family_from_user adding_user_info=true
      args = { mother: @mother_hash, father: { first_name: @father.first_name, last_name: @father.last_name, email: @user.email } }
      args[:adding_user_info] = "1" if adding_user_info
      post :create, args
    end

    def when_adding_family_info
      assert_difference('Family.count') do
        assert_difference('User.count') do
          when_creating_family_from_user
        end
      end
    end

    def expect_the_correct_family
      @fam = assigns(:family)
      assert_equal 0, @fam.errors.count, @fam.errors.messages.inspect
      father = @fam.father
      assert father
      assert father.user
      mother = @fam.mother
      assert mother
      assert mother.user
      [:first_name, :last_name].each { |attr|
        assert_equal @father.__send__(attr), father.__send__(attr)
        assert_equal @mother.__send__(attr), mother.__send__(attr)
      }
      assert_equal @mother.email, mother.email
      assert_equal @user.email, father.email
    end

    def should_fail_to_create_family_from_user adding_user_info=true
      assert_no_difference('Family.count') do
        assert_no_difference('Resident.count') do
          assert_no_difference('User.count') do
            when_creating_family_from_user adding_user_info
          end
        end
      end

      assert_redirected_to @controller.login_path
    end

    test "should create family from existing user when family info was added and resident info already exists" do
      given_a_user_with_no_family_info
      assert_difference('Resident.count') do
        expect_each_new_user_to_receive_email 1 do
          when_adding_family_info
        end
      end
      expect_the_correct_family
      assert_redirected_to family_path(@fam.id)
      verify_expected_email @mother, @email
    end

    test "should create family from existing user when family info was added and only login info exists" do
      given_a_user_with_no_family_info
      @user.resident.destroy
      assert_difference('Resident.count', 2) do
        expect_each_new_user_to_receive_email 1 do
          when_adding_family_info
        end
      end
      expect_the_correct_family
      assert_redirected_to family_path(@fam.id)
      verify_expected_email @mother, @email
    end

    test "should not allow creating family from existing user unless family info was added" do
      given_a_user_with_no_family_info
      should_fail_to_create_family_from_user false
    end

    test "should not allow creating family from existing user if not current_user" do
      given_a_user_with_no_family_info
      @controller.log_in_as users(:dad_user)
      should_fail_to_create_family_from_user
    end

    test "should create family" do
      assert_difference('Family.count') do
        assert_difference('Resident.count', 2) do
          assert_difference('User.count', 2) do
            post :create, father: @father_hash, mother: @mother_hash
          end
        end
      end

      assert_redirected_to families_path
    end

    def expect_each_new_user_to_receive_email count, &block
      assert_difference('ActionMailer::Base.deliveries.size', count) do
        yield
      end
      if 2 == count
        @mother_email, @father_email = ActionMailer::Base.deliveries.pop(2)
        @father_email, @mother_email = [@mother_email, @father_email] if ([@father.email] == @mother_email.to)
      elsif 1 == count
        @email = ActionMailer::Base.deliveries.pop
      end
    end

    def assert_email_contains regex, email
      assert email.body =~ regex, "Mail body expected to match: #{regex}\nActual: <<<<<\n#{email.body}\n>>>>>"
    end

    test "when creating family, each parent shuld receive a password initializatin email" do
      assert_difference('PasswordRecovery.count', 2) do
        expect_each_new_user_to_receive_email 2 do
          post :create, father: @father_hash, mother: @mother_hash
        end
      end
      verify_expected_email @father, @father_email
      verify_expected_email @mother, @mother_email
    end

    def should_fail_to_create_family_from parents
      @family.destroy
      assert_no_difference('Family.count') do
        assert_no_difference('Resident.count') do
          assert_no_difference('User.count') do
            post :create, parents
          end
        end
      end
      assert_response :success
      assert_template :new
      family = assigns(:family)
      assert family, "@family should have been assigned"
      @errors = family.errors
    end

    def should_fail_validation_for_one_reason column, reason
      there_should_be_errors 1
      there_should_be_errors_on_column column, 1
      should_fail_validation_because column, reason
    end

    test "father's first name is required" do
      should_fail_to_create_family_from mother: @mother_hash, father: { last_name: @father.last_name, email: @father.email }
      should_fail_validation_for_one_reason :"father-first_name", "can't be blank"
    end

    test "father's last name is required" do
      should_fail_to_create_family_from mother: @mother_hash, father: { first_name: @father.first_name, email: @father.email }
      should_fail_validation_for_one_reason :"father-last_name", "can't be blank"
    end

    test "father's email is required" do
      should_fail_to_create_family_from mother: @mother_hash, father: { first_name: @father.first_name, last_name: @father.last_name }
      there_should_be_errors 2
      there_should_be_errors_on_column :"father-email", 2
      should_fail_validation_because :"father-email", "can't be blank"
      should_fail_validation_because :"father-email", "does not appear to be valid"
    end

    test "father's first name cannot be blank" do
      should_fail_to_create_family_from mother: @mother_hash, father: { first_name: "", last_name: @father.last_name, email: @father.email }
      should_fail_validation_for_one_reason :"father-first_name", "can't be blank"
    end

    test "father's last name cannot be blank" do
      should_fail_to_create_family_from mother: @mother_hash, father: { first_name: @father.first_name, last_name: "", email: @father.email }
      should_fail_validation_for_one_reason :"father-last_name", "can't be blank"
    end

    test "father's email cannot be blank" do
      should_fail_to_create_family_from mother: @mother_hash, father: { first_name: @father.first_name, last_name: @father.last_name, email: "" }
      there_should_be_errors 2
      there_should_be_errors_on_column :"father-email", 2
      should_fail_validation_because :"father-email", "can't be blank"
      should_fail_validation_because :"father-email", "does not appear to be valid"
    end

    test "father's email must be valid" do
      should_fail_to_create_family_from mother: @mother_hash, father: { first_name: @father.first_name, last_name: @father.last_name, email: "123" }
      should_fail_validation_for_one_reason :"father-email", "does not appear to be valid"
    end

    test "mother's first name is required" do
      should_fail_to_create_family_from father: @father_hash, mother: { last_name: @mother.last_name, email: @mother.email }
      should_fail_validation_for_one_reason :"mother-first_name", "can't be blank"
    end

    test "mother's last name is required" do
      should_fail_to_create_family_from father: @father_hash, mother: { first_name: @mother.first_name, email: @mother.email }
      should_fail_validation_for_one_reason :"mother-last_name", "can't be blank"
    end

    test "mother's email is required" do
      should_fail_to_create_family_from father: @father_hash, mother: { first_name: @mother.first_name, last_name: @mother.last_name }
      there_should_be_errors 2
      there_should_be_errors_on_column :"mother-email", 2
      should_fail_validation_because :"mother-email", "can't be blank"
      should_fail_validation_because :"mother-email", "does not appear to be valid"
    end

    test "mother's first name cannot be blank" do
      should_fail_to_create_family_from father: @father_hash, mother: { first_name: "", last_name: @mother.last_name, email: @mother.email }
      should_fail_validation_for_one_reason :"mother-first_name", "can't be blank"
    end

    test "mother's last name cannot be blank" do
      should_fail_to_create_family_from father: @father_hash, mother: { first_name: @mother.first_name, last_name: "", email: @mother.email }
      should_fail_validation_for_one_reason :"mother-last_name", "can't be blank"
    end

    test "mother's email cannot be blank" do
      should_fail_to_create_family_from father: @father_hash, mother: { first_name: @mother.first_name, last_name: @mother.last_name, email: "" }
      there_should_be_errors 2
      there_should_be_errors_on_column :"mother-email", 2
      should_fail_validation_because :"mother-email", "can't be blank"
      should_fail_validation_because :"mother-email", "does not appear to be valid"
    end

    test "mother's email must be valid" do
      should_fail_to_create_family_from father: @father_hash, mother: { first_name: @mother.first_name, last_name: @mother.last_name, email: "123" }
      should_fail_validation_for_one_reason :"mother-email", "does not appear to be valid"
    end
  end
end
