{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_user_role__dbt_backup drop constraint if exists dim_user_role_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_user_role_pkey primary key (username, role_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_user_role') }}

),

deduplicated as (

    select
        username,
        role_id,
        row_number() over (
            partition by username, role_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        username,
        role_id

    from deduplicated
    where rn = 1

)

select * from final
