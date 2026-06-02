-- 种子表 ads_zqzw_chaiji_sxf_20260517 内的 serv_id：
-- 1) 当月 202605 的状态（含中文描述）
-- 2) 上月 202604 是否有销售品 YD0202-556 在档
SELECT
    s.serv_id                                                  AS serv_id,
    s.acc_nbr                                                  AS acc_nbr,
    cur.state_code                                             AS state_code_202605,
    CASE cur.state_code
        WHEN 'F0' THEN '正常'
        WHEN 'F1' THEN '欠停'
        WHEN 'F2' THEN '挂停'
        WHEN 'F3' THEN '违章停机'
        WHEN 'F4' THEN '拆机'
        WHEN 'F5' THEN '预销户'
        WHEN 'F9' THEN '销户'
        ELSE '其他/未知'
    END                                                        AS state_name_202605,
    CASE WHEN pre.serv_id IS NOT NULL THEN '是' ELSE '否' END    AS has_offer_yd0202_556_202604
FROM ads_zqzw_chaiji_sxf_20260517 s
LEFT JOIN (
    -- 当月 202605 状态：取全业务资料表
    SELECT
        serv_id,
        state_code
    FROM ads_yz_quanyewu_ziliao
    WHERE month_id = '202605'
) cur
  ON s.serv_id = cur.serv_id
LEFT JOIN (
    -- 上月 202604 是否在档 YD0202-556
    SELECT DISTINCT
        serv_id
    FROM ads_yz_xiaoshoupin_zaidang_list
    WHERE month_id = '202604'
      AND offer_code = 'YD0202-556'
) pre
  ON s.serv_id = pre.serv_id
;
