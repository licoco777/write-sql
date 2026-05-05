# 指标索引（运行时）

> 统一的运行时指标索引。先用本文件命中指标，再打开 `metric_file` 查看技术口径 SQL；`table_files` 只用于快速定位 A 层表文档。

## 使用规则

- 只有用户明确命中 `metric_name` 或近似标准指标名时，才进入本文件；普通“某产品入网量/到达量/规模”需求先按 `ROUTING.md` 和 `TABLE_INDEX.md` 选择 069 全业务资料表。
- 标准指标命中后，以单指标文件中的技术口径 SQL 为权威；不要用经验路由改写标准指标 SQL。
- `table_files` 为空或不确定时，读取 `metric_file` 后按 SQL `FROM` 回到 `tables/` 搜索 Hive 表名。
- 指标口径优先级高于经验路由，用户确认口径高于指标文件。
- `table_files` 只用于快速打开表文档核字段，不代表普通需求默认主表。
- 如果 `metric_file` 的 SQL 使用 `view_*` 视图名，先按 SQL 保留视图名；需要落生产表时再让用户校对对应 Hive 表。

## 命中边界

| 用户问法 | 是否走指标索引 | 处理 |
|---|---|---|
| “主宽入网数这个指标怎么算” | 是 | 命中 `metric_name`，打开单指标文件 |
| “按营服统计主宽入网数” | 是 | 命中标准指标，沿用技术口径后再补分组字段 |
| “查一下宽带入网量” | 否，除非用户确认要标准指标 | 普通入网规模，按路由默认 069 全业务资料表 |
| “视联网入网数指标” | 是 | 命中专题指标，使用专题指标 SQL |
| “某销售品入网量/到达量” | 否，除非命中具体标准指标 | 普通产品规模，优先 069；销售品名称不足再补维表 |

| metric_id | metric_name | domain | category | period | cdap_process | table_files | metric_file |
|---|---|---|---|---|---|---|---|
| M-BASIC-BB-001 | 主宽入网数 | 基本面 | 宽带 | 日/月/年 | 全业务资料表 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-BB-001_主宽入网数.md |
| M-BASIC-BB-002 | 主宽入网积分 | 基本面 | 宽带 | 日/月/年 | 全业务资料表（口径待补充） | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-BB-002_主宽入网积分.md |
| M-BASIC-BB-003 | 主宽到达数 | 基本面 | 宽带 | 日/月/年 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-BB-003_主宽到达数.md |
| M-BASIC-BB-004 | 129+宽带入网数 | 基本面 | 宽带 | 日/月/年 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-BB-004_129+宽带入网数.md |
| M-BASIC-BB-005 | 融合新宽新移入网数 | 基本面 | 宽带 | 日/月/年 | 宽带新装清单 | tables/006_宽带新装清单.md | metrics/基本面/M-BASIC-BB-005_融合新宽新移入网数.md |
| M-BASIC-BB-006 | 融合新宽新移入网积分 | 基本面 | 宽带 | 日/月/年 | 宽带新装清单 | tables/006_宽带新装清单.md | metrics/基本面/M-BASIC-BB-006_融合新宽新移入网积分.md |
| M-BASIC-BB-007 | 校园宽带入网数 | 基本面 | 宽带 | 日/月/年 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-BB-007_校园宽带入网数.md |
| M-BASIC-BB-008 | 快捷宽带入网数 | 基本面 | 宽带 | 日/月/年 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-BB-008_快捷宽带入网数.md |
| M-BASIC-BB-009 | 酒店宽带入网数 | 基本面 | 宽带 | 日/月/年 | 宽带新装清单 | tables/006_宽带新装清单.md | metrics/基本面/M-BASIC-BB-009_酒店宽带入网数.md |
| M-BASIC-BB-010 | FTTR入网数 | 基本面 | 宽带 | 日/月/年 | FTTR报表 | tables/002_fttr清单.md | metrics/基本面/M-BASIC-BB-010_FTTR入网数.md |
| M-BASIC-BB-011 | 融合移动有效系数T1 | 基本面 | 宽带 | 月/年 | 融合质态-有效 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/基本面/M-BASIC-BB-011_融合移动有效系数T1.md |
| M-BASIC-BB-012 | 199+宽带拆机量 | 基本面 | 宽带 | 日/月/年 | 宽带离网报表+531离网数据 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/基本面/M-BASIC-BB-012_199+宽带拆机量.md |
| M-BASIC-BB-013 | 宽带销户数 | 基本面 | 宽带 | 月/年 | 宽带离网报表+531离网数据 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/基本面/M-BASIC-BB-013_宽带销户数.md |
| M-BASIC-BB-014 | 宽带销户积分 | 基本面 | 宽带 | 月/年 | 宽带离网报表+531离网数据 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/基本面/M-BASIC-BB-014_宽带销户积分.md |
| M-BASIC-DBL-001 | 双线入网线数 | 基本面 | 双线 | 日/月/年 | 双线全量清单 | tables/033_双线全量清单.md | metrics/基本面/M-BASIC-DBL-001_双线入网线数.md |
| M-BASIC-DBL-002 | 双线入网月租 | 基本面 | 双线 | 日/月/年 | 双线全量清单 | tables/033_双线全量清单.md | metrics/基本面/M-BASIC-DBL-002_双线入网月租.md |
| M-BASIC-DBL-003 | 双线拆机线数 | 基本面 | 双线 | 日/月/年 | 双线全量清单 | tables/033_双线全量清单.md | metrics/基本面/M-BASIC-DBL-003_双线拆机线数.md |
| M-BASIC-DBL-004 | 双线拆机月租 | 基本面 | 双线 | 日/月/年 | 双线全量清单 | tables/033_双线全量清单.md | metrics/基本面/M-BASIC-DBL-004_双线拆机月租.md |
| M-BASIC-DBL-005 | 双线净增线数 | 基本面 | 双线 | 日/月/年 | 双线全量清单 | tables/033_双线全量清单.md | metrics/基本面/M-BASIC-DBL-005_双线净增线数.md |
| M-BASIC-DBL-006 | 双线净增月租 | 基本面 | 双线 | 日/月/年 | 双线全量清单 | tables/033_双线全量清单.md | metrics/基本面/M-BASIC-DBL-006_双线净增月租.md |
| M-BASIC-DBL-007 | 双线续约率 | 基本面 | 双线 | 日/月/年 | 双线清单 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/基本面/M-BASIC-DBL-007_双线续约率.md |
| M-BASIC-DBL-008 | 存量双线提值积分（高套） | 基本面 | 双线 | 日/月/年 | 双线存量提值折高套 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/基本面/M-BASIC-DBL-008_存量双线提值积分（高套）.md |
| M-BASIC-DBL-009 | 双线国际业务发展量 | 基本面 | 双线 | 日/月/年 | 双线全量清单 | tables/033_双线全量清单.md | metrics/基本面/M-BASIC-DBL-009_双线国际业务发展量.md |
| M-BASIC-MV-001 | 合约发展量 | 基本面 | 移动 | 日/月/年 | 移动日报 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-001_合约发展量.md |
| M-BASIC-MV-002 | 合约新入网 | 基本面 | 移动 | 日/月/年 | 移动日报 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-002_合约新入网.md |
| M-BASIC-MV-003 | 合约129+占比 | 基本面 | 移动 | 日/月/年 | 移动日报 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-003_合约129+占比.md |
| M-BASIC-MV-004 | 合约T+n出账率 | 基本面 | 移动 | 月 | 移动日报 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-004_合约T+n出账率.md |
| M-BASIC-MV-005 | 移动日入网 | 基本面 | 移动 | 日 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-005_移动日入网.md |
| M-BASIC-MV-006 | 移动月入网 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-006_移动月入网.md |
| M-BASIC-MV-007 | 移动活跃月入网 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-007_移动活跃月入网.md |
| M-BASIC-MV-008 | 移动有效月入网 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-008_移动有效月入网.md |
| M-BASIC-MV-009 | 移动后付费单产品月入网 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-009_移动后付费单产品月入网.md |
| M-BASIC-MV-010 | 移动预付费单产品月入网 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-010_移动预付费单产品月入网.md |
| M-BASIC-MV-011 | 融合移动月入网 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-011_融合移动月入网.md |
| M-BASIC-MV-012 | 副卡月入网 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-012_副卡月入网.md |
| M-BASIC-MV-013 | 移动月销户 | 基本面 | 移动 | 月 | 移动日报 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-013_移动月销户.md |
| M-BASIC-MV-014 | 移动到达数 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-014_移动到达数.md |
| M-BASIC-MV-015 | 移动有效到达数 | 基本面 | 移动 | 月 | 日生产 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-015_移动有效到达数.md |
| M-BASIC-MV-016 | 移动当月携入号码数 | 基本面 | 移动 | 月 | jm每日流程_月重跑 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-016_移动当月携入号码数.md |
| M-BASIC-MV-017 | 移动当月携出号码数 | 基本面 | 移动 | 月 | jm每日流程_月重跑 | tables/069_全业务资料表.md | metrics/基本面/M-BASIC-MV-017_移动当月携出号码数.md |
| M-NEW-CLOUD-001 | 云桌面台数入网数 | 战新 | 云业务 | 日/月/年 | 资源明细清单生成 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/战新/M-NEW-CLOUD-001_云桌面台数入网数.md |
| M-NEW-MV-001 | 手机直连卫星发展量 | 战新 | 移动 | 日/月/年 | 手机直连卫星发展模型 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/战新/M-NEW-MV-001_手机直连卫星发展量.md |
| M-NEW-MV-002 | 手机直连卫星到达数 | 战新 | 移动 | 日/月/年 | 手机直连卫星发展模型 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/战新/M-NEW-MV-002_手机直连卫星到达数.md |
| M-NEW-MV-003 | 手机直连卫星同装率（受理合约同时受理直连卫星） | 战新 | 移动 | 日/月/年 | 手机直连卫星发展模型 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/战新/M-NEW-MV-003_手机直连卫星同装率（受理合约同时受理直连卫星）.md |
| M-NEW-SMB-001 | 量子密话月入网 | 战新 | 小业务 | 月 | jm每日流程_月重跑 | tables/069_全业务资料表.md | metrics/战新/M-NEW-SMB-001_量子密话月入网.md |
| M-TOPIC-BB-001 | 宽带T+n有效率 | 专题 | 宽带 | 月 | 移动宽带质态监控需求 | tables/093_移动宽带质态监控多维表-宽带清单.md | metrics/专题/M-TOPIC-BB-001_宽带T+n有效率.md |
| M-TOPIC-BB-002 | 宽带T+n欠费率 | 专题 | 宽带 | 月 | 移动宽带质态监控需求 | tables/093_移动宽带质态监控多维表-宽带清单.md | metrics/专题/M-TOPIC-BB-002_宽带T+n欠费率.md |
| M-TOPIC-BB-003 | 宽带T+n停机率 | 专题 | 宽带 | 月 | 移动宽带质态监控需求 | tables/093_移动宽带质态监控多维表-宽带清单.md | metrics/专题/M-TOPIC-BB-003_宽带T+n停机率.md |
| M-TOPIC-BB-004 | 宽带T+n拆机率 | 专题 | 宽带 | 月 | 移动宽带质态监控需求 | tables/093_移动宽带质态监控多维表-宽带清单.md | metrics/专题/M-TOPIC-BB-004_宽带T+n拆机率.md |
| M-TOPIC-BIZ-001 | 商企新入网 | 专题 | 商企 | 日/月/年 | 商客市场短信 | tables/058_商客新建档客户清单.md | metrics/专题/M-TOPIC-BIZ-001_商企新入网.md |
| M-TOPIC-BIZ-002 | 商企提值积分 | 专题 | 商企 | 日/月/年 | 商客市场短信 | tables/058_商客新建档客户清单.md | metrics/专题/M-TOPIC-BIZ-002_商企提值积分.md |
| M-TOPIC-CLOUD-001 | 云桌面台数到达数 | 专题 | 云业务 | 日/月/年 | 资源明细清单生成 | 以单指标技术口径 SQL 的 FROM 为准 | metrics/专题/M-TOPIC-CLOUD-001_云桌面台数到达数.md |
| M-TOPIC-MV-001 | 移动T+n号码有效率 | 专题 | 移动 | 月 | 移动入网质量模型 | tables/069_全业务资料表.md | metrics/专题/M-TOPIC-MV-001_移动T+n号码有效率.md |
| M-TOPIC-MV-002 | 移动T+n套餐有效率 | 专题 | 移动 | 月 | 移动入网质量模型 | tables/069_全业务资料表.md | metrics/专题/M-TOPIC-MV-002_移动T+n套餐有效率.md |
| M-TOPIC-MV-003 | 移动T+n欠费率 | 专题 | 移动 | 月 | 移动入网质量模型 | tables/069_全业务资料表.md | metrics/专题/M-TOPIC-MV-003_移动T+n欠费率.md |
| M-TOPIC-MV-004 | 移动T+n停机率 | 专题 | 移动 | 月 | 移动入网质量模型 | tables/069_全业务资料表.md | metrics/专题/M-TOPIC-MV-004_移动T+n停机率.md |
| M-TOPIC-MV-005 | 移动T+n拆机率 | 专题 | 移动 | 月 | 移动入网质量模型 | tables/069_全业务资料表.md | metrics/专题/M-TOPIC-MV-005_移动T+n拆机率.md |
| M-TOPIC-MV-006 | 融合终补终端续约率 | 专题 | 移动 | 月 | 移动续约_移动续约日模型 | tables/030_移动续约清单.md, tables/031_移动续约多维表.md | metrics/专题/M-TOPIC-MV-006_融合终补终端续约率.md |
| M-TOPIC-MV-007 | 融合话补续约率 | 专题 | 移动 | 月 | 移动续约_移动续约日模型 | tables/030_移动续约清单.md, tables/031_移动续约多维表.md | metrics/专题/M-TOPIC-MV-007_融合话补续约率.md |
| M-TOPIC-MV-008 | 单移终补续约率 | 专题 | 移动 | 月 | 移动续约_移动续约日模型 | tables/030_移动续约清单.md, tables/031_移动续约多维表.md | metrics/专题/M-TOPIC-MV-008_单移终补续约率.md |
| M-TOPIC-PTS-001 | 净增积分 | 专题 | 积分 | 日/月/年 | 净增积分请单 | tables/007_净增积分清单.md | metrics/专题/M-TOPIC-PTS-001_净增积分.md |
| M-TOPIC-PTS-002 | 纯新套餐积分 | 专题 | 积分 | 日/月/年 | 净增积分请单 | tables/007_净增积分清单.md | metrics/专题/M-TOPIC-PTS-002_纯新套餐积分.md |
| M-TOPIC-PTS-003 | 存量加装积分 | 专题 | 积分 | 日/月/年 | 净增积分请单 | tables/007_净增积分清单.md | metrics/专题/M-TOPIC-PTS-003_存量加装积分.md |
| M-TOPIC-PTS-004 | 拆机销户积分 | 专题 | 积分 | 日/月/年 | 净增积分请单 | tables/007_净增积分清单.md | metrics/专题/M-TOPIC-PTS-004_拆机销户积分.md |
| M-TOPIC-PTS-005 | 存量变更积分 | 专题 | 积分 | 日/月/年 | 净增积分请单 | tables/007_净增积分清单.md | metrics/专题/M-TOPIC-PTS-005_存量变更积分.md |
| M-TOPIC-PTS-006 | 优惠到期积分 | 专题 | 积分 | 日/月/年 | 净增积分请单 | tables/007_净增积分清单.md | metrics/专题/M-TOPIC-PTS-006_优惠到期积分.md |
| M-TOPIC-PTS-007 | 揽装价值积分 | 专题 | 积分 | 月/年 | 揽装积分清单 | tables/081_揽装积分清单.md | metrics/专题/M-TOPIC-PTS-007_揽装价值积分.md |
| M-TOPIC-PTS-008 | 揽装激励积分 | 专题 | 积分 | 月/年 | 揽装积分清单 | tables/081_揽装积分清单.md | metrics/专题/M-TOPIC-PTS-008_揽装激励积分.md |
| M-TOPIC-PTS-009 | 发展价值积分 | 专题 | 积分 | 月/年 | 发展存量积分清单 | tables/012_发展存量积分清单.md | metrics/专题/M-TOPIC-PTS-009_发展价值积分.md |
| M-TOPIC-PTS-010 | 发展激励积分 | 专题 | 积分 | 月/年 | 发展存量积分清单 | tables/012_发展存量积分清单.md | metrics/专题/M-TOPIC-PTS-010_发展激励积分.md |
| M-TOPIC-PTS-011 | 存量价值积分 | 专题 | 积分 | 月/年 | 发展存量积分清单 | tables/012_发展存量积分清单.md | metrics/专题/M-TOPIC-PTS-011_存量价值积分.md |
| M-TOPIC-PTS-012 | 存量激励积分 | 专题 | 积分 | 月/年 | 发展存量积分清单 | tables/012_发展存量积分清单.md | metrics/专题/M-TOPIC-PTS-012_存量激励积分.md |
| M-TOPIC-PTS-013 | 降档积分 | 专题 | 积分 | 日/月/年 | 降档清单 | tables/104_降档清单.md | metrics/专题/M-TOPIC-PTS-013_降档积分.md |
| M-TOPIC-PTS-014 | 非依案降档积分 | 专题 | 积分 | 日/月/年 | 降档清单 | tables/104_降档清单.md | metrics/专题/M-TOPIC-PTS-014_非依案降档积分.md |
| M-TOPIC-PTS-015 | 揽装价值积分剔除一次性小微 | 专题 | 积分 | 月/年 | 揽装积分清单 | tables/081_揽装积分清单.md | metrics/专题/M-TOPIC-PTS-015_揽装价值积分剔除一次性小微.md |
| M-TOPIC-PTS-016 | 项目型小微和新产品小微价值积分 | 专题 | 积分 | 月/年 | 发展存量积分清单 | tables/012_发展存量积分清单.md | metrics/专题/M-TOPIC-PTS-016_项目型小微和新产品小微价值积分.md |
| M-TOPIC-PTS-017 | 项目型小微和新产品小微激励积分 | 专题 | 积分 | 月/年 | 发展存量积分清单 | tables/012_发展存量积分清单.md | metrics/专题/M-TOPIC-PTS-017_项目型小微和新产品小微激励积分.md |
| M-TOPIC-REV-001 | 收保率 | 专题 | 收入 | 月/年 | 关于客经收保本地划小数据 | tables/047_最终版划小收入.md | metrics/专题/M-TOPIC-REV-001_收保率.md |
| M-TOPIC-REV-002 | 客保率 | 专题 | 收入 | 月/年 | 关于客经收保本地划小数据 | tables/047_最终版划小收入.md | metrics/专题/M-TOPIC-REV-002_客保率.md |
| M-TOPIC-REV-003 | 划小收入 | 专题 | 收入 | 月 | （修改结算）YZSR子流程-1-收入生产 | tables/097_基本面月清单.md, tables/048_全量科目级收入.md | metrics/专题/M-TOPIC-REV-003_划小收入.md |
| M-TOPIC-REV-004 | 台阶收入 | 专题 | 收入 | 月 | 台阶收入清单打标 | tables/101_台阶收入清单.md | metrics/专题/M-TOPIC-REV-004_台阶收入.md |
| M-TOPIC-REV-005 | 基本面收入 | 专题 | 收入 | 月 | （修改结算）YZSR子流程-1-收入生产 | tables/097_基本面月清单.md, tables/048_全量科目级收入.md | metrics/专题/M-TOPIC-REV-005_基本面收入.md |
| M-TOPIC-REV-006 | 互联网专线收入 | 专题 | 收入 | 月 | （修改结算）YZSR子流程-1-收入生产 | tables/097_基本面月清单.md, tables/048_全量科目级收入.md | metrics/专题/M-TOPIC-REV-006_互联网专线收入.md |
| M-TOPIC-REV-007 | 结算分成 | 专题 | 收入 | 月 | （修改结算）YZSR子流程-1-收入生产 | tables/097_基本面月清单.md, tables/048_全量科目级收入.md | metrics/专题/M-TOPIC-REV-007_结算分成.md |
| M-TOPIC-REV-008 | 漫游结算 | 专题 | 收入 | 月 | （修改结算）YZSR子流程-1-收入生产 | tables/097_基本面月清单.md, tables/048_全量科目级收入.md | metrics/专题/M-TOPIC-REV-008_漫游结算.md |
| M-TOPIC-REV-009 | 积分计提 | 专题 | 收入 | 月 | （修改结算）YZSR子流程-1-收入生产 | tables/097_基本面月清单.md, tables/048_全量科目级收入.md | metrics/专题/M-TOPIC-REV-009_积分计提.md |
| M-TOPIC-REV-010 | 积分兑换 | 专题 | 收入 | 月 | （修改结算）YZSR子流程-1-收入生产 | tables/097_基本面月清单.md, tables/048_全量科目级收入.md | metrics/专题/M-TOPIC-REV-010_积分兑换.md |
| M-TOPIC-REV-011 | 一次性收入 | 专题 | 收入 | 月 | （修改结算）YZSR子流程-1-收入生产 | tables/097_基本面月清单.md, tables/048_全量科目级收入.md | metrics/专题/M-TOPIC-REV-011_一次性收入.md |
| M-TOPIC-SMB-001 | 视联网入网数 | 专题 | 小业务 | 日/月/年 | 视联网发展 | tables/057_视联网发展规模清单.md | metrics/专题/M-TOPIC-SMB-001_视联网入网数.md |
| M-TOPIC-SMB-002 | 视联网到达数 | 专题 | 小业务 | 日/月/年 | 视联网发展 | tables/057_视联网发展规模清单.md | metrics/专题/M-TOPIC-SMB-002_视联网到达数.md |
