class IsAfterStartDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (value != nil) and (record.start_date != nil) 
      unless value > record.start_date
        record.errors[attribute] << "must come after the start date"
      end
    end
  end
end
