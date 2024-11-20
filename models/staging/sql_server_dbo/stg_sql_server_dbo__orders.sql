with 

source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (

    select
        ORDER_ID, 
        md5(coalesce(nullif(SHIPPING_SERVICE, ''), 'sin enviar')) as SHIPPING_SERVICE_ID, 
        ADDRESS_ID, 
        date(convert_timezone('UTC', created_at)) as CREATED_AT_UTC,
        md5(coalesce(nullif(promo_id, ''), 'sin promocion')) as promo_id,
        date(convert_timezone('UTC', ESTIMATED_DELIVERY_AT)) as ESTIMATED_DELIVERY_AT_UTC,
        USER_ID, 
        date(convert_timezone('UTC', DELIVERED_AT)) as DELIVERED_AT_UTC, 
        coalesce(nullif(TRACKING_ID, ''), 'sin enviar') as TRACKING_ID, 
        md5(STATUS) as STATUS_ID, 
        _FIVETRAN_DELETED, 
        _FIVETRAN_SYNCED AS DATE_LOAD

    from source

)

select * from renamed
