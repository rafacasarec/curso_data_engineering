with 

source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (

    select
        ORDER_ID, 
        md5(coalesce(nullif(SHIPPING_SERVICE, ''), 'sin enviar')) as SHIPPING_SERVICE_ID, 
        SHIPPING_COST:: DECIMAL(10,2) as SHIPPING_COST, 
        ADDRESS_ID, 
        convert_timezone('UTC', created_at) as CREATED_AT_UTC, 
        md5(coalesce(nullif(promo_id, ''), 'sin promocion')) as promo_id,
        coalesce(nullif(PROMO_ID, ''), 'sin promocion') as desc_promo, 
        convert_timezone('UTC', ESTIMATED_DELIVERY_AT) as ESTIMATED_DELIVERY_AT_UTC,
        ORDER_COST:: decimal(10,2) as ORDER_COST, 
        USER_ID, 
        ORDER_TOTAL:: DECIMAL(10,2) AS ORDER_TOTAL, 
        convert_timezone('UTC', DELIVERED_AT) as DELIVERED_AT_UTC, 
        coalesce(nullif(TRACKING_ID, ''), 'sin enviar') as TRACKING_ID, 
        md5(STATUS) as STATUS_ID, 
        _FIVETRAN_DELETED, 
        _FIVETRAN_SYNCED AS DATE_LOAD

    from source

)

select * from renamed
