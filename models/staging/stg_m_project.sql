with source as (

    select * from {{ source('raw_ficom', 'm_project') }}

),

cleaned as (

    select
        cast(project_id as varchar(50)) as project_id,
        cast(project_nm as varchar(100)) as project_nm,
        _airbyte_extracted_at

    from source

)

select * from cleaned
