module Affirm
  module Responses
    class Capture
      include Virtus.model

      attribute :id,           String
      attribute :type,         String
      attribute :amount,       Integer
      attribute :currency,     String
      attribute :fee,          Integer
      attribute :created,      DateTime
      attribute :order_id,     String
      attribute :reference_id, String
    end
  end
end
