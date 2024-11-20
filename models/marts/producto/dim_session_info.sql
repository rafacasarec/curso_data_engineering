with session_events as (
    select
        se.session_id,
        se.user_id,
        min(se.event_timestamp_UTC) as first_event_time_utc, 
        max(se.event_timestamp_UTC) as last_event_time_utc,  
        datediff('minute', min(se.event_timestamp_UTC), max(se.event_timestamp_UTC)) as session_length_minutes, 
        count(case when se.event_type = 'page_view' then 1 end) as page_view, 
        count(case when se.event_type = 'add_to_cart' then 1 end) as add_to_cart, 
        count(case when se.event_type = 'checkout' then 1 end) as checkout, 
        count(case when se.event_type = 'package_shipped' then 1 end) as package_shipped 
    from {{ ref('stg_sql_server_dbo__events') }} se
    group by se.session_id, se.user_id
),
session_with_users as (
    select
        se.session_id,
        se.user_id,
        u.first_name,
        u.email,
        se.first_event_time_utc,
        se.last_event_time_utc,
        se.session_length_minutes,
        se.page_view,
        se.add_to_cart,
        se.checkout,
        se.package_shipped
    from session_events se
    left join {{ ref('stg_sql_server_dbo__users') }} u
        on se.user_id = u.user_id
)
select *
from session_with_users
