with 

source as (

    select * from {{ source('sql_server_dbo', 'products') }}

),

renamed as (

    select
        product_id,
        price:: decimal(10,2) as price,
        name as desc_product,
        inventory,
        _fivetran_deleted,
        _fivetran_synced as date_load

    from source

)

select * from renamed
