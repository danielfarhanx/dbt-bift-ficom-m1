with source as (

    select * from {{ source('raw_ficom', 'm_user_role') }}

),

cleaned as (

    select
        cast(username as varchar(1000)) as username,
        cast(role_id as numeric(1000)) as role_id,
        _airbyte_extracted_at

    from source

)

select * from cleaned
