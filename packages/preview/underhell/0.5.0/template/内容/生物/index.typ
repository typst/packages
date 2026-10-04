// → /生物/  目录页:<目录>/index.typ 取目录名作 URL 段与标题。
// 正文页只 import 配置;模板由入口(内容/index.typ 或 页面.typ)用 #show 套用。
// / → /生物/  Directory page: <dir>/index.typ maps to the directory name.
#import "../配置.typ": *

= 生物

目录页列出本目录下的子页(路径以 `生物/` 开头):

#for (路径, 名) in 导航.filter(p => p.at(0).starts-with("生物/")) [
  - #link("/" + 路径 + "/")[#名]
]
