-- 按年（23/24/25）匹配 SR 科目税后收入
-- 维表 ads_yz_zqb_xc_due_income_code_dim_list 三列：due_income_code23 / due_income_code24 / due_income_code25
-- 维度：局向 / 营服 / 产权客户 / 产品 / 揽装人
-- 度量：确认收入（税后）

-- 1. 建目标表（若不存在）
CREATE TABLE IF NOT EXISTS ads_yz_sr_income_year_summary (
    juxiang             STRING       COMMENT '局向',
    yingfu              STRING       COMMENT '营服',
    cq_cust_name        STRING       COMMENT '产权客户',
    prod_id             STRING       COMMENT '产品',
    lanzhuang_staff     STRING       COMMENT '揽装人',
    year_id             STRING       COMMENT '年份(23/24/25)',
    sr_income_aftertax  DECIMAL(20,2) COMMENT '确认收入(税后)'
)
PARTITIONED BY (etl_month STRING)
STORED AS ORC
;

-- 2. 写入逻辑：把 23/24/25 三年分别 JOIN 维表对应的 code 列再 UNION 汇总
INSERT OVERWRITE TABLE ads_yz_sr_income_year_summary PARTITION (etl_month = '${etl_month}')
SELECT
    t.juxiang,
    t.yingfu,
    t.cq_cust_name,
    t.prod_id,
    t.lanzhuang_staff,
    t.year_id,
    SUM(t.sr_income_aftertax) AS sr_income_aftertax
FROM (
    -- 2023 年
    SELECT
        inc.juxiang,
        inc.yingfu,
        inc.cq_cust_name,
        inc.prod_id,
        inc.lanzhuang_staff,
        '23'                          AS year_id,
        inc.confirm_income_aftertax   AS sr_income_aftertax
    FROM ads_yz_quanliang_kemu_income inc
    JOIN (
        SELECT DISTINCT due_income_code23 AS due_income_code
        FROM ads_yz_zqb_xc_due_income_code_dim_list
        WHERE due_income_code23 IS NOT NULL
          AND due_income_code23 <> ''
    ) d
      ON inc.due_income_code = d.due_income_code
    WHERE inc.year_id = '2023'

    UNION ALL

    -- 2024 年
    SELECT
        inc.juxiang,
        inc.yingfu,
        inc.cq_cust_name,
        inc.prod_id,
        inc.lanzhuang_staff,
        '24'                          AS year_id,
        inc.confirm_income_aftertax   AS sr_income_aftertax
    FROM ads_yz_quanliang_kemu_income inc
    JOIN (
        SELECT DISTINCT due_income_code24 AS due_income_code
        FROM ads_yz_zqb_xc_due_income_code_dim_list
        WHERE due_income_code24 IS NOT NULL
          AND due_income_code24 <> ''
    ) d
      ON inc.due_income_code = d.due_income_code
    WHERE inc.year_id = '2024'

    UNION ALL

    -- 2025 年
    SELECT
        inc.juxiang,
        inc.yingfu,
        inc.cq_cust_name,
        inc.prod_id,
        inc.lanzhuang_staff,
        '25'                          AS year_id,
        inc.confirm_income_aftertax   AS sr_income_aftertax
    FROM ads_yz_quanliang_kemu_income inc
    JOIN (
        SELECT DISTINCT due_income_code25 AS due_income_code
        FROM ads_yz_zqb_xc_due_income_code_dim_list
        WHERE due_income_code25 IS NOT NULL
          AND due_income_code25 <> ''
    ) d
      ON inc.due_income_code = d.due_income_code
    WHERE inc.year_id = '2025'
) t
GROUP BY
    t.juxiang,
    t.yingfu,
    t.cq_cust_name,
    t.prod_id,
    t.lanzhuang_staff,
    t.year_id
;
