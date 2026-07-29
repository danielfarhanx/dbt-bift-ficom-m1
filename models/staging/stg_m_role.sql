with source as (

    select * from {{ source('raw_ficom', 'm_role') }}

),

cleaned as (

    select
        cast(role_id as numeric(1000)) as role_id,
        cast(role_nm as varchar(1000)) as role_nm,
        _airbyte_extracted_at

    from source

)

select * from cleaned
