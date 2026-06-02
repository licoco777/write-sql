-- 标准指标命中：M-BASIC-BB-004 129+宽带入网数
-- 主表：dwm_yz_tb_comm_cm_all_final（069 全业务资料表，日表）
-- 技术口径（来源：metrics/基本面/M-BASIC-BB-004_129+宽带入网数.md）：
--   par_month_id = ${month_id}
--   is_cancel_user = 0
--   prod_type = 40
--   kd_desc = '普通宽带'
--   mainstream_net_type = 10
--   is_cz = 1
--   COALESCE(kd_prod_offer_id,'-1') NOT LIKE '%500046067%'  -- 剔除快捷宽带主账号
--   rh_tc_value >= 129 AND is_rh_ykj = 1                     -- 融合 129+
-- 用户未给账期，留 ${month_id} 占位
-- 县分=subst_name（划小分局），营服=branch_name（划小营服，默认非揽装营服）
SELECT
    par_month_id,
    subst_name,
    branch_name,
    COUNT(DISTINCT serv_id) AS bb_129_cnt
FROM dwm_yz_tb_comm_cm_all_final
WHERE par_month_id = ${month_id}
  AND is_cancel_user = 0
  AND prod_type = 40
  AND kd_desc = '普通宽带'
  AND mainstream_net_type = 10
  AND is_cz = 1
  AND COALESCE(kd_prod_offer_id, '-1') NOT LIKE '%500046067%'
  AND rh_tc_value >= 129
  AND is_rh_ykj = 1
GROUP BY par_month_id, subst_name, branch_name;
