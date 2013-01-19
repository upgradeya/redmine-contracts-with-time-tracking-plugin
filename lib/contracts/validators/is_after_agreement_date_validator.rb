class IsAfterAgreementDateValidator < ActiveModel::EachValidator
  include Redmine::I18n

  def validate_each(record, attribute, value)
    if (value != nil) and (record.agreement_date != nil) 
      unless value >= record.agreement_date
        record.errors[attribute] << l(:text_must_come_after_agreement_date)
      end
    end
  end
end
