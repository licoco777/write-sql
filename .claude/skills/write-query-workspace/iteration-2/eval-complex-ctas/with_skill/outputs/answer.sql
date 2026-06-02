-- 案例：VC-20260520-001 按年科目清单匹配科目级税后收入（CTAS 流水线）
-- 主表：048 全量科目级收入 dwm_srhx_src_income_list_mon
-- 维表：用户已有 ads_yz_zqb_xc_due_income_code_dim_list（三列：due_income_code23/24/25）
-- 度量：sum(fee_all)（税后收入）；分区 par_month_id；标准过滤：contract_flag=1（划小）+ is_filter=0（非主营科目剔除）
-- 营服：默认划小营服 branch_name；不使用 channel_branch_name

-- 步骤 2：2023 年科目匹配明细
drop table if exists tmp_ads_yz_zqb_xc_code_cust_sr_dwb_23 purge;
create table tmp_ads_yz_zqb_xc_code_cust_sr_dwb_23
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select a.*
from dwm_srhx_src_income_list_mon a
join ads_yz_zqb_xc_due_income_code_dim_list b
  on a.due_income_code = b.due_income_code23
where a.par_month_id >= 202301
  and a.par_month_id <= 202312
  and a.contract_flag = 1
  and a.is_filter = 0;
-- select count(*) from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_23;

-- 步骤 3：2024 年科目匹配明细
drop table if exists tmp_ads_yz_zqb_xc_code_cust_sr_dwb_24 purge;
create table tmp_ads_yz_zqb_xc_code_cust_sr_dwb_24
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select a.*
from dwm_srhx_src_income_list_mon a
join ads_yz_zqb_xc_due_income_code_dim_list b
  on a.due_income_code = b.due_income_code24
where a.par_month_id >= 202401
  and a.par_month_id <= 202412
  and a.contract_flag = 1
  and a.is_filter = 0;
-- select count(*) from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_24;

-- 步骤 4：2025 年科目匹配明细
drop table if exists tmp_ads_yz_zqb_xc_code_cust_sr_dwb_25 purge;
create table tmp_ads_yz_zqb_xc_code_cust_sr_dwb_25
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select a.*
from dwm_srhx_src_income_list_mon a
join ads_yz_zqb_xc_due_income_code_dim_list b
  on a.due_income_code = b.due_income_code25
where a.par_month_id >= 202501
  and a.par_month_id <= 202512
  and a.contract_flag = 1
  and a.is_filter = 0;
-- select count(*) from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_25;

-- 步骤 5：三年明细合并
drop table if exists tmp_ads_yz_zqb_xc_code_cust_sr_dwb_union purge;
create table tmp_ads_yz_zqb_xc_code_cust_sr_dwb_union
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select * from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_23
union all
select * from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_24
union all
select * from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_25;
-- select count(*) from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_union;

-- 步骤 6：按年 + 局向 + 营服 + 产权客户 + 产品 + 揽装人汇总确认收入（税后）
drop table if exists ads_yz_zqb_xc_code_cust_sr_dwb purge;
create table ads_yz_zqb_xc_code_cust_sr_dwb
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    200 as city_id,
    substr(cast(par_month_id as string), 1, 4) as year_id,
    subst_id,
    subst_name,
    branch_id,
    branch_name,
    cust_nbr,
    cust_name,
    prod_id,
    prod_name,
    sales_id,
    sales_code,
    sales_name,
    contract_flag,
    is_filter,
    sum(fee_all) as sh
from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_union
group by
    substr(cast(par_month_id as string), 1, 4),
    subst_id,
    subst_name,
    branch_id,
    branch_name,
    cust_nbr,
    cust_name,
    prod_id,
    prod_name,
    sales_id,
    sales_code,
    sales_name,
    contract_flag,
    is_filter;
-- select count(*) from ads_yz_zqb_xc_code_cust_sr_dwb;
-- select * from ads_yz_zqb_xc_code_cust_sr_dwb;
