# CDAP 表索引（运行时）

> 机器友好的表目录。**路由决策看 `ROUTING.md`，本文件只做表名/Hive 名查找。** 落 SQL 前仍需打开 `tables/*.md` 核对 frontmatter、字段、分区和常用条件。

## 使用规则

- 优先按 `table_name`、`hive_name`、`prod_hive_name`、业务事实共同定位，不只看序号。
- `prod_hive_name` 非空时，落 SQL 优先使用生产现网名，并在输出中让用户校对。
- 字段、分区、粒度以 `file_path` 指向的表文档为准。
- 本文件只回答“可能是哪张表”和 `file_path`；主表路由决策见 `ROUTING.md`，不要在本文件重复路由。
- 如果用户已经明确主表或生产表名，不要用本文件改写用户选择；只用来核对表文档路径和生产表名。

## 快速定位

本文件只做表名 / Hive 名 / `file_path` 查找。**主表路由决策见 `ROUTING.md`**；标准指标见 `METRIC_INDEX.md`；复杂专项见 `scenarios/INDEX.md`。

| 查什么 | 去哪里 |
|---|---|
| 业务需求 → 主表怎么选 | `ROUTING.md` |
| 标准指标 → 技术口径 SQL | `METRIC_INDEX.md` + `metrics/` |
| 生产表名 / Hive 名 / 表文档路径 | 下方完整索引表 |
| 附件驱动 / 跨表编排专项 | `scenarios/INDEX.md` |

## 选表输出要求

输出“主表确认”时，至少带出：

- `table_id`、`table_name`、`prod_hive_name`。
- `file_path`，方便下一步打开表文档做字段映射。
- 选表理由：一句话说明业务事实为什么在这张表。
- 排除项：列出 1-3 张容易误选的表及原因。

| table_id | table_name | hive_name | prod_hive_name | file_path | grain | partition_keys | use_when | avoid_when |
|---|---|---|---|---|---|---|---|---|
|000|账务信息关系表|||tables/000_账务信息关系表.md|||-|-||
| 001 | 移动新装清单 | dwd_yz_cm_cdma_ydxz_list | dwd_yz_cm_cdma_ydxz_list | tables/001_移动新装清单.md |  | par_month_id | 用户明确要移动新装专项清单字段或专项报表口径 | 常规移动入网/到达规模用 069 |
|002|fttr清单|dwm_fttr_list|dwm_fttr_list|tables/002_fttr清单.md||par_month_id|-|-||
|003|小微ICT竣工清单|ads_yz_xwict_all_list|ads_yz_xwict_all_list|tables/003_小微ICT竣工清单.md||par_month_id|-|-||
|004|合约清单|dwm_yz_cm_cdma_hy_final|dwm_yz_cm_cdma_hy_final|tables/004_合约清单.md|||-|-||
|005|移动划小清单|ads_yz_cdma_hx_list|ads_yz_cdma_hx_list|tables/005_移动划小清单.md|||-|-||
| 006 | 宽带新装清单 | ads_yz_kd_new_list | ads_yz_kd_new_list | tables/006_宽带新装清单.md |  |  | 用户明确要宽带新装专项清单字段或专项报表口径 | 常规宽带入网/到达规模用 069 |
|007|净增积分清单|ads_yz_tb_tyks_score_inc_mtd|ads_yz_tb_tyks_score_inc_mtd|tables/007_净增积分清单.md|||-|-||
|008|129+套餐升降档路径清单|ads_yz_bd129_sdjd_list|ads_yz_bd129_sdjd_list|tables/008_129+套餐升降档路径清单.md||par_month_id|-|-||
|009|129+套餐升降档路径多维表|ads_yz_bd129_sdjd_dwb|ads_yz_bd129_sdjd_dwb|tables/009_129+套餐升降档路径多维表.md|||-|-||
|010|降档原始清单|ads_yz_sunshou_acc_list|ads_yz_sunshou_acc_list|tables/010_降档原始清单.md|||-|-||
|011|降档动作订单清单|ads_yz_sunshou_qudao|ads_yz_sunshou_qudao|tables/011_降档动作订单清单.md|||-|-||
| 012 | 发展存量积分清单 | ads_yz_score_all_list | ads_yz_score_all_list | tables/012_发展存量积分清单.md | 积分类全量明细底表，含号码/服务/积分类型/客户/网格/积分字段 | par_month_id | 积分类全量明细、发展积分、存量积分，以及需要积分类型层级、号码、客户、网格、竣工时间、价值/激励积分及描述的取数 | 字段名相似但业务事实不在本表时不要选；明确专项指标/专项表口径时再看 007/081/082/091 |
| 014 | 优惠资料表 | ads_yz_rpt_comm_cm_msdisc_final | ads_yz_rpt_comm_cm_msdisc_final；dwd_yz_rpt_comm_cm_msdisc_mon_final（月表/历史快照） | tables/014_优惠资料表.md | 销售品在档实例粒度 | par_month_id | 销售品存量、在档、有没有某套餐；历史账期/协议到期核查用月表 | 销售品订购/发展量动作用 041 |
|015|字典表视图|dws_crm_cfguse.dws_attr_value|dws_crm_cfguse.dws_attr_value|tables/015_字典表视图.md|||-|-||
|016|字典维表视图|dws_crm_cfguse.dws_attr_SPEC|dws_crm_cfguse.dws_attr_SPEC|tables/016_字典维表视图.md|||-|-||
|017|产品维表视图|dws_crm_cfguse.dws_product|dws_crm_cfguse.dws_product|tables/017_产品维表视图.md|||-|-||
|018|机构维表视图|zone_gz_yz.dwd_yz_dim_org|zone_gz_yz.dwd_yz_dim_org|tables/018_机构维表视图.md|||-|-||
| 019 | 移动主套餐维表视图 | metadata_ods_day.md_ft_cdma_disc_config | metadata_ods_day.md_ft_cdma_disc_config | tables/019_移动主套餐维表视图.md | 移动主套餐 ID 维度 |  | 按 069 或其它移动事实表 `cdma_disc_type` 回填移动主套餐名称 `cdma_disc_desc` | 不要替代 020 销售品维表；主表已自带主套餐名称时不必补 |
|020|销售品维表视图|dws_crm_cfguse.dws_offer|dws_crm_cfguse.dws_offer|tables/020_销售品维表视图.md|||-|-||
| 079 | 地址维表 | zone_gz_yz.dwd_yz_addr_final | zone_gz_yz.dwd_yz_addr_final | tables/079_地址维表.md | 以 id 为地址粒度；grade 表示地址层级 |  | 地址 / 装机地址 / 指定地址层级相关取数；主业务表取 `serv_addr_id` 后统一转字符关联 `id`，装机地址默认 `grade=10`，目标层级按 `parentid` 或 `addr_id_*` 上卷后再关联目标 `grade` | 字段名相似但业务事实不在本表时不要选；不要把 `serv_addr_id` 默认强转 decimal |
|022|商企入网清单|zone_gz_yz.ads_yz_shangqi_rw_list|zone_gz_yz.ads_yz_shangqi_rw_list|tables/022_商企入网清单.md||par_month_id|-|-||
|023|基础业务托收清单|zone_gz_yz.ads_yz_tb_cl_tuoshou_list|zone_gz_yz.ads_yz_tb_cl_tuoshou_list|tables/023_基础业务托收清单.md||par_month_id|-|-||
|024|营业厅月度订单受理量清单|zone_gz_yz.ads_yz_yyt_sl_list|zone_gz_yz.ads_yz_yyt_sl_list|tables/024_营业厅月度订单受理量清单.md|||-|-||
|025|专业营服全业务清单（改革）|ads_yz_tb_comm_cm_all_zyyf_final|ads_yz_tb_comm_cm_all_zyyf_final|tables/025_专业营服全业务清单（改革）.md||par_month_id|-|-||
|026|小微ict场景化收入数据|zone_gz_yz.ads_yz_scb_ict_fee_list|zone_gz_yz.ads_yz_scb_ict_fee_list|tables/026_小微ict场景化收入数据.md||par_month_id|-|-||
|027|满卡报表清单|zone_gz_yz.ads_yz_mk_list|zone_gz_yz.ads_yz_mk_list|tables/027_满卡报表清单.md||par_month_id|-|-||
|029|企微粉丝清单报表|zone_gz_yz.dwd_yz_qywx_daily_list_end|zone_gz_yz.dwd_yz_qywx_daily_list_end|tables/029_企微粉丝清单报表.md||par_month_id|-|-||
|071|小微清单2024|zone_gz_yz.ads_yz_ict_all2024_LIST|zone_gz_yz.ads_yz_ict_all2024_LIST|tables/071_小微清单2024.md|以 serv_id / 客户维度为主的清单粒度（以实际报表为准）|par_month_id|-|-||
|030|移动续约清单|ads_yz_ydxy_daily_list|ads_yz_ydxy_daily_list|tables/030_移动续约清单.md|||-|-||
|031|移动续约多维表|ads_yz_ydxy_group|ads_yz_ydxy_group|tables/031_移动续约多维表.md|||-|-||
|032|宽带续约清单|ads_yz_kd_xy_list|ads_yz_kd_xy_list|tables/032_宽带续约清单.md||par_month_id|-|-||
|033|双线全量清单|ads_yz_sx_qlyz_list|ads_yz_sx_qlyz_list|tables/033_双线全量清单.md||par_month_id|-|-||
|034|主宽拆机挽留清单|ads_yz_kd_cjwl_list|ads_yz_kd_cjwl_list|tables/034_主宽拆机挽留清单.md|||-|-||
|035|反诈资料宽表|dwm_yz_fz_rpt_comm_cm_serv_d_final|dwm_yz_fz_rpt_comm_cm_serv_d_final|tables/035_反诈资料宽表.md||par_month_id|-|-||
|036|政企移动入网清单报表|dwd_yz_zhengqi_yd_new_daily_list_end|dwd_yz_zhengqi_yd_new_daily_list_end|tables/036_政企移动入网清单报表.md||par_month_id|-|-||
|039|欠不列预警清单|zone_gz_yz.ads_ys_qblyj_daily|zone_gz_yz.ads_ys_qblyj_daily|tables/039_欠不列预警清单.md|||-|-||
|040|全业务号码订单表|zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final|zone_gz_yz.dwm_yz_rpt_comm_ba_subs_final|tables/040_全业务号码订单表.md|||-|-||
| 041 | 优惠订单表 | zone_gz_yz.dwm_yz_rpt_comm_ba_msdisc_final | dwm_yz_rpt_comm_ba_msdisc_final；dwm_yz_rpt_comm_ba_msdisc_mon_final（月表/历史归档） | tables/041_优惠订单表.md | 订单粒度（subs_id 唯一） | par_month_id（月表） | 销售品发展量、订购、互换等订单动作；历史月份订单用月表 | 当前表只放当前套餐订单及历史未归档订单；查历史月份不要只扫当前表；销售品在档/存量用 014 |
|042|号码协销表|zone_gz_yz.dwd_yz_cm_obj_xx_final|zone_gz_yz.dwd_yz_cm_obj_xx_final|tables/042_号码协销表.md|||-|-||
|043|订单协销表|zone_gz_yz.dwd_yz_ba_obj_xx_final|zone_gz_yz.dwd_yz_ba_obj_xx_final|tables/043_订单协销表.md|||-|-||
| 047 | 最终版划小收入 | dwm_srhx_serv_list_mon | dwm_srhx_serv_list_mon_final | tables/047_最终版划小收入.md | 服务/月收入明细，可按 `cust_nbr` 汇总到客户级 | par_month_id | 划小收入、客户清单基本面/产数（`fee_fm_new`/`fee_cs`）；编排见 `scenarios/SC-009` | 不要用 069 费用字段替代；标准指标口径见 097/metrics |
| 048 | 全量科目级收入 | dwm_srhx_src_income_list_mon | dwm_srhx_src_income_list_mon | tables/048_全量科目级收入.md | 服务/号码级科目收入明细 | month_id | 全量科目级收入、按 SR 科目/due_income_code 取税后收入 sum(fee_all)；最新月表 `dwm_srhx_src_income_list` 只放最新收入月份 | 字段名相似但业务事实不在本表时不要选；划小收入汇总用 047；历史月/多账期用 `_mon` |
|049|欠费日清单|ads_ys_lst_qf_pushdata_daily_bss|ads_ys_lst_qf_pushdata_daily_bss|tables/049_欠费日清单.md|||-|-||
|050|宽带到达套餐收入清单|zone_gz_yz.ads_yz_kddd_tcsr_list|zone_gz_yz.ads_yz_kddd_tcsr_list|tables/050_宽带到达套餐收入清单.md||par_month_id|-|-||
|051|小业务收入多维表|zone_gz_yz.ads_yz_ict_all_ydxyw_sr_LIST|zone_gz_yz.ads_yz_ict_all_ydxyw_sr_LIST|tables/051_小业务收入多维表.md||par_month_id|-|-||
|052|调退清单|zone_gz_yz.ads_ys_tt_daily|zone_gz_yz.ads_ys_tt_daily|tables/052_调退清单.md|||-|-||
|053|宽带到达监控多维表|zone_gz_yz.ads_yz_lch_kd_list_mid|zone_gz_yz.ads_yz_lch_kd_list_mid|tables/053_宽带到达监控多维表.md||par_month_id|-|-||
|054|新入网辅导报表|zone_gz_yz.dwd_yz_new_fudao_daily_list_bao|zone_gz_yz.dwd_yz_new_fudao_daily_list_bao|tables/054_新入网辅导报表.md|||-|-||
|055|滞纳金清单|dwm_tb_zhinajin_baobiao_list_ys_site_mon|dwm_tb_zhinajin_baobiao_list_ys_site_mon|tables/055_滞纳金清单.md|||-|-||
|056|网络维护服务实缴清单|zone_gz_yz.ads_yz_scb_kd_wlwhfw_ss_list|zone_gz_yz.ads_yz_scb_kd_wlwhfw_ss_list|tables/056_网络维护服务实缴清单.md|||-|-||
|057|视联网发展规模清单|zone_gz_yz.ads_yz_slw_136_list|zone_gz_yz.ads_yz_slw_136_list|tables/057_视联网发展规模清单.md||par_month_id|-|-||
|058|商客新建档客户清单|zone_gz_yz.ads_yz_xjd_kh_list|zone_gz_yz.ads_yz_xjd_kh_list|tables/058_商客新建档客户清单.md|||-|-||
|059|客服投诉抱怨清单|zone_gz_yz.ads_yz_kfb_tousu_bendi_month_list_end|zone_gz_yz.ads_yz_kfb_tousu_bendi_month_list_end|tables/059_客服投诉抱怨清单.md||par_month_id|-|-||
|060|转化率|zone_gz_yz.ads_yz_zhl_list|zone_gz_yz.ads_yz_zhl_list|tables/060_转化率.md||par_month_id|-|-||
|061|移动固话叠加小业务清单|zone_gz_yz.ads_yz_yd_gh_xyw_list|zone_gz_yz.ads_yz_yd_gh_xyw_list|tables/061_移动固话叠加小业务清单.md||par_month_id|-|-||
|062|预付费日清单|zone_gz_yz.ads_ys_lst_balance_monitor|zone_gz_yz.ads_ys_lst_balance_monitor|tables/062_预付费日清单.md|||-|-||
|063|公安举报涉诈数据清单|zone_gz_yz.ads_yz_gajbsznbr_list|zone_gz_yz.ads_yz_gajbsznbr_list|tables/063_公安举报涉诈数据清单.md||par_month_id|-|-||
|064|固话延伸核查清单|zone_gz_yz.ads_yz_fz_ghyshc_list_final|zone_gz_yz.ads_yz_fz_ghyshc_list_final|tables/064_固话延伸核查清单.md|||-|-||
|065|双线续约清单|zone_gz_yz.ads_yz_sx_xy_list|zone_gz_yz.ads_yz_sx_xy_list|tables/065_双线续约清单.md|||-|-||
|066|移动小业务退订清单|zone_gz_yz.ads_yz_all_ydxyw_TD_LIST|zone_gz_yz.ads_yz_all_ydxyw_TD_LIST|tables/066_移动小业务退订清单.md||par_month_id|-|-||
|067|实名装维清单|zone_gz_yz.ads_yz_smzw_list|zone_gz_yz.ads_yz_smzw_list|tables/067_实名装维清单.md|||-|-||
|068|燃气卫士到达清单|zone_gz_yz.ads_yz_rqws_list|zone_gz_yz.ads_yz_rqws_list|tables/068_燃气卫士到达清单.md||par_month_id|-|-||
| 069 | 全业务资料表 | ads_yz_tb_comm_cm_all_final | dwm_yz_tb_comm_cm_all_final；dwm_yz_tb_comm_cm_all_mon_final | tables/069_全业务资料表.md | 以 serv_id 为服务粒度；账期/统计月份一般为 par_month_id | par_month_id | 入网/到达/在网/出账等全业务规模默认主表；近半年账期优先日表，更早历史走月表，重叠默认日表 | 订单动作用 040/041；收入用 047/048/117；勿用 069 费用字段替代收入明细 |
|070|小微场景化手工计列清单|zone_gz_yz.ads_yz_ict_all_cjhbb2024_sr_LIST|zone_gz_yz.ads_yz_ict_all_cjhbb2024_sr_LIST|tables/070_小微场景化手工计列清单.md||par_month_id|-|-||
|073|存量未托收清单|zone_gz_yz.ads_yz_clts_change_list_mon|zone_gz_yz.ads_yz_clts_change_list_mon|tables/073_存量未托收清单.md|||-|-||
|074|安全产品清单|zone_gz_yz.ADS_YZ_ACCP_NEW_LIST|zone_gz_yz.ADS_YZ_ACCP_NEW_LIST|tables/074_安全产品清单.md||par_month_id|-|-||
|075|小微收入清单|zone_gz_yz.ads_yz_ict2024_all_sr_LIST_ex_list|zone_gz_yz.ads_yz_ict2024_all_sr_LIST_ex_list|tables/075_小微收入清单.md||par_month_id|-|-||
|077|家庭地址客户入网价值清单|zone_gz_yz.ads_yz_yzn_addr_label_setting_list|zone_gz_yz.ads_yz_yzn_addr_label_setting_list|tables/077_家庭地址客户入网价值清单.md||par_month_id|-|-||
|080|大额榜单账单级清单|zone_gz_yz.ads_ys_bd_bill|zone_gz_yz.ads_ys_bd_bill|tables/080_大额榜单账单级清单.md|||-|-||
| 081 | 揽装积分清单 | ads_yz_lyf_lz | ads_yz_lyf_lz | tables/081_揽装积分清单.md | 揽装积分专项口径/派生清单 | par_month_id | 用户明确点名揽装积分专项表、揽装积分清单专项口径或 `ads_yz_lyf_lz` 时使用 | 积分类全量明细默认用 012；不要仅因用户说揽装积分、价值积分、激励积分就自动切到本表 |
|082|双线净增积分清单|ads_yz_tb_tyks_score_inc_zx_mtd|ads_yz_tb_tyks_score_inc_zx_mtd|tables/082_双线净增积分清单.md|||-|-||
|083|拆机登记清单（新）|ads_yz_tb_zsh_cjdj_list|ads_yz_tb_zsh_cjdj_list|tables/083_拆机登记清单（新）.md||par_month_id|-|-||
|087|片区收入多维表|ads_srhx_xxb_wyh_region_list_mon|ads_srhx_xxb_wyh_region_list_mon|tables/087_片区收入多维表.md||par_month_id|-|-||
|088|财务部收入多维表|ads_yz_cwb_sr_list|ads_yz_cwb_sr_list|tables/088_财务部收入多维表.md||par_month_id|-|-||
|089|财务部佣金多维表|ads_yz_yj_list|ads_yz_yj_list|tables/089_财务部佣金多维表.md||par_month_id|-|-||
|090|财务部终端装维成本|ads_yz_zwzd_cost_all_list|ads_yz_zwzd_cost_all_list|tables/090_财务部终端装维成本.md||par_month_id|-|-||
|091|财务部积分多维表|ads_yz_finance_jf_list|ads_yz_finance_jf_list|tables/091_财务部积分多维表.md||par_month_id|-|-||
|092|网点保证金|ads_ys_deposit|ads_ys_deposit|tables/092_网点保证金.md|||-|-||
|093|移动宽带质态监控多维表-宽带清单|ads_zt_kdx_list|ads_zt_kdx_list|tables/093_移动宽带质态监控多维表-宽带清单.md||par_month_id|-|-||
|095|历史欠不列月清单|ads_ys_lst_qbl_mon|ads_ys_lst_qbl_mon|tables/095_历史欠不列月清单.md|||-|-||
|096|酒宽续约清单|ads_yz_jdkd_xy_list|ads_yz_jdkd_xy_list|tables/096_酒宽续约清单.md||par_month_id|-|-||
| 097 | 基本面月清单 | ads_ys_jbm | ads_ys_jbm | tables/097_基本面月清单.md |  |  | 基本面收入专项口径 | 客户级划小收入用 047 |
|098|医保竣工清单|ads_wjbg_list|ads_wjbg_list|tables/098_医保竣工清单.md||par_month_id|-|-||
|099|医保未竣工清单|ads_yb_wjg_list|ads_yb_wjg_list|tables/099_医保未竣工清单.md||par_month_id|-|-||
|100|欠补列日清单|zone_gz_yz.ads_ys_qbl_real|zone_gz_yz.ads_ys_qbl_real|tables/100_欠补列日清单.md|||-|-||
|101|台阶收入清单|ads_yz_xsb_tjsr_skj_list_db|ads_yz_xsb_tjsr_skj_list_db|tables/101_台阶收入清单.md||par_month_id|-|-||
|103|存量专线提（降）值清单|ads_yz_sx_cltz_gt|ads_yz_sx_cltz_gt|tables/103_存量专线提（降）值清单.md|||-|-||
|104|降档清单|ads_yz_jd_list|ads_yz_jd_list|tables/104_降档清单.md||par_month_id|-|-||
| 105 | 特性资料表 | summary_ods_day_city.tb_pre_cm_attr_all | summary_ods_day_city.tb_pre_cm_attr_all（日表）；iodata_ods_month_city.tb_pre_cm_attr_all_mon（月表） | tables/105_特性资料表.md | serv_id + attr_id；月表按 par_month_id 快照 | par_corp_id, par_month_id | **产品规格**属性/特性值；历史或拆机前月快照；号码 IMSI 用 `attr_id='200000103'` 输出 `attr_value1` | 日表只在网；附属产品走 106；普通号码 IMSI 不要走 114 国漫表 |
| 106 | 附属产品资料表 | summary_ods_day_city.rpt_comm_cm_subserv | summary_ods_day_city.rpt_comm_cm_subserv（日表）；iodata_ods_month_city.rpt_comm_cm_subserv_mon（月表） | tables/106_附属产品资料表.md | serv_id + attr_id；月表按 par_month_id 快照 | par_corp_id, par_month_id | **附属产品**属性/特性值；历史或拆机前月快照 | 日表只在网；产品规格走 105 |
| 107 | 销售品参数表 | summary_ods_day_city.rpt_comm_cm_msparam | summary_ods_day_city.rpt_comm_cm_msparam | tables/107_销售品参数表.md | serv_id + prod_offer_id + param_code（以生产表为准） | par_corp_id | 补 `param_value`（折扣/赠金/统付等）；链路见 `FIELD_BACKFILL.md` §销售品参数值（107） | 不作在档主表；在档用 014；`param_code` 不可猜 |
| 108 | 产权客户全量表 | dws_crm_cust.dws_customer | dws_crm_cust.dws_customer | tables/108_产权客户全量表.md | 产权客户粒度（以生产表为准） |  | 产权客户信息；按 `cust_name` 兜底补 `cust_number` | 客户名可能重名；有产权客户编码时优先编码匹配 |
| 109 | 直销客户表 | zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final | zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final | tables/109_直销客户表.md | 产权客户到直销客户映射关系（以生产表为准） |  | 按 `cust_nbr` 补 `ccust_code`、`ccust_name`、机构 ID；机构名称再补 018 | 不要把机构 ID 字段脱离来源语义直接解释；可能一对多 |
| 110 | 结算账单表 | dws_tpss_jszx.dws_settle_bill | dws_tpss_jszx.dws_settle_bill | tables/110_结算账单表.md | 结算账单 / 报账单粒度；包含合同、合作伙伴、网点、经营主体、金额和状态字段 | shard, billing_cycle_id | 结算账单、报账、合同编码、合作伙伴、网点、经营主体、支付/审核状态等取数；市场化承包合同下查网点和有效揽装人时作为合同网点事实来源 | 普通号码、服务、订单、积分或收入明细事实不要误选 |
| 111 | 揽装人维表 | zone_gz_yz.dwd_yz_sales_man_final | zone_gz_yz.dwd_yz_sales_man_final；zone_gz_yz.dwd_yz_sales_man_mon_final | tables/111_揽装人维表.md | 揽装人粒度；日表唯一，月表按 `par_month_id` 快照 | par_month_id（月表） | 查揽装人信息、有效性、归属网点 `own_channel_id`；历史账期用月表 | `sales_code` 不唯一，不要作为揽装人唯一 JOIN / 去重键 |
| 112 | 网点维表 | zone_gz_yz.dwd_yz_sale_outlers_final | zone_gz_yz.dwd_yz_sale_outlers_final；zone_gz_yz.dwd_yz_sale_outlers_mon_final | tables/112_网点维表.md | 网点粒度；日表唯一，月表按 `par_month_id` 快照 | par_month_id（月表） | 查网点编码、名称、有效性、经营主体及机构归属；历史账期用月表 | 不要把网点表当号码或收入事实表 |
| 113 | 揽装所属表 | zone_gz_yz.dwd_yz_sales_man_outlers_final | zone_gz_yz.dwd_yz_sales_man_outlers_final；zone_gz_yz.dwd_yz_sales_man_outlers_mon_final | tables/113_揽装所属表.md | 有效揽装人 + 有效网点对应关系；月表按 `par_month_id` 快照 | par_month_id（月表） | 查有效网点下有效揽装人、合同网点实际工号数量、无号码收入网点诊断；优先用 `staff_id` 关联揽装人 | 只含有效组合；缺记录不等于网点不存在，需回查 111/112 判断无效或无揽装人 |
| 114 | 国际漫游数据表 | dws_ctg.dws_mktag_download_share_guoman_label | dws_ctg.dws_mktag_download_share_guoman_label | tables/114_国际漫游数据表.md | 已开通国际漫游权限的号码日分区数据；号码粒度以 `msisdn + yyyymmdd` 为准 | yyyymmdd | 查已开通国际漫游权限号码、用户开户时间、开通国漫权限时间、G/L IMSI；常与 069 按号码补字段 | 不要当漫游收入或漫游使用行为表；`yyyymmdd` 是日分区/统计日，不是 069 账期 |
| 115 | 员工信息表 | dws_crm_cfguse.dws_staff | dws_crm_cfguse.dws_staff | tables/115_员工信息表.md | 员工信息粒度；同一员工编码可能存在历史多版本记录 |  | 按号码揽装人 `sales_code` 补员工姓名、员工标识、11 开头 CRM 工号 `staff_account`；常用 `city_id='200'` | 不要替代 111 判断揽装人有效性；历史多版本必须按 `status_date desc` 去重 |
| 116 | 固话使用记录月表 | summary_ods_month_city.tb_comm_ywl_gw_mon | summary_ods_month_city.tb_comm_ywl_gw_mon | tables/116_固话使用记录月表.md | 固话号码月使用记录；号码 + 月份粒度（以生产表为准） | par_corp_id, par_month_id | 按固话号码清单查询月份范围内的使用时长；`dur/60` 输出分钟 | 不要用于固话资料状态、收入或订单动作；严格到日的截止需确认日级来源 |
| 117 | 实收来源汇总表 | zone_gz_yz.dwd_yz_if_real_src_sum_new_final | zone_gz_yz.dwd_yz_if_real_src_sum_new_final | tables/117_实收来源汇总表.md | 号码/服务/月实收来源明细，可按 `acc_nbr`、`serv_id`、`par_month_id` 汇总 | par_month_id | 实收金额（附件/圈定/直查）；编排见 `scenarios/SC-009` | 不要与 047/048/069 混用 |
| 118 | 移机订单表 | dwd_yz_rpt_comm_ba_subs_move_final | dwd_yz_rpt_comm_ba_subs_move_final | tables/118_移机订单表.md | 移机订单明细；以移机订单/接入号/竣工时间为核心粒度 | par_month_id | 投诉号码匹配移机订单、查询移机成功订单编码和竣工时间、输出移机前后局向/营服/网格 | 不要用于普通入网/到达规模；移动投诉号码需先按 069 融合套内宽带转换后再关联 |
| 119 | 设备资源关系表 | ads_yz_prod_res_inst_rel_final | ads_yz_prod_res_inst_rel_final | tables/119_设备资源关系表.md | 服务与设备资源关系明细；同一 `serv_id` 可能多设备 |  | 按号码或服务清单回填设备名称、设备类型、购买方式、机身号、数量等设备资源字段 | 不要当入网订单、套餐在档或终端成本主表；附件只有号码时先用 069 补 `serv_id` |
| 120 | 产品关联关系表 | dws_crm_cust.dws_prod_inst_rel_a | dws_crm_cust.dws_prod_inst_rel_a | tables/120_产品关联关系表.md | A/Z 产品实例关联关系；主端 `a_prod_inst_id` 到子端 `z_prod_inst_id` | city_id | 群端/主从 AZ/同组 A-B 端关系；与 121 合并后可主端找子端，也可子端反查主端 | 不是号码资料表；附件只有接入号时先用 069 补 `serv_id`；关系明细可能一对多 |
| 121 | 业务关联关系表 | dws_crm_cust.dws_prod_inst_rel_grp_a | dws_crm_cust.dws_prod_inst_rel_grp_a | tables/121_业务关联关系表.md | A/Z 业务实例关联关系；主端 `a_prod_inst_id` 到子端 `z_prod_inst_id` | city_id | 群端/主从 AZ/同组 A-B 端关系；常与 120 合并补全关系，可主端找子端，也可子端反查主端 | 不是收入或号码资料表；合并 120 后需去重，A/B 端排序口径需确认 |
| 122 | 名单制管控清单 | ads_yz_mo_ccust_mdz_final | ads_yz_mo_ccust_mdz_final | tables/122_名单制管控清单.md | 直销客户名单制管控信息；以直销客户编码 `ccust_code` 为主要关联键 |  | 用户明确要求不用主表 `is_mdz`、要名单制管控清单时，按直销客户编码补 `hk_flag/create_date` | 不替代 069/033 等主事实表的客户或号码字段；来源没有直销客户编码时先补 109 |
| 123 | 终端自注册清单 | summary_ods_day_szx.rpt_terminal_type_new | summary_ods_day_szx.rpt_terminal_type_new | tables/123_终端自注册清单.md | 号码终端自注册信息；同一 `acc_nbr` 可能多次注册 |  | 按号码回填终端自注册机型、制式、厂商、标准化机型、注册时间、串号、IMSI/IMEI 等字段 | 不要误选 119 设备资源关系表、090 终端装维成本或 105/106 特性表；需一号一行时按 `register_time` 取最新 |
| 124 | 揽装人认领规则表 | ads_yz_sales_grid_rule_list | ads_yz_sales_grid_rule_list；ads_yz_sales_grid_rule_list_cl | tables/124_揽装人认领规则表.md | 揽装人工号到应认领责任田的规则关系；以 `sales_code` 到目标责任田为核心 |  | 按揽装人工号判断号码应落入的认领责任田，常用于责任田调整、服务认领差异清单 | 不是普通揽装人/网点维表；有效揽装人与网点关系仍看 111/112/113 |
| 125 | 服务当前划小规则表 | dwd_yz_jyfx_serv_grid_final | dwd_yz_jyfx_serv_grid_final | tables/125_服务当前划小规则表.md | 服务当前划小/认领规则结果；以 `serv_id` 为核心 |  | 判断号码当前划分规则、认领规则，和 069 当前责任田字段一起审计责任田归属 | 不是号码资料底座；普通号码入网/到达仍以 069 为主 |
