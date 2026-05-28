module Affirm
  class FailureResult
    extend Forwardable
    def_delegators :response, :status, :success?

    attr_reader :error

    attr_reader :response
    private :response

    def initialize(response)
      @response = response
      body = response.body
      body = { "message" => body.to_s } unless body.is_a?(Hash)
      @error = Affirm::Responses::Error.new(body)
    end
  end
end
