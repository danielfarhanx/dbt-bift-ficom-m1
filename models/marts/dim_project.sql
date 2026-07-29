{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_project__dbt_backup drop constraint if exists dim_project_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_project_pkey primary key (project_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_project') }}

),

deduplicated as (

    select
        project_id,
        project_nm,
        row_number() over (
            partition by project_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        project_id,
        project_nm

    from deduplicated
    where rn = 1

)

select * from final
