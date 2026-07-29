{{ config(
    materialized='incremental',
    schema='starscm_m1',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1.dim_employe_help__dbt_backup drop constraint if exists dim_employe_help_pkey {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_employe_help_pkey primary key (emp_id, distributor_id, div_id) {% else %} select 1 {% endif %}"
    ]
) }}

with emp_dist as (

    select * from {{ ref('stg_m_emp_dist') }}

),

employee as (

    select * from {{ ref('stg_m_employee') }}

),

emp_div as (

    select * from {{ ref('stg_m_emp_div') }}

),

joined as (

    select
        cast(ed.emp_id as varchar(100)) as emp_id,
        cast(ed.distributor_id as varchar(100)) as distributor_id,
        cast(edv.div_id as varchar(100)) as div_id,
        cast(edv.div_nm as varchar(100)) as div_nm,
        cast(edv.user_nm as varchar(100)) as user_nm,
        cast(edv.jabatan as varchar(100)) as jabatan,
        cast(e.emp_type_id as varchar(100)) as emp_type_id,
        greatest(ed._airbyte_extracted_at, e._airbyte_extracted_at, edv._airbyte_extracted_at) as last_extracted_at

    from emp_dist ed
    inner join employee e on ed.emp_id = e.emp_id
    inner join emp_div edv on e.emp_id = edv.user_id

),

deduplicated as (

    select
        emp_id,
        distributor_id,
        div_id,
        div_nm,
        user_nm,
        jabatan,
        emp_type_id,
        row_number() over (
            partition by emp_id, distributor_id, div_id
            order by last_extracted_at desc
        ) as rn

    from joined

),

final as (

    select
        emp_id,
        distributor_id,
        div_id,
        div_nm,
        user_nm,
        jabatan,
        emp_type_id

    from deduplicated
    where rn = 1

)

select * from final
