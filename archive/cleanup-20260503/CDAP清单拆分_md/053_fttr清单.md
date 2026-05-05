## fttr清单

| FTTR清单dwm_fttr_list |  |  |  |  |
| --- | --- | --- | --- | --- |
| 序号 | 英文字段 | 类型 | 中文说明 | 备注 |
| 1 | corp_id | decimal(3,0) | 地市ID |  |
| 2 | create_date | string | 设备创建时间 |  |
| 3 | eqpt_sn | string | 设备串码 |  |
| 4 | serv_id | decimal(30,0) | 号码服务标识 |  |
| 5 | acc_nbr | string | 号码 |  |
| 6 | state | string | 号码状态 |  |
| 7 | cust_id | decimal(20,0) | 客户ID |  |
| 8 | subst_id | decimal(22,0) | 分局ID |  |
| 9 | branch_id | decimal(22,0) | 营服ID |  |
| 10 | area_id | decimal(22,0) | 包区ID |  |
| 11 | is_gz_zwg | decimal(1,0) |  |  |
| 12 | is_mon_gz_cwg_cust | decimal(1,0) |  |  |
| 13 | is_sq_zwg | decimal(1,0) |  |  |
| 14 | is_mon_sq_cwg_cust | decimal(1,0) |  |  |
| 15 | is_fttr_gz | decimal(1,0) | 是否公众版（1：是；0：否） |  |
| 16 | is_fttr_sq | decimal(1,0) | 是否商企版（1：是；0：否） |  |
| 17 | is_fttr | decimal(1,0) | 是否办理FTTR（1：是；0：否） |  |
| 18 | open_date | string | 号码入网时间 |  |
| 19 | is_new_user_m | int | 号码是否当月入网 |  |
| 20 | last_order_item_id | decimal(21,0) | 设备订单ID |  |
| 21 | subs_id | decimal(22,0) | 订单ID |  |
| 22 | subs_code | varchar(64) | 订单编码 |  |
| 23 | act_date | timestamp | 订单受理时间 |  |
| 24 | subs_stat_date | timestamp | 订单竣工时间 |  |
| 25 | sales_code | string | 揽装工号 |  |
| 26 | sales_man_name | string | 揽装人 |  |
| 27 | channel_type_2011 | string | 渠道大类 |  |
| 28 | channel_subtype_2011 | string | 渠道小类 |  |
| 29 | channel_subtype0_2011 | string | 渠道中类 |  |
| 30 | cust_id2 | decimal(22,0) | 客户ID |  |
| 31 | cust_nbr | varchar(30) | 客户编码 |  |
| 32 | cust_name | varchar(1000) | 客户名 |  |
| 33 | subst_name | string | 分局名 |  |
| 34 | subst_order | int | 分局顺序ID |  |
| 35 | branch_order | int | 营服顺序ID |  |
| 36 | branch_name | string | 营服名 |  |
| 37 | area_name | string | 名区名 |  |
| 38 | is_mdz | string | 是否名单制 |  |
| 39 | bg_type | string | bg类型 |  |
| 40 | region_type | varchar(100) | 五大网格 |  |
| 41 | is_new_user | int | 是否新入网 |  |
| 42 | serv_grp_type_desc | string | 服务分群 |  |
| 43 | six_market_desc | string | 六大细分市场 |  |
| 44 | kd_new | int | 宽带是否新入网 |  |
| 45 | kd_desc | string | 宽带类型 |  |
| 46 | kd_open_date | string | 宽带号码入网时间 |  |
| 47 | speed_value | decimal(10,2) | 速率 |  |
| 48 | is_zw | int | 是否总装维 |  |
| 49 | channel_id | string | 渠道ID |  |
| 50 | is_zwrg | int | 是否装维入格 |  |
| 51 | channel_subtype_2011_zw | string | 渠道装维类别 |  |
| 52 | channel_subtype_2011_zwrg | string | 渠道装维入格类别 |  |
| 53 | std_subst_id | decimal(22,0) | 落地分局ID |  |
| 54 | std_subst_name | string | 落地分局名 |  |
| 55 | std_branch_id | decimal(22,0) | 落地营服ID |  |
| 56 | std_branch_name | string | 落地营服名 |  |
| 57 | salestaff_subst_id | decimal(22,0) | 揽装局向id |  |
| 58 | salestaff_branch_id | decimal(22,0) | 揽装营服id |  |
| 59 | salestaff_channel_id | decimal(22,0) | 揽装网点id |  |
| 60 | xx_salestaff_id1 | string | 第一协销人ID |  |
| 61 | xx_salestaff_code1 | string | 第一协销人编码 |  |
| 62 | xx_salestaff_name1 | string | 第一协销名姓名 |  |
| 63 | xx_salestaff_id2 | string | 第二协销人ID |  |
| 64 | xx_salestaff_code2 | string | 第二协销人编码 |  |
| 65 | xx_salestaff_name2 | string | 第二协销名姓名 |  |
| 66 | bu_type | string | bu类型 |  |
| 67 | staff_id | varchar(20) | 受理人 |  |
| 68 | org_id | decimal(22,0) | 受理机构标识 |  |
| 69 | serv_grp_type | varchar(10) | 服务分群id |  |
| 70 | cell_id | decimal(22,0) | 网格单元id |  |
| 71 | cell_code | varchar(20) | 网格单元编码 |  |
| 72 | salestaff_channel_name | string | 销售点名称 |  |
| 73 | salestaff_channel_nbr | string | 销售点编码 |  |
| 74 | salestaff_subst_name | string | 揽装局向 |  |
| 75 | salestaff_branch_name | string | 揽装营服 |  |
| 76 | is_gsm | int | 是否公司名 |  |
| 77 | cell_name | string | 网格单元名 |  |
| 78 | cell_type | string | 网格单元大类id |  |
| 79 | cell_type_name | string | 网格单元大类 |  |
| 80 | kd_type | string | 宽带类型 |  |
| 81 | is_fttr_sq_desc | string | 是否商企版 |  |
| 82 | is_fttr_gz_desc | string | 是否公众版 |  |
|  | org_name | varchar(500) | 受理机构 |  |
|  | sum_date | string | 统计日期 |  |
|  | Par_month_id | string | 月份 |  |
|  | kd_offer_name |  | 宽带主套餐 |  |
|  | kd_offer_code |  | 宽带主套餐编码 |  |
|  | kd_prod_offer_id |  | 宽带主套餐ID |  |
|  | cust_code |  | 直销客户编码 |  |
|  | grid_code |  | 责任田编码 |  |
|  | salestaff_org_name |  | 揽装机构 |  |
|  | channel_subtype_flag |  | 日报渠道小类 |  |
|  | fttr_offer_name |  | fttr套餐（本地） |  |
|  | fttr_offer_code |  | fttr套餐编码（本地） |  |
|  | fttr_prod_offer_id |  | fttr套餐ID（本地） |  |
|  | salestaff_area_name | string | 揽装包区 |  |
|  | salestaff_area_id | decimal(22,0) | 揽装包区ID |  |
|  | mobile_phone | varchar(500) | 客户联系方式 |  |
|  | mon_gz_cwg_eqpt_sn | varchar(500) | 同客户公众从网关串码 |  |
|  | gz_cwg_num | int | 同客户公众从网关串码数量（本地） |  |
|  | mon_sq_cwg_eqpt_sn | varchar(500) | 同客户商企从网关串码 |  |
|  | sq_cwg_num | int | 同客户商企从网关串码数量（本地） |  |
|  | mkt_res_type_id | decimal(22,0) | 设备ID |  |
|  | mkt_res_type_name | string | 设备名 |  |
|  | prod_offer_id | decimal(21,0) | FTTR销售品ID（省源） |  |
|  | prod_offer_name | string | FTTR销售品名（省源） |  |
|  | msobjgrp_id | decimal(21,0) | 套餐实例id |  |
|  | attr_inner_cd | string | 暂时没用到 |  |
|  | xsd_code | string | 销售点（不包含店中商归集到网厅部分） |  |
|  | xsd_code_td | string | 销售点编码_厅店（包含店中商归集到网厅部分） |  |
|  | xsy_code | string | 销售员 |  |
|  | new_channel_type | decimal(1,0) | 新渠道视图<br>1  主控-营业厅<br>2  主控-包区厅<br>3  主控-包区店<br>4  社会-终端大店<br>5  社会-中小门店<br>6  社会-便利点<br>7  公众直销<br>8  10000号<br>-1 其他 |  |
|  | is_maincontrol_channel | decimal(1,0) | 是否主控渠道（1是0否）=营业厅+包区厅+包区店 |  |
|  | is_yyt_and_bqt | decimal(1,0) | 是否营业厅（含包区厅） |  |
|  | is_quickphone_shop | decimal(1,0) | 是否快电店（1是0否）,该标签不能合并到NEW_CHANNEL_TYPE，与其有交集 |  |
|  | is_society_channel | decimal(1,0) | 是否社会渠道(终端大店+中小门店+便利点) |  |
|  | num_eqpt_sn_cust_gz | decimal(3,0) | 同客户公众从网关串码数量（省源） |  |
|  | num_eqpt_sn_cust_sq | decimal(3,0) | 同客户商企从网关串码数量（省源） |  |
|  | is_wapon | decimal(1,0) | 是否wapon 认证 |  |
|  | num_kdzx_cust | decimal(3,0) | 同客户名下近60天内新装宽带或专线数量 |  |
|  | par_month_id | string | 月份 |  |
|  |  |  |  |  |
|  | xsp_sales_id | varchar(100) | 销售品订单揽装人标识 |  |
|  | xsp_sales_code | string | 销售品订单揽装人工号 |  |
|  | xsp_sales_man_name | string | 销售品订单揽装人 |  |
|  | xsp_salestaff_large_class | string | 销售品订单揽装人大类 |  |
|  | xsp_salestaff_small_class | string | 销售品订单揽装人小类 |  |
|  | xsp_salestaff_org_id | string | 销售品订单揽装人管理机构标识 |  |
|  | xsp_salestaff_subst_id | bigint | 销售品订单揽装人所属分局标识 |  |
|  | xsp_salestaff_branch_id | bigint | 销售品订单揽装人所属营服标识 |  |
|  | xsp_salestaff_subst_name | string | 销售品订单揽装人所属分局 |  |
|  | xsp_salestaff_branch_name | string | 销售品订单揽装人所属营服 |  |
|  | xsp_salestaff_channel_id | string | 销售品订单揽装人进驻网点标识 |  |
|  | xsp_salestaff_own_channel_id | string | 销售品订单揽装人归属销售点标识 |  |
|  | cwg_xzs | bigint | 主网关下从网关当月新增数 |  |
|  | cwg_zws | bigint | 主网关下从网关当月在网数 |  |
|  | cwg_serv_list | string | 主网关下从网关在网服务标识列表 | 数据格式： 服务标识1:设备类型名称:入网时间,服务标识2:设备类型名称:入网时间,....，其中设备类型名称用来区分商企版/公众版从网关  |
|  | xzcwg_serv_list | string | 主网关下从网关当月新增服务标识列表 |  |
|  | sqb_zws | bigint | 主网关下从网关商企版在网数 |  |
|  | gzb_zws | bigint | 主网关下从网关公众版在网数 |  |
|  | sqb_xzs | bigint | 主网关下从网关商企版当月新增数 |  |
|  | gzb_xzs | bigint | 主网关下从网关公众版当月新增数 |  |
|  | xsp_offer_id | decimal(22,0) | 销售品标识(广州本地维表） |  |
|  | xsp_offer_code | string | 销售品编码(广州本地维表） |  |
|  | xsp_offer_name | string | 销售品名称(广州本地维表） |  |
|  | xsp_channel_type_2011 | string | 销售品订单渠道大类 |  |
|  | xsp_channel_subtype_2011 | string | 销售品订单渠道小类 |  |
