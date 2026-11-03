// ============================================================
// config/builder.typ — 页面闭包构建器
// 接收解析后的配置上下文，返回所有页面函数的闭包字典
// ============================================================

#import "../layouts/setup.typ": page-setup
#import "../components/wordcount.typ": word-count-cjk
#import "../pages/covers.typ": cover-page-blind, cover-page-normal
#import "../pages/spine.typ": spine-page
#import "../pages/copyright.typ": copyright-page
#import "../pages/abstract-zh.typ": abstract-page-zh
#import "../pages/abstract-en.typ": abstract-page-en
#import "../pages/outline.typ": chineseoutline
#import "../pages/listoffigures.typ": listoffigures
#import "../pages/notation.typ": notation-page
#import "../pages/bibliography.typ": render-bibliography
#import "../pages/achievement.typ": achievement-page
#import "../pages/acknowledgements.typ": acknowledgements-page
#import "../pages/declaration.typ": declaration-page

/// ctx 包含所有解析后的配置值（字体、样式、CLI 覆盖、用户参数等）
#let build-pages(ctx, system-state) = {
  // ========== 页面基础设置 ==========
  let setup = (body) => {
    system-state.update(ctx.system)
    page-setup(
      style: ctx.style,
      font: ctx.font,
      header-text: ctx.header-text,
      preview: ctx.preview,
      first-line-indent: ctx.first-line-indent,
      smartpagebreak: ctx.smartpagebreak,
      merged-supplements: ctx.supplements,
      codly-args: ctx.codly-args,
      use-latexref: ctx.use-latexref,
      latexref-prefixes: ctx.latexref-prefixes,
      document-title: ctx.title-zh,
      document-author: if ctx.blind { none } else { ctx.author-zh },
      body: body,
    )
  }

  // ========== 论文封面 ==========
  let cover = () => {
    if ctx.blind {
      cover-page-blind(
        style: ctx.style,
        font: ctx.font,
        header-text: ctx.header-text,
        title-zh: ctx.title-zh,
        title-en: ctx.title-en,
        first-major: ctx.first-major,
        major-zh: ctx.major-zh,
        blind-id: ctx.blind-id,
        year: ctx.year,
        month: ctx.month,
        degree-type: ctx.degree-type,
      )
    } else {
      cover-page-normal(
        style: ctx.style,
        font: ctx.font,
        thesis-name: ctx.thesis-name,
        title-zh: ctx.title-zh,
        author-zh: ctx.author-zh,
        student-id: ctx.student-id,
        school: ctx.school,
        major-zh: ctx.major-zh,
        direction: ctx.direction,
        supervisor-zh: ctx.supervisor-zh,
        degree-type: ctx.degree-type,
        year: ctx.year,
        month: ctx.month,
        logo: ctx.logo,
        wordmark: ctx.wordmark,
      )
    }
    (ctx.smartpagebreak)()
  }

  // ========== 书脊页 ==========
  let spine = () => {
    spine-page(
      style: ctx.style,
      title: ctx.title-zh,
      author: ctx.author-zh,
      font: ctx.font,
      blind: ctx.blind,
    )
    (ctx.smartpagebreak)()
  }

  // ========== 版权声明 ==========
  let copyright = () => {
    copyright-page(style: ctx.style)
    (ctx.smartpagebreak)()
  }

  // ========== 中文摘要 ==========
  let abstract-zh = (body, keywords-zh: ()) => {
    set align(left + top)
    abstract-page-zh(
      style: ctx.style,
      keywords-zh: keywords-zh,
      first-line-indent: ctx.first-line-indent,
    )[#body]
  }

  // ========== 英文摘要 ==========
  let abstract-en = (body, keywords-en: ()) => {
    set align(left + top)
    abstract-page-en(
      style: ctx.style,
      title-en: ctx.title-en,
      author-en: ctx.author-en,
      major-en: ctx.major-en,
      supervisor-en: ctx.supervisor-en,
      keywords-en: keywords-en,
      blind: ctx.blind,
    )[#body]
  }

  // ========== 论文目录 ==========
  let outline = () => {
    chineseoutline(
      style: ctx.style,
      title: "目录",
      depth: ctx.outline-depth,
      indent: true
    )
  }

  // ========== 插图列表 ==========
  let list-of-figures = () => {
    listoffigures(
      title: ctx.supplements.插图列表,
      kind: image,
      supplements: ctx.supplements,
    )
  }

  // ========== 表格列表 ==========
  let list-of-tables = () => {
    listoffigures(
      title: ctx.supplements.表格列表,
      kind: table,
      supplements: ctx.supplements,
    )
  }

  // ========== 公式列表 ==========
  let list-of-equations = () => {
    listoffigures(
      title: ctx.supplements.公式列表,
      kind: "equation",
      supplements: ctx.supplements,
    )
  }

  // ========== 代码列表 ==========
  let list-of-code = () => {
    listoffigures(
      title: ctx.supplements.代码列表,
      kind: "code",
      supplements: ctx.supplements,
    )
  }

  // ========== 主要符号对照表 ==========
  let notation = (body) => {
    notation-page(
      style: ctx.style,
      title: ctx.supplements.符号表,
    )[#body]
  }

  // ========== 正文段落样式 ==========
  let body-wrap = (body) => {
    set align(left + top)
    set par(
      justify: true,
      first-line-indent: (amount: ctx.first-line-indent, all: true),
      leading: ctx.style.正文.leading,
      spacing: ctx.style.正文.spacing,
    )
    if ctx.word-count {
      show: word-count-cjk
      body
    } else {
      body
    }
  }

  // ========== 参考文献 ==========
  let bibliography = (body) => {
    render-bibliography(
      style: ctx.style,
      bib-content: ctx.bib-content,
      bib-style: ctx.bib-style,
      bib-version: ctx.bib-version,
      bib-cn-first: ctx.bib-cn-first,
      bib-pinyin-override: ctx.bib-pinyin-override,
      override-bib: ctx.override-bib,
    )[#body]
  }

  // ========== 攻读学位期间发表的论文 ==========
  let achievement = (body) => {
    if ctx.blind { return }
    set align(left + top)
    achievement-page(
      style: ctx.style,
      title: ctx.supplements.成果表,
      outlined: ctx.achievement-outlined,
    )[#body]
  }

  // ========== 致谢部分 ==========
  let acknowledgements = (body) => {
    if ctx.blind { return }
    set align(left + top)
    acknowledgements-page(
      style: ctx.style,
      first-line-indent: ctx.first-line-indent,
    )[#body]
  }

  // ========== 原创声明 ==========
  let declaration = () => {
    if ctx.blind { return }
    declaration-page(clean-declaration: ctx.clean-declaration, style: ctx.style)
  }

  (
    setup: setup,
    cover: cover,
    spine: spine,
    copyright: copyright,
    abstract-zh: abstract-zh,
    abstract-en: abstract-en,
    outline: outline,
    list-of-figures: list-of-figures,
    list-of-tables: list-of-tables,
    list-of-equations: list-of-equations,
    list-of-code: list-of-code,
    notation: notation,
    body-wrap: body-wrap,
    bibliography: bibliography,
    achievement: achievement,
    acknowledgements: acknowledgements,
    declaration: declaration,
  )
}
