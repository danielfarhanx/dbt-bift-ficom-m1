{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_emp_mkt_sales__dbt_backup drop constraint if exists dim_emp_mkt_sales_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_emp_mkt_sales_pkey primary key (m_id, m_id_map_sales) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_emp_mkt_sales') }}

),

deduplicated as (

    select
        m_id,
        m_id_map_sales,
        row_number() over (
            partition by m_id, m_id_map_sales
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        m_id,
        m_id_map_sales

    from deduplicated
    where rn = 1

)

select * from final
