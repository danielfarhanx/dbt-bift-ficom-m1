with source as (

    select * from {{ source('raw_ficom', 'sls_termin') }}

),

cleaned as (

    select
        cast(sls_id as varchar(7)) as sls_id,
        cast(sls_nm as varchar(25)) as sls_nm,
        cast(team_nm as varchar(50)) as team_nm,
        cast(salesforce_nm as text) as salesforce_nm,
        cast(spv_id as varchar(1000)) as spv_id,
        cast(distributor_id as varchar(6)) as distributor_id,
        cast(termin_date as text) as termin_date,
        cast(upd_date as timestamp(6)) as upd_date,
        _airbyte_extracted_at

    from source

)

select * from cleaned
