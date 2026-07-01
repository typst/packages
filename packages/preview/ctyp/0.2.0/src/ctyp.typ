#import "./fonts/index.typ": *
#import "./utils/enumitem.typ": enumitem
#import "./utils/page-grid.typ": page-grid
#import "./utils/heading-numbering.typ": _config-heading-numbering

#let _default-cjk-regex = "[\p{Han}\u3002\uff1f\uff01\uff0c\u3001\uff1b\uff1a\u201c\u201d\u2018\u2019\uff08\uff09\u300a\u300b\u3008\u3009\u3010\u3011\u300e\u300f\u300c\u300d\uff43\uff44\u3014\u3015\u2026\u2014\uff5e\uff4f\uffe5]"

#let _default-font-latin = (
  serif: "Libertinus Serif",
  mono: "DejaVu Sans Mono",
)

#let _default-weight-map = (
  "thin": 100,
  "extralight": 300,
  "light": 300,
  "regular": 400,
  "medium": 500,
  "semibold": 600,
  "bold": 700,
  "extrabold": 800,
  "heavy": 900,
)

#let _default-font-styles = ("normal", "italic", "oblique")

#let _default-font-functions = (
  "highlight": highlight,
  "underline": underline.with(offset: 2pt),
  "strike": strike,
)

/// 该函数设置了一个基本的 CJK 文档排版环境。
/// 它应用了 CJK 字体，设置了段落样式，并提供了 CJK 文本样式的实用函数。
/// -> array
#let ctyp(
  /// 设置 CJK 字体集合。
  /// 如果是 `auto`，使用默认的 Fandol 字体集合。
  /// 如果是 `str`，使用预定义的打包字体集合中的一个。
  /// 如果是 `dictionary`，则包含字体集合的详细信息，其结构如下：
  /// / `family`: 一个从字形到字体名称的映射。包含以下字段：
  ///   / `[shape]`: 代表字形的字符串（如 "song", "hei"）。
  ///     可以多次重复，以定义多种字形。
  ///     对于 CJK 字体而言，字形可以有很多，可包括但不限于 "song", "hei", "kai", "fang"。
  ///     对于每个字形，其值都是一个字典，包含以下字段：
  ///     / `name`: 字体名称。必须是一个可用的、能被 Typst 识别的字体名称。
  ///     / `variants`: 一个定义有哪些变体的数组（如 `["bold", "italic"]`）。
  /// / `map`: 一个元素到字形的映射的字典。包含以下字段
  ///   / `[element]`: 代表元素的字符串（例如 `"text"`, `"strong"`）。可以多次重复以定义多个元素。
  ///     目前仅支持以下元素 `text`, `emph`, `strong`, `raw`, `heading`。
  ///     每个元素的值都是一个字典，包含以下字段：
  ///     / `cjk`: CJK 字体标识，格式为 "shape:variant"。其中 `shape` 是 `family` 中的键，`variant` 是 `variants` 中的值。
  ///     / `latin`: Latin 字体标识，是预定义的字符串之一："serif", "sans", "mono"。
  /// -> auto | str | dictionary
  fontset-cjk: auto,
  /// 指定西文字体。必须是一个字典，将西文字体形状映射到字体名称。
  /// 具有以下字段：
  /// / `serif`: 衬线字体名称。默认为 "Libertinus Serif"。
  /// / `mono`: 等款字体名称。无默认。
  /// / `sans`: 无衬线字体名称。默认为 "DejaVu Sans Mono"。
  /// -> dictionary
  font-latin: (:),
  /// 修改 CJK 字体映射表。
  /// 具有以下字段：
  /// / `[element]`: 代表元素的字符串（例如 `"text"`, `"strong"`）。可以多次重复以定义多个元素。
  ///   目前仅支持以下元素 `text`, `emph`, `strong`, `raw`, `heading`。
  ///   每个元素的值都是一个字典，包含以下字段：
  ///   / `cjk`: CJK 字体标识，格式为 "shape:variant"。其中 `shape` 是 `family` 中的键，`variant` 是 `variants` 中的值。
  ///   / `latin`: Latin 字体标识，是预定义的字符串之一："serif", "sans", "mono"。
  /// -> dictionary
  font-cjk-map: (:),
  /// 是否修正列表和枚举的样式。
  /// 如果为 true，将应用 `fix-list-args` 和 `fix-enum-args` 中定义的样式。
  /// -> bool
  fix-list-enum: true,
  /// 接受一个字典，定义列表样式的参数。详细参数见 @enumitem 函数。
  /// -> dictionary
  fix-list-args: (:),
  /// 接受一个字典，定义枚举样式的参数。详细参数见 @enumitem 函数。
  /// -> dictionary
  fix-enum-args: (:),
  /// 是否修正智能引号。
  /// 如果为 true，将自动将引号转换为智能引号。
  /// -> bool
  fix-smartquote: true,
  /// 是否修正列表的首行缩进。
  /// 如果为 true，将应用 `fix-first-line-indent` 中定义的首行缩进。
  /// -> bool
  fix-first-line-indent: true,
  /// 重置粗体的 delta 值为 0。
  /// 基于此实现在 `font-cjk-map` 中指定元素的字重。
  /// -> int
  reset-strong-delta: 0,
  /// 是否移除 CJK 字符之间的断行空格。
  /// 如果为 true，将移除 CJK 字符之间的断行空格。
  /// 这用于防止 CJK 字符被空格断开。
  /// -> bool
  remove-cjk-break-space: true,
  /// 设置标题编号的样式。
  /// 可以设置为单值或者数组。
  /// 
  /// 如果是单值，则用于所有级别的标题。
  /// 接受的合法类型为：
  /// - `none`：无编号。
  /// - `str`：字符串，接受所有 Typst 支持的编号格式，即 `numbering()` 函数可接受的值。
  /// - `dictionary`：用于设置编号格式的字典，包含以下字段：
  ///   - `format`：字符串，表示编号格式。也是接受所有 Typst 支持的编号格式。
  ///   - `sep`：间隔，表示编号与标题内容之间的间隔。可以是任何合法的长度值。
  ///   - `align`：对齐方式，可以是 `left`, `center`, `right` 中的一个。默认值为 `left`。
  ///   - `first-line-indent`: 首行缩进值。可以是任何合法的长度值。默认值为 `0em`。
  ///   - `hanging-indent`: 悬挂缩进值。默认值为 `auto`，通过测量编号宽度自动设置。也可以是任何合法的长度值，此时不在测量编号宽度，而是使用指定的值。
  ///   - `prefix`：前缀，表示编号前的内容。可以是任何合法的内容。
  ///   - `suffix`：后缀，表示编号后的内容。可以是任何合法的内容。
  /// 
  /// 如果是数组，则数组中的每个元素都是上面可接受的单值。
  /// 当标题层级数大于数组长度时，使用数组中的最后一个元素来设置更高一级的标题。
  /// 
  /// -> none | str | dictionary | array
  heading-numbering: none,
) = {
  // Merge font-cjk-map with default options.
  let fontset-cjk = if fontset-cjk == auto {
    fandol-fontset
  } else if type(fontset-cjk) == dictionary {
    fontset-cjk
  } else if type(fontset-cjk) == str and fontset-cjk in packed-fontset.keys() {
    packed-fontset.at(fontset-cjk)
  } else {
    panic("fontset-cjk must be a dict, auto or one of the packed fontsets: " + packed-fontset.keys().join(", "))
  }
  let font-cjk = fontset-cjk.family
  let font-cjk-map = (:..fontset-cjk.map, ..font-cjk-map)
  let font-latin = (:.._default-font-latin, ..font-latin)

  let _apply-font-to-cjk(..args, body) = {
    let text-args = args.named()
    let cjk-function = text
    if text-args.style in _default-font-functions.keys() {
      cjk-function = _default-font-functions.at(text-args.style)
      text-args.style = "normal"
    }
    show regex(_default-cjk-regex): set text(..text-args)
    show regex(_default-cjk-regex): cjk-function
    show: if fix-smartquote { (body) => {
      show smartquote: set text(font: args.named().font.at(0).name)
      body
    }} else { (body) => body }
    body
  }

  /// This function wraps the given font with a Latin cover.
  let _font-latin-cover(element) = {// Extract CJK font name
    let font-identifier = font-cjk-map.at(element)
    let (shape, ..variants) = font-identifier.cjk.split(":")
    // let variant = if variants.len() > 0 { variants.first() } else { none }
    let font-family = font-cjk.at(shape)
    let font-weight = "regular"
    let font-style = "normal"
    for variant in variants {
      if variant in _default-weight-map.keys() {
        font-weight = variant
      } else if variant in (.._default-font-styles, .._default-font-functions.keys()) {
        font-style = variant
      }
    }
    let font-cjk-name = if font-weight == none or font-weight == "regular" or font-weight in font-family.variants {
      font-family.name
    } else if variant in _default-font-styles {
      font-family.name
    } else {
      font-cjk.values().first().name
    }

    let latin = font-latin.at(font-identifier.latin, default: "Libertinus Serif")

    // Cover CJK font with Latin font.
    let latin = if latin == auto {
      if font-latin == auto { 
        "Libertinus Serif"
      } else if type(font-latin) == str {
        font-latin
      } else {
        panic("font-latin must be a string or auto")
      }
    } else if latin == none {
      font-cjk-name
    } else if type(latin) == str {
      latin
    } else {
      panic("latin must be a string, auto or none")
    }
    (
      font: ((
        name: latin,
        covers: "latin-in-cjk"
      ), font-cjk-name),
      weight: if font-weight == none { 400 } else { _default-weight-map.at(font-weight, default: 400) },
      style: font-style
    )
    
  }

  let theme = (body) => {
    set text(lang: "zh")

    /// [Font Settings] Begin
    /// This region apply fonts to default text, emph, and strong.
    let font-select = ("text", "emph", "strong", "raw", "heading").map(k => (k, _font-latin-cover(k))).to-dict()
    set text(font: font-select.text.font)
    show: if fix-smartquote { (body) => {
      show smartquote: set text(font: font-select.text.font.at(0).name)
      body
    }} else { (body) => body }
    set strong(delta: if type(reset-strong-delta) == int {
      reset-strong-delta
    } else { 0 })
    show emph: set text(font: font-select.emph.font)
    show emph: _apply-font-to-cjk.with(..font-select.emph)
    show strong: set text(font: font-select.strong.font, weight: "bold")
    show strong: _apply-font-to-cjk.with(..font-select.strong)
    show raw: set text(font: font-select.raw.font)
    show raw: _apply-font-to-cjk.with(..font-select.raw)
    show heading: set text(font: font-select.heading.font)
    show heading: _apply-font-to-cjk.with(..font-select.heading)
    /// [Font Settings] End
    
    set par(justify: true)
    show heading: set block(above: 1em, below: 1em)
    
    /// [Other Settings] Begin
    show quote.where(block: true): body => {
      show: block
      show: pad.with(x: 2em)
      let quotes = if body.quotes == auto { not body.block } else { body.quotes }
      if quotes == true {
        quote(block: false, body.body)
      } else {
        par(body.body)
      }
      if body.attribution != none {
        box(width: 100%, {
          set align(right)
          "——" + body.attribution
        })
      }
    }
    /// [Other Settings] End
    
    body
  }
  if fix-list-enum  {
    theme = (body) => {
      show: theme
      show list: body => {
        set par(spacing: .6em)
        enumitem(..fix-list-args, body.children)
      }
      show enum: body => {
        set par(spacing: .6em)
        enumitem(..fix-enum-args, body.children)
      }
      body
    }
  }
  if remove-cjk-break-space {
    theme = (body) => {
      show: theme
      show regex(_default-cjk-regex + " " + _default-cjk-regex): it => {
        let (a, _, b) = it.text.clusters()
        a + b
      }
      body
    }
  }
  /// [Paragraph Settings] Begin
  /// This region apply paragraph settings to specific elements.
  if fix-first-line-indent {
    theme = (body) => {
      show: theme
      set par(first-line-indent: (amount: 2em, all: true))
      show quote.where(block: false): set par(
        first-line-indent: (amount: 1em, all: true)
      )
      show quote.where(block: false).and(quote.where(quotes: false)): set par(
        first-line-indent: (amount: 2em, all: true)
      )
      body
    }
  }
  /// [Paragraph Settings] End
  
  /// [Heading Numbering] Begin
  if heading-numbering != none {
    theme = (body) => {
      show: theme
      show: _config-heading-numbering(heading-numbering)
      body
    }
  }
  /// [Heading Numbering] End
  let font-utils = fontset-cjk.family.pairs().map(((k, v)) => { (
    k, 
    (body, weight: "regular", latin: "serif") => {
      let latin-font-name = if type(latin) == str {
        if latin in font-latin.keys() {
          font-latin.at(latin)
        } else {
          latin
        }
      } else {
        panic("latin must be a string representing a font name or a font shape")
      }
      set text(font: (
        (name: latin-font-name, covers: "latin-in-cjk"),
        v.name
      ), weight: weight)
      body
    }
  ) }).to-dict()
  (
    theme,
    font-utils
  )
}
