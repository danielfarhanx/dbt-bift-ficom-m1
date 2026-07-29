with source as (

    select * from {{ source('raw_ho_mdm', 'fregion') }}

),

cleaned as (

    select
        cast(region_id as varchar(3)) as region_id,
        cast(region_nm as varchar(25)) as region_nm,
        cast(off_id as varchar(6)) as off_id,
        cast(user_id as varchar(10)) as user_id,
        cast(upddate as date) as upddate,
        _airbyte_extracted_at

    from source

)

select * from cleaned
