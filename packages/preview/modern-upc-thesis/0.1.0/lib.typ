// ============================================================
// modern-upc-thesis: 中国石油大学（华东）本科毕设论文 Typst 模板
// 核心入口：导出 documentclass 函数
// ============================================================

#let documentclass(
  // === 元信息 ===
  title: "",
  author: "",
  advisor: "",
  institute: "",
  university: "",
  date: auto,
  
  // === 语言 ===
  language: "zh",
  
  // === 排版参数 ===
  fontsize: 12pt,
  line-spacing: auto,
  page-margin: auto,
  
  // === 主题应用函数（由用户传入） ===
  // 该函数会在所有底层排版设置之后调用，用于覆盖学校专属样式
  theme: none,
  
  // === 正文内容 ===
  body,
) = {
  // ----------------------------------------------------------
  // 1. 加载通用能力层（internal）
  // ----------------------------------------------------------
  import "lib/base.typ" as base
  import "lib/chinese.typ" as chinese
  import "lib/hyperref.typ" as hyperref
  import "lib/utils.typ" as utils
  import "lib/fonts.typ"
  
  // 设置语言
  set text(lang: if language == "zh" { "zh" } else { "en" },
           region: if language == "zh" { "cn" } else { none })
  
  // ----------------------------------------------------------
  // 按章编号：图、表、公式
  // 必须在 show: 调用之前设置，因为它们需要直接作用于 body
  // ----------------------------------------------------------
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    it
  }

  let _fig-numbering(prefix: "") = (..nums) => {
    context {
      let ch = counter(heading.where(level: 1)).at(here()).first()
      prefix + str(ch) + "-" + str(nums.pos().last())
    }
  }
  set figure(numbering: _fig-numbering())

  set math.equation(numbering: (..nums) => {
    context {
      let ch = counter(heading.where(level: 1)).at(here()).first()
      "(" + str(ch) + "-" + str(nums.pos().first()) + ")"
    }
  })

  // ----------------------------------------------------------
  // 2. 加载通用排版层（通过 show: 传播规则）
  // ----------------------------------------------------------
  // 正文字体必须在 base.apply 中直接设置，不能放在 theme 的 show: 规则内。
  // Typst 在 show: func 中，若 func 通过参数传入，其内部的 set text(font: ...)
  // 会被忽略，导致字体回退到系统默认。
  let body-fonts = fonts.get-cjk-serif() + fonts.get-latin-fonts()
  show: base.apply.with(page-margin: page-margin, fontsize: fontsize, font: body-fonts)
  show: chinese.apply.with(line-spacing: line-spacing)
  show: hyperref.apply

  // ----------------------------------------------------------
  // 3. 应用主题层（由用户传入，覆盖通用层）
  // 只能使用 show: theme，不能 theme(body)，否则 theme 中的
  // show outline.entry / show ref 等规则会因匹配时机错误而崩溃。
  // ----------------------------------------------------------
  // 不可将 show: theme 放在 if 语句块内，否则 theme 内部的
  // show 规则（如 show heading、pagebreak 等）会全部失效。
  show: if theme != none { theme } else { it => it }

  // ----------------------------------------------------------
  // 4. 输出正文内容
  // ----------------------------------------------------------
  body
}

// 导出子模块，供主题直接使用
#import "lib/fonts.typ"
#import "lib/utils.typ"
#import "lib/i18n.typ"
#import "lib/hyperref.typ"

// 导出 make-outline，供模板直接使用
#let make-outline = hyperref.make-outline

// 导出三线表辅助函数
#let three-line-table = utils.three-line-table

// 导出表头辅助函数
#let hcell = utils.hcell

// ---- 导出 UPC 主题函数（供模板直接使用，避免子路径导入） ----
#import "themes/upc/style.typ" as _upc-style
#import "themes/upc/titlepage.typ" as _upc-titlepage

#let upc-apply = _upc-style.apply
#let setup-mainmatter = _upc-style.setup-mainmatter
#let frontmatter-header = _upc-style.frontmatter-header
#let mainmatter-header = _upc-style.mainmatter-header
#let footer-content = _upc-style.footer-content
#let upcabstractcn = _upc-style.upcabstractcn
#let upcabstracten = _upc-style.upcabstracten
#let upcacknowledgements = _upc-style.upcacknowledgements
#let upcoriginality = _upc-style.upcoriginality
#let upclicense = _upc-style.upclicense
#let appendix-env = _upc-style.appendix-env
#let titlepage = _upc-titlepage.titlepage
