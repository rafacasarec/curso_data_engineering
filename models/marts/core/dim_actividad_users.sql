--CTE: Contar usuarios únicos
with total_users_cte as (
    select
        count(distinct user_id) as total_users
    from {{ ref('stg_sql_server_dbo__users') }}
),

-- CTE: Calcular el tiempo promedio de entrega
delivery_time_cte as (
    select
        order_id,
        datediff('day', CREATED_AT_UTC, DELIVERED_AT_UTC) as delivery_time_day
    from {{ ref('stg_sql_server_dbo__orders') }}
    where CREATED_AT_UTC is not null and DELIVERED_AT_UTC is not null
),
avg_delivery_time_cte as (
    select
        avg(delivery_time_day) as avg_delivery_time_day,
    from delivery_time_cte
),

-- CTE: Distribución de compras por usuario
user_purchases_cte as (
    select
        user_id,
        count(order_id) as total_purchases
    from {{ ref('stg_sql_server_dbo__orders') }}
    group by user_id
),
purchase_distribution_cte as (
    select
        case
            when total_purchases = 1 then '1 purchase'
            when total_purchases = 2 then '2 purchases'
            else '3 or more purchases'
        end as purchase_group,
        count(user_id) as user_count
    from user_purchases_cte
    group by purchase_group
),

-- CTE: Sesiones únicas por hora
hourly_sessions_cte as (
    select
        date_trunc('hour', event_timestamp_UTC) as session_hour,
        count(distinct session_id) as unique_sessions
    from {{ ref('stg_sql_server_dbo__events') }}
    where event_timestamp_UTC is not null
    group by session_hour
),
avg_sessions_cte as (
    select
        avg(unique_sessions) as avg_sessions_per_hour
    from hourly_sessions_cte
)

-- Resultados finales
select
    -- Total de usuarios
    (select total_users from total_users_cte) as total_users,
    -- Promedio de tiempo de entrega
    (select avg_delivery_time_day from avg_delivery_time_cte) as avg_delivery_time_day,
    -- Distribución de compras
    (select user_count from purchase_distribution_cte where purchase_group = '1 purchase') as users_with_one_purchase,
    (select user_count from purchase_distribution_cte where purchase_group = '2 purchases') as users_with_two_purchases,
    (select user_count from purchase_distribution_cte where purchase_group = '3 or more purchases') as users_with_three_or_more_purchases,
    -- Promedio de sesiones únicas por hora
    (select avg_sessions_per_hour from avg_sessions_cte) as avg_sessions_per_hour
