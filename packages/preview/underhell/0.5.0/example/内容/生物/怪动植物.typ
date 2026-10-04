// → /生物/怪动植物/  多级页:相对 内容/ 的整条路径即 URL 段。
// 正文页只 import 配置;模板由入口(内容/index.typ 或 页面.typ)用 #show 套用。
// / → /生物/怪动植物/  Nested page: the whole path relative to 内容/.
#import "../配置.typ": *

= 怪动植物

`内容/生物/怪动植物.typ` → `/生物/怪动植物/`。

#元素("怪动植物") 的词条来自 配置.typ 里的 `元素系统数据`。
