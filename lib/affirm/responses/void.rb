module Affirm
  module Responses
    class Void
      include Virtus.model

      attribute :id,           String
      attribute :type,         String
      attribute :created,      DateTime
      attribute :reference_id, String
    end
  end
end
