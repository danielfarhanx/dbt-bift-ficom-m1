{{ config(
    materialized='incremental',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1_airbyte.dim_kabupaten__dbt_backup drop constraint if exists dim_kabupaten_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_kabupaten_pkey primary key (t11, t12) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_fcshir12') }}

),

deduplicated as (

    select
        t11,
        t12,
        ket,
        row_number() over (
            partition by t11, t12 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        t11,
        t12,
        ket

    from deduplicated
    where rn = 1

)

select * from final
