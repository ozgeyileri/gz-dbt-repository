SELECT p.*
FROM {{ source('olist', 'olist_order_payments_dataset') }} p
WHERE p.order_id IN (
  SELECT order_id FROM {{ ref('stg_orders') }}
)
