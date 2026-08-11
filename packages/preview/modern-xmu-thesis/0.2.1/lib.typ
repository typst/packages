
#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/bachelor-cover.typ": bachelor-cover
#import "pages/bachelor-integrity.typ": bachelor-integrity
#import "pages/acknowledgement.typ": acknowledgement
#import "pages/bachelor-abstract.typ": bachelor-abstract
#import "pages/bachelor-abstract-en.typ": bachelor-abstract-en
#import "pages/bachelor-outline-page.typ": bachelor-outline-page
#import "pages/bachelor-outline-page-en.typ": bachelor-outline-page-en
#import "pages/bilingual-bibliography.typ": bilingual-bibliography
#import "utils/style.typ": 字体, 字号

// 使用函数闭包特性，通过 `documentclass` 函数类进行全局信息配置，然后暴露出拥有了全局配置的、具体的 `layouts` 和 `templates` 内部函数。
#let documentclass(
  twoside: false, // 双面模式，会加入空白页，便于打印
  fonts: (:), // 字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  info: (:),
) = {
  fonts = 字体 + fonts
  info = (
    (
      title: ("基于 Typst 的", "厦门大学本科毕业论文模板"),
      title-en: "An XMU Undergraduate Thesis Template\nPowered by Typst",
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      department: "某学院",
      major: "某专业",
      field: "某方向",
      supervisor: ("李四", "教授"),
      supervisor-outside: (),
      submit-date: datetime.today(),
    )
      + info
  )

  return (
    // 将传入参数再导出
    twoside: twoside,
    fonts: fonts,
    info: info,
    // 页面布局
    doc: (..args) => {
      doc(
        ..args,
        info: info + args.named().at("info", default: (:)),
      )
    },
    preface: (..args) => {
      preface(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    mainmatter: (..args) => {
      mainmatter(
        twoside: twoside,
        ..args,
        info: info + args.named().at("info", default: (:)),
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    appendix: (..args) => appendix(..args),
    // 封面页
    cover: (..args) => bachelor-cover(
      twoside: twoside,
      ..args,
      fonts: fonts + args.named().at("fonts", default: (:)),
      info: info + args.named().at("info", default: (:)),
    ),
    // 诚信承诺书页
    integrity: (..args) => bachelor-integrity(
      twoside: twoside,
      ..args,
      fonts: fonts + args.named().at("fonts", default: (:)),
    ),
    // 致谢页
    acknowledgement: (..args) => acknowledgement(
      twoside: twoside,
      ..args,
      fonts: fonts + args.named().at("fonts", default: (:)),
    ),
    // 中文摘要页
    abstract: (..args) => bachelor-abstract(
      twoside: twoside,
      ..args,
      fonts: fonts + args.named().at("fonts", default: (:)),
    ),
    // 英文摘要页
    abstract-en: (..args) => bachelor-abstract-en(
      twoside: twoside,
      ..args,
      fonts: fonts + args.named().at("fonts", default: (:)),
    ),
    // 中文目录页
    outline-page: (..args) => bachelor-outline-page(
      twoside: twoside,
      ..args,
      fonts: fonts + args.named().at("fonts", default: (:)),
    ),
    // 英文目录页
    outline-page-en: (..args) => bachelor-outline-page-en(
      twoside: twoside,
      ..args,
      fonts: fonts + args.named().at("fonts", default: (:)),
    ),
    // 双语参考文献页
    bilingual-bibliography: (..args) => bilingual-bibliography(..args),
  )
}
