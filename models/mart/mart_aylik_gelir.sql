SELECT
  FORMAT_DATE('%Y-%m', DATE(order_purchase_timestamp)) AS ay,
  ROUND(SUM(p.payment_value), 2) AS aylik_gelir,
  COUNT(DISTINCT o.order_id) AS siparis_sayisi
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_payments') }} p ON o.order_id = p.order_id
GROUP BY ay
ORDER BY ay
