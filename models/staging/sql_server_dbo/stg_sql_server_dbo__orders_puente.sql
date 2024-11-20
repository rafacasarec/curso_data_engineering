with 

source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (

    select
        ORDER_ID, 
        SHIPPING_COST:: DECIMAL(10,2) as SHIPPING_COST, 
        ORDER_COST:: decimal(10,2) as ORDER_COST, 
        ORDER_TOTAL:: DECIMAL(10,2) AS ORDER_TOTAL, 

    from source

)

select * from renamed
