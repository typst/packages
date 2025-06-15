/// ------ ///
/// Layout ///
/// ------ ///

#import "layouts/doc.typ": meta, doc
#import "layouts/front-matter.typ": front-matter
#import "layouts/main-matter.typ": main-matter
#import "layouts/back-matter.typ": back-matter

/// ----- ///
/// Pages ///
/// ----- ///

// before content
#import "pages/fonts-display.typ": fonts-display
#import "pages/cover.typ": cover

// front matter
#import "pages/copyright.typ": copyright
#import "pages/abstract.typ": abstract, abstract-en
#import "pages/outline-wrapper.typ": outline-wrapper
#import "pages/figure-list.typ": figure-list
#import "pages/table-list.typ": table-list
#import "pages/equation-list.typ": equation-list
#import "pages/notation.typ": notation

// back matter
#import "pages/acknowledge.typ": acknowledge
#import "pages/declaration.typ": declaration
#import "pages/achievement.typ": achievement

/// --------- ///
/// Auxiliary ///
/// --------- ///

#import "imports.typ": cuti, i-figured

#import "utils/text.typ": mask-text, space-text, distr-text
#import "utils/font.typ": use-size, fonts-check, _use-fonts
#import "utils/numbering.typ": custom-numbering
#import "utils/bibliography.typ": bilingual-bibliography

#let define-config(
  doctype: "bachelor",
  degree: "academic",
  twoside: false,
  anonymous: false,
  bibliography: none,
  fonts: (:),
  info: (:),
) = {
  let _support_doctype = ("bachelor",)

  assert(
    _support_doctype.contains(doctype),
    message: "不支持的文档类型, 目前支持的有: " + _support_doctype.join(", "),
  )

  return (
    /// ------- ///
    /// options ///
    /// ------- ///
    info: info,
    fonts: fonts,
    degree: degree,
    doctype: doctype,
    twoside: twoside,
    anonymous: anonymous,
    use-fonts: name => _use-fonts(fonts, name),
    /// ------- ///
    /// layouts ///
    /// ------- ///
    // 元信息
    meta: (..args) => meta(
      ..args,
      info: info + args.named().at("info", default: (:)),
    ),
    // 文稿设置
    doc: (..args) => doc(
      ..args,
      fonts: fonts-check(fonts + args.named().at("fonts", default: (:))),
    ),
    // 前辅文
    front-matter: (..args) => front-matter(
      twoside: twoside,
      ..args,
    ),
    // 正文
    main-matter: (..args) => main-matter(
      twoside: twoside,
      ..args,
    ),
    // 后辅文
    back-matter: (..args) => back-matter(
      twoside: twoside,
      ..args,
    ),
    /// ----- ///
    /// pages ///
    /// ----- ///
    // 字体展示页
    fonts-display: (..args) => fonts-display(
      ..args,
      fonts: fonts-check(fonts + args.named().at("fonts", default: (:))),
    ),
    // 封面页
    cover: (..args) => cover(
      anonymous: anonymous,
      ..args,
      fonts: fonts-check(fonts + args.named().at("fonts", default: (:))),
      info: info + args.named().at("info", default: (:)),
    ),
    // 授权页
    copyright: (..args) => copyright(
      anonymous: anonymous,
      twoside: twoside,
      ..args,
      fonts: fonts-check(fonts + args.named().at("fonts", default: (:))),
    ),
    // 中文摘要页
    abstract: (..args) => abstract(
      anonymous: anonymous,
      twoside: twoside,
      ..args,
      fonts: fonts-check(fonts + args.named().at("fonts", default: (:))),
    ),
    // 英文摘要页
    abstract-en: (..args) => abstract-en(
      anonymous: anonymous,
      twoside: twoside,
      ..args,
      fonts: fonts-check(fonts + args.named().at("fonts", default: (:))),
    ),
    // 目录页
    outline-wrapper: (..args) => outline-wrapper(
      twoside: twoside,
      ..args,
      fonts: fonts-check(fonts + args.named().at("fonts", default: (:))),
    ),
    // 符号表页
    notation: (..args) => notation(
      twoside: twoside,
      ..args,
    ),
    // 插图目录页
    figure-list: (..args) => figure-list(
      twoside: twoside,
      ..args,
    ),
    // 表格目录页
    table-list: (..args) => table-list(
      twoside: twoside,
      ..args,
    ),
    // 公式目录页
    equation-list: (..args) => equation-list(
      twoside: twoside,
      ..args,
    ),
    // 参考文献页
    bilingual-bibliography: (..args) => bilingual-bibliography(
      bibliography: bibliography,
      ..args,
    ),
    // 致谢页
    acknowledge: (..args) => acknowledge(
      anonymous: anonymous,
      twoside: twoside,
      ..args,
    ),
    // 声明页
    declaration: (..args) => declaration(
      anonymous: anonymous,
      twoside: twoside,
      ..args,
    ),
    // 成果页
    achievement: (..args) => achievement(
      anonymous: anonymous,
      twoside: twoside,
      ..args,
    ),
  )
}
