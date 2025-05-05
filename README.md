# orders
orders, line items and skus


##API-Endpoint
-> POST /orders: create or update the order from the external systems on external_id
and also marks the old line as original false in case of new line items passed and create new line items with original as true

sample payload: {
  "external_id": "SAP-ORDER-1234",
  "placed_at": "2025-04-17T12:00:00Z",
  "line_items": [
    { "sku": "SKU123", "quantity": 10 },
    { "sku": "SKU456", "quantity": 5 }
  ]
}

response: {"id": order_id}

-> POST /orders/:id/lock: used to lock an order for editing and throws error is lock is already present or the order is placed 15 minutes ago (only have 15 minutes to lock the order after placed)



-> GET /sku-summary/:sku: Returns the stats of a particular sku.

response: {
  "sku": "SKU123",
  "summary": [
    { "week": "2025-W14", "total_quantity": 42 },
    { "week": "2025-W15", "total_quantity": 51 }
  ]
}


-> Calculate Sku Stat: it is an async job which calculates last 4 full weeks total count for the sku and it is triggerd when an order is created or updated and when the order is locked


##Models
attribute/type

Orders:
id/uuid
external_id/string
placed_at/datetime
locked_at/datetime
created_at/timestamp
updated_at/timestamp


LineItems:
id/uuid
order_id/uuid
sku/string
quantity/integer
original/boolean
created_at/timestamp
updated_at/timestamp


SkuStats
id/uuid
sku/string
week/string
total_quantity/integer
created_at/timestamp
updated_at/timestamp


##Note: Add indexing if required
