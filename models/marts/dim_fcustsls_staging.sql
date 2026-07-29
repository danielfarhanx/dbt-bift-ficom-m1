{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['fcustsls_staging'],
    pre_hook=[
        "{% if is_incremental() %} delete from {{ this }} where (tahun, periode) in (select distinct tahun, periode from {{ source('raw_ficom', 'v_fcustsls_staging_last_2_period') }}) {% endif %}"
    ],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_fcustsls_staging__dbt_backup drop constraint if exists pk_fcustsls_n {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} drop index if exists starscm_m1.idx_dim_fcustsls_staging_tahun_periode {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint pk_fcustsls_n primary key (distributor_id, cust_id, sls_id, periode, tahun) {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} create index if not exists idx_dim_fcustsls_staging_tahun_periode on {{ this }} (tahun, periode) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_fcustsls_staging') }}

),

deduplicated as (

    select
        distributor_id,
        cust_id,
        sls_id,
        periode,
        tahun,
        upd_date,
        nobrs,
        hsenin,
        hselasa,
        hrabu,
        hkamis,
        hjumat,
        hsabtu,
        hminggu,
        visit1,
        visit2,
        visit3,
        visit4,
        route,
        slimit,
        salesforce_id,
        channel_id,
        flag_aktif,
        team_id,
        group_outlet,
        row_number() over (
            partition by distributor_id, cust_id, sls_id, periode, tahun
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        distributor_id,
        cust_id,
        sls_id,
        periode,
        tahun,
        upd_date,
        nobrs,
        hsenin,
        hselasa,
        hrabu,
        hkamis,
        hjumat,
        hsabtu,
        hminggu,
        visit1,
        visit2,
        visit3,
        visit4,
        route,
        slimit,
        salesforce_id,
        channel_id,
        flag_aktif,
        team_id,
        group_outlet

    from deduplicated
    where rn = 1

)

select * from final
