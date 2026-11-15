// 通用课程实验报告示例
//
// 这不是西安电子科技大学统一发布的行政表。不同课程、教师和学院可能要求不同模板；
// 教师已提供模板时，应以教师模板为准。本模块只提供可直接修改的通用实验报告骨架。

#import "layout.typ": *

#let 默认信息 = (
  course: "课程名称",
  title: "实验名称",
  author: "张三",
  student-id: "2026000001",
  department: "学院 / 专业",
  instructor: "任课教师",
  date: "2026 年 10 月",
  group: "第 1 组",
)

#let 信息栏(info, fonts: (:)) = table(
  columns: (24mm, 1fr, 24mm, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 2pt),
  align: (left + horizon, left + horizon, left + horizon, left + horizon),
  text(font: 字体集(fonts).黑体, weight: "bold", "课程"),
  info.course,
  text(font: 字体集(fonts).黑体, weight: "bold", "日期"),
  info.date,
  text(font: 字体集(fonts).黑体, weight: "bold", "姓名"),
  info.author,
  text(font: 字体集(fonts).黑体, weight: "bold", "学号"),
  info.student-id,
  text(font: 字体集(fonts).黑体, weight: "bold", "单位"),
  info.department,
  text(font: 字体集(fonts).黑体, weight: "bold", "教师"),
  info.instructor,
)

#let course-report-documentclass(
  info: (:),
  fonts: (:),
  fallback: false,
  lang: "zh",
) = {
  let 合并 = 默认信息 + info
  let doc = (it,) => 文档页(
    info: 合并,
    fonts: fonts,
    fallback: fallback,
    lang: lang,
    margin-left: 2.2cm,
    margin-right: 2.2cm,
    margin-top: 2.2cm,
    margin-bottom: 2.2cm,
    it,
  )
  let 报告 = (
    sections: (),
    summary: none,
    ..args,
  ) => [
    #align(right, text(font: 字体集(fonts).宋体, size: 10.5pt, 合并.course))
    #v(4mm)
    #标题(合并.title, fonts: fonts, size: 20pt)
    #v(3mm)
    #信息栏(合并, fonts: fonts)
    #v(2mm)
    #line(length: 100%, stroke: 0.75pt)
    #v(6mm)
    #for (i, (section-title, section-body)) in sections.enumerate() [
      #block(breakable: false, above: 10pt, below: 2pt,
        text(font: 字体集(fonts).黑体, size: 14pt, weight: "bold",
          str(i + 1) + "　" + section-title))
      #正文样式(section-body, fonts: fonts)
    ]
    #if summary != none [
      #v(8pt)
      #block(
        width: 100%,
        fill: luma(245),
        inset: 8pt,
        radius: 2pt,
        stroke: luma(210),
      )[
        #text(font: 字体集(fonts).黑体, weight: "bold", "提交前自查：")
        #summary
      ]
    ]
    #v(4mm)
    #提示("本文件为通用课程实验报告示例，不是学校统一模板；教师有指定模板时以教师模板为准。",
      fonts: fonts)
  ]
  (doc, 报告)
}
