// src/title.typ
// 作者與標題區塊

#import "fonts.typ": font-hei

// ============================================================
// § 作者與標題區塊
// ============================================================

// 正規化 authors 為陣列（相容三種傳入方式：純字串、單一 dict、陣列）
#let normalize-authors(authors) = if type(authors) == array { authors } else { (authors,) }

// 渲染作者列表；支援純字串或 dict (name, thanks)，thanks 以腳註呈現
#let render-authors(auths) = {
  let parts = auths.map(a => {
    if type(a) == dictionary {
      let n = a.at("name", default: "")
      let t = a.at("thanks", default: none)
      if t != none { [#n#footnote(t)] } else { [#n] }
    } else {
      [#str(a)]
    }
  })
  parts.join("、")
}

// 置中的標題區塊：主標題（含 thanks）、副標題、作者；
// authors 可為字串、單一 dict 或陣列（同 normalize-authors）；
// font、weight 為標題與副標題的字型與粗細（預設黑體粗體），
// 例如楷體不加粗：`font: font-kai, weight: "regular"`。
#let title-block(
  title,
  title-thanks: none,
  subtitle: none,
  authors: (),
  font: font-hei,
  weight: "bold",
) = align(center)[
  #block(
    text(font: font, weight: weight, size: 1.75em)[
      #title#if title-thanks != none and title-thanks != "" { footnote(title-thanks) }
    ],
  )

  #if subtitle != none and subtitle != "" [
    #v(0.5em)
    #block(text(font: font, weight: weight, size: 1.25em, subtitle))
  ]

  #v(1em)

  #render-authors(normalize-authors(authors))
]
