-- 129+ 宽带入网量，按县分营服汇总
-- 口径推测：主宽新装且主套餐月承诺消费 >= 129 元
SELECT
    f.county_name                            AS county_name,        -- 县
    f.yingfu_name                            AS yingfu_name,        -- 营服
    COUNT(DISTINCT f.acc_nbr)                AS dev_cnt_129plus     -- 129+ 宽带入网量
FROM ads_yz_kuandai_xinzhuang_list f
WHERE f.month_id = '${month_id}'
  AND f.is_zhukuan = '1'                                            -- 主宽
  AND f.is_dev = '1'                                                -- 新装/入网
  AND f.main_offer_fee >= 129                                       -- 主套餐承诺消费 >= 129 元
GROUP BY
    f.county_name,
    f.yingfu_name
;
