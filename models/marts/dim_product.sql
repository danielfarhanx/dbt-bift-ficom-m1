{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_product__dbt_backup drop constraint if exists dim_product_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_product_pkey primary key (pcode) {% else %} select 1 {% endif %}"
    ]
) }}

with product as (

    select * from {{ ref('stg_fmaster') }}

),

mapping_subbrand as (

    select * from {{ ref('stg_m_mapping_subbrand') }}

),

product_snopix as (

    select * from {{ ref('stg_m_product_snopix') }}

),

division_snopix as (

    select * from {{ ref('stg_m_division_snopix') }}

),

joined as (

    select
        p.pcode,
        p.pcodename as pcode_nm,
        ms.div_id,
        ms.div_nm,
        ms.team_id,
        ms.team_nm,
        ms.class_team_id,
        ms.class_team_nm,
        ms.subbrand_id,
        ms.subbrand_nm,
        ms.gdiv_id,
        ms.gdiv_nm,
        ms.cat_id,
        ms.cat_nm,
        sp.div_id as sbu_id,
        sd.div_nm as sbu_nm,
        cast(null as varchar(50)) as mapping_bift,
        cast(null as varchar(50)) as mapping_bift_nm,
        p._airbyte_extracted_at

    from product p
    left join mapping_subbrand ms 
      on (coalesce(p.prlin, '') || coalesce(p.brand, '') || coalesce(p.sbra1, '')) = ms.subbrand_id
    left join product_snopix sp 
      on sp.pcode = p.pcode
    left join division_snopix sd 
      on sd.div_id = sp.div_id

),

deduplicated as (

    select
        cast(pcode as varchar(100)) as pcode,
        cast(pcode_nm as varchar(100)) as pcode_nm,
        cast(div_id as varchar(100)) as div_id,
        cast(div_nm as varchar(100)) as div_nm,
        cast(team_id as varchar(100)) as team_id,
        cast(team_nm as varchar(100)) as team_nm,
        cast(class_team_id as varchar(100)) as class_team_id,
        cast(class_team_nm as varchar(100)) as class_team_nm,
        cast(subbrand_id as varchar(100)) as subbrand_id,
        cast(subbrand_nm as varchar(100)) as subbrand_nm,
        cast(gdiv_id as varchar(100)) as gdiv_id,
        cast(gdiv_nm as varchar(100)) as gdiv_nm,
        cast(cat_id as varchar(100)) as cat_id,
        cast(cat_nm as varchar(100)) as cat_nm,
        cast(sbu_id as varchar) as sbu_id,
        cast(sbu_nm as varchar) as sbu_nm,
        cast(mapping_bift as varchar(50)) as mapping_bift,
        cast(mapping_bift_nm as varchar(50)) as mapping_bift_nm,
        row_number() over (
            partition by pcode
            order by _airbyte_extracted_at desc
        ) as rn

    from joined

),

final as (

    select
        pcode,
        pcode_nm,
        div_id,
        div_nm,
        team_id,
        team_nm,
        class_team_id,
        class_team_nm,
        subbrand_id,
        subbrand_nm,
        gdiv_id,
        gdiv_nm,
        cat_id,
        cat_nm,
        sbu_id,
        sbu_nm,
        mapping_bift,
        mapping_bift_nm

    from deduplicated
    where rn = 1

)

select * from final
