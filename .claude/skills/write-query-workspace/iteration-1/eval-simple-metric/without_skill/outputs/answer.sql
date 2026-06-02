-- 取 202605 主宽到达数（月末主宽在网数）
-- 推测表：宽带到达多维表（ads 层），按月分区
SELECT
    COUNT(DISTINCT acc_nbr)              AS zhukuan_arrival_cnt   -- 主宽到达数
FROM ads_yz_kd_dada_list
WHERE month_id = '202605'
  AND is_zhukuan = '1'                                            -- 主宽标识=是
  AND is_active = '1'                                             -- 月末在网
;
