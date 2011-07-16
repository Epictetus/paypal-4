# See: https://github.com/Shopify/active_merchant/issuesearch?state=open&q=rails+3#issue/30
ActiveMerchant::Validateable.module_eval do
  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end
end

# For @cc.errors.full_messages
ActiveMerchant::Billing::CreditCard.class_eval do
  def self.human_attribute_name(attribute_key_name, options = {})
    defaults = ["#{self.class.name.underscore}.#{attribute_key_name}""#{self.class.name.underscore}.#{attribute_key_name}"]
    defaults << options[:default] if options[:default]
    defaults.flatten!
    defaults << attribute_key_name.to_s.humanize
    options[:count] ||= 1
    I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attributes]))
  end
end
