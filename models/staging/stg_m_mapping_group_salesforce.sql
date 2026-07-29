with source as (

    select * from {{ source('raw_ficom', 'm_mapping_group_salesforce') }}

),

cleaned as (

    select
        cast(div_id as varchar(2)) as div_id,
        cast(div_nm as varchar(35)) as div_nm,
        cast(salesforce_id as varchar(3)) as salesforce_id,
        cast(salesforce_nm as varchar(35)) as salesforce_nm,
        cast(gsalesforce_id as varchar(3)) as gsalesforce_id,
        cast(gsalesforce_nm as varchar(35)) as gsalesforce_nm,
        _airbyte_extracted_at

    from source

)

select * from cleaned
