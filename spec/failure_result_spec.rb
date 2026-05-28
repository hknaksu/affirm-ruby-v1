require "helper"

RSpec.describe Affirm::FailureResult do
  let(:body) do
    {
      "status_code" => 400,
      "type"        => "invalid_request",
      "code"        => "invalid_field",
      "message"     => "An input field resulted in invalid request.",
      "field"       => "foo"
    }
  end

  let(:response) do
    double(:response, status: 400, success?: false, body: body)
  end

  subject { described_class.new(response) }

  context "response" do
    it "should have status" do
      expect(subject.status).to eq(response.status)
    end

    it "should not be successful" do
      expect(subject).not_to be_success
    end
  end

  context "error object" do
    %w(
      status_code
      type
      code
      message
      field
    ).each do |method|
      it method do
        expect(subject.error.public_send(method)).to eq(body[method])
      end
    end
  end

  context "with non-Hash body" do
    let(:response) do
      double(:response, status: 502, success?: false, body: "Bad Gateway")
    end

    subject { described_class.new(response) }

    it "wraps the body string in the error message" do
      expect(subject.error.message).to eq("Bad Gateway")
    end

    it "is not successful" do
      expect(subject).not_to be_success
    end
  end

  context "with nil body" do
    let(:response) do
      double(:response, status: 500, success?: false, body: nil)
    end

    subject { described_class.new(response) }

    it "stringifies nil into the error message" do
      expect(subject.error.message).to eq("")
    end
  end
end
