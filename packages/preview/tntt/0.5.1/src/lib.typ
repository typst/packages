#import "exports.typ"

#import "imports.typ": *
#import "utils/util.typ": *
#import "utils/font.typ": use-size
#import "utils/text.typ": distr-text, fixed-text, mask-text, space-text, v-text

/// Define the configuration for the document.
///
/// - degree (str): The degree.
/// - degree-type (str): The degree-type type.
/// - anonymous (str, bool): Whether to use anonymous mode.
/// - twoside (str, bool): Whether to use two-sided printing.
/// - bibliography (array, bytes, none, str): The bibliography entry.
/// - fonts (dictionary): The font family to use.
/// - info (dictionary): The information to be displayed in the document.
/// -> dictionary
#let define-config(
  degree: "bachelor",
  degree-type: "academic",
  anonymous: false,
  twoside: false,
  bibliography: none,
  fonts: (:),
  info: (:),
) = {
  import exports: *
  import "pages/cover.typ": cover, cover-en

  import "utils/font.typ": _use-cjk-fonts, _use-en-font, _use-fonts

  assert(degree in ("bachelor", "master", "doctor", "postdoc"), message: "不支持的学位")
  assert(degree-type in ("academic",), message: "不支持的学位类型")

  anonymous = is-true(anonymous)

  if type(info.title) == str { info.title = info.title.split("\n") } else {
    assert(type(info.title) == array, message: "论文标题（info.title）必须是字符串或字符串数组")
  }

  // @typstyle off
  (
    /// ------ ///
    /// config ///
    /// ------ ///
    info: info,
    fonts: fonts,
    degree-type: degree-type,
    degree: degree,
    twoside: twoside,
    anonymous: anonymous,
    /// --------- ///
    /// utilities ///
    /// --------- ///
    use-fonts: _use-fonts.with(fonts),
    use-en-font: _use-en-font.with(fonts),
    use-cjk-fonts: _use-cjk-fonts.with(fonts),
    use-twoside: twoside-pagebreak.with(twoside),
    /// ------- ///
    /// layouts ///
    /// ------- ///
    // 文档元配置 | Document Meta Configuration
    meta: meta.with(info: info, extra-prefixes: ("alg:",)), // info of meta cannot be overwritten
    // 文稿设置 | Document Layout Configuration
    doc: doc.with(header-display: degree != "bachelor", default-fonts: fonts, extra-fig-kinds: ("algorithm",)),
    // 前辅文设置 | Front Matter Layout Configuration
    front-matter: front-matter,
    // 正文设置 | Main Matter Layout Configuration
    main-matter: main-matter.with(twoside: twoside, equation-numbering: "(1-1)"),
    // 后辅文设置 | Back Matter Layout Configuration
    back-matter: back-matter.with(twoside: twoside),
    /// ----- ///
    /// pages ///
    /// ----- ///
    // 字体展示页 | Fonts Display Page
    fonts-display: fonts-display.with(fonts: fonts),
    // 中文封面页 | Cover Page
    cover: cover.with(degree: degree, degree-type: degree-type, anonymous: anonymous, default-fonts: fonts, doc-info: info),
    // 英文封面页 | Cover (English) Page
    cover-en: cover-en.with(degree: degree, degree-type: degree-type, twoside: twoside, anonymous: anonymous, default-fonts: fonts, doc-info: info),
    // 书脊页 | Spine Page
    spine: spine.with(degree: degree, twoside: twoside, anonymous: anonymous, default-fonts: fonts, info: info),
    // 学位论文指导小组、公开评阅人和答辩委员会名单页 | Thesis Committee Page
    committee: committee.with(degree: degree, anonymous: anonymous, twoside: twoside),
    // 授权页 | Copyright Page
    copyright: copyright.with(degree: degree, anonymous: anonymous, twoside: twoside),
    // 中文摘要页 | Abstract Page
    abstract: abstract.with(twoside: twoside, outlined: degree != "bachelor", default-fonts: fonts),
    // 英文摘要页 | Abstract (English) Page
    abstract-en: abstract-en.with(twoside: twoside, outlined: degree != "bachelor", default-fonts: fonts),
    // 目录页 | Outline Page
    outline-wrapper: outline-wrapper.with(twoside: twoside, outlined: degree != "bachelor", default-fonts: fonts),
    // 总清单页 | Master List Page
    master-list: master-list.with(twoside: twoside, outlined: degree != "bachelor"),
    // 插图和附表清单页 | Figure and Table Index Page
    figure-table-list: figure-table-list.with(twoside: twoside, outlined: degree != "bachelor"),
    // 插图清单页 | Figure List Page
    figure-list: figure-list.with(twoside: twoside, outlined: degree != "bachelor"),
    // 附表清单页 | Table List Page
    table-list: table-list.with(twoside: twoside, outlined: degree != "bachelor"),
    // 公式清单页 | Equation List Page
    equation-list: equation-list.with(twoside: twoside, outlined: degree != "bachelor"),
    // 符号表页 | Notation Page
    notation: notation.with(twoside: twoside, outlined: degree != "bachelor"),
    // 参考文献页 | Bibliography Page
    bilingual-bibliography: bilingual-bibliography.with(bibliography),
    // 致谢页 | Acknowledge Page
    acknowledge: acknowledge.with(anonymous: anonymous, twoside: twoside),
    // 声明页 | Declaration Page
    declaration: declaration.with(degree: degree, anonymous: anonymous, twoside: twoside),
    // 个人简历、在学期间完成的相关学术成果说明页 | Resume & Achievement Page
    achievement: achievement.with(degree: degree, anonymous: anonymous, twoside: twoside),
    // 论文训练记录表 | Record Sheet Page
    record-sheet: record-sheet.with(degree: degree, anonymous: anonymous, twoside: twoside, doc-info: info),
    // 指导教师/指导小组评语页 | Advisor Comments Page
    comments: comments.with(degree: degree, anonymous: anonymous, twoside: twoside),
    // 答辩委员会决议书 | Committee Resolution Page
    resolution: resolution.with(degree: degree, anonymous: anonymous, twoside: twoside),
  )
}
