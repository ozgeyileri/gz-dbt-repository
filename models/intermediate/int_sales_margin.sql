with 
sales as (
    select * from {{ ref('stg_raw__sales') }}
),

product as (
    select * from {{ ref('stg_raw__product') }}
),

computed_margin as (
    select
        sales.orders_id,
        sales.date_date,
        sales.products_id,
        sales.revenue,
        sales.quantity,
        -- Satın alma maliyeti = miktar * satın alma fiyatı
        sales.quantity * product.purchase_price as purchase_cost,
        -- Marj = gelir - satın alma maliyeti
        sales.revenue - (sales.quantity * product.purchase_price) as margin
    from sales
    inner join product 
        on sales.products_id = product.products_id
)

select * from computed_margin
