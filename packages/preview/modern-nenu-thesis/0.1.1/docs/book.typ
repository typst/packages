#import "@preview/shiroa:0.2.3": *

#show: book

#build-meta(
  dest-dir: "./dist",
)

#book-meta(
  title: "东北师范大学毕业论文模板使用手册",
  repository: "https://github.com/virgiling/NENU-Thesis-Typst",
  repository-edit: "https://github.com/virgiling/NENU-Thesis-Typst/edit/master/docs/{path}",
  authors: ("Dian Ling",),
  language: "zh",
  summary: [
    - #prefix-chapter("introduction.typ")[整体介绍]
    = 使用方法
    - #chapter("guide/install.typ")[在线/离线安装]
    - #chapter("guide/get-start.typ")[简单使用]
    - #chapter("guide/detail.typ")[页面设置与使用]
    - #chapter("guide/decompose.typ")[多文件书写]
    = 参考文档
    - #chapter("reference/info.typ")[info 选项说明]
    - #chapter("reference/pubs.typ")[pubs 选项说明]
    - #chapter("reference/comments.typ")[comments 选项说明]
    - #chapter("reference/thesis.typ")[lib.typ]
  ],
)

// re-export page template
#import "./templates/page.typ": heading-reference, project
#import "@preview/gentle-clues:1.2.0": *
#import "@preview/cheq:0.3.0": checklist

#show: gentle-clues.with(border-radius: 5pt, border-width: 1pt)

#let myinfo(body, title: "信息", title-color: black.lighten(20%), ..args) = info(
  title: text(fill: title-color, title),
  ..args,
  body,
)

#let mywarning(body, title: "警告", title-color: black.lighten(20%), ..args) = warning(
  title: text(fill: title-color, title),
  ..args,
  body,
)

#let mynotify(body, title: "通知", title-color: black.lighten(20%), ..args) = notify(
  title: text(fill: title-color, title),
  ..args,
  body,
)

#let myexperiment(body, title: "实验", title-color: black.lighten(20%), ..args) = experiment(
  title: text(fill: title-color, title),
  ..args,
  body,
)

#let myexample(body, title: "示例", title-color: black.lighten(20%), ..args) = example(
  title: text(fill: title-color, title),
  ..args,
  body,
)

#let type-hint(t, required: false) = {
  {
    set text(weight: 400, size: 16pt)
    if required {
      " (required) "
    }
  }
  {
    text(fill: red, raw(t))
  }
}

#let book-page = project
#let cross-link = cross-link
#let heading-reference = heading-reference
