import { useEffect, useMemo, useState } from "react";
import {
  Bot,
  BrainCircuit,
  DatabaseZap,
  LayoutDashboard,
  MessageCircle,
  Network,
} from "lucide-react";
import heroImage from "./assets/hero-ai-command.png";

const navItems = [
  ["pain", "项目痛点"],
  ["flow", "生成流程"],
  ["knowledge", "知识库资产"],
  ["case", "真实示例"],
  ["apps", "应用扩展"],
  ["value", "价值成效"],
];

const painPoints = [
  {
    label: "需求收口难",
    value: "表达不统一",
    detail: "业务侧通常用自然语言描述需求，表达方式不统一，支撑人员需要反复澄清“查什么、查谁、按什么时间、出什么结果”。",
  },
  {
    label: "口径判断难",
    value: "同词多义",
    detail: "同一个业务词可能对应不同口径，例如入网、到达、在网、出账、拆机、续约等，不同口径会影响主表、字段和过滤条件。",
  },
  {
    label: "表字段选择难",
    value: "104+ 表",
    detail: "CDAP 表多、字段多、历史经验分散，主表选择、字段映射、补表路径很大程度依赖熟手经验。",
  },
  {
    label: "重复工作重",
    value: "流程相似",
    detail: "大量常规取数需求具有相似流程，但每次仍需要人工重新理解、编写和检查 SQL，消耗支撑人员大量时间。",
  },
];

const flowSteps = [
  ["01", "需求拆解与澄清", "识别查什么、查谁、时间口径、结果形式和限制条件"],
  ["02", "主表选择", "根据业务事实、指标口径和表路由规则判断 CDAP 主表"],
  ["03", "业务口径确认", "确认指标定义、时间字段、状态条件、过滤口径和默认假设"],
  ["04", "字段映射", "把业务字段映射到主表字段，识别名称、编码、维度缺口"],
  ["05", "补表规划", "当主表字段不足时，判断补表路径、JOIN 键、粒度和行数风险"],
  ["06", "SQL生成与审计", "根据已确认要素生成 Hive SQL，并输出字段来源和风险提示"],
  ["07", "自检SQL输出", "同步给出样例、量级、空分区、JOIN 放大等自检 SQL"],
];

const knowledgeAssets = [
  ["表路由入口", "104 张表索引", "覆盖 CDAP 主表、维表、补充表等业务取数入口"],
  ["字段资产", "103 个表文档", "沉淀字段说明、分区、粒度、适用场景和补表指引"],
  ["指标口径", "90 个指标口径", "沉淀标准指标到技术条件、时间口径和过滤规则的映射"],
  ["专项链路", "10 个专项场景", "沉淀复杂取数链路、风险审计和自检要求"],
  ["验证沉淀", "18 个验证案例", "沉淀已验证的表选择、字段映射和 SQL 编排模板"],
  ["交付规范", "SQL规则体系", "覆盖 CTAS、JOIN、分区、审计、自检 SQL 等交付规则"],
];

const appScenarios = [
  {
    title: "企业微信机器人",
    desc: "业务人员在企微中直接提问，实时返回 SQL 与口径说明。",
    icon: MessageCircle,
    position: "top-left",
  },
  {
    title: "业务门户",
    desc: "嵌入统一业务门户，形成自然语言取数入口。",
    icon: LayoutDashboard,
    position: "top-right",
  },
  {
    title: "自助取数平台",
    desc: "面向常规取数需求，提供可追溯、可复核的查询生成。",
    icon: DatabaseZap,
    position: "bottom-left",
  },
  {
    title: "智能指标问答",
    desc: "围绕指标解释、字段来源和趋势口径提供问答能力。",
    icon: Bot,
    position: "bottom-right",
  },
];

const valueCards = [
  ["SQL 初稿效率", "50%+", "常规 SQL 初稿从小时级压缩到分钟级"],
  ["需求澄清时间", "30%+", "自动收口关键条件，减少低效往返沟通"],
  ["新人上手周期", "明显缩短", "把熟手经验沉淀成可执行技能流程"],
  ["口径偏差", "持续减少", "统一主表、口径、字段补表和审计规则"],
];

const sqlExample = `-- TMP01: 202505 主宽入网基础队列
drop table if exists tmp_write_sql_cohort_202505 purge;
create table tmp_write_sql_cohort_202505 stored as orc as
SELECT serv_id, subst_name, branch_name, sales_name,
       channel_subst_name, channel_nbr
FROM dwm_yz_tb_comm_cm_all_mon_final
WHERE par_month_id = '202505'
  AND kd_desc = '普通宽带'
  AND is_new_user = 1
  AND date_format(open_date, 'yyyyMM') = '202505'
  AND prod_type = 40;

-- TMP02: 经营主体补表，按 channel_nbr 去重
drop table if exists tmp_write_sql_operator_202505 purge;
create table tmp_write_sql_operator_202505 stored as orc as
SELECT DISTINCT channel_nbr, own_operators_name
FROM zone_gz_yz.dwd_yz_sales_man_outlers_mon_final
WHERE par_month_id = '202505'
  AND channel_nbr IS NOT NULL
  AND own_operators_name IS NOT NULL;

-- TMP03: 队列 + 经营主体 + 后续 12 个月出账明细
drop table if exists tmp_write_sql_cohort_fee_detail purge;
create table tmp_write_sql_cohort_fee_detail stored as orc as
SELECT c.subst_name, c.branch_name, c.sales_name,
       c.channel_subst_name, op.own_operators_name,
       c.serv_id, t.par_month_id, t.fee
FROM tmp_write_sql_cohort_202505 c
LEFT JOIN tmp_write_sql_operator_202505 op
  ON c.channel_nbr = op.channel_nbr
LEFT JOIN dwm_yz_tb_comm_cm_all_mon_final t
  ON c.serv_id = t.serv_id
 AND t.par_month_id BETWEEN '202506' AND '202605';

-- TMP04: 最终结果，按维度汇总并打横 T+1 到 T+12
drop table if exists tmp_write_sql_result_202505 purge;
create table tmp_write_sql_result_202505 stored as orc as
SELECT subst_name AS 分局, branch_name AS 营服,
       sales_name AS 揽装人, channel_subst_name AS 揽装局向,
       own_operators_name AS 经营主体,
       COUNT(DISTINCT serv_id) AS 入网量,
       NVL(SUM(CASE WHEN par_month_id='202506' THEN fee END),0) AS "T+1出账",
       NVL(SUM(CASE WHEN par_month_id='202507' THEN fee END),0) AS "T+2出账",
       NVL(SUM(CASE WHEN par_month_id='202605' THEN fee END),0) AS "T+12出账"
FROM tmp_write_sql_cohort_fee_detail
GROUP BY subst_name, branch_name, sales_name,
         channel_subst_name, own_operators_name;`;

function scrollToSection(id) {
  document.getElementById(id)?.scrollIntoView({ behavior: "smooth", block: "start" });
}

function Stat({ label, value, sub }) {
  return (
    <div className="stat">
      <span>{label}</span>
      <strong>{value}</strong>
      <small>{sub}</small>
    </div>
  );
}

export function App() {
  const [caseMode, setCaseMode] = useState("ctas");
  const [copyState, setCopyState] = useState("idle");
  const [activeSection, setActiveSection] = useState("top");

  const casePanels = useMemo(
    () => ({
      ctas: {
        title: "CTAS 流水线核心 SQL",
        body: sqlExample,
      },
      evolution: {
        title: "方案演进：从 WITH 到 CTAS",
        body: [
          "一问：业务提出提取 202505 主宽入网，并跟踪后续一年 T+1 到 T+12 出账变化。",
          "一答：AI 命中 M-BASIC-BB-001，确认 069 月表、open_date 口径、069.fee 出账字段和 113 经营主体补表路径。",
          "二问：用户确认方案后，AI 先给出 WITH 版本 SQL。",
          "三问：用户指出脚本不应走 WITH，希望中间结果可独立验证、可落盘、可复跑。",
          "三答：方案修正为 4 步 CTAS 流水线，TMP01 队列、TMP02 经营主体、TMP03 出账明细、TMP04 最终打横汇总。",
        ].join("\n"),
      },
      verify: {
        title: "验收自检与风险控制",
        body: [
          "TMP01 验收：检查入网量和 COUNT(DISTINCT serv_id)，确认基础队列量级。",
          "TMP02 验收：按 channel_nbr 去重后检查经营主体记录数，避免 JOIN 放大。",
          "TMP03 验收：检查明细行数、用户数和 202506 到 202605 月份分布。",
          "TMP04 验收：SELECT * LIMIT 10 预览最终结果，确认分局、营服、揽装人、揽装局向、经营主体和 T+1 到 T+12 出账字段齐全。",
          "风险控制：无出账记录月份按 0 处理，经营主体为空或 channel_nbr 为空需在交付说明中标注。",
        ].join("\n"),
      },
    }),
    [],
  );

  useEffect(() => {
    const sectionIds = ["top", ...navItems.map(([id]) => id)];

    function updateActiveSection() {
      const current = sectionIds
        .map((id) => {
          const element = document.getElementById(id);
          if (!element) return null;
          return { id, top: Math.abs(element.getBoundingClientRect().top - 92) };
        })
        .filter(Boolean)
        .sort((a, b) => a.top - b.top)[0];

      if (current) {
        setActiveSection(current.id);
      }
    }

    updateActiveSection();
    window.addEventListener("scroll", updateActiveSection, { passive: true });
    return () => window.removeEventListener("scroll", updateActiveSection);
  }, []);

  async function handleCopySql() {
    try {
      await navigator.clipboard.writeText(sqlExample);
      setCopyState("success");
    } catch {
      setCopyState("error");
    }
    window.setTimeout(() => setCopyState("idle"), 1800);
  }

  return (
    <main className="page-shell">
      <header className="site-header">
        <button className="brand" onClick={() => scrollToSection("top")} aria-label="回到顶部">
          <span className="brand-mark">AI</span>
          <span>自然语言取数能力底座</span>
        </button>
        <nav aria-label="页面章节">
          {navItems.map(([id, label]) => (
            <button className={activeSection === id ? "active" : ""} key={id} onClick={() => scrollToSection(id)}>
              {label}
            </button>
          ))}
        </nav>
      </header>

      <section className="hero" id="top">
        <img className="hero-bg" src={heroImage} alt="AI 数据中枢背景" />
        <div className="hero-overlay" />
        <div className="hero-inner">
          <div className="hero-copy">
            <span className="eyebrow">Intelligent SQL Flow Hub</span>
            <h1>AI自然语言取数能力底座</h1>
            <p className="hero-subtitle">面向CDAP业务数据的智能SQL生成能力建设</p>
            <p className="hero-thesis">
              本项目不是单点取数工具，而是把业务取数流程、主表路由、指标口径、字段映射和 SQL 校验机制沉淀为可复用、可解释、可审计的 AI 能力底座。
            </p>
            <div className="hero-actions">
              <button onClick={() => scrollToSection("case")}>查看真实案例</button>
              <button className="ghost" onClick={() => scrollToSection("flow")}>生成流程</button>
            </div>
          </div>

          <div className="hero-workflow" aria-label="业务需求到SQL输出示意">
            <div className="demand-card">
              <span>业务自然语言需求</span>
              <strong>查询本月重点业务指标并按组织维度汇总</strong>
              <small>查询对象、时间口径、统计方式、输出字段和限制条件</small>
            </div>
            <div className="engine-card">
              <span>AI理解引擎</span>
              <strong>需求拆解 · 主表路由 · 口径识别</strong>
              <div className="engine-rings" aria-hidden="true">
                <i />
                <i />
                <i />
              </div>
            </div>
            <div className="sql-card">
              <div className="code-top">
                <span />
                <span />
                <span />
                <small>Hive</small>
              </div>
              <pre>{`SELECT 组织维度, 指标口径,
       COUNT(*) AS 业务量
FROM   CDAP 标准主表
WHERE  时间口径 = 本月
GROUP BY 组织维度;`}</pre>
              <b>已生成可审计SQL</b>
            </div>
          </div>
        </div>
        <div className="hero-stats" aria-label="预期成效">
          <Stat label="SQL 初稿效率" value="50%+" sub="从小时级到分钟级" />
          <Stat label="需求澄清时间" value="30%+" sub="自动收口关键条件" />
          <Stat label="新人上手周期" value="缩短" sub="沉淀熟手经验" />
          <Stat label="口径偏差" value="减少" sub="统一规则和审计" />
        </div>
      </section>

      <section className="section dark-band" id="pain">
        <div className="section-head">
          <span>01</span>
          <div>
            <h2>项目痛点：“三难一重”</h2>
            <p>数据需求增长快，传统人工取数模式难以稳定支撑业务敏捷决策。</p>
          </div>
        </div>
        <div className="pain-grid">
          {painPoints.map((item) => (
            <article className="pain-card" key={item.label}>
              <small>{item.value}</small>
              <h3>{item.label}</h3>
              <p>{item.detail}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section" id="flow">
        <div className="section-head">
          <span>02</span>
          <div>
            <h2>智能生成流程：从需求理解到SQL审计</h2>
            <p>让 AI 按支撑人员真实取数逻辑，完成从需求理解、口径说明到 SQL 生成和结果校验的全过程辅助。</p>
          </div>
        </div>
        <div className="flow-line">
          {flowSteps.map(([num, title, desc]) => (
            <article className="flow-step" key={num}>
              <b>{num}</b>
              <h3>{title}</h3>
              <p>{desc}</p>
            </article>
          ))}
        </div>
        <div className="architecture">
          <div>
            <span>AI技能流程</span>
            <strong>需求拆解、方案确认、SQL审计</strong>
          </div>
          <div>
            <span>业务知识库</span>
            <strong>主表路由、指标口径、字段补表</strong>
          </div>
          <div>
            <span>SQL规则体系</span>
            <strong>生成规范、风险提示、自检机制</strong>
          </div>
        </div>
      </section>

      <section className="section" id="knowledge">
        <div className="section-head">
          <span>03</span>
          <div>
            <h2>知识库资产：把经验变成规则</h2>
            <p>真实技能资产围绕表索引、指标口径、字段补表、SQL 审计和验证案例组织，形成可量化、可复用的取数能力底座。</p>
          </div>
        </div>
        <div className="asset-grid">
          {knowledgeAssets.map(([name, metric, desc]) => (
            <article className="asset-card" key={name}>
              <span>{name}</span>
              <strong>{metric}</strong>
              <p>{desc}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section case-section" id="case">
        <div className="section-head">
          <span>04</span>
          <div>
            <h2>真实示例：主宽入网出账跟踪</h2>
            <p>来自需求全记录和真实 SQL 输出，展示 AI 如何把一次复杂取数需求修正为可验证 CTAS 流水线。</p>
          </div>
        </div>

        <div className="case-grid">
          <aside className="case-brief">
            <span>业务需求</span>
            <h3>202505 主宽入网，跟踪后续一年出账变化</h3>
            <dl>
              <div>
                <dt>主表</dt>
                <dd>069 月表 / dwm_yz_tb_comm_cm_all_mon_final</dd>
              </div>
              <div>
                <dt>补表</dt>
                <dd>113 揽装所属月表，按 channel_nbr 补经营主体</dd>
              </div>
              <div>
                <dt>时间窗口</dt>
                <dd>入网月 202505，出账跟踪 202506 到 202605</dd>
              </div>
              <div>
                <dt>输出字段</dt>
                <dd>分局、营服、揽装人、揽装局向、经营主体、入网量、T+1 到 T+12 出账</dd>
              </div>
            </dl>
          </aside>

          <section className="code-console">
            <div className="console-head">
              <div className="console-dots">
                <span />
                <span />
                <span />
              </div>
              <div className="case-tabs" role="tablist" aria-label="案例信息">
                {Object.entries({ ctas: "CTAS SQL", evolution: "方案演进", verify: "验收自检" }).map(([key, label]) => (
                  <button
                    className={caseMode === key ? "active" : ""}
                    key={key}
                    onClick={() => setCaseMode(key)}
                    role="tab"
                    aria-selected={caseMode === key}
                  >
                    {label}
                  </button>
                ))}
              </div>
              <button className={`copy-btn ${copyState}`} onClick={handleCopySql}>
                {copyState === "success" ? "已复制" : copyState === "error" ? "复制失败" : "复制SQL"}
              </button>
            </div>
            <h3>{casePanels[caseMode].title}</h3>
            <pre>{casePanels[caseMode].body}</pre>
          </section>
        </div>

        <div className="lineage-grid">
          {["069月表 → 基础队列", "113月表 → 经营主体", "069月表 → 12月出账", "TMP04 → 打横汇总"].map((item) => (
            <div key={item}>{item}</div>
          ))}
        </div>
      </section>

      <section className="section" id="apps">
        <div className="section-head">
          <span>05</span>
          <div>
            <h2>应用扩展：连接业务全场景</h2>
            <p>能力底座先行，先在内部支撑场景验证，再开放为统一的自然语言取数组件。</p>
          </div>
        </div>
        <div className="app-orbit">
          <div className="orbit-lines" aria-hidden="true">
            <i />
            <i />
            <i />
          </div>
          <div className="hub-core">
            <div className="hub-icon">
              <BrainCircuit aria-hidden="true" size={42} strokeWidth={1.8} />
            </div>
            <span>NL2SQL</span>
            <strong>AI自然语言取数能力底座</strong>
            <small>统一能力服务 · 统一口径规则 · 统一审计输出</small>
          </div>
          {appScenarios.map(({ title, desc, icon: Icon, position }) => (
            <article className={`app-node ${position}`} key={title}>
              <div className="app-icon">
                <Icon aria-hidden="true" size={30} strokeWidth={1.8} />
              </div>
              <span>应用入口</span>
              <h3>{title}</h3>
              <p>{desc}</p>
            </article>
          ))}
          <div className="service-caption">
            <Network aria-hidden="true" size={18} />
            <span>通过统一 API / 技能服务接入多类业务入口</span>
          </div>
        </div>
      </section>

      <section className="section value-section" id="value">
        <div className="section-head">
          <span>06</span>
          <div>
            <h2>价值成效：赋能数据生产力</h2>
            <p>从人工经验取数走向“知识库 + AI 协同驱动”的标准化支撑模式。</p>
          </div>
        </div>
        <div className="value-grid">
          {valueCards.map(([title, value, desc]) => (
            <article className="value-card" key={title}>
              <span>{title}</span>
              <strong>{value}</strong>
              <p>{desc}</p>
            </article>
          ))}
        </div>
        <div className="vision">
          <strong>我们的愿景</strong>
          <p>让业务用自然语言即可获取可信数据，让数据真正服务业务，让决策更智能、更可靠、更高效。</p>
        </div>
      </section>
    </main>
  );
}
