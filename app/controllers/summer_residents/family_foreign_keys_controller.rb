module SummerResidents
  class FamilyForeignKeysController < SummerResidentsController
    skip_before_filter :require_administrator_priveleges, only: [:edit, :update, :new, :create]
    before_filter :require_administrator_priveleges_if_different_user, only: [:edit, :update]

    def new
      create_and_assign_to_family
      edit_but_if_cancelled :blank
    end

    def edit
      @instance = model_name.find(params[:id])
      edit_but_if_cancelled :show
    end

    def create
      create_and_assign_to_family
      assign_attributes
      show_unless_errors
    end

    def update
      @instance = model_name.find(params[:id])
      assign_attributes
      show_unless_errors
    end

    def destroy
      model_name.find(params[:id]).destroy
  
      respond_to do |format|
        format.js { render nothing: true }
      end
    end
    helper_method :js_name, :locals
  protected
    def create_and_assign_to_family
      @instance = model_name.new
      @instance.family = Family.find(params[:fam_id])
    end

    def locals
      { r: @instance }
    end

    def model_name
      "SummerResidents::#{controller_name.classify}".constantize
    end

    def js_name
      controller_name.classify.underscore
    end

    def edit_but_if_cancelled x
      respond_to do |format|
        format.js { render action: params[:cancel] ? x : :edit }
      end
    end

    def show_unless_errors
      respond_to do |format|
        format.js { render action: (@instance.valid? ? :show : :errors) }
      end
    end

    def assign_attributes
      model_attributes.each { |f|
        @instance.__send__ "#{f}=", params[f]
      }
      @instance.save
    end
  end
end
