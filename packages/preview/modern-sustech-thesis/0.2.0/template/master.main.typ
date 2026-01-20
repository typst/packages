//////////////////////
// 硕士学位论文示例 //
//////////////////////

// 使用前请确保系统里正常安装了所需的静态字体：思源宋体、思源黑体、楷体、TIXS Math
// 更多可用字体见用户手册

// 导入配置
#import "master.config.typ": *

// 施加大体样式，必须放在开头！
#show: generic-style

// 封面
#cover

// 题名，是函数调用！
#title-page()

// 英文封面；异于论文语言，需要声明
// 我们本就要用美式英语，所以不改 region
#title-page(lang: "en")

// 学位论文公开评阅人和答辩委员会名单
#reviewers-n-committee

// 原创性和授权声明
#declarations

// 前言有不同的页码要求，施加前言页码样式
#show: front-matter-paginated-style

// 先放默认摘要，语言与论文同
#abstract[
  // 用 include 直接导入文件内容，不是 import！
  #include "chapters/zh.abstract.typ"
]

// 再放另一语言的摘要
#abstract(lang: "en")[
  #include "chapters/en.abstract.typ"
]

// 目录，注意这不是一般的函数调用 outline()，而是放下变量
#outline

// 符号和缩略语说明
#include "chapters/glossary.typ"

// 开始写正文，必须先施加正文样式！
#show: body-matter-style

#include "chapters/preface.typ"

#include "chapters/experiment.typ"

#include "chapters/conclusion.typ"

// 参考文献，直接填文件
#bibliography("ref.bib")

// 写附录，自然用附录样式
#show: appendix-style

// 不同于学士学位论文，附录没有总标题
// 每个一级标题是一章附录

#include "chapters/appendix-a.typ"

#include "chapters/appendix-b.typ"

// 附录之后用附件样式
#show: attachment-style

#include "chapters/acknowledgement.typ"

#include "chapters/resume.typ"

