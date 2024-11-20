with items_with_orders as (
    -- Unimos order_items con orders y productos para obtener el promo_id y calcular el valor bruto del producto
    select
        oi.order_id,
        oi.product_id,
        p.desc_product, -- Nombre del producto desde la tabla products
        oi.quantity,
        o.promo_id, -- Promo ID desde orders
        p.price,
        oi.quantity * p.price as product_value -- Valor bruto del producto
    from {{ ref('stg_sql_server_dbo__order_items') }} oi
    left join {{ ref('stg_sql_server_dbo__orders') }} o
        on oi.order_id = o.order_id
    left join {{ ref('stg_sql_server_dbo__products') }} p
        on oi.product_id = p.product_id
),
active_promos as (
    -- Filtramos solo las promociones activas
    select
        promo_id,
        discount
    from {{ ref('stg_sql_server_dbo__promos') }}
    where status = 'active' -- Solo promociones activas
),
items_with_promos as (
    -- Unimos los datos previos con las promociones activas
    select
        iwo.order_id,
        iwo.product_id,
        iwo.desc_product, -- Incluimos el nombre del producto
        iwo.quantity,
        iwo.product_value,
        ap.discount as active_discount, -- Descuento solo si la promoción está activa
        coalesce(ap.discount, 0) as discount_applied, -- Si no hay promo activa, aplicamos 0
        iwo.product_value - coalesce(ap.discount, 0) as discounted_value -- Valor del producto después del descuento
    from items_with_orders iwo
    left join active_promos ap
        on iwo.promo_id = ap.promo_id
),
product_contributions as (
    -- Calculamos la contribución de cada producto al total del pedido (basado en el valor con descuento)
    select
        iwp.order_id,
        iwp.product_id,
        iwp.desc_product, -- Nombre del producto
        iwp.discounted_value,
        iwp.discount_applied,
        iwp.quantity,
        iwp.product_value,
        iwp.discounted_value / sum(iwp.discounted_value) over (partition by iwp.order_id) as product_contribution -- Proporción del producto en el pedido
    from items_with_promos iwp
),
distributed_shipping as (
    -- Distribuimos el costo de envío proporcionalmente
    select
        pc.order_id,
        pc.product_id,
        pc.desc_product, -- Nombre del producto
        pc.discounted_value,
        pc.discount_applied,
        pc.product_contribution,
        pc.quantity,
        pc.product_value,
        op.shipping_cost * pc.product_contribution as shipping_cost_per_product -- Costo de envío distribuido proporcionalmente
    from product_contributions pc
    left join {{ ref('stg_sql_server_dbo__orders_puente') }} op
        on pc.order_id = op.order_id
)
-- Agrupamos por product_id y desc_product para calcular las ganancias por producto
select
    ds.product_id,
    ds.desc_product, -- Nombre del producto
    sum(ds.product_value) as total_gross_value, -- Valor bruto total por producto
    sum(ds.discount_applied) as total_discount, -- Descuento total aplicado al producto
    sum(ds.product_value - ds.discount_applied) as total_final_revenue -- Ingreso final por producto
from distributed_shipping ds
group by ds.product_id, ds.desc_product





