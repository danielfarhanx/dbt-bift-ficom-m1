with source as (

    select * from {{ source('raw_ficom', 'm_mapping_project') }}

),

cleaned as (

    select
        cast(distributor_id as varchar(6)) as distributor_id,
        cast(spv_id as varchar(10)) as spv_id,
        cast(sls_id as varchar(10)) as sls_id,
        cast(cust_id as varchar(10)) as cust_id,
        cast(status as varchar(50)) as status,
        cast(dealing_date as timestamp(6)) as dealing_date,
        cast(upload_date as timestamp(6)) as upload_date,
        _airbyte_extracted_at

    from source

)

select * from cleaned
