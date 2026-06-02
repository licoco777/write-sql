-- 指标：主宽到达数（M-BASIC-BB-003）
-- 主表：069 全业务资料表（生产现网日表 dwm_yz_tb_comm_cm_all_final）
-- 口径：账期 202605，未拆机 + 普通宽带 + 当月出账
SELECT COUNT(DISTINCT serv_id) AS main_broadband_arrive_cnt
FROM dwm_yz_tb_comm_cm_all_final
WHERE par_month_id = 202605
  AND is_cancel_user = 0
  AND prod_type = 40
  AND kd_desc = '普通宽带'
  AND is_cz = 1
;
