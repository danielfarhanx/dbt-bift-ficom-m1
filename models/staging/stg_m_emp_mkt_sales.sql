with source as (

    select * from {{ source('raw_ficom', 'm_emp_mkt_sales') }}

),

cleaned as (

    select
        cast(m_id as varchar(1000)) as m_id,
        cast(m_id_map_sales as varchar(1000)) as m_id_map_sales,
        _airbyte_extracted_at

    from source

)

select * from cleaned
