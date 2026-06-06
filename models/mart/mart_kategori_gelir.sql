SELECT
  COALESCE(t.string_field_1, p.product_category_name, 'unknown') AS kategori,
  ROUND(SUM(pay.payment_value), 2) AS toplam_gelir,
  COUNT(DISTINCT o.order_id) AS siparis_sayisi
FROM {{ ref('stg_orders') }} o
JOIN {{ source('olist', 'olist_order_items_dataset') }} i ON o.order_id = i.order_id
JOIN {{ ref('stg_products') }} p ON i.product_id = p.product_id
JOIN {{ ref('stg_payments') }} pay ON o.order_id = pay.order_id
LEFT JOIN {{ source('olist', 'olist_product_category_name_translation') }} t
  ON p.product_category_name = t.string_field_0
GROUP BY kategori
ORDER BY toplam_gelir DESC
