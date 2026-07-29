{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_mapping_project__dbt_backup drop constraint if exists dim_mapping_project_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_mapping_project_pkey primary key (distributor_id, spv_id, sls_id, cust_id, status) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_mapping_project') }}

),

deduplicated as (

    select
        distributor_id,
        spv_id,
        sls_id,
        cust_id,
        status,
        dealing_date,
        upload_date,
        row_number() over (
            partition by distributor_id, spv_id, sls_id, cust_id, status 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        distributor_id,
        spv_id,
        sls_id,
        cust_id,
        status,
        dealing_date,
        upload_date

    from deduplicated
    where rn = 1

)

select * from final
