with source as (

    select * from {{ source('raw_snopix', 'm_product') }}

),

cleaned as (

    select
        cast(pcode as varchar(10)) as pcode,
        cast(pcodename as varchar(100)) as pcodename,
        cast(div_id as varchar(3)) as div_id,
        cast(brand_id as varchar(3)) as brand_id,
        cast(subbrand_id as varchar(3)) as subbrand_id,
        cast(parent_id as varchar(10)) as parent_id,
        cast(pcode_map as varchar(10)) as pcode_map,
        cast(is_active as numeric) as is_active,
        cast(user_id as varchar(15)) as user_id,
        cast(upd_date as timestamp) as upd_date,
        cast(flag as varchar(25)) as flag,
        cast(ct_id as varchar(6)) as ct_id,
        cast(kubikasi as numeric) as kubikasi,
        cast(tonase as numeric) as tonase,
        cast(pallet as numeric) as pallet,
        cast(shelf_life as numeric) as shelf_life,
        cast(sls_div as varchar(2)) as sls_div,
        cast(flag_season as numeric) as flag_season,
        cast(mar_type_id as varchar) as mar_type_id,
        cast(flag_wip as varchar) as flag_wip,
        _airbyte_extracted_at

    from source

)

select * from cleaned
