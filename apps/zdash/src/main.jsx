import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";
import "./styles.css";

const stats = [
  { label: "Total Agents", value: "9", sub: "CEO · Coordinator · 7 Specialists", tone: "gold" },
  { label: "Daily Target", value: "$100", sub: "XAU/USD AutoTrading", tone: "green" },
  { label: "PnL Today", value: "+4.15R", sub: "realized +$21.01", tone: "cyan", live: true },
  { label: "Drawdown Guard", value: "-50%", sub: "floor $86.37 / peak $172.74", tone: "pink" },
  { label: "Backtest PnL", value: "$1,431", sub: "ob_aggressive strategy", tone: "purple" },
  { label: "Session Logs", value: "1,779+", sub: "Joe agent log entries", tone: "orange" },
];

const agents = [
  { icon: "👔", name: "zDash", tier: "LEGENDARY", role: "CEO · EXECUTIVE", tone: "gold", desc: "Chief Executive Officer — ผู้นำสูงสุด กำหนดทิศทาง สั่งการ Coordinator Jamie และออก Policy ทั้งหมดของระบบ", tasks: "342", uptime: "99.9%", score: "98" },
  { icon: "💃", name: "Jamie", tier: "EPIC", role: "COORDINATOR · MANAGER", tone: "pink", desc: "ผู้ประสานงานหลัก รับ Task จาก CEO แจกงานให้ Specialist ติดตามความคืบหน้า และรายงานผล", tasks: "1,204", uptime: "99.7%", score: "95" },
  { icon: "📈", name: "Crypto", tier: "EPIC", role: "TRADING SPECIALIST", tone: "green", desc: "วิเคราะห์ตลาด XAU/USD, Crypto ใช้ Claude AI ตรวจสัญญาณ Order Block, Liquidity Sweep ส่งออเดอร์อัตโนมัติ", tasks: "567", uptime: "99.5%", score: "93" },
  { icon: "✍️", name: "Editor", tier: "EPIC", role: "CONTENT SPECIALIST", tone: "cyan", desc: "สร้างและแก้ไขคอนเทนต์อัตโนมัติ บทความ รายงาน ใช้ Claude เขียนตาม Brand Voice ของ zDash", tasks: "89", uptime: "98.2%", score: "87" },
  { icon: "📱", name: "Social", tier: "EPIC", role: "SOCIAL MEDIA SPECIALIST", tone: "orange", desc: "โพสต์ Facebook, Instagram, TikTok อัตโนมัติ สร้าง Caption, Hashtag วิเคราะห์ Engagement ตามเวลาที่กำหนด", tasks: "234", uptime: "97.8%", score: "82" },
  { icon: "🎨", name: "Graphic", tier: "EPIC", role: "DESIGN SPECIALIST", tone: "purple", desc: "สร้างภาพกราฟิก, Thumbnail, Infographic ด้วย AI Image Generation ตาม Brief ที่ Editor ส่งมา", tasks: "156", uptime: "96.5%", score: "79" },
  { icon: "🛡️", name: "Guardian", tier: "EPIC", role: "RISK MANAGER", tone: "red", desc: "ตรวจสอบ Drawdown ทุก Trade ถ้า DD เกิน -50% of Peak → หยุดระบบทันที ป้องกันการสูญเสียเงินทุน", tasks: "891", uptime: "100%", score: "99" },
  { icon: "🔬", name: "Joe", tier: "RARE", role: "ANALYST · DEVELOPER", tone: "teal", desc: "วิเคราะห์ข้อมูล ทำ Backtesting กลยุทธ์ พัฒนา/แก้ไข Code ระบบ Session log 1,779+ entries", tasks: "445", uptime: "98.9%", score: "88" },
  { icon: "📅", name: "Friday", tier: "RARE", role: "SCHEDULER · AUTOMATION", tone: "mint", desc: "จัดตาราง Cron Jobs เปิดระบบ 06:00 สแกน XAU ทุก 5 นาที ปิดระบบ 23:30 รายงานรายวัน 20:00", tasks: "78", uptime: "99.1%", score: "90" },
];

const commandNodes = [
  { title: "zDash", role: "CEO · EXECUTIVE", icon: "👔", tone: "gold" },
  { title: "Jamie", role: "COORDINATOR", icon: "💃", tone: "pink" },
];

const specialistNodes = [
  ["Crypto", "TRADING", "📈", "green"],
  ["Editor", "CONTENT", "✍️", "cyan"],
  ["Social", "SOCIAL", "📱", "orange"],
  ["Graphic", "DESIGN", "🎨", "purple"],
  ["Guardian", "RISK", "🛡️", "red"],
  ["Joe", "ANALYST", "🔬", "teal"],
  ["Friday", "SCHEDULER", "📅", "mint"],
];

const externalSystems = ["MT5 Terminal", "Claude API", "Tapo Smart Plug", "NSSM Service", "XAU Scanner", "Social APIs", "AI Image Gen", "Task Scheduler"];

const tradingFlow = [
  { title: "📡 Scanner Live", desc: "สแกน XAUUSD M5 ทุก 5 นาที · Funnel 21/10/3 filter", tone: "cyan" },
  { title: "🧠 Claude AI", desc: "วิเคราะห์ Order Block · Liquidity Sweep · H4 Trend", tone: "purple" },
  { title: "✅ Validation", desc: "ตรวจ Confidence Level · conf ≥ H4 ผ่าน filter", tone: "gold" },
  { title: "🛡️ Risk Check", desc: "ตรวจ Drawdown Guard · Max DD -50% of peak", tone: "red" },
  { title: "🚀 MT5 Execute", desc: "ส่ง Order ผ่าน MT5 API · SL/TP/Lot อัตโนมัติ", tone: "green" },
];

const automationFlow = [
  { title: "📅 Friday Cron", desc: "06:00 เปิด · */5 scan · 23:30 ปิดระบบ", tone: "mint" },
  { title: "🖥️ Windows SVC", desc: "NSSM auto-start · Janie server daemon", tone: "gold" },
  { title: "💃 Jamie Dispatch", desc: "รับ Task → แจกงาน · ติดตาม + รายงานผล", tone: "pink" },
  { title: "🔌 Tapo IoT", desc: "สั่ง Smart Plug · เปิด/ปิด Hardware", tone: "purple" },
  { title: "📊 Dashboard", desc: "XAU Dashboard · PnL · DD · Positions", tone: "teal" },
];

const modules = [
  { icon: "📡", title: "XAU Live Scanner", sub: "trading · real-time", tone: "cyan", features: ["สแกน XAUUSD M5 อัตโนมัติทุก 5 นาที", "Funnel Filter: Scan 32 → Filtered 10 → Signal 3", "Claude AI วิเคราะห์ Order Block, Liquidity Sweep, H4 Trend", "แสดงผล BUY/SELL พร้อม Confidence Level", "Log ทุก signal พร้อม timestamp ICT (UTC+7)", "Real-time price display ผ่าน MT5 Terminal"] },
  { icon: "🤖", title: "AutoTrading Engine", sub: "trading · execution", tone: "green", features: ["ส่งออเดอร์ผ่าน MT5 API อัตโนมัติทันทีที่ signal ผ่าน", "คำนวณ SL/TP จาก Signal Analysis อัตโนมัติ", "Daily Target: +$100/วัน หยุดเองเมื่อถึงเป้า", "Dry-Run mode สำหรับทดสอบก่อน live จริง", "Recent Trades log 10 รายการล่าสุด", "Halt Flag ปิดระบบฉุกเฉินได้ทันที"] },
  { icon: "🛡️", title: "Drawdown Guard", sub: "risk management · safety", tone: "red", features: ["ตรวจสอบ DD ทุก Trade แบบ Real-time", "Kill Switch: DD เกิน -50% of Peak → หยุดระบบทันที", "Floor: $86.37 / Peak: $172.74", "Halt Flag แจ้งเตือนผ่าน Dashboard ทันที", "ป้องกัน Revenge Trading อัตโนมัติ 100%", "Log ทุก Risk Event พร้อม timestamp"] },
  { icon: "🔬", title: "Backtesting Lab", sub: "analytics · strategy optimization", tone: "purple", features: ["ทดสอบ Strategy 11+ แบบ: ob, ph, ab, bc variants", "คำนวณ Expectancy, Win Rate, Profit Factor", "Best: ob_aggressive (Expectancy 0.6974, PnL $1,431)", "Parameter Sweep: aggressive/balanced/conservative", "Performance Metrics รายละเอียดแต่ละ Variant", "Export ผลลัพธ์ CSV สำหรับ Analysis เพิ่มเติม"] },
  { icon: "📅", title: "Task Scheduler", sub: "automation · cron jobs", tone: "mint", features: ["morning_ch: 06:00 — เปิดระบบตอนเช้า", "xau_scan: */5 — สแกน XAU ทุก 5 นาที", "report_daily: 20:00 — สรุปผลรายวัน", "night_off: 23:30 — ปิดระบบตอนคืน", "Windows Task Scheduler / NSSM Integration", "Toggle Enable/Disable แต่ละ Job ผ่าน Web UI"] },
  { icon: "💬", title: "Jamie Command Center", sub: "coordinator · task dispatch", tone: "pink", features: ["รับคำสั่งจาก zDash CEO ผ่าน Chat Interface", "แจก Task ให้ Specialist Agent ที่เหมาะสม", "ติดตาม Status ของทุก Task แบบ Real-time", "รายงานผล Summary กลับให้ CEO", "จัดการ Conflict เมื่อ Task ซ้ำหรือขัดแย้ง", "Log ทุก Session พร้อม Context ครบถ้วน"] },
  { icon: "📋", title: "Session Manager", sub: "agent runtime · logging", tone: "gold", features: ["Log ทุก Agent Session พร้อม ID unique", "Joe: 1,779+ log entries สำหรับ development sessions", "Full-text search ใน Session logs ทั้งหมด", "แสดง Context ของแต่ละ Task", "Link ระหว่าง Sessions ที่เกี่ยวข้องกัน", "Audit trail สำหรับ agent runtime"] },
  { icon: "📱", title: "Social Media Pipeline", sub: "content · distribution", tone: "orange", features: ["Editor สร้าง Content → Graphic สร้าง Visual", "Social Agent โพสต์ FB, IG, TikTok อัตโนมัติ", "AI Image Generation สำหรับ Thumbnail/Infographic", "Scheduling โพสต์ตามเวลาที่กำหนด", "Hashtag Generator อัตโนมัติตาม Content", "Engagement Analytics planned"] },
  { icon: "🖥️", title: "Dashboard & Monitoring", sub: "UI · visualization", tone: "teal", features: ["Team Roster: Grid Agent ทุกตัว พร้อม Status", "XAU Dashboard: Live price, PnL, Positions", "Scheduler UI: Toggle Jobs, Log viewer", "Backtest Results: Strategy comparison table", "Org Map: แผนผัง CEO→Jamie→Specialists", "Session Logs: Full-text, searchable history"] },
];

const stack = [
  ["🧠", "Claude API (Anthropic)", "AI · LLM CORE", "Core AI — วิเคราะห์ตลาด, สร้างคอนเทนต์, ตัดสินใจ Agent ทุกตัว"],
  ["📊", "MetaTrader 5 (MT5)", "TRADING · BROKER API", "ส่งออเดอร์ XAU/USD เชื่อม Broker API รับ Live Price Feed"],
  ["🐍", "Python 3.x", "BACKEND · CORE", "ภาษาหลัก: tapo_controller.py, scanner.py, scheduler.py, janie/server.py"],
  ["🖥️", "Windows Server", "INFRASTRUCTURE · OS", "Host หลักของระบบ Task Scheduler + NSSM Auto-start"],
  ["⚡", "NSSM", "SERVICE MANAGER", "Wrap Janie server เป็น Windows Service"],
  ["🔌", "TP-Link Tapo API", "IoT · HARDWARE", "Smart Plug API ควบคุม Hardware เปิด/ปิดอุปกรณ์ในออฟฟิส"],
  ["⚛️", "React / Vite", "FRONTEND · DASHBOARD", "Dashboard Web UI: Team Roster, XAU, Scheduler, Backtest, Org Map"],
  ["🗄️", "SQLite / JSON Store", "STORAGE · DATA", "เก็บ Session logs, Trade history, Backtest results, Scheduler config"],
  ["🌐", "REST API + WebSocket", "COMMUNICATION", "Agent ติดต่อกันผ่าน Internal API · Real-time ผ่าน WebSocket"],
  ["🔐", "Janie Server", "AGENT RUNTIME", "Runtime หลักของ Agent ทั้งหมด รับ-ส่ง task, manage session, log"],
  ["📱", "Social Media APIs", "INTEGRATION", "Facebook Graph API, Instagram API, TikTok API สำหรับ Social Agent"],
  ["🎨", "AI Image Generation", "DESIGN ENGINE", "สร้างภาพสำหรับ Graphic Agent"],
];

const tradingMetrics = [
  ["+4.15R", "PNL TODAY", "green"], ["$100", "DAILY TARGET", "gold"], ["-50%", "MAX DRAWDOWN", "red"], ["M5", "TIMEFRAME", "cyan"],
  ["21/10/3", "FUNNEL", "purple"], ["H4", "TREND FILTER", "orange"], ["$1,431", "BEST PnL", "green"], ["0.6974", "EXPECTANCY", "gold"],
];

const strategies = [
  ["ob_aggressive", "209", "35.4%", "0.6974", "2.3858", "36.6374", "+$1,431.78", "BEST", "green"],
  ["ph_aggressive", "311", "31.0%", "0.8760", "1.493", "1.790", "+$272.4", "GOOD", "cyan"],
  ["ob_balanced", "209", "50.0%", "0.8070", "1.857", "4", "+$168.7", "GOOD", "cyan"],
  ["ob_conservative", "61", "57.0%", "1.458", "—", "4", "+$88.9", "AVG", "gold"],
  ["bc_aggressive", "12", "36.7%", "-0.897", "—", "5.8", "-$10.8", "SKIP", "red"],
];

const apiRows = [
  ["GET", "/api/agents/status", "Jamie", "สถานะ Agent ทุกตัว online/offline/busy"],
  ["POST", "/api/task/assign", "Jamie", "ส่ง Task ให้ Specialist Agent ที่ระบุ"],
  ["GET", "/api/trading/signals", "Crypto", "Live XAU Signals จาก Scanner"],
  ["POST", "/api/trading/execute", "Crypto", "ส่งออเดอร์ผ่าน MT5"],
  ["GET", "/api/risk/drawdown", "Guardian", "Drawdown % ปัจจุบัน + floor/peak"],
  ["DELETE", "/api/trading/halt", "Guardian", "Kill Switch — หยุดการเทรดทันที"],
  ["GET", "/api/scheduler/jobs", "Friday", "รายการ Cron Jobs ทั้งหมด"],
  ["POST", "/api/scheduler/toggle", "Friday", "เปิด/ปิด Scheduled Job"],
  ["POST", "/api/backtest/run", "Joe", "รัน Backtest ด้วย Strategy ที่กำหนด"],
  ["GET", "/api/sessions/list", "Joe", "Session Logs ทั้งหมดพร้อม Full-text"],
  ["WS", "/ws/xau/live", "Crypto", "WebSocket — XAU Live Price Stream"],
  ["WS", "/ws/agents/events", "Jamie", "WebSocket — Agent Events Real-time"],
];

const roadmap = [
  ["PHASE 1 · FOUNDATION", "ตั้ง Janie Server + Agent Runtime", "ติดตั้ง Python environment, สร้าง Janie server (FastAPI), ตั้ง Agent class พื้นฐาน, เชื่อม Claude API, ทดสอบ Basic CEO→Jamie communication"],
  ["PHASE 2 · TRADING CORE", "XAU Scanner + MT5 Integration", "เชื่อม MT5 API, สร้าง XAU Scanner (M5), Funnel Filter 21/10/3, Claude AI Analysis module, Signal Validation, ทดสอบ Dry-Run mode ก่อน live"],
  ["PHASE 3 · RISK SYSTEM", "Drawdown Guard + Kill Switch", "สร้าง Guardian agent, Drawdown calculation, Kill Switch trigger (-50% DD), Halt Flag system, Integration กับ AutoTrading Engine"],
  ["PHASE 4 · AUTOMATION", "Scheduler + IoT + Windows Service", "ตั้ง Friday agent + Cron Jobs, เชื่อม Tapo Smart Plug API, ติดตั้ง NSSM auto-start"],
  ["PHASE 5 · BACKTESTING", "Strategy Lab + Optimization", "สร้าง Joe agent Backtesting module, ทดสอบ Strategy variants, Parameter sweep, เลือก ob_aggressive เป็น Primary"],
  ["PHASE 6 · CONTENT PIPELINE", "Editor + Social + Graphic Agents", "สร้าง Content pipeline: Editor→Graphic→Social, เชื่อม Social Media APIs, AI Image Generation, ทดสอบ Auto-post workflow"],
  ["PHASE 7 · DASHBOARD", "Full Dashboard + All Modules", "สร้าง React Dashboard: Team Roster, XAU Dashboard, Scheduler UI, Backtest Results, Org Map, Session Logs"],
];

function Section({ number, label, heading, sub, children }) {
  return (
    <section className="section" id={label.toLowerCase().replaceAll(" ", "-") }>
      <div className="section-title">{number} — {label}</div>
      <h2 className="section-heading">{heading}</h2>
      {sub ? <p className="section-sub">{sub}</p> : null}
      {children}
    </section>
  );
}

function Header() {
  return (
    <header className="header">
      <div className="logo">⬡ zDash · SYSTEM BLUEPRINT</div>
      <div className="badges">
        <span className="badge badge-gold">v2.0 PRODUCTION</span>
        <span className="badge badge-green">● 9 AGENTS LIVE</span>
        <span className="badge badge-cyan">XAU AutoTrading UI</span>
      </div>
    </header>
  );
}

function StatsGrid() {
  const [pnl, setPnl] = useState("+4.150R");
  useEffect(() => {
    const timer = window.setInterval(() => {
      const value = (4.15 + Math.sin(Date.now() / 3000) * 0.06).toFixed(3);
      setPnl(`+${value}R`);
    }, 2000);
    return () => window.clearInterval(timer);
  }, []);

  return (
    <div className="stats-grid">
      {stats.map((stat) => (
        <article className={`stat-card tone-${stat.tone}`} key={stat.label}>
          <div className="stat-label">{stat.label}</div>
          <div className="stat-value">{stat.live ? pnl : stat.value}</div>
          <div className="stat-sub">{stat.sub}</div>
        </article>
      ))}
    </div>
  );
}

function AgentCard({ agent }) {
  return (
    <article className={`agent-card tone-${agent.tone}`}>
      <div className="agent-tier">{agent.tier}</div>
      <div className="agent-icon">{agent.icon}</div>
      <h3 className="agent-name">{agent.name}</h3>
      <div className="agent-role">{agent.role}</div>
      <p className="agent-desc">{agent.desc}</p>
      <div className="agent-stats">
        <div><b>{agent.tasks}</b><span>TASKS</span></div>
        <div><b>{agent.uptime}</b><span>UPTIME</span></div>
        <div><b>{agent.score}</b><span>SCORE</span></div>
      </div>
    </article>
  );
}

function OrgMap() {
  return (
    <div className="arch-diagram">
      <div className="command-chain">
        {commandNodes.map((node, index) => (
          <React.Fragment key={node.title}>
            <div className={`org-node tone-${node.tone}`}>
              <strong>{node.icon} {node.title}</strong>
              <span>{node.role}</span>
            </div>
            {index < commandNodes.length - 1 ? <div className="down-arrow">↓ command</div> : null}
          </React.Fragment>
        ))}
      </div>
      <div className="delegate-line">Jamie task delegation</div>
      <div className="specialists-grid">
        {specialistNodes.map(([name, role, icon, tone]) => (
          <div className={`org-node compact tone-${tone}`} key={name}>
            <strong>{icon} {name}</strong>
            <span>{role}</span>
          </div>
        ))}
      </div>
      <div className="external-title">EXTERNAL SYSTEMS</div>
      <div className="external-grid">
        {externalSystems.map((system) => <span key={system}>{system}</span>)}
      </div>
    </div>
  );
}

function Flow({ items }) {
  return <div className="flow-row">{items.map((item, index) => <React.Fragment key={item.title}><div className={`flow-node tone-${item.tone}`}><b>{item.title}</b><p>{item.desc}</p></div>{index < items.length - 1 ? <div className="flow-arrow">→</div> : null}</React.Fragment>)}</div>;
}

function ModuleCard({ item }) {
  return (
    <article className={`module-card tone-${item.tone}`}>
      <div className="module-header"><div className="module-icon-wrap">{item.icon}</div><div><h3>{item.title}</h3><span>{item.sub}</span></div></div>
      <ul>{item.features.map((feature) => <li key={feature}><span>▸</span>{feature}</li>)}</ul>
    </article>
  );
}

function App() {
  return (
    <>
      <Header />
      <main className="container">
        <Section number="01" label="SYSTEM OVERVIEW" heading="zDash AI Agent System" sub="ระบบ Multi-AI-Agent สำหรับ Trading automation UI + จัดการธุรกิจ ประกอบด้วย Agent 9 ตัว ทำงานร่วมกันแบบ Corporation Structure">
          <StatsGrid />
        </Section>

        <Section number="02" label="AGENT ROSTER" heading="Team Members — 9 Agents" sub="Agent ทุกตัวมี Role ชัดเจน ทำงานแบบ Hierarchy: CEO → Jamie Coordinator → Specialist Agents">
          <div className="agents-grid">{agents.map((agent) => <AgentCard agent={agent} key={agent.name} />)}</div>
        </Section>

        <Section number="03" label="ARCHITECTURE" heading="Command Flow & Communication" sub="การไหลของคำสั่งและข้อมูลระหว่าง Agent ทั้งหมด">
          <OrgMap />
        </Section>

        <Section number="04" label="DATA FLOW" heading="Trading Pipeline" sub="การไหลของข้อมูลตั้งแต่สัญญาณตลาดจนถึงการส่งคำสั่งตาม blueprint">
          <Flow items={tradingFlow} />
          <Flow items={automationFlow} />
        </Section>

        <Section number="05" label="SYSTEM MODULES" heading="Core Modules — Full Detail" sub="โมดูลหลักของระบบทั้งหมด พร้อม Features ละเอียดครบ">
          <div className="modules-grid">{modules.map((item) => <ModuleCard item={item} key={item.title} />)}</div>
        </Section>

        <Section number="06" label="TECHNOLOGY STACK" heading="เทคโนโลยีทั้งหมด" sub="Stack ครบชุดที่ใช้ในการสร้างระบบตั้งแต่ AI Engine จนถึง IoT">
          <div className="tech-grid">{stack.map(([icon, name, cat, desc]) => <article className="tech-card" key={name}><div>{icon}</div><section><h3>{name}</h3><b>{cat}</b><p>{desc}</p></section></article>)}</div>
        </Section>

        <Section number="07" label="TRADING SPECS" heading="XAU AutoTrading Configuration" sub="พารามิเตอร์และการตั้งค่าการเทรด + Backtest Results สำหรับแสดงผลใน dashboard">
          <div className="metrics-row">{tradingMetrics.map(([value, label, tone]) => <div className={`metric-box tone-${tone}`} key={label}><strong>{value}</strong><span>{label}</span></div>)}</div>
          <div className="card table-wrap"><table><thead><tr><th>STRATEGY</th><th>TRADES</th><th>WIN RATE</th><th>EXPECTANCY</th><th>PROFIT FACTOR</th><th>MAX R</th><th>TOTAL PnL</th><th>VERDICT</th></tr></thead><tbody>{strategies.map((row) => <tr key={row[0]}>{row.slice(0, 7).map((cell, index) => <td key={`${row[0]}-${index}`}>{cell}</td>)}<td><span className={`pill tone-${row[8]}`}>{row[7]}</span></td></tr>)}</tbody></table></div>
        </Section>

        <Section number="08" label="SCHEDULER CONFIG" heading="Cron Jobs & Service Runtime" sub="การตั้งค่า Automation ทั้งหมด ควบคุมด้วย Friday Agent">
          <pre className="code-block">{`JOBS = [
  { name: "morning_ch",   cron: "0 6 * * *",    action: "system.start",      tapo: true },
  { name: "xau_scan",     cron: "*/5 * * * *",  action: "trading.scan_xau",  symbol: "XAUUSD" },
  { name: "report_daily", cron: "0 20 * * *",   action: "report.daily",      agent: "joe" },
  { name: "night_off",    cron: "30 23 * * *", action: "system.shutdown",   tapo: true },
]

# zDash local dashboard service
npm run build
npm run preview  # http://127.0.0.1:3006

# Cloudflare Tunnel
https://zdash.zeaz.dev -> http://127.0.0.1:3006`}</pre>
        </Section>

        <Section number="09" label="API REFERENCE" heading="Internal API Endpoints" sub="Janie Server REST API + WebSocket สำหรับสื่อสารระหว่าง Agent">
          <div className="card table-wrap"><table><thead><tr><th>METHOD</th><th>ENDPOINT</th><th>AGENT</th><th>DESCRIPTION</th></tr></thead><tbody>{apiRows.map(([method, endpoint, agent, desc]) => <tr key={endpoint}><td><span className={`method method-${method.toLowerCase()}`}>{method}</span></td><td className="mono">{endpoint}</td><td>{agent}</td><td>{desc}</td></tr>)}</tbody></table></div>
        </Section>

        <Section number="10" label="BUILD ROADMAP" heading="วิธีสร้างระบบ Step-by-Step" sub="ลำดับการสร้างระบบทั้งหมดตั้งแต่ต้นจนสมบูรณ์ 7 Phase">
          <div className="timeline">{roadmap.map(([phase, title, desc]) => <article className="timeline-item" key={phase}><span className="timeline-dot" /><b>{phase}</b><h3>{title}</h3><p>{desc}</p></article>)}</div>
        </Section>

        <footer>⬡ zDash · FULL SYSTEM BLUEPRINT v2.0 · 2026-05-24 · 9 AGENTS ACTIVE</footer>
      </main>
    </>
  );
}

createRoot(document.getElementById("root")).render(<App />);
