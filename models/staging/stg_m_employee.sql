with source as (

    select * from {{ source('raw_ficom', 'm_employee') }}

),

cleaned as (

    select
        cast(emp_id as varchar(100)) as emp_id,
        cast(emp_nm as varchar(100)) as emp_nm,
        cast(emp_type_id as varchar(100)) as emp_type_id,
        cast(superior_id as varchar(100)) as superior_id,
        cast(email as varchar(100)) as email,
        cast(user_id as varchar(100)) as user_id,
        cast(upd_date as varchar(100)) as upd_date,
        cast(is_terminate as varchar(100)) as is_terminate,
        cast(terminate_date as varchar(100)) as terminate_date,
        cast(nik as varchar(100)) as nik,
        cast(full_name as varchar(100)) as full_name,
        _airbyte_extracted_at

    from source

)

select * from cleaned
