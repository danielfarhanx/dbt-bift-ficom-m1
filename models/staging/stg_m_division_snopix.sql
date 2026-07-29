{{ config(
    materialized='ephemeral'
) }}

with source as (

    select * from {{ source('raw_snopix', 'm_division') }}

),

cleaned as (

    select
        cast(div_id as varchar) as div_id,
        cast(div_nm as varchar) as div_nm,
        _airbyte_extracted_at

    from source

)

select * from cleaned
