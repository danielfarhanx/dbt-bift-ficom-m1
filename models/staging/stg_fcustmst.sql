with source as (

    select * from {{ source('raw_ho_bw', 'fcustmst') }}

),

cleaned as (

    select
        cast(subdist_id as varchar(6)) as subdist_id,
        cast(custno as varchar(7)) as custno,
        cast(custname as varchar(25)) as custname,
        cast(custadd1 as varchar(25)) as custadd1,
        cast(prop_id as varchar(5)) as prop_id,
        cast(kab_id as varchar(5)) as kab_id,
        cast(kec_id as varchar(5)) as kec_id,
        cast(kel_id as varchar(5)) as kel_id,
        _airbyte_extracted_at

    from source

)

select * from cleaned
