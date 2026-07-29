{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"]
) }}

with staging as (

    select * from {{ ref('stg_sls_termin') }}

),

deduplicated as (

    select
        sls_id,
        sls_nm,
        team_nm,
        salesforce_nm,
        spv_id,
        distributor_id,
        termin_date,
        upd_date,
        row_number() over (
            partition by distributor_id, sls_id, spv_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        sls_id,
        sls_nm,
        team_nm,
        salesforce_nm,
        spv_id,
        distributor_id,
        termin_date,
        upd_date

    from deduplicated
    where rn = 1

)

select * from final
