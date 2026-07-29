with source as (

    select * from {{ source('raw_ficom', 'm_distributor') }}

),

cleaned as (

    select
        cast(distributor_id as varchar(6)) as distributor_id,
        cast(distributor_nm as varchar(225)) as distributor_nm,
        cast(sbd_city as varchar(30)) as sbd_city,
        cast(region_id as varchar(3)) as region_id,
        cast(slsdiv_id as varchar(3)) as slsdiv_id,
        _airbyte_extracted_at

    from source

)

select * from cleaned
