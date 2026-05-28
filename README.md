# affirm-ruby-v1

Ruby wrapper for the [Affirm Transactions API](https://docs.affirm.com/developers/docs/manage-transactions) (`/api/v1/transactions`).

## Installation

```ruby
gem "affirm-ruby-v1", require: "affirm"
```

Local path:

```ruby
gem "affirm-ruby-v1", path: "../affirm-ruby-v1", require: "affirm"
```

## Configuration

```ruby
Affirm.configure do |config|
  config.public_api_key  = "ABC"
  config.private_api_key = "XYZ"
  config.environment     = :sandbox # or :production
end
```

## Usage

### Authorize

```ruby
response = Affirm::Charge.authorize(checkout_token, order.id)
# or
response = Affirm::Charge.authorize(checkout_token, order_id: order.id.to_s)
```

### Read transaction

```ruby
Affirm::Charge.find(transaction_id)
```

### Capture

```ruby
Affirm::Charge.capture(transaction_id)
Affirm::Charge.capture(transaction_id, amount: 5000) # partial capture
```

### Void

```ruby
Affirm::Charge.void(transaction_id)
```

### Refund

```ruby
Affirm::Charge.refund(transaction_id, amount: 500)
```

### Update

```ruby
Affirm::Charge.update(transaction_id,
  order_id: "CUSTOM_ORDER_ID",
  shipping_carrier: "USPS",
  shipping_confirmation: "1Z23223"
)
```

### Response handling

```ruby
if response.success?
  response.id                        # Affirm transaction id (e.g. "AMLC-5X0W")
  response.status                    # e.g. "authorized"
  response.amount
  response.checkout_id
  response.order_id
  response.authorization_expiration
else
  response.error.message
end
```

## v1 authorize response fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Transaction id — store this for capture/void/refund |
| `status` | String | e.g. `authorized`, `captured`, `voided` |
| `amount` | Integer | Amount in cents |
| `currency` | String | e.g. `USD` |
| `checkout_id` | String | Affirm checkout identifier |
| `order_id` | String | Your merchant order id |
| `authorization_expiration` | DateTime | When the authorization expires |
| `amount_refunded` | Integer | Refunded amount in cents |
| `events` | Array | Auth/capture/refund event history |

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## License

Released under the MIT license which is included in the [MIT-LICENSE](https://github.com/kjvarga/sitemap_generator/blob/master/MIT-LICENSE) file.

Copyright (c) Hakan Aksu
