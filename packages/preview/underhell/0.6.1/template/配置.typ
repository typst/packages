// 站点配置:模板成员再导出 + 网页模板。
// 各章只写 #import "../配置.typ": *(模板成员经它再导出),不直接引 lib.typ。
// / Site config: re-exports the template and defines the web template.
// Chapters only write #import "../配置.typ": * — the template is re-exported here.

#import "@preview/underhell:0.6.1": *

// 元素系统数据:宽表 CSV,首列是元素 id,其后每列是一个元素系统,
// 单元格为该元素在对应系统下的名词(留空则回退)。列名可自行增删。
// / Element-system data: wide CSV, first column = element id, each further
// column = one element system; empty cells fall back.
#let 元素数据 = csv("附件/元素系统.csv")

// 网页模板:入口 内容/index.typ 用 #show 套用。
// 封面/logo 走模板默认;要加图就把图片放进本项目,再 cover: image("…") / logo: image("…")。
// / Web template: applied by the entry point via #show.
#let 网页模板 = 地狱之下模板.with(
  title: "我的设定集",
  subtitle: "一个崭新的世界",
  author: "你的名字",
  lang: "zh",
  paper: "a4",
  品牌名: "我的世界",
  备案号: "",
  元素系统数据: 元素数据,
)
