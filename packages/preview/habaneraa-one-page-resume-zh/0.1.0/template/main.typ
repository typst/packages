#import "@preview/habaneraa-one-page-resume-zh:0.1.0": setup-styles

#let (resume-header, resume-entry) = setup-styles(
  accent-color: rgb("#179299"),  // 根据需要调整主题色，如需黑白请改为 rgb("#000000")
  font-size: 12pt,                 // 全局字体大小
  element-spaciness: 1.30,         // 间距乘数，用于调整排版让内容适应到刚好一页
)

#show: resume-header.with(
  author: "你的名字",
  basic-info: ([求职意向 / 学历 / 政治面貌 / 性别年龄籍贯等],),
  telephone: "138-0000-0000",
  email: "you@example.com",
  github-id: "your-id",
)

= 小节标题
#resume-entry(
  title: "第一个简历项",
  subtitle: "文本1",
  date: "文本2"
)[
  - 这是一个基于 Typst 的中文简历模板
  - 极简，自由书写，轻松排版，高度定制
  - 多种文本样式：_强调_ ; *高亮* ; `monospaced` ; #underline[下划线] ; #link("https://github.com")[超链接]
]
