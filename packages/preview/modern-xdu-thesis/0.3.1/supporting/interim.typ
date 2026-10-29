// 西安电子科技大学研究生学位论文中期考核报告表
//
// 覆盖学术/专业硕士与学术/专业博士。表内顺序与字段依据研究生院原始 Word 表，
// 不把开题报告的章节结构机械复用到中期考核。

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
    report-date: "2026 年 10 月",
  )
}

#let 封面类别(graduate, degree) = {
  let 前缀 = if degree == "professional" { "专业学位" } else { "" }
  let 层次 = if graduate == "doctor" { "博士" } else { "硕士" }
  前缀 + 层次 + "学位论文中期考核报告表"
}

#let 要求(graduate, degree) = {
  if graduate == "doctor" {
    if degree == "professional" {
      (
        "博士生在完成学位论文开题报告后一年内，必须进行学位论文中期考核，具体要求参照开题报告会要求执行。",
        "每位博士生根据自身实际情况选择考核时间。",
        "中期考核结论分为两种：1. 通过，按专家意见修改后继续学位论文撰写工作；2. 不通过，重新考核。中期考核结果与博士生奖助金挂钩。",
        "在学位论文中期考核规定的时间期限内休学的博士生，中期考核的时间期限相应顺延。",
        "中期考核必须在规定时间内通过研究生学位管理系统申请，本表由系统自动生成，用 A3 纸张正反套印，在提交送审学位论文时交至所在学院。",
        "表格填写要求：正文字体宋体，字号小四，行间距固定值 20 磅。",
      )
    } else {
      (
        "博士生在完成学位论文开题报告后一年内，必须进行学位论文中期考核，会议由各学院统一组织，具体要求参照开题报告会要求执行。",
        "中期考核每年举行 2 次（6 月和 12 月），每位博士生根据自身实际情况选择考核时间。",
        "中期考核结论分为两种：1. 通过，按专家意见修改后继续学位论文撰写工作；2. 不通过，重新考核。中期考核结果与博士生奖助金挂钩。",
        "在学位论文中期考核规定的时间期限内休学的博士生，中期考核的时间期限相应顺延。",
        "中期考核必须在规定时间内通过研究生学位管理系统申请，本表由系统自动生成，用 A3 纸张正反套印，在提交送审学位论文时交至所在学院。",
        "表格填写要求：正文字体宋体，字号小四，行间距固定值 20 磅。",
      )
    }
  } else {
    (
      "硕士生在完成学位论文开题报告后半年内，必须进行学位论文中期考核，会议由各学院自行组织，具体要求参照开题报告会要求执行。",
      "中期考核结论分为两种：1. 通过，按专家意见修改后继续学位论文撰写工作；2. 不通过，重新考核。",
      "在学位论文中期考核规定的时间期限内休学的硕士生，中期考核的时间期限相应顺延。",
      "中期考核必须在规定时间内通过研究生学位管理系统申请，本表由系统自动生成，用 A3 纸张正反套印。",
      "表格填写要求：正文字体宋体，字号小四，行间距固定值 20 磅。",
    )
  }
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
        ("报告日期", info.report-date),
      )
    } else {
      (
        ("姓　　名", info.author),
        ("一级学科", info.discipline),
        ("二级学科", info.subdiscipline),
        ("指导教师", info.supervisor),
        ("学　　院", info.department),
        ("报告日期", info.report-date),
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
      ("报告日期", info.report-date),
    )
  } else {
    (
      ("姓　　名", info.author),
      ("一级学科", info.discipline),
      ("二级学科", info.subdiscipline),
      ("指导教师", info.supervisor),
      ("学　　院", info.department),
      ("报告日期", info.report-date),
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
  标题("中期考核报告要求", fonts: fonts, size: 16pt)
  v(12pt)
  正文样式({
    for 条目 in 要求(graduate, degree) {
      条目
      parbreak()
    }
  }, fonts: fonts)
}

#let 中期表(
  info,
  body: (:),
  graduate: "master",
  degree: "academic",
  fonts: (:),
) = {
  let 导师意见 = 内容(body, "advisorOpinion")
  let 结论 = 内容(body, "conclusion")
  表单块(title: none, fonts: fonts, first: true)[
    #小节("选题来源：", 内容(body, "topicSource"), fonts: fonts, blank-lines: 1)
  ]
  表单块(title: "一、学位论文研究目标及研究内容", fonts: fonts)[
    #小节("", 内容(body, "goalContent"), fonts: fonts,
      hint: "（与开题报告中的研究目标和研究内容一致。）", blank-lines: 8)
  ]
  表单块(title: "二、目前已完成学位论文工作的内容", fonts: fonts)[
    #小节("", 内容(body, "completed"), fonts: fonts,
      hint: "（主要包括所完成的理论和实验研究以及所获得的结论。）", blank-lines: 10)
  ]
  表单块(title: "三、现阶段完成的工作与开题报告内容不相符的情况说明", fonts: fonts)[
    #小节("", 内容(body, "changes"), fonts: fonts, blank-lines: 8)
  ]
  表单块(title: "四、下一步工作计划及需要完成的研究内容和需要解决的关键技术", fonts: fonts)[
    #小节("", 内容(body, "nextPlan"), fonts: fonts, blank-lines: 10)
  ]
  表单块(title: "五、已发表的与学位论文相关的学术论文、其他研究成果以及拟发表的研究成果", fonts: fonts)[
    #小节("", 内容(body, "publications"), fonts: fonts, blank-lines: 8)
  ]
  表单块(title: "指导教师评价意见", fonts: fonts)[
    #小节(
      "",
      if 有内容(导师意见) { 导师意见 } else { "（重点写出该生的表现、计划完成情况、对后续工作情况的估计等。）" },
      fonts: fonts,
      blank-lines: 10,
    )
    #签名区(
      labels: if degree == "professional" {
        ("校内指导教师签名：", "校外指导教师签名：")
      } else {
        ("指导教师签名：",)
      },
      fonts: fonts,
    )
  ]
  表单块(title: "中期总结报告评语及结论", fonts: fonts)[
    #小节(
      "",
      if 有内容(结论) { 结论 } else { "（中期考核结论分为两种：1. 通过，按专家意见修改后继续学位论文撰写工作；2. 不通过，重新考核。）" },
      fonts: fonts,
      blank-lines: 10,
    )
    #签名区(labels: ("组长签名：", "成员签名："), fonts: fonts)
  ]
}

#let interim-documentclass(
  graduate: "master",
  degree: "academic",
  info: (:),
  fonts: (:),
  fallback: false,
  lang: "zh",
) = {
  校验(graduate, degree)
  let 合并 = 默认信息(graduate, degree) + info
  let doc = (it,) => 文档页(info: 合并, fonts: fonts, fallback: fallback, lang: lang, it)
  let 报告 = (body: (:), ..args) => [
    #封面(合并, graduate: graduate, degree: degree, fonts: fonts)
    #pagebreak()
    #说明页(graduate, degree, fonts: fonts)
    #pagebreak()
    #中期表(合并, body: body, graduate: graduate, degree: degree, fonts: fonts)
  ]
  (doc, 报告)
}
