{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"]
) }}

with staging as (

    select * from {{ ref('stg_m_cycle3') }}

),

deduplicated as (

    select
        year_op,
        week_op,
        period_op,
        cdate,
        flag,
        row_number() over (
            partition by year_op, week_op 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        year_op,
        week_op,
        period_op,
        cdate,
        flag

    from deduplicated
    where rn = 1

)

select * from final
