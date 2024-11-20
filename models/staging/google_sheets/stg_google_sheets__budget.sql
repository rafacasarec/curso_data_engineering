with 

source as (

    select * from {{ source('google_sheets', 'budget') }}

),

renamed as (

    select
        md5(concat(QUANTITY, '-', PRODUCT_ID, '-', MONTH)) as budget_id,
        product_id,
        quantity,
        month,
        monthname(month) as month_name,
        _fivetran_synced as date_load
    from source

)

select * from renamed