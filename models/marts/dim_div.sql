{{ config(
    materialized='incremental',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1_airbyte.dim_div__dbt_backup drop constraint if exists dim_div_pk {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_div_pk primary key (div_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_division') }}

),

deduplicated as (

    select
        div_id,
        div_nm,
        row_number() over (
            partition by div_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        div_id,
        div_nm

    from deduplicated
    where rn = 1

)

select * from final
