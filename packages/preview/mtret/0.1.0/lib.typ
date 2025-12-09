#import "@preview/cjk-unbreak:0.2.0": remove-cjk-break-space
#import "fastfig.typ": *

// --------------------------------
// 各種変数
// --------------------------------
#let serif = ("New Computer Modern", "Harano Aji Mincho")
#let sans = ("New Computer Modern Sans", "Harano Aji Gothic")
#let typewriter = ("DejaVu Sans Mono", "Morale")
#let title_size = 1.6em
#let subtitle_size = 1.2em
#let title_subcontent_size = 1.1em
#let date_format = "[year]年[month padding:zero]月[day padding:zero]日"

// 基本的なスタイルの設定
#let style(doc) = {
  set page(paper: "a4", numbering: "— 1/1 —")
  set text(11pt, font: serif, lang: "ja")
  set par(
    first-line-indent: (
      all: false, // 見出しで問題になるので見出し側で修正
      amount: 1em,
    ),
    leading: 0.8em,
    spacing: 0.8em,
  )

  show heading: set text(font: sans)
  set heading(numbering: "1.")
  show heading: it => {
    it
    par()[] // 見出しではインデント付き改段落を要する
    v(-0.5em)
  }

  show raw: set text(font: ("DejaVu Sans Mono", "Moralerspace Xenon HW"))

  show: remove-cjk-break-space
  show: zebraw.with(background-color: white, lang: false)
  doc
}

// 全角コンマ等への変更
#let repl_full-en_punctuation(doc) = {
  show "、": "，"
  show "。": "．"

  doc
}


// タイトルの出力
#let titles(title, subtitle: none) = {
  set document(title: title)

  // タイトル生成
  set align(center)
  text(weight: "bold", size: title_size, font: sans)[#title]
  linebreak()
  v(-1pt)
  text(weight: "regular", size: subtitle_size, font: sans)[#subtitle]
}


// 名前の出力
#let name(id: none, author) = {
  set document(author: author)

  // 名前生成
  set text(size: title_subcontent_size)
  set align(right)
  id
  h(1em)
  author
}

// 日付の出力
#let date_info(qdate: none) = {
  let today = datetime.today()
  set document(date: today)

  // 日付欄設定
  set align(right)
  set text()
  if qdate == none {
    today.display(date_format)
  } else {
    [#qdate.display("出題日" + date_format)
      \
      #today.display("提出日" + date_format)]
  }
}

