with
sales_margin as (
    select * from {{ ref('int_sales_margin') }}
),

orders_summary as (
    select
        orders_id,
        date_date,
        -- Sipariş bazında toplam ciro, miktar, maliyet ve marj hesaplamaları
        sum(revenue) as revenue,
        sum(quantity) as quantity,
        sum(purchase_cost) as purchase_cost,
        sum(margin) as margin
    from sales_margin
    group by 
        orders_id, 
        date_date
)

select * from orders_summary
