{{ config(
    materialized='incremental',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1_airbyte.dim_salesman_spv__dbt_backup drop constraint if exists dim_salesman_spv_pk {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_salesman_spv_pk primary key (distributor_id, spv_id, sls_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_salesman_spv') }}

),

deduplicated as (

    select
        distributor_id,
        spv_id,
        sls_id,
        upd_date,
        row_number() over (
            partition by distributor_id, spv_id, sls_id
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        distributor_id,
        spv_id,
        sls_id,
        upd_date

    from deduplicated
    where rn = 1

)

select * from final
