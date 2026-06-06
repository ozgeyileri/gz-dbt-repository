SELECT
  c.customer_state AS eyalet,
  ROUND(SUM(p.payment_value), 2) AS toplam_gelir,
  COUNT(DISTINCT o.order_id) AS siparis_sayisi
FROM {{ ref('stg_orders') }} o
JOIN {{ source('olist', 'olist_customers_dataset') }} c ON o.customer_id = c.customer_id
JOIN {{ ref('stg_payments') }} p ON o.order_id = p.order_id
GROUP BY eyalet
ORDER BY toplam_gelir DESC
