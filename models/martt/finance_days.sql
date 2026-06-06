with
orders_operational as (
    select * from {{ ref('int_orders_operational') }}
),

stg_ship as (
    select * from {{ ref('stg_raw__ship') }}
),

daily_metrics as (
    select
        -- 1. Tarih
        orders_operational.date_date,
        -- 2. Toplam işlem sayısı (Benzersiz sipariş adedi)
        count(distinct orders_operational.orders_id) as nb_transactions,
        -- 3. Toplam gelir
        sum(orders_operational.revenue) as revenue,
        -- 4. Ortalama Sepet (Toplam Gelir / Toplam İşlem Sayısı)
        round(safe_divide(sum(orders_operational.revenue), count(distinct orders_operational.orders_id)), 2) as average_basket,
        -- 5. Operasyonel Marj
        sum(orders_operational.operational_margin) as operational_margin,
        -- 6. Toplam satın alma maliyeti
        sum(orders_operational.purchase_cost) as purchase_cost,
        -- 7. Toplam nakliye ücretleri (Müşterinin ödediği)
        sum(stg_ship.shipping_fee) as shipping_fee,
        -- 8. Toplam lojistik maliyetleri (Şirkete yansıyan kargo maliyeti)
        sum(stg_ship.ship_cost) as log_cost,
        -- 9. Satılan toplam ürün miktarı
        sum(orders_operational.quantity) as quantity
    from orders_operational
    inner join stg_ship 
        on orders_operational.orders_id = stg_ship.orders_id
    group by 
        orders_operational.date_date
)

select * from daily_metrics
order by date_date desc
