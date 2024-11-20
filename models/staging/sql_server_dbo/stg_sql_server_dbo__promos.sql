with 

source as (

    select * from {{ source('sql_server_dbo', 'promos') }}

),

renamed as (

    select
        md5(promo_id) as promo_id,
        PROMO_ID as desc_promo, 
        DISCOUNT, 
        STATUS, 
        _FIVETRAN_DELETED, 
        _FIVETRAN_SYNCED as data_loaded

    from source

),

add_no_promo as (

    select
        md5('sin promocion') as promo_id,  
        'sin promocion' as desc_promo,
        0 as discount,                     
        'active' as status,                
        null as _fivetran_deleted, 
        current_timestamp as data_loaded   
)

select * 
from renamed

union all

select *
from add_no_promo

