// 西安电子科技大学本科毕业设计（论文）开题报告与中期报告
//
// 依据本科生院资料包中的第 5、6 号 Word 原表。两张表都是需装订的独立行政表，
// 与本科论文正文模板不是同一种文档，不能复用 bachelor/ 的论文版心。

#import "layout.typ": *

#let 本科默认信息 = (
  title: ("基于 Typst 的本科毕业设计", "排版方法研究"),
  author: "张三",
  major: "电子信息工程",
  student-id: "22010100001",
  supervisor: "李四　教授",
  department: "电子工程学院",
  class-year: "2026",
  proposal-date: "2026 年 10 月",
  report-date: "2027 年 4 月",
)

#let 开题要求 = (
  "一、论文名称及项目来源",
  "二、研究目的和意义",
  "三、国内外研究现状和发展趋势",
  "四、主要研究内容、要解决的问题及本文的初步方案",
  "五、工作的主要阶段、进度和完成时间",
  "六、已进行的前期准备工作",
  "七、指导教师意见",
  "学院审核意见",
)

#let 中期要求 = (
  "一、本科生在完成学位论文开题之后三个月内，必须进行学位论文中期考核，考核由各学院自行组织，具体要求参照毕业设计文件执行。",
  "二、中期考核结论分为两种：1. 通过，按专家意见修改后继续学位论文撰写工作；2. 不通过，重新考核，正式答辩前达不到通过标准的，答辩延期进行。",
  "三、中期报告由学生填写，填写完成后，需在限定时间内，在教务系统中上传最终版。",
  "四、中期考核时需携带此表，本表一式三份，本人、指导教师、学院各一份，用 A3 纸张正反套印；承担毕业设计单位审核盖章后的表格最终胶装入存档论文中。",
  "五、表格填写要求：正文字体宋体，字号小四，行间距固定值 20 磅，可续页，请勿更改表格样式。",
)

#let 本科开题封面(info, fonts: (:)) = {
  let 标题行 = if type(info.title) == array { info.title } else { (info.title,) }
  align(
    center,
    text(font: 字体集(fonts).宋体, size: 18pt,
      [西安电子科技大学 #box(width: 48mm, {
        下划线()
        align(center, info.department)
      })]),
  )
  v(14mm)
  标题("本科生毕业论文（设计）开题报告", fonts: fonts, size: 22pt)
  v(4mm)
  标题("（" + info.class-year + " 届）", fonts: fonts, size: 15pt)
  v(24mm)
  填写行("学生姓名", info.author, label-width: 28mm, value-size: 15pt, fonts: fonts)
  v(8mm)
  填写行("专　　业", info.major, label-width: 28mm, value-size: 15pt, fonts: fonts)
  v(8mm)
  填写行("学　　号", info.student-id, label-width: 28mm, value-size: 15pt, fonts: fonts)
  v(8mm)
  填写行("指导教师", info.supervisor, label-width: 28mm, value-size: 15pt, fonts: fonts)
  v(18mm)
  align(center, text(font: 字体集(fonts).宋体, size: 14pt, info.proposal-date))
  v(4mm)
  align(center, text(font: 字体集(fonts).宋体, size: 10.5pt,
    "（本表一式三份，学生、指导教师、学院各一份）"))
  v(6mm)
  align(right, text(font: 字体集(fonts).宋体, size: 10.5pt,
    "题目：" + 标题行.join("　")))
}

#let 本科开题表(info, body: (:), fonts: (:)) = {
  let 字段(键, 默认: none) = 内容(body, 键, 默认: 默认)
  表单块(title: 开题要求.at(0), fonts: fonts, first: true)[
    #小节("", 字段("titleSource"), fonts: fonts, blank-lines: 4)
  ]
  表单块(title: 开题要求.at(1), fonts: fonts)[
    #小节("", 字段("purpose"), fonts: fonts, blank-lines: 7)
  ]
  表单块(title: 开题要求.at(2), fonts: fonts)[
    #小节("", 字段("researchStatus"), fonts: fonts, blank-lines: 8)
  ]
  表单块(title: 开题要求.at(3), fonts: fonts)[
    #小节("", 字段("researchContent"), fonts: fonts, blank-lines: 10)
  ]
  表单块(title: 开题要求.at(4), fonts: fonts)[
    #小节("", 字段("schedule"), fonts: fonts, blank-lines: 7)
  ]
  表单块(title: 开题要求.at(5), fonts: fonts)[
    #小节("", 字段("preparation"), fonts: fonts, blank-lines: 7)
  ]
  表单块(title: 开题要求.at(6), fonts: fonts)[
    #小节("", 字段("advisorOpinion"), fonts: fonts, blank-lines: 7)
    #签名区(labels: ("签名：",), fonts: fonts, gap: 10pt)
  ]
  表单块(title: 开题要求.at(7), fonts: fonts)[
    #小节("", 字段("schoolOpinion"), fonts: fonts, blank-lines: 6)
    #签名区(labels: ("签名：",), fonts: fonts, gap: 10pt)
  ]
}

#let 本科中期封面(info, fonts: (:)) = {
  顶部学号(info, fonts: fonts)
  v(10mm)
  标题("西安电子科技大学", fonts: fonts, size: 22pt)
  v(2mm)
  标题("本科生毕业设计（论文）中期报告", fonts: fonts, size: 22pt)
  v(24mm)
  let 标题行 = if type(info.title) == array { info.title.join("") } else { info.title }
  填写行("题　　目", 标题行, label-width: 30mm, value-size: 15pt, fonts: fonts)
  v(7mm)
  填写行("学生姓名", info.author, label-width: 30mm, value-size: 15pt, fonts: fonts)
  v(7mm)
  填写行("专　　业", info.major, label-width: 30mm, value-size: 15pt, fonts: fonts)
  v(7mm)
  填写行("学　　号", info.student-id, label-width: 30mm, value-size: 15pt, fonts: fonts)
  v(7mm)
  填写行("指导教师", info.supervisor, label-width: 30mm, value-size: 15pt, fonts: fonts)
  v(7mm)
  填写行("报告日期", info.report-date, label-width: 30mm, value-size: 15pt, fonts: fonts)
  // 固定页脚放在版心底边之上，避免宋体字面下缘侵入下页边距。
  place(
    bottom + center,
    dy: -3pt,
    text(font: 字体集(fonts).宋体, size: 16pt, "西安电子科技大学本科生院制"),
  )
}

#let 本科中期说明(fonts: (:)) = {
  标题("西安电子科技大学", fonts: fonts, size: 16pt)
  标题("本科生毕业设计（论文）中期报告要求", fonts: fonts, size: 16pt)
  v(10pt)
  正文样式({
    for 条目 in 中期要求 {
      条目
      parbreak()
    }
  }, fonts: fonts)
}

#let 本科中期表(info, body: (:), fonts: (:)) = {
  let 值(键) = 内容(body, 键)
  表单块(title: "1、毕业设计工作是否更换题目及是否按开题报告预定的内容及进度安排进行",
    fonts: fonts, first: true)[
    #小节("", 值("titleAndSchedule"), fonts: fonts, blank-lines: 7)
  ]
  表单块(title: "2、目前已完成的研究工作及结果", fonts: fonts)[
    #小节("", 值("completed"), fonts: fonts,
      hint: "（针对任务书中目标逐条描述，内容应详实充分）", blank-lines: 10)
  ]
  表单块(title: "3．后期拟完成的研究工作及进度安排（要有可行性）", fonts: fonts)[
    #小节("", 值("nextPlan"), fonts: fonts, blank-lines: 8)
  ]
  表单块(title: "4．存在的困难与问题", fonts: fonts)[
    #小节("", 值("difficulties"), fonts: fonts, blank-lines: 6)
  ]
  表单块(title: "5．如期完成全部论文工作的可能性", fonts: fonts)[
    #小节("", 值("feasibility"), fonts: fonts, blank-lines: 6)
  ]
  表单块(title: "6、指导导师意见（应包含对任务书中目标完成情况进行评价）", fonts: fonts)[
    #小节("", 值("advisorOpinion"), fonts: fonts, blank-lines: 7)
    #签名区(labels: ("导师签名：",), fonts: fonts, gap: 10pt)
  ]
  表单块(title: "7、中期报告检查组意见", fonts: fonts)[
    #小节("", 值("groupOpinion"), fonts: fonts,
      hint: "（中期考核结论分为两种：1. 通过，按专家意见修改后继续学位论文撰写工作；2. 不通过，重新考核，正式答辩前达不到通过标准的，答辩延期进行。）",
      blank-lines: 8)
    #签名区(labels: ("组长签名：", "成员签名："), fonts: fonts, gap: 10pt)
  ]
  pagebreak(weak: true)
  表单块(title: "8、承担毕业设计单位审核（盖章）", fonts: fonts)[
    #小节("", 值("unitReview"), fonts: fonts,
      hint: "（校内毕设学生由学院审核，校外毕设学生由承担毕设企业或单位审核）",
      blank-lines: 6)
    #签名区(labels: ("审核意见：", "盖章："), fonts: fonts, gap: 10pt)
  ]
}

#let bachelor-proposal-documentclass(
  info: (:),
  fonts: (:),
  fallback: false,
  lang: "zh",
) = {
  let 合并 = 本科默认信息 + info
  let doc = (it,) => 文档页(
    info: 合并,
    fonts: fonts,
    fallback: fallback,
    lang: lang,
    margin-left: 3.17cm,
    margin-right: 3.17cm,
    margin-top: 2.54cm,
    margin-bottom: 2.54cm,
    it,
  )
  let 报告 = (body: (:), ..args) => [
    #本科开题封面(合并, fonts: fonts)
    #pagebreak()
    #本科开题表(合并, body: body, fonts: fonts)
  ]
  (doc, 报告)
}

#let bachelor-interim-documentclass(
  info: (:),
  fonts: (:),
  fallback: false,
  lang: "zh",
) = {
  let 合并 = 本科默认信息 + info
  let doc = (it,) => 文档页(
    info: 合并,
    fonts: fonts,
    fallback: fallback,
    lang: lang,
    margin-left: 2.54cm,
    margin-right: 2.54cm,
    margin-top: 2.54cm,
    margin-bottom: 2.54cm,
    it,
  )
  let 报告 = (body: (:), ..args) => [
    #本科中期封面(合并, fonts: fonts)
    #pagebreak()
    #本科中期说明(fonts: fonts)
    #pagebreak()
    #本科中期表(合并, body: body, fonts: fonts)
  ]
  (doc, 报告)
}
