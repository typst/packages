// 西安电子科技大学研究生学位论文开题报告表
//
// 覆盖学术/专业硕士与学术/专业博士。字段和顺序依据研究生院 2025.01 与
// 专业博士 2026.09 资料包中的原始 Word 表；版式数值见 docs/配套材料规格.md。

#import "layout.typ": *

#let 校验(graduate, degree) = {
  assert(graduate in ("master", "doctor"), message: "graduate 必须是 master 或 doctor")
  assert(degree in ("academic", "professional"),
    message: "degree 必须是 academic 或 professional")
}

#let 默认信息(graduate, degree) = {
  let 学位类别 = if graduate == "doctor" {
    if degree == "professional" { "工程博士" } else { "工学博士" }
  } else {
    if degree == "professional" { "电子信息硕士" } else { "工学硕士" }
  }
  (
    title: ("基于 Typst 的学位论文排版方法", "研究"),
    author: "张三",
    student-id: "2026000001",
    department: "电子工程学院",
    discipline: "电子科学与技术",
    subdiscipline: "电磁场与微波技术",
    degree-name: 学位类别,
    domain: "人工智能",
    supervisor: "李四　教授",
    enterprise-supervisor: if degree == "professional" { "王五　高级工程师" } else { "" },
    proposal-date: "2026 年 10 月",
    internship-unit: "示例实习单位",
    internship-post: "算法研发",
    internship-mode: "校内",
    internship-period: "2026 年 7 月至 2027 年 6 月",
    thesis-type: "应用基础技术",
  )
}

#let 封面类别(graduate, degree) = {
  let 前缀 = if degree == "professional" { "专业学位" } else { "" }
  let 层次 = if graduate == "doctor" { "博士" } else { "硕士" }
  前缀 + 层次 + "学位论文开题报告表"
}

#let 要求(graduate, degree) = {
  if graduate == "doctor" {
    if degree == "professional" {
      (
        "博士生通过综合考试后，必须在第三学期末之前（直接攻博研究生在第五学期末之前）进行学位论文开题报告。",
        "各学位授权点和指导教师必须严格督促每位博士生如实、如期在本学科（领域）或相关学科（领域）范围内公开举行开题报告会，严禁伪造和抄袭开题报告。",
        "开题报告会由博士生所在学科（领域）的负责人或其指导教师（指导小组负责人）组织 3～5 名相关学科（领域）的专家组成报告会小组，小组成员原则上应为博士生导师，其中至少有 1 名企业（行业）专家。小组设组长 1 名，博士生本人的指导教师可作为小组成员参加开题报告会。",
        "开题报告结论分为两种：1. 通过，按专家意见修改后进行学位论文撰写工作；2. 不通过，重新开题。",
        "开题报告通过的博士生，根据报告会小组专家的意见和建议，填写好本表，经报告会小组所有成员和本人指导教师签字确认后，在提交送审学位论文时交至所在学院。",
        "开题报告没有通过的博士生，填写“西安电子科技大学博士研究生开题报告修改说明表”，根据报告会小组专家的意见和建议修改开题报告，重新组织开题。重新组织开题的博士生必须在第四学期末之前（直接攻博研究生在第六学期末之前）完成开题报告会。",
        "在学位论文开题规定的时间期限内休学的博士生，开题的时间期限相应顺延。",
        "开题必须在规定时间内通过研究生学位管理系统申请，本表由系统自动生成，用 A3 纸张正反套印。",
        "表格填写要求：正文字体宋体，字号小四，行间距固定值 20 磅。",
      )
    } else {
      (
        "博士生通过综合考试后，必须在第三学期末之前（直接攻博研究生在第五学期末之前）进行学位论文开题报告。",
        "各学位授权点和指导教师必须严格督促每位博士生如实、如期在本学科或相关学科范围内公开举行开题报告会，严禁伪造和抄袭开题报告。",
        "开题报告会由博士生所在学科的负责人或其指导教师（指导小组负责人）组织 3～5 名相关学科的专家组成报告会小组，小组成员原则上应为博士生导师，其中至少有 1 名校外专家。小组设组长 1 名，博士生本人的指导教师可作为小组成员参加开题报告会。",
        "开题报告结论分为两种：1. 通过，按专家意见修改后进行学位论文撰写工作；2. 不通过，重新开题。",
        "开题报告通过的博士生，根据报告会小组专家的意见和建议，填写好本表，经报告会小组所有成员和本人指导教师签字确认后，在提交送审学位论文时交至所在学院。",
        "开题报告没有通过的博士生，填写“西安电子科技大学博士研究生选题报告修改说明表”，根据报告会小组专家的意见和建议修改选题报告，重新组织开题。重新组织开题的博士生必须在第四学期末之前（直接攻博研究生在第六学期末之前）完成开题报告会。",
        "在学位论文开题规定的时间期限内休学的博士生，开题的时间期限相应顺延。",
        "开题必须在规定时间内通过研究生学位管理系统申请，本表由系统自动生成，用 A3 纸张正反套印。",
        "表格填写要求：正文字体宋体，字号小四，行间距固定值 20 磅。",
      )
    }
  } else {
    (
      "硕士研究生必须在第三学期末之前进行学位论文开题报告。",
      "硕士学位论文的开题报告会由各学院自行组织，硕士研究生必须如实、如期在本学科（领域）或相关学科（领域）范围内公开举行开题报告会，严禁伪造和抄袭开题报告。",
      "开题报告结论分为两种：1. 通过，按专家意见修改后进行学位论文撰写工作；2. 不通过，重新开题。",
      "在学位论文开题规定的时间期限内休学的硕士研究生，开题的时间期限相应顺延。",
      "开题必须在规定时间内通过研究生学位管理系统申请，本表由系统自动生成，用 A3 纸张正反套印。",
      "表格填写要求：正文字体宋体，字号小四，行间距固定值 20 磅。",
    )
  }
}

#let 评价条目(graduate, degree) = {
  if graduate == "doctor" {
    if degree == "professional" {
      (
        ("论文选题", "1. 选题来自相关工程领域的重大、重点工程项目；\n2. 选题具有重要的工程应用价值和前景。"),
        ("研究方案", "1. 研究目标明确；\n2. 整体设想及构架科学合理；\n3. 研究内容具有创新性，发现了新现象、探索了新规律；或提出了新理论、新技术、新方法，解决了国家专项工程的关键技术难题，修正或发展了已有理论或技术；\n4. 研究或设计方法科学合理，关键技术有难度；\n5. 预期取得的研究成果具有较高水平和较大影响力。"),
        ("研究基础", "1. 具备了较好的实验条件和较为深厚的研究工作积累；\n2. 发表了与重大科研项目有关的论文、行业标准、相关专著、科技奖励、发明专利及其他相关实用性成果。"),
        ("进度安排", "时间安排充裕、合理。"),
      )
    } else {
      (
        ("论文选题", "1. 选题为学科前沿，具有开创性，对国民经济、科学技术发展具有理论意义或实用价值，研究方向明确；\n2. 国内外研究现状综合全面反映该学科和相关领域的发展和最新成果，归纳总结正确。"),
        ("研究方案", "1. 研究目标明确；\n2. 整体设想及构架科学合理；\n3. 研究内容具有创新性，探索了有价值的现象、新规律，提出了新命题、新方法；\n4. 研究或设计方法科学合理，关键技术有难度；\n5. 预期取得的研究成果具有较高水平和较大影响力。"),
        ("研究基础", "1. 具备了较好的实验条件和较为深厚的研究工作积累；\n2. 在国际及国内重要刊物上发表了与学位论文相关的文章。"),
        ("进度安排", "时间安排充裕、合理。"),
      )
    }
  } else if degree == "professional" {
    (
      ("论文选题", "1. 选题具有重要的理论意义或实际意义，是直接面向工程或具有探索性的应用课题；\n2. 国内外研究现状综合全面反映该领域的最新研究成果，归纳总结正确。"),
      ("研究方案", "1. 研究目标明确；\n2. 整体设想及构架科学合理；\n3. 研究或设计方法科学合理，关键技术有难度；\n4. 预期取得的研究成果具有实用性和新技术应用价值，可产生一定的社会效益和经济效益。"),
      ("研究基础", "具备了较好的实验条件和较为深厚的研究工作积累。"),
      ("进度安排", "时间安排充裕、合理。"),
    )
  } else {
    (
      ("论文选题", "1. 选题接触学科前沿，对国民经济、科技发展具有一定的理论意义和实用价值；\n2. 国内外研究现状综合全面反映该学科或相关领域的最新研究成果，归纳总结正确。"),
      ("研究方案", "1. 研究目标明确；\n2. 整体设想及构架科学合理；\n3. 研究内容有独到之处，提出了新命题、新方法；较好地解决了自然科学或工程技术中的某一具体问题；\n4. 研究或设计方法科学合理，关键技术有难度；\n5. 预期取得的研究成果有一定的应用价值，可产生一定的社会效益和经济效益。"),
      ("研究基础", "具备了较好的实验条件和较为深厚的研究工作积累。"),
      ("进度安排", "时间安排充裕、合理。"),
    )
  }
}

#let 研究要求(graduate) = {
  if graduate == "doctor" { "本部分内容要体现出学位论文的整体设想及构架。" } else { "本部分内容要体现出学位论文的整体设想及构架。" }
}

#let 封面(info, graduate: "master", degree: "academic", fonts: (:)) = {
  let 标题行 = if type(info.title) == array { info.title } else { (info.title,) }
  顶部学号(info, fonts: fonts)
  v(8mm)
  标题("西 安 电 子 科 技 大 学", fonts: fonts, size: 16pt)
  v(3mm)
  标题(封面类别(graduate, degree), fonts: fonts, size: 18pt)
  v(18mm)

  填写行("论文题目：", 标题行.at(0, default: ""), label-width: 30mm, fonts: fonts)
  for 行 in 标题行.slice(1) {
    v(4pt)
    填写行("", 行, label-width: 30mm, fonts: fonts)
  }
  v(8mm)

  let 字段 = if graduate == "doctor" {
    if degree == "professional" {
      (
        ("姓　　名", info.author),
        ("学位类别", info.degree-name),
        ("领域（方向）", info.domain),
        ("指导教师", info.supervisor),
        ("学　　院", info.department),
        ("开题日期", info.proposal-date),
      )
    } else {
      (
        ("姓　　名", info.author),
        ("一级学科", info.discipline),
        ("二级学科", info.subdiscipline),
        ("指导教师", info.supervisor),
        ("学　　院", info.department),
        ("开题日期", info.proposal-date),
      )
    }
  } else if degree == "professional" {
    (
      ("姓　　名", info.author),
      ("学位类别", info.degree-name),
      ("领　　域", info.domain),
      ("校内导师", info.supervisor),
      ("校外导师", info.enterprise-supervisor),
      ("学　　院", info.department),
      ("开题日期", info.proposal-date),
    )
  } else {
    (
      ("姓　　名", info.author),
      ("一级学科", info.discipline),
      ("二级学科", info.subdiscipline),
      ("指导教师", info.supervisor),
      ("学　　院", info.department),
      ("开题日期", info.proposal-date),
    )
  }
  for (标签, 值) in 字段 {
    填写行(标签, 值, label-width: 34mm, fonts: fonts)
    v(4mm)
  }
  // 固定页脚放在版心底边之上，避免宋体字面下缘侵入下页边距。
  place(
    bottom + center,
    dy: -3pt,
    text(font: 字体集(fonts).宋体, size: 16pt, "西安电子科技大学研究生院制"),
  )
}

#let 说明页(graduate, degree, fonts: (:)) = {
  标题("开题报告要求", fonts: fonts, size: 16pt)
  v(12pt)
  正文样式({
    for 条目 in 要求(graduate, degree) {
      条目
      parbreak()
    }
  }, fonts: fonts)
}

#let 信息行(label, value, fonts: (:)) = {
  grid(
    columns: (38mm, 1fr),
    column-gutter: 4mm,
    align: (left + bottom, left + bottom),
    text(font: 字体集(fonts).宋体, size: 正文号, weight: "bold", label),
    box(width: 100%, {
      下划线()
      value
    }),
  )
}

#let 评语表(graduate, degree, rubric, fonts: (:)) = {
  let 选中(键) = if type(rubric) == dictionary { rubric.at(键, default: none) } else { none }
  table(
    columns: (22%, 58%, 20%),
    stroke: 0.5pt,
    inset: 5pt,
    align: (center + horizon, left + horizon, center + horizon),
    table.header(
      text(font: 字体集(fonts).宋体, weight: "bold", "一级指标"),
      text(font: 字体集(fonts).宋体, weight: "bold", "二级指标"),
      text(font: 字体集(fonts).宋体, weight: "bold", "评价意见"),
    ),
    ..评价条目(graduate, degree).map(((指标, 内容)) => (
      text(font: 字体集(fonts).宋体, weight: "bold", 指标),
      text(font: 字体集(fonts).宋体, 内容),
      选项行(选中(指标), fonts: fonts),
    )).flatten(),
  )
  v(4pt)
  提示("注：填写评价意见时，请在相应评价意见前的“□”中打“√”。", fonts: fonts)
}

#let 概况内容(info, body, graduate, degree, fonts: (:)) = {
  if graduate == "master" and degree == "professional" {
    信息行("实习单位名称", info.internship-unit, fonts: fonts)
    v(3pt)
    信息行("实习岗位", info.internship-post, fonts: fonts)
    v(3pt)
    信息行("实习实践模式", info.internship-mode + "（校内；校外）", fonts: fonts)
    v(3pt)
    信息行("计划实习时间", info.internship-period, fonts: fonts)
    v(3pt)
    信息行("论文类型", info.thesis-type, fonts: fonts)
    v(6pt)
  }
  小节("选题来源：", 内容(body, "topicSource"), fonts: fonts, blank-lines: 1)
  小节("中文摘要：", 内容(body, "abstract"), fonts: fonts, blank-lines: 8)
}

#let 开题表(
  info,
  body: (:),
  graduate: "master",
  degree: "academic",
  fonts: (:),
) = {
  let 教师意见 = 内容(body, "advisorOpinion")
  let 记录 = 内容(body, "record")
  let 结论 = 内容(body, "conclusion")
  表单块(title: "一、论文概况", fonts: fonts, first: true)[
    #概况内容(info, body, graduate, degree, fonts: fonts)
  ]
  表单块(title: "二、选题依据", fonts: fonts)[
    #小节("（一）选题意义", 内容(body, "significance"), fonts: fonts, blank-lines: 5)
    #小节("（二）国内外研究现状", 内容(body, "researchStatus"), fonts: fonts, blank-lines: 8)
  ]
  表单块(title: "三、研究方案", fonts: fonts)[
    #小节("（一）研究目标", 内容(body, "goal"), fonts: fonts, blank-lines: 5)
    #小节("（二）研究内容", 内容(body, "researchContent"), fonts: fonts,
      hint: 研究要求(graduate), blank-lines: 8)
    #小节("（三）拟解决的关键问题", 内容(body, "keyProblems"), fonts: fonts, blank-lines: 5)
    #小节("（四）拟采取的研究方法、技术路线、实验方案及可行性研究",
      内容(body, "methods"), fonts: fonts, blank-lines: 7)
    #if graduate == "doctor" [
      #小节("（五）论文的创新点", 内容(body, "innovation"), fonts: fonts, blank-lines: 4)
    ]
    #小节(
      if graduate == "doctor" { "（六）研究计划及预期取得的研究成果" } else { "（五）研究计划及预期取得的研究成果" },
      内容(body, "plan"),
      fonts: fonts,
      hint: "研究计划要具体，要明确指出每一个时间段的学位论文进展情况及预期取得的研究成果。",
      blank-lines: 7,
    )
  ]
  表单块(title: "四、研究基础", fonts: fonts)[
    #小节("（一）已具备的实验条件和研究工作积累", 内容(body, "foundation"), fonts: fonts, blank-lines: 7)
    #小节("（二）已取得的科研成果", 内容(body, "achievements"), fonts: fonts, blank-lines: 6)
  ]

  if graduate == "master" {
    表单块(title: "五、指导教师意见", fonts: fonts)[
      #小节(
        "",
        if 有内容(教师意见) { 教师意见 } else { "（重点对硕士生的开题情况以及是否同意开题予以说明。）" },
        fonts: fonts,
        blank-lines: 10,
      )
      #签名区(labels: if degree == "professional" {
        ("校内导师签名：", "校外导师签名：")
      } else {
        ("指导教师签名：",)
      }, fonts: fonts)
    ]
    表单块(title: "六、开题报告记录", fonts: fonts)[
      #小节("", if 有内容(记录) { 记录 } else { "（着重记录专家对选题报告提出的问题及修改意见和建议。）" },
        fonts: fonts, blank-lines: 12)
    ]
    pagebreak(weak: true)
    表单块(title: "七、开题报告评语及结论", fonts: fonts)[
      #评语表(graduate, degree, body.at("rubric", default: (:)), fonts: fonts)
      #v(4pt)
      #if 有内容(结论) [ #正文样式(结论, fonts: fonts) ] else [ #留白(5) ]
      #签名区(labels: ("组长签名：", "成员签名："), fonts: fonts)
    ]
  } else {
    表单块(title: "五、开题报告记录", fonts: fonts)[
      #小节("", if 有内容(记录) { 记录 } else { "（着重记录专家对选题报告提出的问题及修改意见和建议。）" },
        fonts: fonts, blank-lines: 12)
    ]
    pagebreak(weak: true)
    表单块(title: "六、开题报告评语及结论", fonts: fonts)[
      #评语表(graduate, degree, body.at("rubric", default: (:)), fonts: fonts)
      #v(4pt)
      #if 有内容(结论) [ #正文样式(结论, fonts: fonts) ] else [ #留白(5) ]
      #签名区(labels: ("组长签名：", "成员签名："), fonts: fonts)
    ]
    if degree == "professional" {
      // 专业博士意见页有两组签名，不能让校外导师签名单独落到空白末页。
      pagebreak(weak: true)
    }
    表单块(title: "七、指导教师意见", fonts: fonts)[
      #小节(
        "",
        if 有内容(教师意见) { 教师意见 } else { "（重点对博士生的开题情况以及是否同意开题予以说明。）" },
        fonts: fonts,
        blank-lines: 10,
      )
      #签名区(labels: if degree == "professional" {
        ("校内导师签名：", "校外导师签名：")
      } else {
        ("指导教师签名：",)
      }, fonts: fonts)
    ]
  }
}

#let proposal-documentclass(
  graduate: "master",
  degree: "academic",
  info: (:),
  fonts: (:),
  fallback: false,
  lang: "zh",
) = {
  校验(graduate, degree)
  let 合并 = 默认信息(graduate, degree) + info
  let doc = (
    it,
  ) => 文档页(info: 合并, fonts: fonts, fallback: fallback, lang: lang, it)
  let 报告 = (body: (:), ..args) => [
    #封面(合并, graduate: graduate, degree: degree, fonts: fonts)
    #pagebreak()
    #说明页(graduate, degree, fonts: fonts)
    #pagebreak()
    #开题表(合并, body: body, graduate: graduate, degree: degree, fonts: fonts)
  ]
  (doc, 报告)
}
