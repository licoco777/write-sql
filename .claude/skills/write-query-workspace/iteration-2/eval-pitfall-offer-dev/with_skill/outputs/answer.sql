-- 案例：VC-20260428-001 按销售品取月发展量明细
-- 主表：041 优惠订单表 dwm_yz_rpt_comm_ba_msdisc_final（动作事实）
-- 销售品：通过 020 销售品维表按 PROD_OFFER_CODE='YD0202-556' 反查 OFFER_ID（city_id=200）
-- 发展量动作：action_id IN (1292,6200)；排除撤单作废：subs_stat_reason NOT IN ('1200','1300')
-- 时间口径：竣工 subs_stat_date 月份 IN ('202509','202510')
-- 划小局向：041.subst_id → 018 机构维表 levs=3 取名称
-- 揽装局向：041.salestaff_subst_id → 018 机构维表 levs=3 取名称
-- 竣工时间：CASE WHEN subs_stat='301200' THEN subs_stat_date ELSE NULL END
SELECT
    a.acc_nbr,
    a.cust_name,
    a.sales_code,
    a.sales_man_name,
    CASE WHEN a.subs_stat = '301200' THEN a.subs_stat_date ELSE NULL END AS wg_date,
    hx_subst.org_name AS subst_name,
    lz_subst.org_name AS salestaff_subst_name
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
  AND date_format(a.subs_stat_date, 'yyyyMM') IN ('202509', '202510')
;
