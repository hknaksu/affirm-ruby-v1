module Affirm
  module Charge
    extend self

    # Authorize a checkout token against the Affirm v1 Transactions API.
    #
    #   Affirm::Charge.authorize(checkout_token, order.id)
    #   Affirm::Charge.authorize(checkout_token, order.id, reference_id: "REF-1")
    #
    def authorize(checkout_token, order_id, reference_id: nil)
      if order_id.nil? || order_id.to_s.empty?
        raise ArgumentError, "order_id is required for Affirm v1 authorize"
      end

      payload = {
        transaction_id: checkout_token,
        order_id: order_id.to_s
      }
      payload[:reference_id] = reference_id if reference_id

      respond Client.request(:post, "transactions", **payload)
    end

    def find(transaction_id)
      respond Client.request(:get, "transactions/#{transaction_id}")
    end

    def capture(transaction_id, **options)
      respond Client.request(:post, "transactions/#{transaction_id}/capture", **options)
    end

    def void(transaction_id)
      respond Client.request(:post, "transactions/#{transaction_id}/void")
    end

    def refund(transaction_id, amount:)
      respond Client.request(:post, "transactions/#{transaction_id}/refund", amount: amount)
    end

    def update(transaction_id, **updates)
      respond Client.request(:post, "transactions/#{transaction_id}/update", **updates)
    end

    private

    def respond(response)
      return FailureResult.new(response) unless response.success?

      body = response.body
      return FailureResult.new(response) unless body.is_a?(Hash)

      type  = body["type"]
      klass = case type
      when *%w(capture void refund update)
        Object.const_get("Affirm::Responses::#{type.capitalize}")
      else
        Affirm::Responses::Auth
      end

      SuccessResult.new(klass.new(body))
    end
  end
end
