with source as (

    select * from {{ source('raw_ficom', 'm_salesman_spv') }}

),

cleaned as (

    select
        cast(distributor_id as varchar(6)) as distributor_id,
        cast(spv_id as varchar) as spv_id,
        cast(sls_id as varchar(7)) as sls_id,
        cast(upd_date as timestamp) as upd_date,
        _airbyte_extracted_at

    from source

)

select * from cleaned
