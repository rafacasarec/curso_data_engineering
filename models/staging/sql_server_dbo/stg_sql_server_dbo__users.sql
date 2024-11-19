with 

source as (

    select * from {{ source('sql_server_dbo', 'users') }}

),

renamed as (

    select
        USER_ID,
        ADDRESS_ID,
        FIRST_NAME,
        LAST_NAME,
        PHONE_NUMBER,
        EMAIL, 
        convert_timezone('UTC', UPDATED_AT) as UPDATED_AT_UTC,
        convert_timezone('UTC', CREATED_AT) as CREATED_AT_UTC,  
        _FIVETRAN_DELETED, 
        _FIVETRAN_SYNCED as data_loaded

    from source

)

select * from renamed
