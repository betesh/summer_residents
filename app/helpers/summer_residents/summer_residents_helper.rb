module SummerResidents
  module SummerResidentsHelper
    def engine_tag &block
      content_tag :div, class: "summer_residents", &block
    end

    def model_tag obj, type=:div, &block
      name = obj.class.to_s.underscore.gsub("/", "_")
      content_tag type, class: name, id: "#{name}_#{obj.id}", &block
    end

    def type_field type, instance
      (hidden_field_tag "type", type, id: "resident_type_#{instance.id}").html_safe
    end

    def telephone_form_row val, name=:phone
      "<tr><td class=\"label_td\">#{label_tag name}:</td><td>#{telephone_field_tag name, val, size: 10, maxlength: 10}</td></tr>".html_safe
    end
  end
end
