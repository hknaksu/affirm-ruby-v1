module Affirm
  module Responses
    class Refund
      include Virtus.model

      attribute :id,           String
      attribute :reference_id, String
      attribute :amount,       Integer
      attribute :fee_refunded,   Integer
      attribute :created,        DateTime
      attribute :type,           String
    end
  end
end
