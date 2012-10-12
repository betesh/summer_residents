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
