with source as (

    select * from {{ source('raw_ficom', 'm_group_channels') }}

),

cleaned as (

    select
        cast(div_id as varchar(6)) as div_id,
        cast(group_channel_id as varchar(6)) as group_channel_id,
        cast(group_channel_nm as varchar(30)) as group_channel_nm,
        cast(channel_id as varchar(10)) as channel_id,
        cast(channel_nm as varchar(50)) as channel_nm,
        _airbyte_extracted_at

    from source

)

select * from cleaned
