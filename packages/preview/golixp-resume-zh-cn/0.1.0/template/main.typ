// ============================================
// 简历示例文件 (Resume Example)
// ============================================
// 本文件展示如何使用模块化简历模板创建个人简历
// 用户可以根据自己的需求修改内容和样式

// --------------------------------------------
// 模块导入 (Module Imports)
// --------------------------------------------

// 导入库入口 - 提供配置 API + 图标 + 组件
#import "@preview/golixp-resume-zh-cn:0.1.0": *

// ============================================
// 导入页面配置 (Import Page Configuration)
// ============================================

#show: resume-doc.with(
  overrides: (
    // 可以在此通过 overrides 覆盖配置，例如：
    // colors: (primary: rgb(180, 0, 0)),
    // fonts: (main: "Source Han Sans SC"),
  ),
)

// ============================================
// 简历正文开始 (Resume Content)
// ============================================

// --------------------------------------------
// 个人信息 (Personal Information)
// --------------------------------------------

// 使用 personal-header 组件展示姓名和联系方式
// info-items 是一个数组，每项包含 icon（图标名）和 content（内容）
// 可选：link 参数用于添加链接

#personal-header(
    "张三",  // 姓名
    (
      // 联系方式列表 - 每项包含图标和内容
      (icon: "phone", content: "138-0000-0000"),
      (icon: "email", content: "zhangsan@email.com"),
      (icon: "location", content: "北京市"),
      (icon: "github", content: "github.com/zhangsan", link: "https://github.com/zhangsan"),
    ),
    // 可选：添加照片
    // photo: "photo.jpg",
    // photo-width: 2.5cm,
  )

// --------------------------------------------
// 个人总结 (Personal Summary)
// --------------------------------------------

  #section-header("个人总结", icon-name: "lightbulb")

// 方式一：段落形式的个人简介
#summary-paragraph[
  5年全栈开发经验，专注于高性能后端服务和现代化前端架构。熟悉分布式系统设计，
  具备从需求分析到系统上线的全流程项目经验。善于技术选型和团队协作，追求代码质量和开发效率的平衡。
]

// 方式二：列表形式的个人特质（取消注释使用）
// #summary-list((
//   [5年全栈开发经验，精通 Go/Python 后端开发],
//   [具备分布式系统和微服务架构设计能力],
//   [优秀的团队协作能力和技术文档编写能力],
// ))

// --------------------------------------------
// 教育经历 (Education)
// --------------------------------------------

#section-header("教育经历", icon-name: "graduation")

// 使用 education-item 添加教育经历
  #education-item(
    "2015.09 - 2019.06",   // 时间段
    "某某大学",              // 学校名称
    "本科",                  // 学位
    "计算机科学与技术",        // 专业
    gpa: "3.8/4.0",         // GPA（可选）
    honors: ("优秀毕业生", "一等奖学金"),  // 荣誉（可选）
    // description: [相关课程：数据结构、算法设计、操作系统、计算机网络],  // 描述（可选）
  )

// 方式二：使用 education-list 批量添加（取消注释使用）
// #education-list((
//   (
//     period: "2015.09 - 2019.06",
//     school: "某某大学",
//     degree: "本科",
//     major: "计算机科学与技术",
//     gpa: "3.8/4.0",
//   ),
// ))

// --------------------------------------------
// 工作经历 (Work Experience)
// --------------------------------------------

  #section-header("工作经历", icon-name: "work")

// 方式一：使用 work-item 单独添加每项经历
  #work-item(
    "2021.06 - 至今",      // 时间段
    "某科技有限公司",        // 公司名称
    "高级后端工程师",        // 职位
    location: "北京",       // 地点（可选）
    tech-stack: ("Go", "Python", "Kubernetes", "PostgreSQL"),  // 技术栈（可选）
    responsibilities: (     // 工作职责
      [负责核心交易系统的架构设计和开发，支撑日均百万级订单处理],
      [主导微服务改造项目，将单体应用拆分为 15+ 个微服务],
      [优化数据库查询性能，将核心接口响应时间从 200ms 降至 50ms],
    ),
    achievements: (         // 主要成就（可选）
      [获得年度技术创新奖],
      [晋升为技术组长，带领 5 人团队],
    ),
  )

  #work-item(
    "2019.07 - 2021.05",
    "某互联网公司",
    "后端开发工程师",
    location: "上海",
    tech-stack: ("Java", "Spring Boot", "MySQL", "Redis"),
    responsibilities: (
      [参与电商平台后端服务开发，负责订单和支付模块],
      [设计实现高并发秒杀系统，支持 10 万+ QPS],
      [编写技术文档和单元测试，代码覆盖率达到 85%],
    ),
  )

// 方式二：使用 work-list 批量添加经历（取消注释使用）
// #work-list((
//   (
//     period: "2021.06 - 至今",
//     company: "某科技有限公司",
//     position: "高级后端工程师",
//     location: "北京",
//     tech-stack: ("Go", "Python", "Kubernetes"),
//     responsibilities: ([工作职责1], [工作职责2]),
//   ),
//   // 更多经历...
// ))

// --------------------------------------------
// 项目经历 (Project Experience)
// --------------------------------------------

  #section-header("项目经历", icon-name: "project")

// 使用 project-item 添加项目
#project-item(
  "分布式任务调度平台",     // 项目名称
  ("Go", "gRPC", "etcd", "React"),  // 技术栈
  [自研分布式任务调度系统，支持定时任务、工作流编排和任务依赖管理。],  // 项目描述
  responsibilities: (      // 职责/贡献（可选）
    [设计基于 etcd 的分布式锁和选主机制，保证任务执行的高可用],
    [实现任务 DAG 调度引擎，支持复杂工作流编排],
    [开发可视化管理界面，支持任务监控和日志查看],
  ),
  link: "https://github.com/example/scheduler",  // 项目链接（可选）
  period: "2022.03 - 2022.08",  // 时间段（可选）
)

#project-item(
  "实时数据分析平台",
  ("Python", "Flink", "Kafka", "ClickHouse"),
  [构建实时数据处理和分析平台，支持业务指标实时计算和可视化展示。],
  responsibilities: (
    [基于 Flink 开发实时 ETL 流程，处理日均 TB 级数据],
    [设计 ClickHouse 数据模型，优化查询性能],
  ),
)

// --------------------------------------------
// 专业技能 (Skills)
// --------------------------------------------

  #section-header("专业技能", icon-name: "code")

// 方式一：使用 skill-category 分类展示技能
#skill-category(
  "编程语言",              // 分类名称
  ("Go", "Python", "Java", "JavaScript", "TypeScript"),  // 技能列表
  level: "精通",           // 熟练度（可选）
)

#skill-category(
  "后端技术",
  ("Spring Boot", "Gin", "FastAPI", "gRPC", "GraphQL"),
)

#skill-category(
  "数据库",
  ("MySQL", "PostgreSQL", "Redis", "MongoDB", "ClickHouse"),
)

#skill-category(
  "云原生",
  ("Docker", "Kubernetes", "Prometheus", "Grafana", "Helm"),
)

#skill-category(
  "其他",
  ("Git", "Linux", "CI/CD", "Agile"),
)

// 方式二：使用 skill-list 批量添加（取消注释使用）
// #skill-list((
//   (category: "编程语言", skills: ("Go", "Python", "Java"), level: "精通"),
//   (category: "后端技术", skills: ("Spring Boot", "Gin")),
// ))

// 方式三：使用 skill-cloud 标签云展示（取消注释使用）
// #skill-cloud((
//   (name: "Go", icon: "go", level: "精通"),
//   (name: "Python", icon: "python", level: "精通"),
//   (name: "Docker", icon: "docker"),
// ), columns: 3)

// --------------------------------------------
// 获奖荣誉 (Awards)
// --------------------------------------------

  #section-header("获奖荣誉", icon-name: "award")

// 使用 award-item 添加奖项
#award-item(
  "技术创新奖",            // 奖项名称
  "2023.12",              // 获奖日期
  issuer: "某科技有限公司",  // 颁发机构（可选）
  description: [主导完成微服务架构升级项目],  // 描述（可选）
)

#award-item(
  "ACM 区域赛银牌",
  "2018.05",
  issuer: "ACM-ICPC",
)

// 方式二：使用 award-list 批量添加（取消注释使用）
// #award-list((
//   (name: "技术创新奖", date: "2023.12", issuer: "某公司"),
//   (name: "优秀员工", date: "2022.12"),
// ))

// ============================================
// 其他组件示例 (Additional Components Demo)
// ============================================
// 以下是模块中其他可用组件的使用示例，
// 可根据需要取消注释使用

/*
// --- 标签列表 ---
// 以标签形式展示技术栈或关键词
#tag-list(("Go", "Python", "Docker", "K8s"))

// --- 双列布局 ---
// 将内容分为两列展示
#two-col(
  [左侧内容],
  [右侧内容],
  ratio: (1fr, 2fr),  // 列宽比例
)

// --- 侧边栏布局 ---
// 左侧时间轴 + 右侧内容的布局
#sidebar(
  [2023.01],           // 侧边栏内容（通常是时间）
  [主要内容区域],         // 主内容
  with-line: true,     // 是否显示分割线
)

// --- 信息卡片 ---
// 带背景的信息展示卡片
#info-card(
  "卡片标题",
  [卡片内容],
  icon-name: "info",
)

// --- 时间轴 ---
// 时间轴形式展示经历
#timeline((
  (period: "2023", title: "事件1", subtitle: "副标题", description: [描述内容]),
  (period: "2022", title: "事件2"),
))

// --- 图标使用 ---
// 显示单个图标
#icon("github")

// 图标 + 文本标签
#icon-label("email", "contact@email.com")

// 技术图标（自动匹配技术对应的图标）
#tech-icon("rust")
*/
