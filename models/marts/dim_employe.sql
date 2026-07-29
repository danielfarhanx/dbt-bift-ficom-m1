{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_employe__dbt_backup drop constraint if exists dim_employe_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_employe_pkey primary key (emp_id) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_m_employee') }}

),

deduplicated as (

    select
        emp_id,
        emp_nm,
        emp_type_id,
        superior_id,
        email,
        user_id,
        upd_date,
        is_terminate,
        terminate_date,
        nik,
        full_name,
        row_number() over (
            partition by emp_id 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        emp_id,
        emp_nm,
        emp_type_id,
        superior_id,
        email,
        user_id,
        upd_date,
        is_terminate,
        terminate_date,
        nik,
        full_name

    from deduplicated
    where rn = 1

)

select * from final
