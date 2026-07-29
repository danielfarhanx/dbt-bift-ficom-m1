{{ config(
    materialized='incremental',
    schema='starscm_m1_airbyte',
    tags=['main-dim'],
    pre_hook=["delete from {{ this }}"],
    post_hook=[
        "{% if not is_incremental() %} alter table if exists starscm_m1_airbyte.dim_product_pack__dbt_backup drop constraint if exists dim_product_pack_pk {% else %} select 1 {% endif %}",
        "{% if not is_incremental() %} alter table {{ this }} add constraint dim_product_pack_pk primary key (pcode) {% else %} select 1 {% endif %}"
    ]
) }}

with staging as (

    select * from {{ ref('stg_fmaster') }}

),

deduplicated as (

    select
        pcode, pcodename, cpro, matgr, prlin, brand, sbra1, prkat, sbra2, flavr, packs, packt, princ, suppno, rptname1, rptname2, rptname3, sortno, unit1, unit2, unit3, convunit2, convunit3, weight1, weight2, weight3, buyprice1, buyprice2, buyprice3, sellprice1, sellprice2, sellprice3, mweekno, lweekno, pbm, pbmjual, plines, minstock, xminstock, sftstock, xsftstock, flagaktif, flagmain, flagnew, flagbatch, jatah, tipeob, grins, rpp, pcparent, hpp, data01, data02, data03, data04, data05, data06, data07, data08, data09, data10, data11, data12, data13, data14, datecreate, usercreate, updatedate, userupdate, timecreate, timeupdate,
        row_number() over (
            partition by pcode 
            order by _airbyte_extracted_at desc
        ) as rn

    from staging

),

final as (

    select
        pcode, pcodename, cpro, matgr, prlin, brand, sbra1, prkat, sbra2, flavr, packs, packt, princ, suppno, rptname1, rptname2, rptname3, sortno, unit1, unit2, unit3, convunit2, convunit3, weight1, weight2, weight3, buyprice1, buyprice2, buyprice3, sellprice1, sellprice2, sellprice3, mweekno, lweekno, pbm, pbmjual, plines, minstock, xminstock, sftstock, xsftstock, flagaktif, flagmain, flagnew, flagbatch, jatah, tipeob, grins, rpp, pcparent, hpp, data01, data02, data03, data04, data05, data06, data07, data08, data09, data10, data11, data12, data13, data14, datecreate, usercreate, updatedate, userupdate, timecreate, timeupdate

    from deduplicated
    where rn = 1

)

select * from final
