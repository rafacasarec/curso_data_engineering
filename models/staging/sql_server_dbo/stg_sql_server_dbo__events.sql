with 

source as (

    select * from {{ source('sql_server_dbo', 'events') }}

),

renamed as (

    select
        event_id,
        page_url,
        event_type,
        user_id,
        coalesce(nullif(product_id, ''), 'null') as product_id,
        session_id,
        convert_timezone('UTC', created_at) as event_timestamp_UTC, 
        coalesce(nullif(order_id, ''), 'null') as order_id,
        _fivetran_deleted,
        _fivetran_synced as date_load

    from source

)

select * from renamed
