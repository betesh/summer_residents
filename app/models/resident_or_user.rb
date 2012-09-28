module ResidentOrUser
  extend ActiveSupport::Concern
  included do
    after_save :reset_family
  end
  def family
    @family ||= self.wife_and_kids || self.husband_and_kids
  end
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  private
    def reset_family
      @family = nil
    end
end
