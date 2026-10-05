// 站点配置:模板成员再导出 + 网页模板 + 导航卡片清单。
// 各页只写 #import "…/配置.typ": *(模板成员经它再导出),不再直接引 lib.typ。
// / Site config: re-exports the template, defines the web template and the
// nav-card list. Every page imports from here.

#import "@preview/underhell:0.6.1": *

// 右上角导航栏:站内只留首页,外链(http)自动新窗口打开。
#let 站内链接 = (
  (标签: "首页", 网址: "/", 提示: "主文档"),
  (标签: "项目主页", 网址: "https://example.com", 提示: "回到主页"),
)

// 网页模板:入口(内容/index.typ 或 页面.typ)用 #show 套用;正文页不设 show。
#let 网页模板 = 地狱之下模板.with(
  title: "A Date with Destiny",
  subtitle: "A one-shot adventure for 4 players of levels 1-4 - with dinosaurs",
  author: "Colin Jacobs",
  lang: "zh",
  cover: image("../img/party.png", height: 100%),
  paper: "a4",
  logo: image("../img/GenericLogo.png", width: 13%),
  fancy-author: true,
  元素系统数据: csv("../../../文档/附件/元素系统.csv"),
  品牌名: "Example Press",
  页脚链接: 站内链接,
  备案号: "",
)

// 导航卡片清单:(路径, 标题)。路径相对 内容/(不含 .typ),即网页 URL 段。
// 只配导航显示哪些页、什么顺序、叫什么;页面集合由构建脚本扫 内容/ 目录树得到。
// / Nav-card list: (path, title). Paths are relative to 内容/ and double as URL
// segments; the page set itself is scanned from the 内容/ tree by the build script.
#let 导航 = (
  ("世界纲要", "世界纲要"),
  ("生物", "生物"),
  ("生物/怪动植物", "怪动植物"),
)
