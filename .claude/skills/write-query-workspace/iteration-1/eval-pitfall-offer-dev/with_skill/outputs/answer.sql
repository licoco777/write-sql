-- 按销售品编码 YD0202-556 取 202509/202510 月发展量明细
-- 主表：dwm_yz_rpt_comm_ba_msdisc_final（041 优惠订单表）
-- 关键口径（VC-20260428-001）：
--   动作：action_id IN (1292, 6200)  -- 1292 订购、6200 销售品互换
--   排除撤单作废：COALESCE(subs_stat_reason,'-1') NOT IN ('1200','1300')
--   竣工默认输出标记列与竣工时间，不进 WHERE：CASE WHEN subs_stat='301200' ...
-- 销售品编码 -> ID：补 020 销售品维表 dws_offer，必须 city_id=200
-- 划小局向名称：041.subst_id -> 018 dwd_yz_dim_org（levs=3）
-- 揽装局向名称：041.salestaff_subst_id -> 018 dwd_yz_dim_org（levs=3）
SELECT
    a.acc_nbr                                                AS acc_nbr,
    a.cust_name                                              AS cust_name,
    a.sales_code                                             AS sales_code,
    a.sales_man_name                                         AS sales_man_name,
    CASE WHEN a.subs_stat = '301200' THEN a.subs_stat_date END AS jg_date,
    CASE WHEN a.subs_stat = '301200' THEN 1 ELSE 0 END       AS is_jg,
    f.prod_offer_code                                        AS prod_offer_code,
    f.offer_name                                             AS offer_name,
    a.subst_id                                               AS subst_id,
    hx_subst.org_name                                        AS subst_name,
    a.salestaff_subst_id                                     AS salestaff_subst_id,
    lz_subst.org_name                                        AS salestaff_subst_name,
    date_format(a.subs_stat_date, 'yyyyMM')                  AS dev_month
FROM dwm_yz_rpt_comm_ba_msdisc_final a
JOIN dws_crm_cfguse.dws_offer f
    ON a.prod_offer_id = f.offer_id
   AND f.city_id = 200
   AND f.prod_offer_code = 'YD0202-556'
LEFT JOIN dwd_yz_dim_org hx_subst
    ON a.subst_id = hx_subst.org_id
   AND hx_subst.levs = 3
LEFT JOIN dwd_yz_dim_org lz_subst
    ON a.salestaff_subst_id = lz_subst.org_id
   AND lz_subst.levs = 3
WHERE a.action_id IN (1292, 6200)
  AND COALESCE(a.subs_stat_reason, '-1') NOT IN ('1200', '1300')
  AND date_format(a.subs_stat_date, 'yyyyMM') IN ('202509', '202510');
