{{ config(
    materialized='view'
) }}

WITH genel AS (
  SELECT 'Toplam Gelir' AS kpi_adi,
    CAST(ROUND(SUM(p.payment_value), 2) AS STRING) AS deger,
    'BRL' AS birim
  FROM {{ source('olist_source', 'olist_orders_dataset') }} o
  JOIN {{ source('olist_source', 'olist_order_payments_dataset') }} p ON o.order_id = p.order_id
  UNION ALL
  SELECT 'Ortalama Siparis Degeri (AOV)',
    CAST(ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id), 2) AS STRING),
    'BRL'
  FROM {{ source('olist_source', 'olist_orders_dataset') }} o
  JOIN {{ source('olist_source', 'olist_order_payments_dataset') }} p ON o.order_id = p.order_id
  UNION ALL
  SELECT 'Toplam Siparis Sayisi',
    CAST(COUNT(DISTINCT order_id) AS STRING),
    'Adet'
  FROM {{ source('olist_source', 'olist_orders_dataset') }}
  UNION ALL
  SELECT 'Toplam Musteri Sayisi',
    CAST(COUNT(DISTINCT c.customer_unique_id) AS STRING),
    'Adet'
  FROM {{ source('olist_source', 'olist_orders_dataset') }} o
  JOIN {{ source('olist_source', 'olist_customers_dataset') }} c ON o.customer_id = c.customer_id
),
tekrar AS (
  SELECT 'Tekrar Satin Alan Musteri Orani' AS kpi_adi,
    CAST(ROUND(COUNTIF(total_orders > 1) * 100.0 / COUNT(*), 2) AS STRING) AS deger,
    '%' AS birim
  FROM (
    SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS total_orders
    FROM {{ source('olist_source', 'olist_orders_dataset') }} o
    JOIN {{ source('olist_source', 'olist_customers_dataset') }} c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
  )
),
kategori AS (
  SELECT 'En Cok Satan Kategori' AS kpi_adi,
    COALESCE(pr.product_category_name, 'unknown') AS deger,
    'Kategori' AS birim
  FROM {{ source('olist_source', 'olist_orders_dataset') }} o
  JOIN {{ source('olist_source', 'olist_order_items_dataset') }} i ON o.order_id = i.order_id
  JOIN {{ source('olist_source', 'olist_products_dataset') }} pr ON i.product_id = pr.product_id
  GROUP BY pr.product_category_name
  ORDER BY COUNT(*) DESC
  LIMIT 1
),
eyalet AS (
  SELECT 'En Yuksek Gelirli Eyalet' AS kpi_adi,
    c.customer_state AS deger,
    'Eyalet' AS birim
  FROM {{ source('olist_source', 'olist_orders_dataset') }} o
  JOIN {{ source('olist_source', 'olist_customers_dataset') }} c ON o.customer_id = c.customer_id
  JOIN {{ source('olist_source', 'olist_order_payments_dataset') }} p ON o.order_id = p.order_id
  GROUP BY c.customer_state
  ORDER BY SUM(p.payment_value) DESC
  LIMIT 1
),
teslimat AS (
  SELECT 'Ortalama Teslimat Suresi' AS kpi_adi,
    CAST(ROUND(AVG(DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY)), 1) AS STRING) AS deger,
    'Gun' AS birim
  FROM {{ source('olist_source', 'olist_orders_dataset') }}
  WHERE order_delivered_customer_date IS NOT NULL
)
SELECT * FROM genel
UNION ALL SELECT * FROM tekrar
UNION ALL SELECT * FROM kategori
UNION ALL SELECT * FROM eyalet
UNION ALL SELECT * FROM teslimat
