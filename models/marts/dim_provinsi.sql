{{ config(
    materialized='incremental',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1_airbyte.dim_provinsi__dbt_backup drop constraint if exists dim_provinsi_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_provinsi_pkey primary key (t11) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_fcshir11') }}

),

deduplicated as (

    select
        t11,
        ket,
        row_number() over (
            partition by t11 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        t11,
        ket

    from deduplicated
    where rn = 1

)

select * from final
