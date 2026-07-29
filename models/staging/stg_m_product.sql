{{ config(
    materialized='ephemeral'
) }}

with source as (

    select * from {{ source('raw_ficom', 'm_product') }}

),

cleaned as (

    select
        cast(pcode as varchar(100)) as pcode,
        cast(pcode_nm as varchar(100)) as pcode_nm,
        cast(prlin as varchar) as prlin,
        cast(brand as varchar) as brand,
        cast(sbra1 as varchar) as sbra1,
        cast(sbra2 as varchar) as sbra2,
        cast(unit1 as varchar) as unit1,
        cast(unit2 as varchar) as unit2,
        cast(unit3 as varchar) as unit3,
        cast(is_focus as numeric) as is_focus,
        cast(pc_parent as varchar) as pc_parent,
        cast(conv_unit2 as numeric) as conv_unit2,
        cast(conv_unit3 as numeric) as conv_unit3,
        cast(sell_price1 as numeric) as sell_price1,
        cast(sell_price2 as numeric) as sell_price2,
        cast(sell_price3 as numeric) as sell_price3,
        _airbyte_extracted_at

    from source

)

select * from cleaned
