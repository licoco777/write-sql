-- 种子 serv_id（ads_zqzw_chaiji_sxf_20260517）+ 当月 202605 状态（含中文）+ 上月 202604 销售品在档（YD0202-556）
-- 模板：verified-cases/VC-20260520-002
-- 主表与口径：
--   当月状态：dwm_yz_tb_comm_cm_all_final（069），par_month_id=202605，字段 state（码值）
--   状态中文名：dws_crm_cfguse.dws_attr_value，attr_id='4000000201'，attr_value=cast(state as string) -> attr_value_name
--   上月销售品在档：ads_yz_rpt_comm_cm_msdisc_final（014），par_month_id=202604 + prod_offer_code='YD0202-556'
--   014 一对多：先按 serv_id 聚合后再 JOIN，避免放大
WITH last_month_offer AS (
    SELECT
        serv_id,
        MAX(prod_offer_name) AS prod_offer_name
    FROM ads_yz_rpt_comm_cm_msdisc_final
    WHERE par_month_id = 202604
      AND prod_offer_code = 'YD0202-556'
    GROUP BY serv_id
)
SELECT
    s.serv_id                                                AS serv_id,
    cm.acc_nbr                                               AS acc_nbr,
    cm.state                                                 AS state_code,
    av.attr_value_name                                       AS state_name,
    CASE WHEN o.serv_id IS NOT NULL THEN 1 ELSE 0 END        AS has_offer_last_month,
    o.prod_offer_name                                        AS prod_offer_name
FROM ads_zqzw_chaiji_sxf_20260517 s
LEFT JOIN dwm_yz_tb_comm_cm_all_final cm
    ON s.serv_id = cm.serv_id
   AND cm.par_month_id = 202605
LEFT JOIN dws_crm_cfguse.dws_attr_value av
    ON av.attr_id = '4000000201'
   AND av.attr_value = CAST(cm.state AS string)
LEFT JOIN last_month_offer o
    ON s.serv_id = o.serv_id;
