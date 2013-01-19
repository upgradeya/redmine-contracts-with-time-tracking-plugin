class IsAfterStartDateValidator < ActiveModel::EachValidator
  include Redmine::I18n

  def validate_each(record, attribute, value)
    if (value != nil) and (record.start_date != nil) 
      unless value > record.start_date
        record.errors[attribute] << l(:text_must_come_after_start_date)
      end
    end
  end
end
