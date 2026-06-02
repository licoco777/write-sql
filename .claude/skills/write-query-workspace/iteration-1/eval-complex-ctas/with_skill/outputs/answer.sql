-- 复杂场景 CTAS 流水线：按年（23/24/25）从用户科目维表匹配 SR 科目税后收入，按维度汇总
-- 主表：dwm_srhx_src_income_list_mon（048 全量科目级收入）
-- 维表：ads_yz_zqb_xc_due_income_code_dim_list（用户已提供，三列年码）
-- 模板：verified-cases/VC-20260520-001
-- 营服默认划小营服 branch_name，不用揽装营服 channel_branch_name
-- 度量：sum(fee_all)（税后确认收入）

-- 步骤1：23 年明细
drop table if exists tmp_ads_yz_zqb_xc_code_cust_sr_dwb_23 purge;
create table tmp_ads_yz_zqb_xc_code_cust_sr_dwb_23
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    a.par_month_id,
    a.subst_id,
    a.subst_name,
    a.branch_id,
    a.branch_name,
    a.cust_nbr,
    a.cust_name,
    a.prod_id,
    a.prod_name,
    a.sales_id,
    a.sales_code,
    a.sales_name,
    a.contract_flag,
    a.is_filter,
    a.due_income_code,
    a.fee_all
from dwm_srhx_src_income_list_mon a
join ads_yz_zqb_xc_due_income_code_dim_list b
  on a.due_income_code = b.due_income_code23
where a.par_month_id >= 202301
  and a.par_month_id <= 202312
  and a.contract_flag = 1
  and a.is_filter = 0;
-- select count(*) from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_23;

-- 步骤2：24 年明细
drop table if exists tmp_ads_yz_zqb_xc_code_cust_sr_dwb_24 purge;
create table tmp_ads_yz_zqb_xc_code_cust_sr_dwb_24
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    a.par_month_id,
    a.subst_id,
    a.subst_name,
    a.branch_id,
    a.branch_name,
    a.cust_nbr,
    a.cust_name,
    a.prod_id,
    a.prod_name,
    a.sales_id,
    a.sales_code,
    a.sales_name,
    a.contract_flag,
    a.is_filter,
    a.due_income_code,
    a.fee_all
from dwm_srhx_src_income_list_mon a
join ads_yz_zqb_xc_due_income_code_dim_list b
  on a.due_income_code = b.due_income_code24
where a.par_month_id >= 202401
  and a.par_month_id <= 202412
  and a.contract_flag = 1
  and a.is_filter = 0;
-- select count(*) from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_24;

-- 步骤3：25 年明细
drop table if exists tmp_ads_yz_zqb_xc_code_cust_sr_dwb_25 purge;
create table tmp_ads_yz_zqb_xc_code_cust_sr_dwb_25
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    a.par_month_id,
    a.subst_id,
    a.subst_name,
    a.branch_id,
    a.branch_name,
    a.cust_nbr,
    a.cust_name,
    a.prod_id,
    a.prod_name,
    a.sales_id,
    a.sales_code,
    a.sales_name,
    a.contract_flag,
    a.is_filter,
    a.due_income_code,
    a.fee_all
from dwm_srhx_src_income_list_mon a
join ads_yz_zqb_xc_due_income_code_dim_list b
  on a.due_income_code = b.due_income_code25
where a.par_month_id >= 202501
  and a.par_month_id <= 202512
  and a.contract_flag = 1
  and a.is_filter = 0;
-- select count(*) from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_25;

-- 步骤4：三年合并
drop table if exists tmp_ads_yz_zqb_xc_code_cust_sr_dwb_union purge;
create table tmp_ads_yz_zqb_xc_code_cust_sr_dwb_union
row format delimited fields terminated by '\u0001'
stored as orc tblproperties('orc.compression'='snappy') as
select
    par_month_id, subst_id, subst_name, branch_id, branch_name,
    cust_nbr, cust_name, prod_id, prod_name,
    sales_id, sales_code, sales_name,
    contract_flag, is_filter, due_income_code, fee_all
from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_23
union all
select
    par_month_id, subst_id, subst_name, branch_id, branch_name,
    cust_nbr, cust_name, prod_id, prod_name,
    sales_id, sales_code, sales_name,
    contract_flag, is_filter, due_income_code, fee_all
from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_24
union all
select
    par_month_id, subst_id, subst_name, branch_id, branch_name,
    cust_nbr, cust_name, prod_id, prod_name,
    sales_id, sales_code, sales_name,
    contract_flag, is_filter, due_income_code, fee_all
from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_25;
-- select count(*) from tmp_ads_yz_zqb_xc_code_cust_sr_dwb_union;

-- 步骤5：按年 + 局向/营服/产权客户/产品/揽装人汇总
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
