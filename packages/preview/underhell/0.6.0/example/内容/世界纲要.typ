// → /世界纲要/  单级页:相对 内容/ 的文件路径(去 .typ)即 URL 段。
// 正文页只 import 配置;模板由入口(内容/index.typ 或 页面.typ)用 #show 套用。
// / → /世界纲要/  Single-level page: the path relative to 内容/ (minus .typ).
#import "配置.typ": *

= 世界纲要

`内容/世界纲要.typ` → `/世界纲要/`。

#lorem(60)
