{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_channels__dbt_backup drop constraint if exists dim_channels_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_channels_pkey primary key (channel_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_group_channels') }}

),

deduplicated as (

    select
        channel_id,
        channel_nm,
        group_channel_nm as channel_group,
        row_number() over (
            partition by channel_id
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        channel_id,
        channel_nm,
        channel_group

    from deduplicated
    where rn = 1

)

select * from final
