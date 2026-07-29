{{ config(
    materialized='table',
    schema='starscm_m1',
    tags=['main-dim'],
    post_hook=[
        "alter table if exists starscm_m1.dim_target_month__dbt_backup drop constraint if exists dim_target_month_pkey",
        "alter table {{ this }} add constraint dim_target_month_pkey primary key (distributor_id, distributor_id_mtx, tahun, periode, pcode)"
    ]
) }}

with staging as (

    select * from {{ ref('stg_v_target_monthly_bift') }}

),

deduplicated as (

    select
        distributor_id, distributor_id_mtx, tahun, periode, pcode, target_qty, target_val,
        row_number() over (
            partition by distributor_id, distributor_id_mtx, tahun, periode, pcode 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        distributor_id, distributor_id_mtx, tahun, periode, pcode, target_qty, target_val

    from deduplicated
    where rn = 1

)

select * from final
