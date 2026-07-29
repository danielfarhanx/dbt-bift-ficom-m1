{{ config(
    materialized='incremental',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1_airbyte.dim_product_snopix__dbt_backup drop constraint if exists pk_dim_product_snopix {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint pk_dim_product_snopix primary key (pcode) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_product_snopix') }}

),

deduplicated as (

    select
        pcode, pcodename, div_id, brand_id, subbrand_id, parent_id, pcode_map, is_active, user_id, upd_date, flag, ct_id, kubikasi, tonase, pallet, shelf_life, sls_div, flag_season, mar_type_id, flag_wip,
        row_number() over (
            partition by pcode 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        pcode, pcodename, div_id, brand_id, subbrand_id, parent_id, pcode_map, is_active, user_id, upd_date, flag, ct_id, kubikasi, tonase, pallet, shelf_life, sls_div, flag_season, mar_type_id, flag_wip

    from deduplicated
    where rn = 1

)

select * from final
