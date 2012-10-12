module SummerResidents
  module SummerResidentsHelper
    def engine_tag &block
      content_tag :div, class: "summer_residents", &block
    end

    def model_tag obj, type=:div, &block
      name = obj.class.to_s.underscore.gsub("/", "_")
      content_tag type, class: name, id: "#{name}_#{obj.id}", &block
    end
  end
end
