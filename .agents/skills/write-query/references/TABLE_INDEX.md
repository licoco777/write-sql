# CDAP 表索引（运行时）

> 机器友好的表目录。用于 Schema Linking / 主表选择阶段，只做定位，不替代表文档。落 SQL 前仍需打开 `tables/*.md` 核对 frontmatter、字段、分区和常用条件。

## 使用规则

- 优先按 `table_name`、`hive_name`、`prod_hive_name`、业务事实共同定位，不只看序号。
- `prod_hive_name` 非空时，落 SQL 优先使用生产现网名，并在输出中让用户校对。
- 字段、分区、粒度以 `file_path` 指向的表文档为准。
- 本文件只回答“可能是哪张表”；字段是否存在、分区怎么写、码值怎么过滤，必须继续打开对应表文档。
- 如果用户已经明确主表或生产表名，不要用本文件改写用户选择；只用来核对表文档路径和生产表名。

## 快速定位

先按业务事实选主表，再到下方完整索引查 `file_path`。

| 用户需求类型 | 优先主表 | 典型用途 | 不要误选 |
|---|---|---|---|
| 任意产品入网量 / 新装量 / 到达量 | 069 全业务资料表 | 宽带、移动、固话及其它产品的入网量、到达量、规模统计 | 不要按产品名直接跳到专项新装清单 |
| 全业务存量、在网、出账、常规状态规模 | 069 全业务资料表 | 服务级全业务明细、月末状态、常规规模统计 | 不要因为有订单字段就先选订单表 |
| 移动/宽带新装专项明细 | 001 移动新装清单；006 宽带新装清单 | 仅当用户明确要专项新装清单字段、专项报表字段或专项清单口径时 | 不要覆盖 069 的常规全业务入网/到达口径 |
| 销售品订购、互换、发展量动作 | 041 优惠订单表 | 按销售品统计发展量、动作明细 | 不要选 014 优惠资料表或专项产品清单 |
| 销售品存量、在档 | 014 优惠资料表 | 查询某销售品当前/账期在档用户 | 不要选 041 订单动作表 |
| 销售品名称、销售品编码补全 | 020 销售品维表视图 | 用 `offer_id` 补 `offer_name` 等 | 不要作为事实主表 |
| 销售品参数、折扣、赠金、统付金额补全 | 107 销售品参数表 | 按 `serv_id + prod_offer_id + param_code` 补 `param_value` | 不要用它判断销售品是否在档；在档仍先用 014 |
| 号码订单动作 | 040 全业务号码订单表 | 号码级受理、变更、订单动作 | 不要用 069 代替动作事实 |
| 收入类 | 047 最终版划小收入；048 全量科目级收入；097 基本面月清单；101 台阶收入清单 | 划小收入、科目收入、基本面、台阶收入；最新月科目收入可用 `dwm_srhx_src_income_list` | 不要用 069 的状态字段推收入 |
| 积分类 | 012 发展存量积分清单；007 净增积分清单；081 揽装积分清单；082 双线净增积分清单；091 财务部积分多维表 | 积分类全量明细默认先看 012；专项指标/专项表明确时再看 007/081/082/091 | 不要把派生专项表当全量底表；不要仅因 `jz_points` 字段去 069 |
| 续约类 | 030 移动续约清单；032 宽带续约清单；065 双线续约清单；096 酒宽续约清单 | 移动/宽带/双线/酒店宽带续约 | 不要用新装或订单表替代续约事实 |
| 降档/升降档 | 008/009 129+套餐升降档路径；010 降档原始清单；011 降档动作订单清单；104 降档清单 | 升降档路径、降档动作、降档明细 | 先区分路径、多维、动作、结果 |
| 客户实体映射 / 客户信息维护 | 108 产权客户全量表；109 直销客户表 | 签订/维护直销客户；通过产权客户找直销客户；按客户信息更新客户资料 | 号码/服务明细要客户名、产权客户名、直销客户名时，优先用 069 或当前事实主表自带客户字段 |
| 机构、销售员、协销补字段 | 018 机构维表；111 揽装人维表；112 网点维表；113 揽装所属表；115 员工信息表；042 号码协销表；043 订单协销表 | 补机构层级、销售员、员工 CRM 工号、协销人、网点经营主体 | 不要作为默认主表 |
| 结算账单 / 合同网点 | 110 结算账单表；111 揽装人维表；112 网点维表；113 揽装所属表 | 结算报账、合同编码、合同账期、合同下网点、网点有效性、有效揽装人 | 不要用 069、订单表、积分表承接合同结算事实 |
| 国际漫游开通 | 114 国际漫游数据表 | 已开通国际漫游权限号码、开户时间、开通国漫权限时间、G/L IMSI | 不要用漫游结算收入表或订单表推断是否开通国漫 |
| 字典/码值中文名 | 015 字典表视图；016 字典维表视图 | 编码转中文、属性值解释 | 不要把码值表当业务事实表 |
| 产品规格属性 / 特性历史快照 / IMSI | 105 特性资料表 | 拆机前月主产品特性、历史某月 attr_id 特性值、号码 IMSI（`attr_id='200000103'`） | 不要用特性日表查已拆机历史；勿与 106 混用；普通号码 IMSI 不要走 114 国漫表 |
| 附属产品属性 / 附属产品历史快照 | 106 附属产品资料表 | 拆机前月附属产品特性 | 不要用附属日表查已拆机历史；勿与 105 混用 |

## 选表输出要求

输出“主表确认”时，至少带出：

- `table_id`、`table_name`、`prod_hive_name`。
- `file_path`，方便下一步打开表文档做字段映射。
- 选表理由：一句话说明业务事实为什么在这张表。
- 排除项：列出 1-3 张容易误选的表及原因。

| table_id | table_name | hive_name | prod_hive_name | file_path | grain | partition_keys | use_when | avoid_when |
|---|---|---|---|---|---|---|---|---|
| 000 | 账务信息关系表 |  |  | tables/000_账务信息关系表.md |  |  | 账务信息关系表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 001 | 移动新装清单 | dwd_yz_cm_cdma_ydxz_list | dwd_yz_cm_cdma_ydxz_list | tables/001_移动新装清单.md |  | par_month_id | 移动新装清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 002 | fttr清单 | dwm_fttr_list | dwm_fttr_list | tables/002_fttr清单.md |  | par_month_id | fttr清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 003 | 小微ICT竣工清单 | ads_yz_xwict_all_list | ads_yz_xwict_all_list | tables/003_小微ICT竣工清单.md |  | par_month_id | 小微ICT竣工清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 004 | 合约清单 | dwm_yz_cm_cdma_hy_final | dwm_yz_cm_cdma_hy_final | tables/004_合约清单.md |  |  | 合约清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 005 | 移动划小清单 | ads_yz_cdma_hx_list | ads_yz_cdma_hx_list | tables/005_移动划小清单.md |  |  | 移动划小清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 006 | 宽带新装清单 | ads_yz_kd_new_list | ads_yz_kd_new_list | tables/006_宽带新装清单.md |  |  | 宽带新装清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 007 | 净增积分清单 | ads_yz_tb_tyks_score_inc_mtd | ads_yz_tb_tyks_score_inc_mtd | tables/007_净增积分清单.md |  |  | 净增积分清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 008 | 129+套餐升降档路径清单 | ads_yz_bd129_sdjd_list | ads_yz_bd129_sdjd_list | tables/008_129+套餐升降档路径清单.md |  | par_month_id | 129+套餐升降档路径清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 009 | 129+套餐升降档路径多维表 | ads_yz_bd129_sdjd_dwb | ads_yz_bd129_sdjd_dwb | tables/009_129+套餐升降档路径多维表.md |  |  | 129+套餐升降档路径多维表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 010 | 降档原始清单 | ads_yz_sunshou_acc_list | ads_yz_sunshou_acc_list | tables/010_降档原始清单.md |  |  | 降档原始清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 011 | 降档动作订单清单 | ads_yz_sunshou_qudao | ads_yz_sunshou_qudao | tables/011_降档动作订单清单.md |  |  | 降档动作订单清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 012 | 发展存量积分清单 | ads_yz_score_all_list | ads_yz_score_all_list | tables/012_发展存量积分清单.md | 积分类全量明细底表，含号码/服务/积分类型/客户/网格/积分字段 | par_month_id | 积分类全量明细、发展积分、存量积分，以及需要积分类型层级、号码、客户、网格、竣工时间、价值/激励积分及描述的取数 | 字段名相似但业务事实不在本表时不要选；明确专项指标/专项表口径时再看 007/081/082/091 |
| 013 | 全业务资料表 | ads_yz_tb_comm_cm_all_final | dwm_yz_tb_comm_cm_all_final；dwm_yz_tb_comm_cm_all_mon_final | tables/013_全业务资料表.md | 以 serv_id 为服务粒度；账期/统计月份一般为 par_month_id | par_month_id | 全业务资料表相关取数；近半年账期优先日表 `dwm_yz_tb_comm_cm_all_final`，更早历史账期走月表 `dwm_yz_tb_comm_cm_all_mon_final`，重叠账期默认优先日表 | 字段名相似但业务事实不在本表时不要选 |
| 014 | 优惠资料表 | ads_yz_rpt_comm_cm_msdisc_final | ads_yz_rpt_comm_cm_msdisc_final | tables/014_优惠资料表.md |  | par_month_id | 优惠资料表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 015 | 字典表视图 | dws_crm_cfguse.dws_attr_value | dws_crm_cfguse.dws_attr_value | tables/015_字典表视图.md |  |  | 字典表视图相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 016 | 字典维表视图 | dws_crm_cfguse.dws_attr_SPEC | dws_crm_cfguse.dws_attr_SPEC | tables/016_字典维表视图.md |  |  | 字典维表视图相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 017 | 产品维表视图 | dws_crm_cfguse.dws_product | dws_crm_cfguse.dws_product | tables/017_产品维表视图.md |  |  | 产品维表视图相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 018 | 机构维表视图 | zone_gz_yz.dwd_yz_dim_org | zone_gz_yz.dwd_yz_dim_org | tables/018_机构维表视图.md |  |  | 机构维表视图相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 019 | 移动主套餐维表视图 | metadata_ods_day.tb_dim_cdma_disc_type | metadata_ods_day.tb_dim_cdma_disc_type | tables/019_移动主套餐维表视图.md |  |  | 移动主套餐维表视图相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 020 | 销售品维表视图 | dws_crm_cfguse.dws_offer | dws_crm_cfguse.dws_offer | tables/020_销售品维表视图.md |  |  | 销售品维表视图相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 021 | 揽装所属表（旧编号） | zone_gz_yz.dwd_yz_sales_man_outlers_final | zone_gz_yz.dwd_yz_sales_man_outlers_final | tables/021_揽装网点维表.md | 有效揽装人 + 有效网点对应关系（旧文档名保留兼容） |  | 旧编号兼容；新查询优先看 113 揽装所属表、111 揽装人维表、112 网点维表 | 不要当纯网点维表；网点唯一信息看 112 |
| 079 | 地址维表 | zone_gz_yz.dwd_yz_addr_final | zone_gz_yz.dwd_yz_addr_final | tables/079_地址维表.md | 以 id 为地址粒度；grade 表示地址层级 |  | 地址 / 装机地址 / 7级地址相关取数；主业务表取 `serv_addr_id` 后统一转字符关联 `id`，装机地址默认 `grade=10`，7 级地址按 `addr_id_7` 二次关联 `grade=7` | 字段名相似但业务事实不在本表时不要选；不要把 `serv_addr_id` 默认强转 decimal |
| 022 | 商企入网清单 | zone_gz_yz.ads_yz_shangqi_rw_list | zone_gz_yz.ads_yz_shangqi_rw_list | tables/022_商企入网清单.md |  | par_month_id | 商企入网清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 023 | 基础业务托收清单 | zone_gz_yz.ads_yz_tb_cl_tuoshou_list | zone_gz_yz.ads_yz_tb_cl_tuoshou_list | tables/023_基础业务托收清单.md |  | par_month_id | 基础业务托收清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 024 | 营业厅月度订单受理量清单 | zone_gz_yz.ads_yz_yyt_sl_list | zone_gz_yz.ads_yz_yyt_sl_list | tables/024_营业厅月度订单受理量清单.md |  |  | 营业厅月度订单受理量清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 025 | 专业营服全业务清单（改革） | ads_yz_tb_comm_cm_all_zyyf_final | ads_yz_tb_comm_cm_all_zyyf_final | tables/025_专业营服全业务清单（改革）.md |  | par_month_id | 专业营服全业务清单（改革）相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 026 | 小微ict场景化收入数据 | zone_gz_yz.ads_yz_scb_ict_fee_list | zone_gz_yz.ads_yz_scb_ict_fee_list | tables/026_小微ict场景化收入数据.md |  | par_month_id | 小微ict场景化收入数据相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 027 | 满卡报表清单 | zone_gz_yz.ads_yz_mk_list | zone_gz_yz.ads_yz_mk_list | tables/027_满卡报表清单.md |  | par_month_id | 满卡报表清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 029 | 企微粉丝清单报表 | zone_gz_yz.dwd_yz_qywx_daily_list_end | zone_gz_yz.dwd_yz_qywx_daily_list_end | tables/029_企微粉丝清单报表.md |  | par_month_id | 企微粉丝清单报表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 029 | 小微清单2024 | zone_gz_yz.ads_yz_ict_all2024_LIST | zone_gz_yz.ads_yz_ict_all2024_LIST | tables/029_小微清单2024.md | 以 serv_id / 客户维度为主的清单粒度（以实际报表为准） | par_month_id | 小微清单2024相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 030 | 移动续约清单 | ads_yz_ydxy_daily_list | ads_yz_ydxy_daily_list | tables/030_移动续约清单.md |  |  | 移动续约清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 031 | 移动续约多维表 | ads_yz_ydxy_group | ads_yz_ydxy_group | tables/031_移动续约多维表.md |  |  | 移动续约多维表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 032 | 宽带续约清单 | ads_yz_kd_xy_list | ads_yz_kd_xy_list | tables/032_宽带续约清单.md |  | par_month_id | 宽带续约清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 033 | 双线全量清单 | ads_yz_sx_qlyz_list | ads_yz_sx_qlyz_list | tables/033_双线全量清单.md |  | par_month_id | 双线全量清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 034 | 主宽拆机挽留清单 | ads_yz_kd_cjwl_list | ads_yz_kd_cjwl_list | tables/034_主宽拆机挽留清单.md |  |  | 主宽拆机挽留清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 035 | 反诈资料宽表 | dwm_yz_fz_rpt_comm_cm_serv_d_final | dwm_yz_fz_rpt_comm_cm_serv_d_final | tables/035_反诈资料宽表.md |  | par_month_id | 反诈资料宽表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 036 | 政企移动入网清单报表 | dwd_yz_zhengqi_yd_new_daily_list_end | dwd_yz_zhengqi_yd_new_daily_list_end | tables/036_政企移动入网清单报表.md |  | par_month_id | 政企移动入网清单报表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 039 | 欠不列预警清单 | zone_gz_yz.ads_ys_qblyj_daily | zone_gz_yz.ads_ys_qblyj_daily | tables/039_欠不列预警清单.md |  |  | 欠不列预警清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 040 | 全业务号码订单表 | zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final | zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final | tables/040_全业务号码订单表.md |  |  | 全业务号码订单表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 041 | 优惠订单表 | zone_gz_yz.dwm_yz_rpt_comm_ba_msdisc_final | dwm_yz_rpt_comm_ba_msdisc_final | tables/041_优惠订单表.md | 订单粒度（subs_id 唯一） |  | 优惠订单表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 042 | 号码协销表 | zone_gz_yz.dwd_yz_cm_obj_xx_final | zone_gz_yz.dwd_yz_cm_obj_xx_final | tables/042_号码协销表.md |  |  | 号码协销表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 043 | 订单协销表 | zone_gz_yz.dwd_yz_ba_obj_xx_final | zone_gz_yz.dwd_yz_ba_obj_xx_final | tables/043_订单协销表.md |  |  | 订单协销表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 047 | 最终版划小收入 | dwm_srhx_serv_list_mon | dwm_srhx_serv_list_mon | tables/047_最终版划小收入.md |  |  | 最终版划小收入相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 048 | 全量科目级收入 | dwm_srhx_src_income_list_mon | dwm_srhx_src_income_list_mon | tables/048_全量科目级收入.md | 服务/号码级科目收入明细 | month_id | 全量科目级收入、按 SR 科目/due_income_code 取税后收入 sum(fee_all)；最新月表 `dwm_srhx_src_income_list` 只放最新收入月份 | 字段名相似但业务事实不在本表时不要选；划小收入汇总用 047；历史月/多账期用 `_mon` |
| 049 | 欠费日清单 | ads_ys_lst_qf_pushdata_daily_bss | ads_ys_lst_qf_pushdata_daily_bss | tables/049_欠费日清单.md |  |  | 欠费日清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 050 | 宽带到达套餐收入清单 | zone_gz_yz.ads_yz_kddd_tcsr_list | zone_gz_yz.ads_yz_kddd_tcsr_list | tables/050_宽带到达套餐收入清单.md |  | par_month_id | 宽带到达套餐收入清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 051 | 小业务收入多维表 | zone_gz_yz.ads_yz_ict_all_ydxyw_sr_LIST | zone_gz_yz.ads_yz_ict_all_ydxyw_sr_LIST | tables/051_小业务收入多维表.md |  | par_month_id | 小业务收入多维表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 052 | 调退清单 | zone_gz_yz.ads_ys_tt_daily | zone_gz_yz.ads_ys_tt_daily | tables/052_调退清单.md |  |  | 调退清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 053 | 宽带到达监控多维表 | zone_gz_yz.ads_yz_lch_kd_list_mid | zone_gz_yz.ads_yz_lch_kd_list_mid | tables/053_宽带到达监控多维表.md |  | par_month_id | 宽带到达监控多维表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 054 | 新入网辅导报表 | zone_gz_yz.dwd_yz_new_fudao_daily_list_bao | zone_gz_yz.dwd_yz_new_fudao_daily_list_bao | tables/054_新入网辅导报表.md |  |  | 新入网辅导报表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 055 | 滞纳金清单 | dwm_tb_zhinajin_baobiao_list_ys_site_mon | dwm_tb_zhinajin_baobiao_list_ys_site_mon | tables/055_滞纳金清单.md |  |  | 滞纳金清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 056 | 网络维护服务实缴清单 | zone_gz_yz.ads_yz_scb_kd_wlwhfw_ss_list | zone_gz_yz.ads_yz_scb_kd_wlwhfw_ss_list | tables/056_网络维护服务实缴清单.md |  |  | 网络维护服务实缴清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 057 | 视联网发展规模清单 | zone_gz_yz.ads_yz_slw_136_list | zone_gz_yz.ads_yz_slw_136_list | tables/057_视联网发展规模清单.md |  | par_month_id | 视联网发展规模清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 058 | 商客新建档客户清单 | zone_gz_yz.ads_yz_xjd_kh_list | zone_gz_yz.ads_yz_xjd_kh_list | tables/058_商客新建档客户清单.md |  |  | 商客新建档客户清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 059 | 客服投诉抱怨清单 | zone_gz_yz.ads_yz_kfb_tousu_bendi_month_list_end | zone_gz_yz.ads_yz_kfb_tousu_bendi_month_list_end | tables/059_客服投诉抱怨清单.md |  | par_month_id | 客服投诉抱怨清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 060 | 转化率 | zone_gz_yz.ads_yz_zhl_list | zone_gz_yz.ads_yz_zhl_list | tables/060_转化率.md |  | par_month_id | 转化率相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 061 | 移动固话叠加小业务清单 | zone_gz_yz.ads_yz_yd_gh_xyw_list | zone_gz_yz.ads_yz_yd_gh_xyw_list | tables/061_移动固话叠加小业务清单.md |  | par_month_id | 移动固话叠加小业务清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 062 | 预付费日清单 | zone_gz_yz.ads_ys_lst_balance_monitor | zone_gz_yz.ads_ys_lst_balance_monitor | tables/062_预付费日清单.md |  |  | 预付费日清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 063 | 公安举报涉诈数据清单 | zone_gz_yz.ads_yz_gajbsznbr_list | zone_gz_yz.ads_yz_gajbsznbr_list | tables/063_公安举报涉诈数据清单.md |  | par_month_id | 公安举报涉诈数据清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 064 | 固话延伸核查清单 | zone_gz_yz.ads_yz_fz_ghyshc_list_final | zone_gz_yz.ads_yz_fz_ghyshc_list_final | tables/064_固话延伸核查清单.md |  |  | 固话延伸核查清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 065 | 双线续约清单 | zone_gz_yz.ads_yz_sx_xy_list | zone_gz_yz.ads_yz_sx_xy_list | tables/065_双线续约清单.md |  |  | 双线续约清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 066 | 移动小业务退订清单 | zone_gz_yz.ads_yz_all_ydxyw_TD_LIST | zone_gz_yz.ads_yz_all_ydxyw_TD_LIST | tables/066_移动小业务退订清单.md |  | par_month_id | 移动小业务退订清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 067 | 实名装维清单 | zone_gz_yz.ads_yz_smzw_list | zone_gz_yz.ads_yz_smzw_list | tables/067_实名装维清单.md |  |  | 实名装维清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 068 | 燃气卫士到达清单 | zone_gz_yz.ads_yz_rqws_list | zone_gz_yz.ads_yz_rqws_list | tables/068_燃气卫士到达清单.md |  | par_month_id | 燃气卫士到达清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 069 | 全业务资料表 | ads_yz_tb_comm_cm_all_final | dwm_yz_tb_comm_cm_all_final | tables/069_全业务资料表.md | 以 serv_id 为服务粒度；账期/统计月份一般为 par_month_id | par_month_id | 全业务资料表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 070 | 小微场景化手工计列清单 | zone_gz_yz.ads_yz_ict_all_cjhbb2024_sr_LIST | zone_gz_yz.ads_yz_ict_all_cjhbb2024_sr_LIST | tables/070_小微场景化手工计列清单.md |  | par_month_id | 小微场景化手工计列清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 073 | 存量未托收清单 | zone_gz_yz.ads_yz_clts_change_list_mon | zone_gz_yz.ads_yz_clts_change_list_mon | tables/073_存量未托收清单.md |  |  | 存量未托收清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 074 | 安全产品清单 | zone_gz_yz.ADS_YZ_ACCP_NEW_LIST | zone_gz_yz.ADS_YZ_ACCP_NEW_LIST | tables/074_安全产品清单.md |  | par_month_id | 安全产品清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 075 | 小微收入清单 | zone_gz_yz.ads_yz_ict2024_all_sr_LIST_ex_list | zone_gz_yz.ads_yz_ict2024_all_sr_LIST_ex_list | tables/075_小微收入清单.md |  | par_month_id | 小微收入清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 077 | 家庭地址客户入网价值清单 | zone_gz_yz.ads_yz_yzn_addr_label_setting_list | zone_gz_yz.ads_yz_yzn_addr_label_setting_list | tables/077_家庭地址客户入网价值清单.md |  | par_month_id | 家庭地址客户入网价值清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 080 | 大额榜单账单级清单 | zone_gz_yz.ads_ys_bd_bill | zone_gz_yz.ads_ys_bd_bill | tables/080_大额榜单账单级清单.md |  |  | 大额榜单账单级清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 081 | 揽装积分清单 | ads_yz_lyf_lz | ads_yz_lyf_lz | tables/081_揽装积分清单.md | 揽装积分专项口径/派生清单 | par_month_id | 用户明确点名揽装积分专项表、揽装积分清单专项口径或 `ads_yz_lyf_lz` 时使用 | 积分类全量明细默认用 012；不要仅因用户说揽装积分、价值积分、激励积分就自动切到本表 |
| 082 | 双线净增积分清单 | ads_yz_tb_tyks_score_inc_zx_mtd | ads_yz_tb_tyks_score_inc_zx_mtd | tables/082_双线净增积分清单.md |  |  | 双线净增积分清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 083 | 拆机登记清单（新） | ads_yz_tb_zsh_cjdj_list | ads_yz_tb_zsh_cjdj_list | tables/083_拆机登记清单（新）.md |  | par_month_id | 拆机登记清单（新）相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 087 | 片区收入多维表 | ads_srhx_xxb_wyh_region_list_mon | ads_srhx_xxb_wyh_region_list_mon | tables/087_片区收入多维表.md |  | par_month_id | 片区收入多维表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 088 | 财务部收入多维表 | ads_yz_cwb_sr_list | ads_yz_cwb_sr_list | tables/088_财务部收入多维表.md |  | par_month_id | 财务部收入多维表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 089 | 财务部佣金多维表 | ads_yz_yj_list | ads_yz_yj_list | tables/089_财务部佣金多维表.md |  | par_month_id | 财务部佣金多维表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 090 | 财务部终端装维成本 | ads_yz_zwzd_cost_all_list | ads_yz_zwzd_cost_all_list | tables/090_财务部终端装维成本.md |  | par_month_id | 财务部终端装维成本相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 091 | 财务部积分多维表 | ads_yz_finance_jf_list | ads_yz_finance_jf_list | tables/091_财务部积分多维表.md |  | par_month_id | 财务部积分多维表相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 092 | 网点保证金 | ads_ys_deposit | ads_ys_deposit | tables/092_网点保证金.md |  |  | 网点保证金相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 093 | 移动宽带质态监控多维表-宽带清单 | ads_zt_kdx_list | ads_zt_kdx_list | tables/093_移动宽带质态监控多维表-宽带清单.md |  | par_month_id | 移动宽带质态监控多维表-宽带清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 095 | 历史欠不列月清单 | ads_ys_lst_qbl_mon | ads_ys_lst_qbl_mon | tables/095_历史欠不列月清单.md |  |  | 历史欠不列月清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 096 | 酒宽续约清单 | ads_yz_jdkd_xy_list | ads_yz_jdkd_xy_list | tables/096_酒宽续约清单.md |  | par_month_id | 酒宽续约清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 097 | 基本面月清单 | ads_ys_jbm | ads_ys_jbm | tables/097_基本面月清单.md |  |  | 基本面月清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 098 | 医保竣工清单 | ads_wjbg_list | ads_wjbg_list | tables/098_医保竣工清单.md |  | par_month_id | 医保竣工清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 099 | 医保未竣工清单 | ads_yb_wjg_list | ads_yb_wjg_list | tables/099_医保未竣工清单.md |  | par_month_id | 医保未竣工清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 100 | 欠补列日清单 | zone_gz_yz.ads_ys_qbl_real | zone_gz_yz.ads_ys_qbl_real | tables/100_欠补列日清单.md |  |  | 欠补列日清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 101 | 台阶收入清单 | ads_yz_xsb_tjsr_skj_list_db | ads_yz_xsb_tjsr_skj_list_db | tables/101_台阶收入清单.md |  | par_month_id | 台阶收入清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 103 | 存量专线提（降）值清单 | ads_yz_sx_cltz_gt | ads_yz_sx_cltz_gt | tables/103_存量专线提（降）值清单.md |  |  | 存量专线提（降）值清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 104 | 降档清单 | ads_yz_jd_list | ads_yz_jd_list | tables/104_降档清单.md |  | par_month_id | 降档清单相关取数；先按表文档字段和常用条件核对 | 字段名相似但业务事实不在本表时不要选 |
| 105 | 特性资料表 | summary_ods_day_city.tb_pre_cm_attr_all | summary_ods_day_city.tb_pre_cm_attr_all（日表）；iodata_ods_month_city.tb_pre_cm_attr_all_mon（月表） | tables/105_特性资料表.md | serv_id + attr_id；月表按 par_month_id 快照 | par_corp_id, par_month_id | **产品规格**属性/特性值；历史或拆机前月快照；号码 IMSI 用 `attr_id='200000103'` 输出 `attr_value1` | 日表只在网；附属产品走 106；普通号码 IMSI 不要走 114 国漫表 |
| 106 | 附属产品资料表 | summary_ods_day_city.rpt_comm_cm_subserv | summary_ods_day_city.rpt_comm_cm_subserv（日表）；iodata_ods_month_city.rpt_comm_cm_subserv_mon（月表） | tables/106_附属产品资料表.md | serv_id + attr_id；月表按 par_month_id 快照 | par_corp_id, par_month_id | **附属产品**属性/特性值；历史或拆机前月快照 | 日表只在网；产品规格走 105 |
| 107 | 销售品参数表 | summary_ods_day_city.rpt_comm_cm_msparam | summary_ods_day_city.rpt_comm_cm_msparam | tables/107_销售品参数表.md | serv_id + prod_offer_id + param_code（以生产表为准） | par_corp_id | 销售品参数值补全；用户问折扣、赠金、统付金额、优惠参数等，先由 069/014 锁定 `serv_id` 与 `prod_offer_id` 后补 `param_value` | 不要作为销售品在档事实表；在档/到期时间先查 014；`param_code` 不可猜 |
| 108 | 产权客户全量表 | dws_crm_cust.dws_customer | dws_crm_cust.dws_customer | tables/108_产权客户全量表.md | 产权客户粒度（以生产表为准） |  | 产权客户信息；按 `cust_name` 兜底补 `cust_number` | 客户名可能重名；有产权客户编码时优先编码匹配 |
| 109 | 直销客户表 | zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final | zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final | tables/109_直销客户表.md | 产权客户到直销客户映射关系（以生产表为准） |  | 按 `cust_nbr` 补 `ccust_code`、`ccust_name`、机构 ID；机构名称再补 018 | 不要把机构 ID 字段脱离来源语义直接解释；可能一对多 |
| 110 | 结算账单表 | dws_tpss_jszx.dws_settle_bill | dws_tpss_jszx.dws_settle_bill | tables/110_结算账单表.md | 结算账单 / 报账单粒度；包含合同、合作伙伴、网点、经营主体、金额和状态字段 | shard, billing_cycle_id | 结算账单、报账、合同编码、合作伙伴、网点、经营主体、支付/审核状态等取数；市场化承包合同下查网点和有效揽装人时作为合同网点事实来源 | 普通号码、服务、订单、积分或收入明细事实不要误选 |
| 111 | 揽装人维表 | zone_gz_yz.dwd_yz_sales_man_final | zone_gz_yz.dwd_yz_sales_man_final；zone_gz_yz.dwd_yz_sales_man_mon_final | tables/111_揽装人维表.md | 揽装人粒度；日表唯一，月表按 `par_month_id` 快照 | par_month_id（月表） | 查揽装人信息、有效性、归属网点 `own_channel_id`；历史账期用月表 | `sales_code` 不唯一，不要作为揽装人唯一 JOIN / 去重键 |
| 112 | 网点维表 | zone_gz_yz.dwd_yz_sale_outlers_final | zone_gz_yz.dwd_yz_sale_outlers_final；zone_gz_yz.dwd_yz_sale_outlers_mon_final | tables/112_网点维表.md | 网点粒度；日表唯一，月表按 `par_month_id` 快照 | par_month_id（月表） | 查网点编码、名称、有效性、经营主体及机构归属；历史账期用月表 | 不要把网点表当号码或收入事实表 |
| 113 | 揽装所属表 | zone_gz_yz.dwd_yz_sales_man_outlers_final | zone_gz_yz.dwd_yz_sales_man_outlers_final；zone_gz_yz.dwd_yz_sales_man_outlers_mon_final | tables/113_揽装所属表.md | 有效揽装人 + 有效网点对应关系；月表按 `par_month_id` 快照 | par_month_id（月表） | 查有效网点下有效揽装人、合同网点实际工号数量、无号码收入网点诊断；优先用 `staff_id` 关联揽装人 | 只含有效组合；缺记录不等于网点不存在，需回查 111/112 判断无效或无揽装人 |
| 114 | 国际漫游数据表 | dws_ctg.dws_mktag_download_share_guoman_label | dws_ctg.dws_mktag_download_share_guoman_label | tables/114_国际漫游数据表.md | 已开通国际漫游权限的号码日分区数据；号码粒度以 `msisdn + yyyymmdd` 为准 | yyyymmdd | 查已开通国际漫游权限号码、用户开户时间、开通国漫权限时间、G/L IMSI；常与 069 按号码补字段 | 不要当漫游收入或漫游使用行为表；`yyyymmdd` 是日分区/统计日，不是 069 账期 |
| 115 | 员工信息表 | dws_crm_cfguse.dws_staff | dws_crm_cfguse.dws_staff | tables/115_员工信息表.md | 员工信息粒度；同一员工编码可能存在历史多版本记录 |  | 按号码揽装人 `sales_code` 补员工姓名、员工标识、11 开头 CRM 工号 `staff_account`；常用 `city_id='200'` | 不要替代 111 判断揽装人有效性；历史多版本必须按 `status_date desc` 去重 |
