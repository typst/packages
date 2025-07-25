// MIT No Attribution
// Copyright 2025 Shunsuke Kimura

#import "@preview/cjk-unbreak:0.1.1": remove-cjk-break-space

#let jabiz(
  // 基本情報
  title: [タイトル],
  date: datetime.today(),
  to: [宛先],
  from: [発信者],
  tougo: [拝啓],
  ketsugo: [敬具],
  kigaki: none,
  contact: none,
  // フォント
  font-title: "Noto Sans CJK JP",  // サンセリフ体、ゴシック体などの指定を推奨
  font-main: "Noto Serif CJK JP",  // セリフ体、明朝体などの指定を推奨
  size-title: 18pt,
  size-main: 10pt,
  // 外観
  page-number: none,  // e.g. "1/1"
  // 本文
  body
) = {
  // Set document metadata.
  set document(title: title)

  // Configure the page.
  set page(numbering: page-number)
  set text(size-main, font: font-main, lang: "ja")
  set par(leading: 0.5em, justify: true, spacing: 0.6em, first-line-indent: (amount: 0em, all: true))

  // 日付
  if date != none {
    if type(date) == datetime {
      date = date.display("[year]年[month padding:none]月[day padding:none]日")
    }
    align(right, block(align(left, date)))
    v(2em, weak: true)
  }

  // 宛先
  if to != none {
    align(left, to)
    v(1em, weak: true)
  }

  // 発信者
  if from != none {
    align(right, from)
    v(1em, weak: true)
  }

  // タイトル
  if title == none {
    v(size-title*2, weak: true)
    align(center, text(size-title, font: font-title, weight: "bold", title))
    v(size-title*2, weak: true)
  }

  // 本文
  if tougo != none { tougo }
  set par(first-line-indent: 1em)
  remove-cjk-break-space(body)
  if ketsugo != none { align(right, ketsugo) }

  // 記書き
  if kigaki != none {
    v(3em, weak: true)
    align(center, text(size-main*1.2)[記])
    v(2em, weak: true)
    remove-cjk-break-space(kigaki)
    v(1em, weak: true)
    align(right, [以上])
  }

  if contact != none {
    v(3em, weak: true)
    align(right, block(align(left, contact)))
  }
}
