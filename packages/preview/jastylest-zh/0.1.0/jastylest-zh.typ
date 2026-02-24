// 共同样式设定
#let common-style(it) = {
  // 设置中文
  set text(lang: "zh", region: "cn")

  // 链接下划线
  show link: underline.with(offset: auto)

  // 列表设定
  set list(indent: 1.5em)
  set enum(indent: 1.5em)

  // 下划线现在不会挡到汉字
  set underline(offset: 0.2em)

  // 设置表格标题
  show figure.where(kind: table): set figure.caption(position: top)

  // 半宽括号与汉字之间的空格
  let cjk = "(\p{Hiragana}|\p{Katakana}|\p{Han})"
  show regex("(" + cjk + "[(])|([)]" + cjk + ")"): it => {
    let a = it.text.match(regex("(.)(.)"))
    a.captures.at(0)
    h(0.25em)
    a.captures.at(1)
  }

  // 公式与汉字之间的空格
  show math.equation.where(block: false): it => {
    // size0にするとpreviewででかく表示されるバグがある
    hide[#text(size: 1pt)[\$]]
    it
    hide[#text(size: 1pt)[\$]]
  }

  it
}

// 文档样式设定
#let article(
  seriffont: "STIX Two Text",
  seriffont-cjk: "Noto Serif CJK SC",
  sansfont: "Fira Sans",
  sansfont-cjk: "Noto Sans CJK SC",
  monofont: "Fira Mono",
  monofont-cjk: "Noto Sans Mono CJK SC",
  mathfont: "STIX Two Math",
  kaiti-cjk: "FandolKai",
  paper: "a4",
  font-size: 11pt,
  code-font-size: 10pt,
  font-weight: "regular",
  cols: 1,
  titlepage: false,
  title: none,
  office: none,
  author: none,
  date: datetime.today().display("[year]年[month repr:numerical padding:none]月[day padding:none]日"),
  abstract: none,
  it,
) = {
  // 页面设定
  set page(
    paper: paper,
    numbering: "1",
    columns: cols,
  )
  
  // 文本设定
  set text(
    font: ((name: seriffont, covers: "latin-in-cjk"), seriffont-cjk),
    size: font-size,
    weight: font-weight,
  )
  show smartquote: set text(
    font: seriffont,  // 修正引号字体
  )
  show emph: set text(
    font: ((name: seriffont, covers: "latin-in-cjk"), kaiti-cjk),
  )
  show raw: set text(
    font: (monofont, monofont-cjk),
    size: code-font-size,
  )
  show math.equation: set text(
    font: mathfont,
  )
  
  // 标题设定
  set heading(numbering: "1.1")
  show heading: it => {
    v(1em)
    set par(first-line-indent: 0em)
    if it.numbering != none {
      counter(heading).display(it.numbering)
    }
    h(1em)
    it.body
  }
  
  // 段落设定
  set par(
    leading: 0.8em,
    first-line-indent: 2em,
    justify: true,
  )

  // 其他设定
  set columns(gutter: 2em)
  show: common-style.with()
  
  // 标题生成
  if title != none {
    if (type(author) != array) {
      author = (author,)
    }
    author = author.join(", ")
    align(
      center,
      {
        if titlepage {
          context {
            let pageheight = page.height
            set text(size: 1.5em)
            v(pageheight / 7)
            text(size: 2em)[#title]
            v(pageheight / 7)
            office
            parbreak()
            author
            v(pageheight / 7)
            date
            pagebreak()
          }
        } else {
          text(size: 1.7em)[#title]
          parbreak()
          [#office\ #author]
          parbreak()
          date
          v(1em)
        }
      },
    )
  }

  it
}

#let noindent(it) = {
  set par(first-line-indent: 0em)  // 临时取消缩进
  it
}

#let template(
  seriffont: "STIX Two Text",
  seriffont-cjk: "Noto Serif CJK SC",
  sansfont: "Fira Sans",
  sansfont-cjk: "Noto Sans CJK SC",
  monofont: "Fira Mono",
  monofont-cjk: "Noto Sans Mono CJK SC",
  mathfont: "STIX Two Math",
  kaiti-cjk: "FandolKai",
  paper: "a4",
  font-size: 11pt,
  code-font-size: 10pt,
  font-weight: "regular",
  cols: 1,
  titlepage: false,
  title: none,
  office: none,
  author: none,
  date: datetime.today().display("[year]年[month repr:numerical padding:none]月[day padding:none]日"),
  abstract: none,
) = {
  let textsf(..args) = {
    show smartquote: set text(
      font: sansfont  // 修正引号字体
    )
    show emph: set text(
      font: ((name: sansfont, covers: "latin-in-cjk"), kaiti-cjk),
    )
    text(
      font: ((name: sansfont, covers: "latin-in-cjk"), sansfont-cjk),
      ..args,
    )
  }
  
  return (
    article.with(
      seriffont: seriffont,
      seriffont-cjk: seriffont-cjk,
      sansfont: sansfont,
      sansfont-cjk: sansfont-cjk,
      monofont: monofont,
      monofont-cjk: monofont-cjk,
      mathfont: mathfont,
      kaiti-cjk: kaiti-cjk,
      paper: paper,
      font-size: font-size,
      code-font-size: code-font-size,
      font-weight: font-weight,
      cols: cols,
      titlepage: titlepage,
      title: title,
      office: office,
      author: author,
      date: date,
    ),
    textsf
  )
}