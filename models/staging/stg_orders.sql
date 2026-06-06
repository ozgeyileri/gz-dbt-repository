SELECT *
FROM {{ source('olist', 'olist_orders_dataset') }}
WHERE order_status = 'delivered'