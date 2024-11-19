with 

source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (

    select
        md5(STATUS) as STATUS_ID,
        STATUS
    
    from source

)

select * from renamed