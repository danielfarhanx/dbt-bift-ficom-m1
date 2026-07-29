with source as (

    select * from {{ source('raw_ficom', 'm_emp_div') }}

),

cleaned as (

    select
        cast(div_id as varchar(100)) as div_id,
        cast(div_nm as varchar(100)) as div_nm,
        cast(jabatan as varchar(100)) as jabatan,
        cast(user_id as varchar(100)) as user_id,
        cast(user_nm as varchar(100)) as user_nm,
        _airbyte_extracted_at

    from source

)

select * from cleaned
