#let cs-thesis = (
  layout: "cs-thesis",
  cover: (
    title: [毕业设计题目],
    class: [专业班级],
    student-id: [学号],
    name: [作者姓名],
    teacher: [指导教师],
    report-date: [完成日期],
    college: [计算机科学与技术学院],
  ),
  outline: (depth: 2, font_sizes: (12pt, 12pt)),
  bibliography: (
    style: "gb-7714-2005-numeric",
  ),
  front-matter: (
    abstract-zh: [请在这里填写中文摘要。],
    keywords-zh: ("关键词一", "关键词二"),
    abstract-en: [Write the English abstract here.],
    keywords-en: ("keyword one", "keyword two"),
  ),
  statement: none,
  acknowledgments: none,
)
