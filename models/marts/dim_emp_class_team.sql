{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_emp_class_team__dbt_backup drop constraint if exists dim_emp_class_team_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_emp_class_team_pkey primary key (m_id, class_team_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_emp_class_team') }}

),

deduplicated as (

    select
        m_id,
        class_team_id,
        row_number() over (
            partition by m_id, class_team_id
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        m_id,
        class_team_id

    from deduplicated
    where rn = 1

)

select * from final
