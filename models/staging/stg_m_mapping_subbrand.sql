{{ config(
    materialized='ephemeral'
) }}

with source as (

    select * from {{ source('raw_ficom', 'm_mapping_subbrand') }}

),

cleaned as (

    select
        cast(cat_id as varchar(100)) as cat_id,
        cast(cat_nm as varchar(100)) as cat_nm,
        cast(div_id as varchar(100)) as div_id,
        cast(div_nm as varchar(100)) as div_nm,
        cast(gdiv_id as varchar(100)) as gdiv_id,
        cast(gdiv_nm as varchar(100)) as gdiv_nm,
        cast(team_id as varchar(100)) as team_id,
        cast(team_nm as varchar(100)) as team_nm,
        cast(subbrand_id as varchar(100)) as subbrand_id,
        cast(subbrand_nm as varchar(100)) as subbrand_nm,
        cast(class_team_id as varchar(100)) as class_team_id,
        cast(class_team_nm as varchar(100)) as class_team_nm,
        _airbyte_extracted_at

    from source

)

select * from cleaned
