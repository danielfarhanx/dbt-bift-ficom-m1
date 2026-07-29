with source as (

    select * from {{ source('raw_ho_mdm', 'fcshir12') }}

),

cleaned as (

    select
        cast(t11 as varchar(5)) as t11,
        cast(t12 as varchar(5)) as t12,
        cast(ket as varchar(30)) as ket,
        _airbyte_extracted_at

    from source

)

select * from cleaned
