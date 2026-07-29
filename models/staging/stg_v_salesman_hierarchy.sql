with source as (

    select * from {{ source('raw_ficom', 'v_salesman_hierarchy') }}

),

cleaned as (

    select
        cast(sd_id as varchar(6)) as sd_id,
        cast(sd_nm as varchar(25)) as sd_nm,
        cast(nsm_id as varchar(6)) as nsm_id,
        cast(nsm_nm as varchar(25)) as nsm_nm,
        cast(grsm_id as varchar(6)) as grsm_id,
        cast(grsm_nm as varchar(25)) as grsm_nm,
        cast(rsm_id as varchar(6)) as rsm_id,
        cast(rsm_nm as varchar(25)) as rsm_nm,
        cast(ss_id as varchar(6)) as ss_id,
        cast(ss_nm as varchar(25)) as ss_nm,
        cast(sls_id as varchar(7)) as sls_id,
        cast(distributor_id as varchar(6)) as distributor_id,
        _airbyte_extracted_at

    from source

)

select * from cleaned
