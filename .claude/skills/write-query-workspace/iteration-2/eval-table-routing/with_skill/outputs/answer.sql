-- 路由：双线 / 互联网专线 / 组网专线 → 069 全业务资料表（prod_type2 IN (60,70,71)）
-- 主表：069 dwm_yz_tb_comm_cm_all_final（近半年账期优先日表）
--   60 = 互联网专线，70/71 = 组网专线
--   双线速率主路径在 069 时直接取 069.speed_value
-- 补表：033 双线全量清单 ads_yz_sx_qlyz_list 取月租 yz_cs
--   按 acc_nbr + par_month_id 关联；同号同月可能多行，按 load_date 取最新一行去重
-- 账期：202605 当月明细
SELECT
    a.par_month_id,
    a.serv_id,
    a.acc_nbr,
    a.prod_type2,
    CASE
        WHEN a.prod_type2 = 60 THEN '互联网专线'
        WHEN a.prod_type2 IN (70, 71) THEN '组网专线'
    END AS prod_type2_desc,
    a.speed_value,
    sx.yz_cs AS month_fee
FROM dwm_yz_tb_comm_cm_all_final a
LEFT JOIN (
    SELECT acc_nbr, par_month_id, yz_cs
    FROM (
        SELECT
            acc_nbr,
            par_month_id,
            yz_cs,
            ROW_NUMBER() OVER (
                PARTITION BY acc_nbr, par_month_id
                ORDER BY load_date DESC
            ) AS rn
        FROM ads_yz_sx_qlyz_list
        WHERE par_month_id = 202605
    ) t
    WHERE rn = 1
) sx
    ON a.acc_nbr = sx.acc_nbr
   AND a.par_month_id = sx.par_month_id
WHERE a.par_month_id = 202605
  AND a.prod_type2 IN (60, 70, 71)
  AND a.is_cancel_user = 0
;
