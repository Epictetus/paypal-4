class PurchaseController < ApplicationController
  before_filter :require_ssl, :only => [ :index, :credit ]
  before_filter :load_card
  
  BILL_AMOUNT = 1200
  
  def index
  end
  
  # Use the DirectPayment API
  def credit
    render :action => 'index' and return unless @cc.valid?
    
    @response = paypal_gateway.purchase(BILL_AMOUNT, @cc, 
      :ip => request.remote_ip,
      :billing_address => params[:billing_address])
      
    if @response.success?
      @purchase = Purchase.create(:response => @response)
      redirect_to :action => "complete", :id => @purchase
    else
      paypal_error(@response)
    end
  end
  
  # Use the Express Checkout API
  def express
    gateway = paypal_gateway(:paypal_express)
    
    @response = gateway.setup_purchase(BILL_AMOUNT,
      :return_url => url_for(:action => 'express_complete'),
      :cancel_return_url => url_for(:action => 'index'),
      :description => "My Great Product Name"
    )

    if @response.success?
      # The useraction=commit in the redirect URL tells PayPal there won't
      # be an additional review step at our site before a charge is made
      redirect_to "#{gateway.redirect_url_for(@response.params['token'])}&useraction=commit"
    else
      paypal_error(@response)
    end
  end
  
  # PayPal Express redirects from PayPal back to this action with a token
  def express_complete
    gateway = paypal_gateway(:paypal_express)
    @details = gateway.details_for(params[:token])
    if @details.success?
      @response = gateway.purchase(BILL_AMOUNT, 
        :token => @details.params['token'], 
        :payer_id => @details.params['payer_id'])
      if @response.success?
        @purchase = Purchase.create(:response => @response)
        redirect_to :action => "complete", :id => @purchase
      else
        paypal_error(@response)
      end
    else
      paypal_error(@details)
    end
  end
  
  def complete
    raise ActiveRecord::RecordNotFound unless @purchase = Purchase.find_by_token(params[:id])
  end
  
  protected
    
    def require_ssl
      return unless Rails.env.production?
      redirect_to "https://#{request.host}#{request.request_uri}" unless request.ssl?
    end
    
    def paypal_gateway(gw = :paypal)
      ActiveMerchant::Billing::Base.gateway(gw).new(YAML.load_file(Rails.root.join('config', 'paypal.yml'))[Rails.env])
    end

    def paypal_error(response)
      @paypal_error = response.message
      render :action => 'index'
    end
    
    def load_card
      @cc = ActiveMerchant::Billing::CreditCard.new(params[:creditcard])
    end
end
