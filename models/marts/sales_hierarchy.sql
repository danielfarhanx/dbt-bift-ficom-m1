{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.sales_hierarchy__dbt_backup drop constraint if exists sales_hierarchy_pk {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint sales_hierarchy_pk primary key (distributor_id, ss_id, rsm_id, grsm_id, nsm_id, sd_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_v_salesman_hierarchy') }}

),

deduplicated as (

    select
        sd_id,
        sd_nm,
        nsm_id,
        nsm_nm,
        grsm_id,
        grsm_nm,
        rsm_id,
        rsm_nm,
        ss_id,
        ss_nm,
        distributor_id,
        row_number() over (
            partition by distributor_id, ss_id, rsm_id, grsm_id, nsm_id, sd_id
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        sd_id,
        sd_nm,
        nsm_id,
        nsm_nm,
        grsm_id,
        grsm_nm,
        rsm_id,
        rsm_nm,
        ss_id,
        ss_nm,
        distributor_id

    from deduplicated
    where rn = 1

)

select * from final
