#import "@preview/cjk-unbreak:0.2.3": remove-cjk-break-space
#import "@preview/codly:2.0.0" as codly

// --------------------------------
// 各種変数
// --------------------------------
#let serif = ("New Computer Modern", "Harano Aji Mincho")
#let sans = ("New Computer Modern Sans", "Harano Aji Gothic")
#let typewriter = ("Moralerspace Argon HW", "DejaVu Sans Mono")
#let title-size = 1.6em
#let subtitle-size = 1.2em
#let title-subcontent-size = 1.1em
#let date-format = "[year]年[month padding:zero]月[day padding:zero]日"

// 基本的なスタイルの設定
#let style(doc) = {
  set page(paper: "a4", numbering: "— 1/1 —")
  set text(11pt, font: serif, lang: "ja")
  set par(
    first-line-indent: (
      all: true,
      amount: 1em,
    ),
    leading: 0.8em,
    spacing: 0.8em,
  )

  show heading: set text(font: sans)
  set heading(numbering: "1.")
  show heading: it => {
    it
    v(2pt)
  }

  show raw: set text(font: typewriter)
  set figure.caption(separator: "：")

  show: codly.set_(lang-position: none)
  show: codly.line-set_(fill: white, stroke: none)
  // codlyはgridで組むため，HTML出力では中身ごと捨てられる
  show raw.where(block: true): it => context if target() == "html" { it } else { codly.new(it) }
  show: remove-cjk-break-space
  doc
}

// タイトルの出力
#let titles(title, subtitle: none) = {
  set document(title: title)

  // タイトル生成
  set align(center)
  text(weight: "bold", size: title-size, font: sans)[#title]
  if subtitle == none {
    v(2pt)
  } else {
    linebreak()
    v(0pt)
    text(weight: "regular", size: subtitle-size, font: sans)[#subtitle]
  }
}


/// 文書メタデータ用に`content`を文字列へ変換する.
///
/// - it (str, content): 変換対象
/// -> str
#let plain(it) = if type(it) == str { it } else if it.has("text") { it.text } else if it.has("children") {
  it.children.map(plain).sum(default: "")
} else if it.has("body") { plain(it.body) } else { " " }

/// 学籍番号と氏名の組を出力する.
///
/// 1人なら名前付き引数で, 複数人なら組を並べて渡す.
///
/// *Example:*
///
/// ```example
/// #name(id: "hinshiba", name: "瀕死")
/// #name((id: "hinshiba", name: "瀕死"), (id: "moyashi170607", name: "こつ子"))
/// ```
///
/// - members (arguments): 学籍番号`id`と氏名`name`の組
/// -> content
#let name(..members) = {
  assert(
    members.pos() == () or members.named() == (:),
    message: "name: `id: a, name: b`か`(id: a, name: b), ...`のどちらかで渡してください",
  )
  let members = if members.pos() == () { (members.named(),) } else { members.pos() }
  set document(author: members.map(m => plain(m.name)))

  // 名前生成
  set text(size: title-subcontent-size)
  set align(right)
  let pairs = members.map(m => (m.at("id", default: none), m.name))
  // grid要素はHTML出力で中身ごと捨てられる
  context if target() == "html" { pairs.map(p => p.filter(x => x != none).join(" ")).join(linebreak()) } else {
    grid(columns: 2, column-gutter: 1em, row-gutter: par.leading, align: (right), ..pairs.flatten())
  }
}

// 日付の出力
#let date-info(qdate: none) = {
  let today = datetime.today()
  set document(date: today)

  // 日付欄設定
  set align(right)
  if qdate == none {
    today.display(date-format)
  } else {
    [#qdate.display("出題日" + date-format)
      \
      #today.display("提出日" + date-format)]
  }
}

