with user_orders as (
    
    select
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.phone_number,
        u.CREATED_AT_UTC as created_at_utc,
        u.UPDATED_AT_UTC as updated_at_utc,
        a.address,
        a.zipcode,
        a.state,
        a.country,
        o.order_id,
        sum(oi.quantity * p.price) as total_order_cost_usd, 
        op.shipping_cost as total_shipping_cost_usd, 
        coalesce(pr.discount, 0) as total_discount_usd, 
        sum(oi.quantity) as total_quantity_product, 
        count(distinct oi.product_id) as total_different_products 
    from {{ ref('stg_sql_server_dbo__users') }} u
    left join {{ ref('stg_sql_server_dbo__orders') }} o
        on u.user_id = o.user_id
    left join {{ ref('stg_sql_server_dbo__order_items') }} oi
        on o.order_id = oi.order_id
    left join {{ ref('stg_sql_server_dbo__orders_puente') }} op
        on op.order_id = oi.order_id
    left join {{ ref('stg_sql_server_dbo__products') }} p
        on oi.product_id = p.product_id
    left join {{ ref('stg_sql_server_dbo__addresses') }} a
        on u.address_id = a.address_id
    left join (
        
        select promo_id, discount
        from {{ ref('stg_sql_server_dbo__promos') }}
        where status = 'active'
    ) pr
        on o.promo_id = pr.promo_id
    group by 
        u.user_id, u.first_name, u.last_name, u.email, u.phone_number, u.CREATED_AT_UTC, u.UPDATED_AT_UTC,
        a.address, a.zipcode, a.state, a.country,
        o.order_id, op.shipping_cost, pr.discount
),
user_aggregates as (
    
    select
        user_id,
        first_name,
        last_name,
        email,
        phone_number,
        created_at_utc,
        updated_at_utc,
        address,
        zipcode,
        state,
        country,
        count(distinct order_id) as total_number_orders, 
        sum(total_order_cost_usd) as total_order_cost_usd, 
        sum(total_shipping_cost_usd) as total_shipping_cost_usd, 
        sum(total_discount_usd) as total_discount_usd, 
        sum(total_quantity_product) as total_quantity_product, 
        sum(total_different_products) as total_different_products 
    from user_orders
    group by 
        user_id, first_name, last_name, email, phone_number, created_at_utc, updated_at_utc,
        address, zipcode, state, country
)
select *
from user_aggregates