# class CreditCard
#   include ActiveModel::Validations
#   
#   ## Attributes
#   
#   cattr_accessor :require_verification_value
#   self.require_verification_value = true
#   
#   # Essential attributes for a valid, non-bogus creditcards
#   attr_accessor :number, :month, :year, :type, :first_name, :last_name
#   
#   # Required for Switch / Solo cards
#   attr_accessor :start_month, :start_year, :issue_number
# 
#   # Optional verification_value (CVV, CVV2 etc). Gateways will try their best to 
#   # run validation on the passed in value if it is supplied
#   attr_accessor :verification_value
# end

module ActiveRecord
  module Billing
    class CreditCard
      def inspect
        attributes_as_nice_string = [:number, :month, :year, :type, :first_name, :last_name].collect { |name|
          "#{name}: #{send(name)}"
        }.compact.join(", ")
        "#<#{self.class} #{attributes_as_nice_string}>"
      end
    end
  end
end
