with source as (

    select * from {{ source('raw_ficom', 'm_distributor_upd_date') }}

),

cleaned as (

    select
        cast(distributor_id as varchar(6)) as distributor_id,
        upd_date,
        _airbyte_extracted_at

    from source

)

select * from cleaned
