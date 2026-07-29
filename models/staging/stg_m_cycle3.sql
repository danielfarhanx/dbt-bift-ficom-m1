with source as (

    select * from {{ source('raw_ficom', 'm_cycle3') }}

),

cleaned as (

    select
        cast(flag as varchar(1)) as flag,
        cast(week as int4) as week_op,
        cast(year as int4) as year_op,
        cast(cdate as timestamp(6)) as cdate,
        cast(period as int4) as period_op,
        _airbyte_extracted_at

    from source

)

select * from cleaned
