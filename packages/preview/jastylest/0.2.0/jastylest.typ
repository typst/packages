#import "katex-font.typ" as katex-font

// 共通のスタイル設定
#let common-style(it) = {
  // 設定日本語
  set text(lang: "ja")

  // リスト設定
  set list(indent: 1.5em)
  set enum(indent: 1.5em)

  // 表のキャプションを上に
  show figure.where(kind: table): set figure.caption(position: top)

  // 数式外の丸括弧の外側に隙間を開ける処理
  let cjk = "(\p{Hiragana}|\p{Katakana}|\p{Han})"
  let pre-ghost = {
    hide(text(size: 0pt, "$"))
    hide(sym.wj)
  }
  let post-ghost = {
    hide(sym.wj)
    hide(text(size: 0pt, "$"))
  }
  // 開き括弧
  show regex("(" + cjk + `[\(\[]`.text + ")"): it => {
    let a = it.text.match(regex("(.)(.)"))
    a.captures.at(0)
    pre-ghost
    a.captures.at(1)
  }
  // 閉じ括弧
  show regex("(" + `[\)\]]`.text + cjk + ")"): it => {
    let a = it.text.match(regex("(.)(.)"))
    a.captures.at(0)
    post-ghost
    a.captures.at(1)
  }

  // 数式とcjk文字の間に隙間を開ける処理
  show math.equation.where(block: false): it => {
    pre-ghost
    it
    post-ghost
  }

  it
}

// ドキュメントのスタイル設定
#let article(
  seriffont: "New Computer Modern",
  seriffont-cjk: "Harano Aji Mincho",
  sansfont: "Arial",
  sansfont-cjk: "Harano Aji Gothic",
  paper: "a4",
  page-margin: auto,
  font-size: 11pt,
  cols: 1,
  abstract: none,
  it,
) = {
  // ページ設定
  set page(
    paper: paper,
    numbering: "1",
    columns: cols,
    margin: page-margin,
  )
  // テキスト設定
  set text(
    font: (seriffont, (name: seriffont-cjk, covers: "latin-in-cjk")),
    size: font-size,
    weight: "medium",
  )
  // 見出し設定
  set heading(numbering: "1.1")
  show heading: set text(
    font: (sansfont, (name: sansfont-cjk, covers: "latin-in-cjk")),
    weight: "medium",
  )
  show heading: it => {
    v(1em)
    set par(first-line-indent: 0em)
    if it.numbering != none {
      counter(heading).display(it.numbering)
    }
    h(1em)
    it.body
  }
  // 段落設定
  set par(
    leading: 1em,
    spacing: 1em,
    first-line-indent: 1em,
    justify: true,
  )
  // その他の設定
  set columns(gutter: 2em)
  show: common-style.with()
  show math.equation: set text(font: (
    "New Computer Modern Math",
    (name: seriffont-cjk, covers: "latin-in-cjk"),
  ))

  // アブストラクト生成
  if abstract != none {
    set text(size: 0.9em)
    set align(center)
    box(width: 90%, {
      set align(left)
      abstract
    })
  }

  it
}

#let title(
  title: none,
  titlepage: true,
  personal: none,
  author: none,
  office: none,
  suboffice: none,
  teacher: none,
  date: datetime.today().display("[year]年[month repr:numerical padding:none]月[day padding:none]日"),
) = {
  if titlepage {
    set page(numbering: none)
    align(
      center,
      {
        if (type(author) != array) {
          author = (author,)
        }
        author = author.join(", ")

        align(right, suboffice)

        v(1fr)

        heading(
          numbering: none,
          outlined: false,
          text(
            size: 14.4pt,
            weight: "regular",
            title,
          ),
        )

        v(1fr)

        text(size: 10pt, date)

        v(1fr)

        text(size: 12pt, office)
        v(30pt)
        text(size: 12pt, personal)
        parbreak()
        v(30pt)
        text(size: 12pt, author)

        if teacher != none {
          v(0.5cm)
          text(size: 10pt, teacher)
        }

        v(1fr)
        pagebreak()
      },
    )
    counter(page).update(1)
  } else {
    place(
      top + center,
      scope: "parent",
      float: true,
      {
        text(size: 1.4em)[#title]
        parbreak()
        {
          if office != none {
            office
            linebreak()
          }
          if personal != none or author != none {
            personal
            h(1em)
            author
            linebreak()
          }
          if date != none and date != "" {
            date
          }
        }
        v(1em)
      },
    )
  }
}

// ページが途中で修了したか
#let finished = state("finished", false)
#let totalpage = state("totalpage", 0)
#let lastpage = state("lastpage", 0)
// スライドのスタイル設定
#let slide(
  font: "Arial",
  font-cjk: "Harano Aji Gothic",
  paper: "presentation-16-9",
  height: 540pt,
  font-size: 24pt,
  margin: 30pt,
  title-color: rgb("#84c0c7"),
  title: none,
  subtitle: none,
  office: none,
  author: none,
  date: datetime.today().display("[year]年[month repr:numerical padding:none]月[day padding:none]日"),
  it,
) = {
  // 変数の計算
  let width = if paper == "presentation-16-9" {
    height * 16 / 9
  } else if paper == "presentation-4-3" {
    height * 4 / 3
  } else {
    panic("Unsupported paper size: " + paper)
  }

  // ドキュメント設定
  if title != none {
    set document(title: title)
  }
  if author != none {
    set document(author: author)
  }
  // リンクに下線を引く
  show link: underline.with(offset: 0pt)
  // ページ設定
  set page(
    paper: paper,
    width: width,
    height: height,
    margin: (top: 3em, right: margin, bottom: 2em, left: margin),
    header: context {
      let page = here().page()
      let headings = query(selector(heading.where(level: 1).or(heading.where(level: 2))))
      let reverse-pos = headings.rev().position(x => x.location().page() <= page)
      if reverse-pos == none {
        return
      }
      let heading-index = headings.len() - reverse-pos - 1
      let heading = headings.at(heading-index)
      place(top, dx: -margin, block(width: width, height: 2em, fill: title-color, inset: 0.5em, {
        set text(1.2em, weight: "bold")
        heading.body
      }))
    },
    header-ascent: 0pt,
    footer: {
      set align(right)
      context {
        counter(page).display("1")
        [/]
        str(totalpage.final())
      }
    },
    footer-descent: 0.5em,
  )
  // テキスト設定
  set text(size: font-size, font: ((name: font-cjk, covers: "latin-in-cjk"), font))
  // その他の設定
  set align(horizon)
  set outline(target: heading.where(level: 1), title: none)
  show outline.entry: it => [
    - #it
  ]
  set bibliography(title: none)
  show heading.where(level: 1): it => {
    set page(header: none, footer: none)
    set align(center)
    it
    pagebreak(weak: true)
  }
  show heading.where(level: 2): pagebreak(weak: true)

  // タイトル生成
  if title != none {
    if (type(author) != array) {
      author = (author,)
    }
    set page(footer: none)
    set align(center)
    text(
      size: 1.4em,
      weight: "bold",
      title,
    )
    if subtitle != none {
      v(0.5em, weak: true)
      text(size: 1.2em, subtitle)
    }
    if author != none {
      v(1em, weak: true)
      if office != none {
        office
        linebreak()
      }
      author.join(", ")
    }
    if date != none {
      v(1.4em, weak: true)
      text(1.1em, date)
    }
    pagebreak(weak: true)
  }

  show: common-style.with()

  it

  context {
    if not finished.get() {
      totalpage.update(here().page())
    }
    lastpage.update(here().page())
  }
}

#let finished-page() = context {
  totalpage.update(here().page())
  finished.update(true)
}

#let empty-slide() = {
  set page(header: none, footer: none)
  hide(" ")
  pagebreak(weak: true)
}

// タイトル付きブロック
#let title-block(
  title: none,
  title-color: rgb("#84c0c7"),
  doc,
) = {
  block(sticky: true)[
    #if title != none {
      block(
        width: 100%,
        fill: title-color,
        stroke: title-color,
        inset: 10pt,
        spacing: 0pt,
        radius: (top: 5pt, bottom: 0pt),
        title,
      )
    }
    #if type(title-color) == gradient {
      title-color = title-color.sample(50%)
    }
    #block(
      width: 100%,
      fill: title-color.transparentize(70%),
      stroke: title-color,
      inset: 10pt,
      spacing: 0pt,
      radius: (
        top: if title != none { 0pt } else { 5pt },
        bottom: 5pt,
      ),
      doc,
    )
  ]
}
