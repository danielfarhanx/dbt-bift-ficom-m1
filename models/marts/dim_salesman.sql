{{ config(
    materialized='incremental',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1_airbyte.dim_salesman__dbt_backup drop constraint if exists dim_salesman_pk {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_salesman_pk primary key (subdist_id, slsno) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_fsls') }}

),

deduplicated as (

    select
        subdist_id, slsno, rayon_id, slsname, slsadd1, slsadd2, slscity, team_id, workdate, oprtype, transdate, off_id, educ, birth, phone, hp, email, slsfc_id, flag_block, region_id, area_id, slsdiv_id, user_id, upddate, brth_place, sex, sls_sts, sls_bank, sls_relg,
        row_number() over (
            partition by subdist_id, slsno 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        subdist_id, slsno, rayon_id, slsname, slsadd1, slsadd2, slscity, team_id, workdate, oprtype, transdate, off_id, educ, birth, phone, hp, email, slsfc_id, flag_block, region_id, area_id, slsdiv_id, user_id, upddate, brth_place, sex, sls_sts, sls_bank, sls_relg

    from deduplicated
    where rn = 1

)

select * from final
