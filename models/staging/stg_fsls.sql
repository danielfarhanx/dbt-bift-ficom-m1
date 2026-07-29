with source as (

    select * from {{ source('raw_ho_bw', 'fsls') }}

),

cleaned as (

    select
        cast(subdist_id as varchar(6)) as subdist_id,
        cast(slsno as varchar(6)) as slsno,
        cast(rayon_id as varchar(6)) as rayon_id,
        cast(slsname as varchar(25)) as slsname,
        cast(slsadd1 as varchar(25)) as slsadd1,
        cast(slsadd2 as varchar(25)) as slsadd2,
        cast(slscity as varchar(20)) as slscity,
        cast(team_id as varchar(4)) as team_id,
        cast(workdate as timestamp) as workdate,
        cast(oprtype as varchar(1)) as oprtype,
        cast(transdate as timestamp) as transdate,
        cast(off_id as varchar(6)) as off_id,
        cast(educ as varchar(10)) as educ,
        cast(birth as timestamp) as birth,
        cast(phone as varchar(15)) as phone,
        cast(hp as varchar(15)) as hp,
        cast(email as varchar(20)) as email,
        cast(slsfc_id as varchar(3)) as slsfc_id,
        cast(flag_block as varchar(1)) as flag_block,
        cast(region_id as varchar(3)) as region_id,
        cast(area_id as varchar(3)) as area_id,
        cast(slsdiv_id as varchar(3)) as slsdiv_id,
        cast(user_id as varchar(10)) as user_id,
        cast(upddate as timestamp) as upddate,
        cast(brth_place as varchar(15)) as brth_place,
        cast(sex as varchar(1)) as sex,
        cast(sls_sts as varchar(1)) as sls_sts,
        cast(sls_bank as varchar(30)) as sls_bank,
        cast(sls_relg as varchar(1)) as sls_relg,
        _airbyte_extracted_at

    from source

)

select * from cleaned
