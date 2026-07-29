{{ config(
    materialized='table',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    post_hook=[
        "alter table if exists starscm_m1_airbyte.dim_pemerintahan__dbt_backup drop constraint if exists dim_pemerintahan_pkey1",
        "alter table {{ this }} add constraint dim_pemerintahan_pkey1 primary key (subdist_id, custno)"
    ]
) }}

with customer as (

    select * from {{ ref('stg_fcustmst') }}

),

provinsi as (

    select * from {{ ref('dim_provinsi') }}

),

kabupaten as (

    select * from {{ ref('dim_kabupaten') }}

),

kecamatan as (

    select * from {{ ref('dim_kecamatan') }}

),

kelurahan as (

    select * from {{ ref('dim_kelurahan') }}

),

joined as (

    select
        c.subdist_id,
        c.custno,
        c.custname,
        c.custadd1,
        c.prop_id,
        p.ket as prop_name,
        c.kab_id,
        kab.ket as kab_name,
        c.kec_id,
        kec.ket as kec_name,
        c.kel_id,
        kel.ket as kel_name,
        c._airbyte_extracted_at

    from customer c
    left join provinsi p on c.prop_id = p.t11
    left join kabupaten kab on c.prop_id = kab.t11 and c.kab_id = kab.t12
    left join kecamatan kec on c.prop_id = kec.t11 and c.kab_id = kec.t12 and c.kec_id = kec.t13
    left join kelurahan kel on c.prop_id = kel.t11 and c.kab_id = kel.t12 and c.kec_id = kel.t13 and c.kel_id = kel.t14

),

deduplicated as (

    select
        subdist_id,
        custno,
        custname,
        custadd1,
        prop_id,
        prop_name,
        kab_id,
        kab_name,
        kec_id,
        kec_name,
        kel_id,
        kel_name,
        row_number() over (
            partition by subdist_id, custno 
            order by _airbyte_extracted_at desc
        ) as rn

    from joined

),

final as (

    select
        subdist_id,
        custno,
        custname,
        custadd1,
        prop_id,
        prop_name,
        kab_id,
        kab_name,
        kec_id,
        kec_name,
        kel_id,
        kel_name

    from deduplicated
    where rn = 1

)

select * from final
