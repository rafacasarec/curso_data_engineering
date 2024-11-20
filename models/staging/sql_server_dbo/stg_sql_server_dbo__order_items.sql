with 

source as (

    select * from {{ source('sql_server_dbo', 'order_items') }}

),

renamed as (

    select
        md5(concat(order_id, '-', product_id)) as order_item_id,
        order_id,
        product_id,
        quantity,
        _fivetran_deleted,
        _fivetran_synced as date_load

    from source

)

select * from renamed
