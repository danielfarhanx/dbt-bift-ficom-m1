with source as (

    select * from {{ source('raw_ficom', 'm_emp_dist') }}

),

cleaned as (

    select
        cast(emp_id as varchar(100)) as emp_id,
        cast(distributor_id as varchar(100)) as distributor_id,
        _airbyte_extracted_at

    from source

)

select * from cleaned
