{{ config(
    materialized='incremental',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1_airbyte.dim_distributor_upd_date__dbt_backup drop constraint if exists dim_distributor_upd_date_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_distributor_upd_date_pkey primary key (distributor_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_distributor_upd_date') }}

),

deduplicated as (

    select
        distributor_id,
        upd_date,
        row_number() over (
            partition by distributor_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        distributor_id,
        upd_date

    from deduplicated
    where rn = 1

)

select * from final
