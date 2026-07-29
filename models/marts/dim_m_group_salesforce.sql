{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_m_group_salesforce__dbt_backup drop constraint if exists dim_m_group_salesforce_pk {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_m_group_salesforce_pk primary key (div_id, gsalesforce_id, salesforce_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_mapping_group_salesforce') }}

),

deduplicated as (

    select
        div_id,
        div_nm,
        gsalesforce_id,
        gsalesforce_nm,
        salesforce_id,
        salesforce_nm,
        row_number() over (
            partition by div_id, gsalesforce_id, salesforce_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        div_id,
        div_nm,
        gsalesforce_id,
        gsalesforce_nm,
        salesforce_id,
        salesforce_nm

    from deduplicated
    where rn = 1

)

select * from final
