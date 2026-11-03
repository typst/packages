// ============================================================
// covers.typ — 学位论文封面页
// 提供两个封面变体：
//   - cover-page-blind：匿名评阅用（隐去作者信息，显示论文编号）
//   - cover-page-normal：正常提交用（显示校徽、作者、导师等信息）
// ============================================================

#import "../imports.typ": show-cn-fakebold
#import "../utils/style.typ": style as _style
#import "../utils/number.typ": chinesenumber, chineseyear
#import "../utils/util.typ": resolve-path, ensure-not-eps

// ========== 封面排版工具 ==========

/// 按指定宽度拆分文本，返回字符串数组，每行不超过 max-width。
/// 用于封面页长标题的自动换行。支持中英文混合及空格分词。
#let split-text-by-width(text-content, max-width) = {
  let chars = if type(text-content) == str {
    text-content.clusters()
  } else {
    str(text-content).clusters()
  }

  let is-word-char = (c) => {
    c.len() == 1 and c != " " and c != "\t" and c != "\n"
  }

  let tokens = ()
  let i = 0
  while i < chars.len() {
    let c = chars.at(i)
    if c == "\n" {
      tokens.push(("\n", true))
      i += 1
    } else if c == " " or c == "\t" {
      if i + 1 < chars.len() and is-word-char(chars.at(i + 1)) {
        let word = c
        i += 1
        while i < chars.len() and is-word-char(chars.at(i)) {
          word += chars.at(i)
          i += 1
        }
        tokens.push((word, false))
      } else {
        tokens.push((c, true))
        i += 1
      }
    } else if is-word-char(c) {
      let word = c
      i += 1
      while i < chars.len() and is-word-char(chars.at(i)) {
        word += chars.at(i)
        i += 1
      }
      tokens.push((word, false))
    } else {
      tokens.push((c, false))
      i += 1
    }
  }

  let result = ()
  let current = ""

  for (token, is-space) in tokens {
    if token == "\n" {
      if current.len() > 0 {
        result.push(current.trim())
      }
      current = ""
    } else {
      let next = current + token
      if measure(next).width > max-width {
        if current.len() > 0 {
          result.push(current.trim())
        }
        if is-space {
          current = ""
        } else {
          current = token.trim()
        }
      } else {
        current = next
      }
    }
  }

  if current.len() > 0 {
    result.push(current.trim())
  }

  result
}

/// 未选中复选框（空心方框）
#let sym-box-unchecked(size) = box(width: size, align(
  center + horizon,
  square(size: size),
))

/// 选中复选框（方框内带 ✓）。
#let sym-box-checked(size) = box(width: size, align(
  center + horizon,
  square(size: size)[✓],
))

/// 构建封面页的字段网格（如姓名、学号等），支持自动换行
/// fields: 数组，每项为 (字段名, 字段值) 元组
/// name-width / value-width: 两列宽度
/// row-height: 每行高度
#let build-field-grid(fields, name-width, value-width, row-height, font: none, style: none) = context {
  let s = if style != none { style } else { _style }
  let grid-contents = ()

  for (name, value) in fields {
    let value-parts = split-text-by-width(value, value-width)
    for (i, part) in value-parts.enumerate() {
      if i == 0 {
        grid-contents.push([#text(font: s.封面字段标签.font, size: s.封面字段标签.size)[#name]#v(0.5em)])
      } else {
        grid-contents.push([])
      }
      grid-contents.push([
        #set align(center)
        #set text(size: s.封面信息.size, font: s.封面信息.font)
        #part
        #v(0.5em)
      ])
    }
  }

  grid(
    columns: (name-width, value-width),
    rows: row-height,
    row-gutter: 0.5em,
    stroke: (x, y) => if x == 1 { (bottom: 1pt) } else { none },
    ..grid-contents,
  )
}

/// 学位类型选择框
/// degree-type: "academic"（学术学位）或 "professional"（专业学位）
/// 其他值会触发 assert 报错
#let degree-type-checkbox(degree-type) = {
  assert(
    degree-type == "academic" or degree-type == "professional",
    message: "degree-type 必须是 \"academic\" 或 \"professional\"，当前值: "
      + repr(degree-type),
  )
  let academic-box = if degree-type == "academic" {
    sym-box-checked(12pt)
  } else {
    sym-box-unchecked(12pt)
  }
  let professional-box = if degree-type == "professional" {
    sym-box-checked(12pt)
  } else {
    sym-box-unchecked(12pt)
  }
  set align(center + horizon)
  [#academic-box#h(0.5em)学术学位#h(4 * 0.5em)#professional-box#h(0.5em)专业学位]
}

/// 校徽灰色占位框：未提供校徽图片时显示，提示用户自行配置
#let _logo-placeholder(font) = box(
  width: 2.4em,
  height: 2.4em,
  fill: luma(235),
  stroke: 0.5pt + luma(150),
  inset: 0.15em,
)[
  #set align(center + horizon)
  #text(size: _style.封面占位符.size, fill: luma(120), font: _style.封面占位符.font)[校徽]
]

/// 校名字标灰色占位框：未提供字标图片时显示，提示用户自行配置
#let _wordmark-placeholder(font) = box(
  width: 8em,
  height: 1.6em,
  fill: luma(235),
  stroke: 0.5pt + luma(150),
  inset: 0.15em,
)[
  #set align(center + horizon)
  #text(size: _style.封面占位符.size, fill: luma(120), font: _style.封面占位符.font)[字标]
]

/// 正常版封面
/// 显示校徽和字标（logo + wordmark）、论文类型、题目、作者信息及学位类型
/// 未提供校徽/字标图片时显示灰色占位框（logo/wordmark 参数为 none）
/// 利用 build-field-grid 实现字段名与值的对齐排版
#let cover-page-normal(
  font: none,
  thesis-name: none,
  title-zh: none,
  author-zh: none,
  student-id: none,
  school: none,
  major-zh: none,
  direction: none,
  supervisor-zh: none,
  degree-type: "academic",
  year: none,
  month: none,
  logo: none,
  wordmark: none,
  style: none,
) = {
  let s = if style != none { style } else { _style }
  set align(center + horizon)
  set text(font: s.封面题目.font, size: s.封面题目.size)
  box(
    grid(
      columns: (auto, auto),
      gutter: 0.4em,
      if logo != none {
        image(ensure-not-eps(resolve-path(logo)), height: 2.4em, fit: "contain")
      } else {
        _logo-placeholder(font)
      },
      if wordmark != none {
        image(ensure-not-eps(resolve-path(wordmark)), height: 1.6em, fit: "contain")
      } else {
        _wordmark-placeholder(font)
      },
    ),
  )
  linebreak()
  text(font: s.封面题头.font, size: s.封面题头.size)[#thesis-name]
  v(1fr)
  context {
    set text(weight: s.封面题目.weight)
    show: show-cn-fakebold
    let title-zh-parts = split-text-by-width(title-zh, 10.16cm)
    let grid-contents = (
      [
        #set align(center)
        #text(font: s.封面题目标签.font, size: s.封面题目标签.size)[题目：]
      ],
    )
    for (i, part) in title-zh-parts.enumerate() {
      grid-contents.push(part)
      if i < title-zh-parts.len() - 1 {
        grid-contents.push([])
      }
    }

    grid(
      columns: (2.75cm, 10.16cm),
      rows: 1.48cm,
      align: center,
      stroke: (x, y) => if x == 1 { (bottom: 1pt) } else { none },
      ..grid-contents,
    )
  }
  v(5fr)
  set text(font: s.封面信息.font, size: s.封面信息.size)
  build-field-grid(
    (
      (text("姓") + h(2em) + text("名："), author-zh),
      (text("学") + h(2em) + text("号："), student-id),
      (text("院") + h(2em) + text("系："), school),
      (text("专") + h(2em) + text("业："), major-zh),
      ("研究方向：", direction),
      ("导师姓名：", supervisor-zh),
    ),
    3.19cm,
    7.63cm,
    1.5em,
    font: font,
    style: style,
  )
  v(2fr)
  text(font: s.封面信息.font)[#degree-type-checkbox(degree-type)]
  v(1fr)
  text(font: s.封面日期.font, size: s.封面日期.size)[
    #chineseyear(year) 
    #text(font: s.封面日期标点.font, size: s.封面日期标点.size)[年] 
    #chinesenumber(month) 
    #text(font: s.封面日期标点.font, size: s.封面日期标点.size)[月]
  ]
}

/// 盲审版封面
/// 显示校名（header-text）、中英文题目、学科信息、论文编号和学位类型
/// 隐去作者姓名、学号、导师等可识别信息
#let cover-page-blind(
  font: none,
  header-text: none,
  title-zh: none,
  title-en: none,
  first-major: none,
  major-zh: none,
  blind-id: none,
  year: none,
  month: none,
  degree-type: "academic",
  style: none,
) = {
  let s = if style != none { style } else { _style }
  set align(center + top)
  text(size: s.封面题头.size, font: s.封面题头.font)[
    #show: show-cn-fakebold
    #header-text
  ]
  linebreak()
  set text(size: s.封面信息.size, font: s.封面信息.font)
  set par(justify: true, leading: s.封面盲审.leading)
  [（匿名评阅论文封面）]
  v(1fr)
  [
    #set align(left)
    #set par(spacing: s.封面盲审.spacing)
    中文题目：#title-zh.split("\n").map(it => it.trim()).join(" ")

    英文题目：#title-en.split("\n").map(it => it.trim()).join(" ")

    #linebreak()

    一级学科：#first-major

    二级学科：#major-zh

    论文编号：#blind-id
  ]
  v(1fr)
  degree-type-checkbox(degree-type)
  v(3fr)
  [#chineseyear(year) 年 #chinesenumber(month) 月]
}
