with source as (

    select * from {{ source('raw_ho_mdm', 'fcshir14') }}

),

cleaned as (

    select
        cast(t11 as varchar(5)) as t11,
        cast(t12 as varchar(5)) as t12,
        cast(t13 as varchar(5)) as t13,
        cast(t14 as varchar(5)) as t14,
        cast(ket as varchar(30)) as ket,
        _airbyte_extracted_at

    from source

)

select * from cleaned
