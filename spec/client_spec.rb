require "helper"

RSpec.describe Affirm::Client do
  context "new instance" do
    it "creates Faraday connection" do
      expect(subject.connection).to be_an_instance_of(Faraday::Connection)
    end
  end

  context ".request" do
    it "dispatches :get to a new instance" do
      instance = instance_double(described_class, get: :ok)
      expect(described_class).to receive(:new).and_return(instance)
      expect(instance).to receive(:get).with("transactions/1", { foo: "bar" }).and_return(:ok)

      expect(
        described_class.request(:get, "transactions/1", { foo: "bar" })
      ).to eq(:ok)
    end

    it "dispatches :post to a new instance" do
      instance = instance_double(described_class, post: :ok)
      expect(described_class).to receive(:new).and_return(instance)
      expect(instance).to receive(:post).with("transactions", { transaction_id: "ABC" }).and_return(:ok)

      expect(
        described_class.request(:post, "transactions", { transaction_id: "ABC" })
      ).to eq(:ok)
    end

    it "defaults data to an empty hash" do
      instance = instance_double(described_class, get: :ok)
      expect(described_class).to receive(:new).and_return(instance)
      expect(instance).to receive(:get).with("transactions/1", {}).and_return(:ok)

      described_class.request(:get, "transactions/1")
    end
  end

  context "with api keys set" do
    before do
      Affirm.configure do |config|
        config.public_api_key  = "abc"
        config.private_api_key = "xyz"
      end
    end

    it "sets json handlers" do
      expect(
        subject.connection.builder.handlers.map(&:klass)
      ).to include(Faraday::Request::Json, Faraday::Response::Json)
    end

    it "sets basic auth header" do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/v1/auth-check") do |env|
          expect(env.request_headers["Authorization"]).to eq("Basic YWJjOnh5eg==")
          [200, {}, ""]
        end
      end

      subject.connection.builder.handlers.pop
      subject.connection.adapter(:test, stubs)

      expect(subject.get("auth-check")).to be_success
      stubs.verify_stubbed_calls
    end
  end

  context "post request" do
    before(:all) do
      @stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post("/api/v1/foo") { [200, {}, ""] }
        stub.post("/api/v1/bar", '{"key":"value"}') { [200, {}, ""] }
      end
    end

    after(:all) { @stubs.verify_stubbed_calls }

    before do
      subject.connection.builder.handlers.pop
      subject.connection.adapter(:test, @stubs)
    end

    it "makes request to full url" do
      response = subject.post("foo", {})
      expect(response.env.url.to_s).to eq("https://api.affirm.com/api/v1/foo")
    end

    it "makes request to specified path with no leading slash specified" do
      expect(subject.post("foo")).to be_success
    end

    it "makes request to specified path with leading slash specified" do
      expect(subject.post("/foo")).to be_success
    end

    it "makes request with json data" do
      expect(subject.post("/bar", { key: "value" })).to be_success
    end
  end

  context "get request" do
    before(:all) do
      @stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/v1/foo") { [200, {}, ""] }
        stub.get("/api/v1/bar?key=value") { [200, {}, ""] }
      end
    end

    after(:all) { @stubs.verify_stubbed_calls }

    before do
      subject.connection.builder.handlers.pop
      subject.connection.adapter(:test, @stubs)
    end

    it "makes request to full url" do
      response = subject.get("foo", {})
      expect(response.env.url.to_s).to eq("https://api.affirm.com/api/v1/foo")
    end

    it "makes request to specified path with no leading slash specified" do
      expect(subject.get("foo")).to be_success
    end

    it "makes request to specified path with leading slash specified" do
      expect(subject.get("/foo")).to be_success
    end

    it "makes request with params" do
      expect(subject.get("/bar", { key: "value" })).to be_success
    end
  end
end
