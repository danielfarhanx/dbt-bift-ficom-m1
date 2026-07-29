{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"]
) }}

with staging as (

    select * from {{ ref('stg_fregion') }}

),

deduplicated as (

    select
        region_id,
        region_nm,
        off_id,
        user_id,
        upddate,
        row_number() over (
            partition by region_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        region_id,
        region_nm,
        off_id,
        user_id,
        upddate

    from deduplicated
    where rn = 1

)

select * from final
