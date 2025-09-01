#import "@preview/uestc-thesis:1.0.0": *


//避免封面页缩放
// #set page(
//   paper: "a4",
//   margin: (top: 0mm, bottom: 0mm, left: 0mm, right: 0mm),
//   numbering: none
// )
// +封面页，替换为你的封面pdf文件路径
// #muchpdf(read("materials/cover-example.pdf", encoding: none))

//全局格式配置
#show: global-conf.with(title: "论文标题",author:"Devin")

//+声明页，若封面pdf已包含声明页，注释掉该行
#declaration()


// 中文摘要，替换为你的中文摘要内容
#let abstract_cn = [
  这是中文摘要
]
// 英文摘要，替换为你的英文摘要内容
#let abstract_en = [This is English Abstract
]

//+摘要，替换为你的关键词内容
#abstract(
  abstract-cn: abstract_cn,  
  keywords: [关键词1，关键词2，关键词3],
  abstract-en: abstract_en,
  keywords-en: [Keywords1, Keywords2, Keywords3],
)

//+目录
#toc()

//+图目录
#list-of-figures()

//+表目录
#list-of-tables()

//重置页码
#counter(page).update(1)

/*正文内容开始*/

//章节1
#include "chapters/chapter1.typ"
#pagebreak()
//章节2
#include "chapters/chapter2.typ"
#pagebreak()
//章节3
#include "chapters/chapter3.typ"
#pagebreak()
//章节4
#include("./chapters/chapter4.typ")


//章节5
// #include("./chapters/chapter5.typ")
//章节6
// #include("./chapters/chapter6.typ")


/*正文内容结束*/

//+致谢页
#acknowledgements(
  content: [
    感谢我的导师在研究过程中给予的悉心指导和帮助。导师渊博的学识、严谨的治学态度和宽广的视野给我留下了深刻的印象，对我的学术成长有着深远的影响。

    感谢课题组的所有老师和同学们在研究过程中给予的宝贵建议和热心帮助。

    感谢D公司提供的研究数据和调研机会，感谢公司相关负责人在实地调研过程中给予的支持和帮助。

    最后，感谢我的家人在攻读硕士学位期间给予的理解、鼓励和支持，让我能够全身心投入到学习和研究中。
  ],
)



//+参考文献
#references(bibliography(
 "references.bib",
 title: [参考文献],
 style: "gb-7714-2015-numeric"
))



//+附录
#include("./chapters/appendix.typ")


