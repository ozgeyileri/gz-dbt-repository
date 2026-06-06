with
orders_margin as (
    select * from {{ ref('int_orders_margin') }}
),

ship as (
    select * from {{ ref('stg_raw__ship') }}
),

operational_margin_computed as (
    select
        orders_margin.orders_id,
        orders_margin.date_date,
        orders_margin.revenue,
        orders_margin.quantity,
        orders_margin.purchase_cost,
        orders_margin.margin,
        -- Operasyonel Marj = marj + nakliye_ücreti - nakliye_maliyeti
        -- Formül: margin + shipping_fee - ship_cost
        -- Not: log_cost tablomuzda ayrı bir sütun olmadığı için genel kargo maliyeti olan ship_cost düşülmüştür.
        cast(orders_margin.margin + ship.shipping_fee - ship.ship_cost as float64) as operational_margin
    from orders_margin
    inner join ship 
        on orders_margin.orders_id = ship.orders_id
)

select * from operational_margin_computed
