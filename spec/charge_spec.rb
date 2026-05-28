require "helper"
require_relative "charge_object_interface"

RSpec.describe Affirm::Charge do
  let(:failed_response) { double(:response, success?: false, body: Hash.new) }

  context "authorize" do
    context "with failed response" do
      subject { described_class }

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions", transaction_id: "ABC", order_id: "ORDER-1")
          .and_return(failed_response)
      end

      it "returns failure object" do
        expect(
          subject.authorize("ABC", "ORDER-1")
        ).to be_an_instance_of(Affirm::FailureResult)
      end
    end

    context "with successful response" do
      subject { described_class.authorize("ABC", "ORDER-1") }

      let(:body) do
        JSON.load(
          File.read(File.expand_path("../fixtures/auth.json", __FILE__))
        )
      end

      let(:successful_response) do
        double(:response, success?: true, body: body)
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions", transaction_id: "ABC", order_id: "ORDER-1")
          .and_return(successful_response)
      end

      it_behaves_like "a transaction object interface"
    end

    context "with reference_id" do
      subject { described_class.authorize("ABC", "ORDER-1", reference_id: "REF-9") }

      let(:successful_response) do
        double(:response, success?: true, body: { "id" => "TX-1", "status" => "authorized" })
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions", transaction_id: "ABC", order_id: "ORDER-1", reference_id: "REF-9")
          .and_return(successful_response)
      end

      it "returns success" do
        expect(subject).to be_success
      end
    end

    context "without order_id" do
      it "raises ArgumentError when nil" do
        expect {
          described_class.authorize("ABC", nil)
        }.to raise_error(ArgumentError, /order_id is required/)
      end

      it "raises ArgumentError when empty string" do
        expect {
          described_class.authorize("ABC", "")
        }.to raise_error(ArgumentError, /order_id is required/)
      end
    end

    context "with successful response but non-Hash body" do
      subject { described_class.authorize("ABC", "ORDER-1") }

      let(:non_hash_response) do
        double(:response, success?: true, body: "<html>Bad Gateway</html>")
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions", transaction_id: "ABC", order_id: "ORDER-1")
          .and_return(non_hash_response)
      end

      it "returns failure object" do
        expect(subject).to be_an_instance_of(Affirm::FailureResult)
      end
    end

    context "with successful response and no type field" do
      subject { described_class.authorize("ABC", "ORDER-1") }

      let(:body) do
        JSON.load(
          File.read(File.expand_path("../fixtures/auth.json", __FILE__))
        )
      end

      let(:successful_response) do
        double(:response, success?: true, body: body)
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions", transaction_id: "ABC", order_id: "ORDER-1")
          .and_return(successful_response)
      end

      it "wraps an Auth response in a SuccessResult" do
        expect(subject).to be_an_instance_of(Affirm::SuccessResult)
        expect(subject.__send__(:object)).to be_an_instance_of(Affirm::Responses::Auth)
      end
    end
  end

  context "find" do
    context "with failed response" do
      subject { described_class }

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:get, "transactions/1")
          .and_return(failed_response)
      end

      it "returns failure object" do
        expect(
          subject.find(1)
        ).to be_an_instance_of(Affirm::FailureResult)
      end
    end

    context "with successful response" do
      subject { described_class.find("ABC") }

      let(:body) do
        JSON.load(
          File.read(File.expand_path("../fixtures/auth.json", __FILE__))
        )
      end

      let(:successful_response) do
        double(:response, success?: true, body: body)
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:get, "transactions/ABC")
          .and_return(successful_response)
      end

      it_behaves_like "a transaction object interface"
    end
  end

  context "capture" do
    context "with failed response" do
      subject { described_class }

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/capture")
          .and_return(failed_response)
      end

      it "returns failure object" do
        expect(
          subject.capture(1)
        ).to be_an_instance_of(Affirm::FailureResult)
      end
    end

    context "with successful response" do
      subject { described_class.capture(1) }

      let(:body) do
        {
          "id"           => "ABC-111",
          "order_id"     => "XYZ-999",
          "currency"     => "USD",
          "amount"       => 100,
          "fee"          => 10,
          "created"      => Time.local(2015, 1, 1),
          "type"         => "capture",
          "reference_id" => "REF-1"
        }
      end

      let(:successful_response) do
        double(:response, success?: true, body: body)
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/capture")
          .and_return(successful_response)
      end

      %w(
        id
        reference_id
        order_id
        currency
        amount
        fee
        type
      ).each do |method|
        it method do
          expect(subject.public_send(method)).to eq(body[method])
        end
      end

      it "created" do
        expect(to_seconds(subject.created)).to eq(to_seconds(body["created"]))
      end
    end

    context "with capture options" do
      subject { described_class.capture(1, amount: 100, order_id: "O1") }

      let(:successful_response) do
        double(:response, success?: true, body: { "type" => "capture", "id" => "CAP-1" })
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/capture", amount: 100, order_id: "O1")
          .and_return(successful_response)
      end

      it "returns success" do
        expect(subject).to be_success
      end
    end
  end

  context "void" do
    context "with failed response" do
      subject { described_class }

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/void")
          .and_return(failed_response)
      end

      it "returns failure object" do
        expect(
          subject.void(1)
        ).to be_an_instance_of(Affirm::FailureResult)
      end
    end

    context "with successful response" do
      subject { described_class.void(1) }

      let(:body) do
        {
          "id"           => "ABC-111",
          "reference_id" => "XYZ-999",
          "created"      => Time.local(2015, 1, 1),
          "type"         => "void"
        }
      end

      let(:successful_response) do
        double(:response, success?: true, body: body)
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/void")
          .and_return(successful_response)
      end

      %w(
        id
        reference_id
        type
      ).each do |method|
        it method do
          expect(subject.public_send(method)).to eq(body[method])
        end
      end

      it "created" do
        expect(to_seconds(subject.created)).to eq(to_seconds(body["created"]))
      end
    end
  end

  context "refund" do
    context "with failed response" do
      subject { described_class }

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/refund", amount: 50)
          .and_return(failed_response)
      end

      it "returns failure object" do
        expect(
          subject.refund(1, amount: 50)
        ).to be_an_instance_of(Affirm::FailureResult)
      end
    end

    context "with successful response" do
      subject { described_class.refund(1, amount: 50) }

      let(:body) do
        {
          "id"           => "ABC-111",
          "reference_id" => "XYZ-999",
          "amount"       => 50,
          "fee_refunded" => 0,
          "created"      => Time.local(2015, 1, 1),
          "type"         => "refund"
        }
      end

      let(:successful_response) do
        double(:response, success?: true, body: body)
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/refund", amount: 50)
          .and_return(successful_response)
      end

      %w(
        id
        reference_id
        amount
        fee_refunded
        type
      ).each do |method|
        it method do
          expect(subject.public_send(method)).to eq(body[method])
        end
      end

      it "created" do
        expect(to_seconds(subject.created)).to eq(to_seconds(body["created"]))
      end
    end
  end

  context "update" do
    context "with failed response" do
      subject { described_class }

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/update",
            order_id: "XYZ-007",
            shipping_carrier: "FedEx",
            shipping_confirmation: "1ZX007")
          .and_return(failed_response)
      end

      it "returns failure object" do
        expect(
          subject.update(1,
            order_id: "XYZ-007",
            shipping_carrier: "FedEx",
            shipping_confirmation: "1ZX007"
          )
        ).to be_an_instance_of(Affirm::FailureResult)
      end
    end

    context "with successful response" do
      subject do
        described_class.update(1,
          order_id: "XYZ-007",
          shipping_carrier: "FedEx",
          shipping_confirmation: "1ZX007"
        )
      end

      let(:body) do
        {
          "id"                    => "ABC-007",
          "order_id"              => "XYZ-007",
          "shipping_carrier"      => "FedEx",
          "shipping_confirmation" => "1ZX007",
          "created"               => Time.local(2015, 1, 1),
          "type"                  => "update"
        }
      end

      let(:successful_response) do
        double(:response, success?: true, body: body)
      end

      before do
        expect(Affirm::Client).to receive(:request)
          .with(:post, "transactions/1/update",
            order_id: "XYZ-007",
            shipping_carrier: "FedEx",
            shipping_confirmation: "1ZX007"
          )
          .and_return(successful_response)
      end

      %w(
        id
        order_id
        shipping_carrier
        shipping_confirmation
        type
      ).each do |method|
        it method do
          expect(subject.public_send(method)).to eq(body[method])
        end
      end

      it "created" do
        expect(to_seconds(subject.created)).to eq(to_seconds(body["created"]))
      end
    end
  end
end
