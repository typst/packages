#import "imports.typ": *
#import "utils/font.typ": use-size
#import "utils/numbering.typ": custom-numbering
#import "utils/text.typ": distr-text, mask-text, space-text

/// Define the configuration for the document.
///
/// - doctype ("bachelor"): The document type.
/// - degree ("academic"): The degree type.
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool): Whether to use two-sided printing.
/// - strict (bool): Whether to enable strict check mode for text rendering.
/// - bibliography (): The bibliography entry.
/// - fonts (dictionary): The font family to use.
/// - info (dictionary): The information to be displayed in the document.
/// -> dictionary
#let define-config(
  doctype: "bachelor",
  degree: "academic",
  anonymous: false,
  twoside: false,
  strict: false,
  bibliography: none,
  fonts: (:),
  info: (:),
) = {
  /// ------ ///
  /// Layout ///
  /// ------ ///

  import "layouts/doc.typ": doc, meta
  import "layouts/front-matter.typ": front-matter
  import "layouts/main-matter.typ": main-matter
  import "layouts/back-matter.typ": back-matter

  /// ----- ///
  /// Pages ///
  /// ----- ///

  // before content
  import "pages/fonts-display.typ": fonts-display
  import "pages/cover.typ": cover

  // front matter
  import "pages/copyright.typ": copyright
  import "pages/abstract.typ": abstract, abstract-en
  import "pages/outline-wrapper.typ": outline-wrapper
  import "pages/figure-list.typ": figure-list
  import "pages/table-list.typ": table-list
  import "pages/equation-list.typ": equation-list
  import "pages/notation.typ": notation

  // back matter
  import "pages/acknowledge.typ": acknowledge
  import "pages/declaration.typ": declaration
  import "pages/achievement.typ": achievement
  import "pages/record-sheet.typ": record-sheet

  /// --------- ///
  /// Auxiliary ///
  /// --------- ///

  import "utils/font.typ": _fonts-check, _use-cjk-fonts, _use-fonts
  import "utils/page.typ": _use-twoside
  import "utils/util.typ": extend-dict as _extend-dict, str2bool as _str2bool
  import "utils/bibliography.typ": bilingual-bibliography

  /// ------- ///
  /// Process ///
  /// ------- ///

  if type(twoside) == str { twoside = _str2bool(twoside) }
  if type(anonymous) == str { anonymous = _str2bool(anonymous) }
  if type(strict) == str { strict = _str2bool(strict) }

  let _support_doctype = ("bachelor",)
  assert(_support_doctype.contains(doctype), message: "不支持的文档类型, 目前支持的有: " + _support_doctype.join(", "))

  let _support_degree = ("academic",)
  assert(_support_degree.contains(degree), message: "不支持的学位类型, 目前支持的有: " + _support_degree.join(", "))

  let _extend_info(args) = _extend-dict(info, args, "info")
  let _extend_fonts(args) = _fonts-check(_extend-dict(fonts, args, "fonts"))

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
    use-twoside: _use-twoside(twoside),
    use-fonts: name => _use-fonts(fonts, name),
    use-cjk-fonts: name => _use-cjk-fonts(fonts, name),
    /// ------- ///
    /// layouts ///
    /// ------- ///
    // 文档元信息
    meta: (..args) => meta(strict: strict, ..args, info: _extend_info(args)),
    // 文稿设置
    doc: (..args) => doc(..args, fonts: _extend_fonts(args)),
    // 前辅文
    front-matter: (..args) => front-matter(twoside: twoside, ..args),
    // 正文
    main-matter: (..args) => main-matter(twoside: twoside, ..args),
    // 后辅文
    back-matter: (..args) => back-matter(twoside: twoside, ..args),
    /// ----- ///
    /// pages ///
    /// ----- ///
    // 字体展示页
    fonts-display: (..args) => fonts-display(..args, fonts: _extend_fonts(args)),
    // 封面页
    cover: (..args) => cover(anonymous: anonymous, ..args, fonts: _extend_fonts(args), info: _extend_info(args)),
    // 授权页
    copyright: (..args) => copyright(anonymous: anonymous, twoside: twoside, ..args, fonts: _extend_fonts(args)),
    // 中文摘要页
    abstract: (..args) => abstract(twoside: twoside, ..args, fonts: _extend_fonts(args)),
    // 英文摘要页
    abstract-en: (..args) => abstract-en(twoside: twoside, ..args, fonts: _extend_fonts(args)),
    // 目录页
    outline-wrapper: (..args) => outline-wrapper(twoside: twoside, ..args, fonts: _extend_fonts(args)),
    // 符号表页
    notation: (..args) => notation(twoside: twoside, ..args),
    // 插图目录页
    figure-list: (..args) => figure-list(twoside: twoside, ..args),
    // 表格目录页
    table-list: (..args) => table-list(twoside: twoside, ..args),
    // 公式目录页
    equation-list: (..args) => equation-list(twoside: twoside, ..args),
    // 参考文献页
    bilingual-bibliography: (..args) => bilingual-bibliography(bibliography: bibliography, ..args),
    // 致谢页
    acknowledge: (..args) => acknowledge(anonymous: anonymous, twoside: twoside, ..args),
    // 声明页
    declaration: (..args) => declaration(anonymous: anonymous, twoside: twoside, ..args),
    // 成果页
    achievement: (..args) => achievement(anonymous: anonymous, twoside: twoside, ..args),
    // 论文训练记录表
    record-sheet: (..args) => record-sheet(anonymous: anonymous, twoside: twoside, ..args, info: _extend_info(args)),
  )
}
