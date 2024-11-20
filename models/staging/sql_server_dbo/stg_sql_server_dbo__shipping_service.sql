with 

source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (

    select distinct
        md5(coalesce(nullif(SHIPPING_SERVICE, ''), 'sin enviar')) as SHIPPING_SERVICE_ID,
        coalesce(nullif(SHIPPING_SERVICE, ''), 'sin enviar') as SHIPPING_SERVICE,
        SHIPPING_COST:: DECIMAL(10,2) as SHIPPING_COST
    
    from source

)

select * from renamed