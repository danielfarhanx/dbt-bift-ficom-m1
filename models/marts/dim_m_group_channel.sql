{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_m_group_channel__dbt_backup drop constraint if exists dim_m_group_channel_pk {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_m_group_channel_pk primary key (div_id, group_channel_id, channel_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_group_channels') }}

),

deduplicated as (

    select
        div_id,
        group_channel_id,
        group_channel_nm,
        channel_id,
        channel_nm,
        row_number() over (
            partition by div_id, group_channel_id, channel_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        div_id,
        group_channel_id,
        group_channel_nm,
        channel_id,
        channel_nm

    from deduplicated
    where rn = 1

)

select * from final
