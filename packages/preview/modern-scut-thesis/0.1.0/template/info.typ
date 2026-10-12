// 论文信息（单一真相源）
// 在这里统一维护作者、学号、学位类型、学院、专业、日期等信息。
// `template/thesis.typ` 会从本文件导入这些信息；封面、摘要等页面自动使用。
// 盲审、查重与印刷等构建场景由 `template/build.typ` 解析。

#let doctype = "master" // "master" | "doctor"

// "academic" 学术型 | "professional" 专业学位（影响盲审封面标题与字段标签）
#let kind = "academic"
// 留学生学位论文（影响盲审封面标题）
#let international = false
// 同等学力申请学位（盲审封面标题下加括号副题）
#let equivalent = false

#let info = (
  title: ("基于 Typst 的", "华南理工大学学位论文"),
  title-en: "SCUT Thesis Template for Typst",
  author: "张三",
  author-en: "Zhang San",
  student-id: "1234567890",
  department: "某学院",
  major: "某专业",
  field: "某方向",
  supervisor: ("李四", "教授"),
  supervisor-en: "Prof. Li Si", // "Assoc. Prof. Wang Wu"
  submit-date: datetime(year: 2026, month: 6, day: 1),
  defend-date: datetime.today(),
  confer-date: datetime(year: 2026, month: 6, day: 1) + duration(days: 30),
  school-code: "10561",
  school-name: "华南理工大学",
  school-name-en: "South China University of Technology",
  school-address-en: "Guangzhou, China",
  degree-type: "工学",
  clc: "XXXXX",  // 按论文主题对照《中国图书馆分类法》填写
  chairman: "某某某 教授",
  reviewer: ("某某某 教授", "某某某 教授", "某某某 教授"),
)
