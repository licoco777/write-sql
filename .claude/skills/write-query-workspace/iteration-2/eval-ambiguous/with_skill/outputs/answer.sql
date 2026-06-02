-- 指标：M-BASIC-BB-004 129+宽带入网数（基本面/宽带）
-- 主表：069 全业务资料表 dwm_yz_tb_comm_cm_all_final
-- 标准口径（指标 SQL 权威）：
--   par_month_id 当月、is_cancel_user=0、prod_type=40、kd_desc='普通宽带'
--   mainstream_net_type=10、is_cz=1
--   COALESCE(KD_PROD_OFFER_ID,'-1') NOT LIKE '%500046067%'（剔除快捷宽带主账号）
--   rh_tc_value >= 129 AND is_rh_ykj = 1（融合 129+）
-- 分组：县分 subst_name + 划小营服 branch_name（默认划小营服，非 channel_branch_name）
-- 账期参数化：${month_id}
SELECT
    subst_name,
    branch_name,
    COUNT(DISTINCT serv_id) AS bb_129_arrive_cnt
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
GROUP BY subst_name, branch_name
;
