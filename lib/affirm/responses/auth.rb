module Affirm
  module Responses
    class Auth
      include Virtus.model

      attribute :id,                       String
      attribute :status,                   String
      attribute :amount,                   Integer
      attribute :amount_refunded,          Integer
      attribute :authorization_expiration, DateTime
      attribute :checkout_id,              String
      attribute :created,                  DateTime
      attribute :currency,                 String
      attribute :events,                   Array[Objects::Event]
      attribute :order_id,                 String
      attribute :provider_id,              Integer
      attribute :remove_tax,               Boolean
      attribute :reference_id,             String
      attribute :tax_amount,               Integer
      attribute :shipping_amount,          Integer
    end
  end
end
