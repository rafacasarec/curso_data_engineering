with 

source as (

    select * from {{ source('sql_server_dbo', 'addresses') }}

),

renamed as (

    select
        ADDRESS_ID, 
        ZIPCODE, 
        COUNTRY, 
        ADDRESS, 
        STATE, 
        REGEXP_SUBSTR(ADDRESS, '^[0-9]+') AS address_number,
        REGEXP_SUBSTR(ADDRESS, '[A-Za-z].*') AS address_street,
        _FIVETRAN_DELETED, 
        _FIVETRAN_SYNCED AS data_loaded

    from source

)

select * from renamed
