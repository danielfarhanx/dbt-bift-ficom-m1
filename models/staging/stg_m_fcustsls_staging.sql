{%- set source_table = 'm_fcustsls_staging' -%}
{%- if execute -%}
  {%- set check_query -%}
    select count(*) from information_schema.tables 
    where table_schema = 'starscm_m1' and table_name = 'dim_fcustsls_staging'
  {%- endset -%}
  {%- set results = run_query(check_query) -%}
  {%- if results and results.rows[0][0] > 0 -%}
     {%- if not flags.FULL_REFRESH -%}
       {%- set source_table = 'v_fcustsls_staging_last_2_period' -%}
     {%- endif -%}
  {%- endif -%}
{%- endif -%}

with source as (

    select * from {{ source('raw_ficom', source_table) }}

),

cleaned as (

    select
        cast(distributor_id as varchar(6)) as distributor_id,
        cast(cust_id as varchar) as cust_id,
        cast(sls_id as varchar) as sls_id,
        cast(periode as numeric) as periode,
        cast(tahun as numeric) as tahun,
        cast(upd_date as timestamptz) as upd_date,
        cast(nobrs as numeric) as nobrs,
        cast(hsenin as varchar) as hsenin,
        cast(hselasa as varchar) as hselasa,
        cast(hrabu as varchar) as hrabu,
        cast(hkamis as varchar) as hkamis,
        cast(hjumat as varchar) as hjumat,
        cast(hsabtu as varchar) as hsabtu,
        cast(hminggu as varchar) as hminggu,
        cast(visit1 as varchar) as visit1,
        cast(visit2 as varchar) as visit2,
        cast(visit3 as varchar) as visit3,
        cast(visit4 as varchar) as visit4,
        cast(route as numeric) as route,
        cast(slimit as numeric) as slimit,
        cast(salesforce_id as varchar) as salesforce_id,
        cast(channel_id as varchar) as channel_id,
        cast(flag_aktif as varchar) as flag_aktif,
        cast(team_id as varchar(10485760)) as team_id,
        cast(group_outlet as varchar(10485760)) as group_outlet,
        _airbyte_extracted_at

    from source

)

select * from cleaned
