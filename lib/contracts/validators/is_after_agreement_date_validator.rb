class IsAfterAgreementDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (value != nil) and (record.agreement_date != nil) 
      unless value >= record.agreement_date
        record.errors[attribute] << "must come on or after the agreement date"
      end
    end
  end
end
