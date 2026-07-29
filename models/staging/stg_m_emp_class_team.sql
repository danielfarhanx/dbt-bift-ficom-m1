with source as (

    select * from {{ source('raw_ficom', 'm_emp_class_team') }}

),

cleaned as (

    select
        cast(m_id as varchar(1000)) as m_id,
        cast(class_team_id as varchar(1000)) as class_team_id,
        _airbyte_extracted_at

    from source

)

select * from cleaned
