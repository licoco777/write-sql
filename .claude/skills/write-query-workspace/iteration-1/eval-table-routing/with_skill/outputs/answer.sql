-- 双线/互联网专线号码 202605 当月速率与月租明细
-- 双线定义：069.prod_type2 IN (60, 70, 71)  -- 60 互联网专线，70/71 组网专线
-- 速率：069 主路径自带 speed_value
-- 月租：069 缺该字段，按 acc_nbr + par_month_id 补 033 双线全量清单 ads_yz_sx_qlyz_list.yz_cs
-- 033 同号码同月可能多行，按 load_date 取最新一行去重
SELECT
    a.acc_nbr                                       AS acc_nbr,
    a.serv_id                                       AS serv_id,
    a.par_month_id                                  AS par_month_id,
    a.prod_type2                                    AS prod_type2,
    CASE a.prod_type2
        WHEN 60 THEN '互联网专线'
        WHEN 70 THEN '组网专线'
        WHEN 71 THEN '组网专线'
    END                                             AS prod_type2_desc,
    a.speed_value                                   AS speed_value,
    sx.yz_cs                                        AS yz_cs,
    a.subst_name                                    AS subst_name,
    a.branch_name                                   AS branch_name
FROM dwm_yz_tb_comm_cm_all_final a
LEFT JOIN (
    SELECT
        acc_nbr,
        par_month_id,
        yz_cs,
        speed_value,
        ROW_NUMBER() OVER (PARTITION BY acc_nbr, par_month_id ORDER BY load_date DESC) AS rn
    FROM ads_yz_sx_qlyz_list
    WHERE par_month_id = 202605
) sx
    ON a.acc_nbr = sx.acc_nbr
   AND a.par_month_id = sx.par_month_id
   AND sx.rn = 1
WHERE a.par_month_id = 202605
  AND a.prod_type2 IN (60, 70, 71);
