with source as (

    select * from {{ source('raw_snopix', 'v_target_weekly_bift') }}

),

cleaned as (

    select
        cast(distributor_id as varchar(6)) as distributor_id,
        cast(distributor_id_mtx as varchar(6)) as distributor_id_mtx,
        cast(tahun as numeric(100)) as tahun,
        cast(week as numeric(100)) as week,
        cast(pcode as varchar(6)) as pcode,
        cast(target_qty as text) as target_qty,
        cast(target_value as text) as target_val,
        _airbyte_extracted_at

    from source

)

select * from cleaned
