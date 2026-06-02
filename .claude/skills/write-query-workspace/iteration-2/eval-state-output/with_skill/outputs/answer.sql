-- 案例：VC-20260520-002 种子 serv_id 匹配当月 state 与上月销售品在档
-- 种子表：ads_zqzw_chaiji_sxf_20260517（驱动 LEFT JOIN，保证每个 serv_id 一行）
-- 当月状态：069 全业务资料表 dwm_yz_tb_comm_cm_all_final，par_month_id=202605，取 state（码值 + 中文）
-- 状态中文：字典 dws_crm_cfguse.dws_attr_value，attr_id='4000000201'，attr_value=cast(state as string) → attr_value_name
-- 上月销售品在档：014 优惠资料表 ads_yz_rpt_comm_cm_msdisc_final，par_month_id=202604，prod_offer_code='YD0202-556'
--   先按 serv_id 聚合（max(prod_offer_name)）防止一对多放大
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
    s.serv_id,
    cm.state AS state_code,
    av.attr_value_name AS state_name,
    CASE WHEN o.serv_id IS NOT NULL THEN 1 ELSE 0 END AS has_offer_last_month,
    o.prod_offer_name
FROM ads_zqzw_chaiji_sxf_20260517 s
LEFT JOIN dwm_yz_tb_comm_cm_all_final cm
    ON s.serv_id = cm.serv_id
   AND cm.par_month_id = 202605
LEFT JOIN dws_crm_cfguse.dws_attr_value av
    ON av.attr_id = '4000000201'
   AND av.attr_value = cast(cm.state AS string)
LEFT JOIN last_month_offer o
    ON s.serv_id = o.serv_id
;
