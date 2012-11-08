module SummerResidents
  class FamilyForeignKeysController < SummerResidentsController
    skip_before_filter :require_administrator_priveleges, only: [:edit, :update, :new, :create]
    before_filter :require_administrator_priveleges_if_different_user, only: [:edit, :update]

    def new
      create_and_assign_to_family
      edit_but_show_if_cancelled
    end

    def destroy
      model_name.find(params[:id]).destroy
  
      respond_to do |format|
        format.js { render nothing: true }
      end
    end
    helper_method :js_name
  protected
    def model_name
      "SummerResidents::#{controller_name.classify}".constantize
    end

    def js_name
      "#{controller_name.classify.underscore}"
    end

    def edit_but_show_if_cancelled
      respond_to do |format|
        format.js { render action: params[:cancel] ? :show : :edit }
      end
    end

    def show_unless_errors if_save
      respond_to do |format|
        format.js { render action: (if_save ? :show : :errors) }
      end
    end

    def assign_attributes
      model_attributes.each { |f|
        @instance.__send__ "#{f}=", params[f]
      }
    end
  end
end
