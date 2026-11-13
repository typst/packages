// 文档入口:编译本文件即得完整文档(PDF 或 HTML)。
// 正文分文件放在 内容/ 下,标题层级直接用 = / == …,由 #include 合并进来。
// 各章自带 #import "…/配置.typ": *(模板成员经它再导出)。
// / Entry point: compile this file for the whole document. Chapters live in
// separate files under 内容/ and are merged with #include.
#import "../配置.typ": *

#show: 网页模板

#outline(title: "目录")

#include "概述.typ"
#include "示例.typ"
#include "关于.typ"
