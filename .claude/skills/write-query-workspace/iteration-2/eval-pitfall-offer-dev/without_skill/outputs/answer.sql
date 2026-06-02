-- 销售品 YD0202-556 在 202509、202510 月发展量明细
-- 输出字段：号码、客户名、揽装人、竣工时间、划小局向、揽装局向
SELECT
    f.acc_nbr            AS acc_nbr,             -- 号码
    f.cust_name          AS cust_name,           -- 客户名
    f.lanzhuang_staff    AS lanzhuang_staff,     -- 揽装人
    f.finish_time        AS finish_time,         -- 竣工时间
    f.huaxiao_juxiang    AS huaxiao_juxiang,     -- 划小局向
    f.lanzhuang_juxiang  AS lanzhuang_juxiang    -- 揽装局向
FROM ads_yz_quanyewu_haoma_dingdan f
WHERE f.month_id IN ('202509', '202510')
  AND f.offer_code = 'YD0202-556'
  AND f.is_dev = '1'                              -- 发展（新装/新增）
  AND f.finish_time IS NOT NULL
;
