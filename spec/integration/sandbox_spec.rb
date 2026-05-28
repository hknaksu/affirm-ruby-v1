require "helper"

# Integration specs hit the live Affirm sandbox. Excluded from the default
# rspec run; invoke with `bundle exec rspec --tag integration`.
#
# Required env vars:
#   AFFIRM_PUBLIC_API_KEY
#   AFFIRM_PRIVATE_API_KEY
RSpec.describe "Affirm sandbox", :integration do
  before(:all) do
    public_key  = ENV.fetch("AFFIRM_PUBLIC_API_KEY")
    private_key = ENV.fetch("AFFIRM_PRIVATE_API_KEY")

    Affirm.configuration = nil
    Affirm.configure do |config|
      config.public_api_key  = public_key
      config.private_api_key = private_key
      config.environment     = :sandbox
    end
  end

  after(:all) do
    Affirm.configuration = nil
  end

  it "configures the sandbox endpoint" do
    expect(Affirm.configuration.endpoint).to eq("https://sandbox.affirm.com")
  end

  describe "Affirm::Charge.find with an unknown id" do
    subject(:result) { Affirm::Charge.find("DOES-NOT-EXIST-#{Time.now.to_i}") }

    it "returns a FailureResult" do
      expect(result).to be_an_instance_of(Affirm::FailureResult)
    end

    it "returns a non-success HTTP status" do
      expect(result.status).to be >= 400
    end

    it "exposes a parsed error message" do
      expect(result.error.message.to_s).not_to be_empty
    end
  end

  describe "Affirm::Charge.authorize with a bogus checkout token" do
    subject(:result) { Affirm::Charge.authorize("not-a-real-token", "ORDER-INTEGRATION-#{Time.now.to_i}") }

    it "returns a FailureResult" do
      expect(result).to be_an_instance_of(Affirm::FailureResult)
    end

    it "returns a non-success HTTP status" do
      expect(result.status).to be >= 400
    end

    it "exposes a parsed error message" do
      expect(result.error.message.to_s).not_to be_empty
    end
  end
end
