---
metric_id: "M-TOPIC-SMB-002"
metric_name: "视联网到达数"
domain: "专题"
category: "小业务"
period: "日/月/年"
cdap_flow: "视联网发展"
owners:
  business: "林颖斌/陈冠文"
  technical: "钟雨君"
source_file: "小业务.md"
---

# [M-TOPIC-SMB-002] 视联网到达数

## 指标属性

| 字段 | 值 |
|------|-----|
| 业务板块 | 专题 |
| 业务分类 | 小业务 |
| 统计周期 | 日/月/年 |
| 业务口径责任人 | 林颖斌/陈冠文 |
| 技术口径责任人 | 钟雨君 |
| CDAP生产流程 | 视联网发展 |

## 业务口径

视联网到达数对标省 136 报表口径，来自视联网发展规模清单。到达口径由天翼看家、天翼云眼、平安慧眼三部分组成。

核心口径：

- 天翼看家：`action_type='tykj_dd'`，且满足产品 ID、`attr_value like '%AI%'` 或 `offer_label='TYKJ-AI-202211'`。
- 天翼云眼：`action_type='tyyy_dd'`，剔除 `offer_code='ZH0003-432-1-2'`，并扣减 `offer_label='TYYY-SPHJJM-202211'`。
- 平安慧眼：`action_type='pahy_dd'`。
- 到达统计只按 `par_month_id` 限定账期，不加 `subs_stat_date` 入网日期范围。

## 技术口径（SQL）

```sql
--统计视联网到达=tykj_dd+tyyy_dd+pahy_dd：
SELECT subst_id,subst_name,branch_id,branch_name,area_id,area_name,channel_type_2011,channel_subtype_2011,region_type,
    count(distinct case when action_type='tykj_dd' AND prod_id in (500005461,500005463,600019000) then serv_id else null end)
   + count(distinct case when action_type='tykj_dd' AND attr_value like('%AI%') then serv_id else null end)
   + count(distinct case when action_type='tykj_dd' AND offer_label='TYKJ-AI-202211' then msinfo_id else null end) tykj_dd, --天翼看家到达
    count(distinct case when action_type='tyyy_dd' AND offer_code not in ('ZH0003-432-1-2') then msinfo_id else null end) 
   - count(distinct case when action_type='tyyy_dd' AND offer_label='TYYY-SPHJJM-202211' then msinfo_id else null end) tyyy_dd, --天翼云眼到达
    count(distinct case when action_type='pahy_dd' then msinfo_id else null end) pahy_dd --平安慧眼到达
 FROM view_ads_yz_slw_136_list
 WHERE par_month_id='202604'  -- 统计月份
 GROUP BY subst_id,subst_name,branch_id,branch_name,area_id,area_name,channel_type_2011,channel_subtype_2011,region_type;
```

## 参数化建议

- 将固定月份参数化（如 `par_month_id`、`month_id`、`day_id`）。
- 若涉及日期范围，建议统一为 `${start_day}` / `${end_day}`。

## 依赖说明

- 相关主表：`../../tables/057_视联网发展规模清单.md`。
- 来源沉淀：`CDAP自助分析常用统计语句分享.docx` 的视联网发展规模清单 20250120 更新口径。
