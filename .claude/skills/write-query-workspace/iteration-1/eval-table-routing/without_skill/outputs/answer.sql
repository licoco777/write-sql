-- 双线 / 互联网专线 号码：202605 当月的速率与月租明细
-- 业务范围：移动+宽带双线 或 互联网专线（含商客专线）
SELECT
    f.acc_nbr           AS acc_nbr,            -- 号码
    f.cust_name         AS cust_name,
    f.prod_id           AS prod_id,            -- 产品
    f.prod_name         AS prod_name,
    f.biz_type          AS biz_type,           -- 业务大类：双线/专线
    f.access_rate       AS access_rate,        -- 接入速率
    f.rate_unit         AS rate_unit,          -- 速率单位（M/G）
    f.monthly_rent      AS monthly_rent,       -- 月租
    f.zhongduan_juxiang AS zhongduan_juxiang,  -- 局向
    f.start_date        AS start_date,
    f.end_date          AS end_date
FROM ads_yz_quanyewu_ziliao f
WHERE f.month_id = '202605'
  AND (
        f.biz_type IN ('双线', '互联网专线')
     OR f.prod_kind_code IN ('SX', 'IPLINE', 'ZX')            -- 双线/专线产品大类
  )
;
