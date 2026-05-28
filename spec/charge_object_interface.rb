RSpec.shared_examples "a transaction object interface" do
  %w(
    id
    status
    currency
    amount
    order_id
    checkout_id
  ).each do |method|
    it method do
      expect(subject.public_send(method)).to eq(body[method])
    end
  end

  it "created" do
    expect(
      to_seconds(subject.created)
    ).to eq(to_seconds(body["created"]))
  end

  it "authorization_expiration" do
    expect(
      to_seconds(subject.authorization_expiration)
    ).to eq(to_seconds(body["authorization_expiration"]))
  end

  %w(
    id
    currency
    amount
    type
  ).each do |method|
    it "events.#{method}" do
      expect(
        subject.events.first.public_send(method)
      ).to eq(body["events"].first[method])
    end
  end

  it "events.created" do
    expect(
      to_seconds(subject.events.first.created)
    ).to eq(to_seconds(body["events"].first["created"]))
  end
end
