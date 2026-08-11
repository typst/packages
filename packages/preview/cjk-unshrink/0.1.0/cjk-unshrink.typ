// =======================================================================
//
// Git repository:
//      https://github.com/neruthes/typstpkg-cjk-unshrink
//
//
// Copyright (c) 2026 Neruthes.
// Published with the MIT license.
//
// =======================================================================




#let __default_alignment_table = (
  "，": left,
  "。": left,
  "；": left,
  "：": left,
  "？": left,
  "！": left,
)

#let cjk-unshrink(
  doc,
  alignment-table: (:),
  plain-汉字: true,
  plain-ひらがな: true,
  plain-カタカナ: true,
  plain-한글: false,
  aggregate-punctuation: false,
  debug: false,
) = {
  let __sequence_handler(seq, is_for_right_side_punct: true) = {
    let __wide_punct_char_list = "，。：；）》〉】〕〗］」』｝？！（《〈【〔〖［「『｛".clusters()
    let chars = seq.text.clusters()
    let items = ()

    for (i, char) in chars.enumerate() {
      let __char_box_alignment = alignment-table.at(char, default: center)
      let is_force_wide = (
        __wide_punct_char_list.contains(char)
          or (i == 0 and not is_for_right_side_punct)
          or (i == chars.len() - 1 and is_for_right_side_punct)
      )

      items.push(if is_force_wide { box(width: 1em, align(__char_box_alignment, text(char))) } else { text(char) })
    }

    let body = items.join()
    if aggregate-punctuation {
      box(baseline: 0%, stroke: if debug { if is_for_right_side_punct { red } else { green } }, body)
    } else {
      body
    }
  }

  show regex(".[，。：；）》〉】〕〗］」』｝？！]+"): it => __sequence_handler(it, is_for_right_side_punct: true)
  show regex("[（《〈【〔〖［「『｛]+."): it => __sequence_handler(it, is_for_right_side_punct: false)
  show regex("\p{Han}"): it => if plain-汉字 { box(width: 1em, it) } else { it }
  show regex("\p{Hiragana}"): it => if plain-ひらがな { box(width: 1em, it) } else { it }
  show regex("\p{Katakana}"): it => if plain-カタカナ { box(width: 1em, it) } else { it }
  show regex("\p{Hangul}"): it => if plain-한글 { box(width: 1em, it) } else { it }

  doc
}


#let demo_doc = [
  #let kp = 1in / 72.27
  #set text(lang: "zh", font: "Noto Sans CJK SC", size: 10mm)
  #set page(margin: (210mm - 10mm * 17) / 2, background: {
    for xx in range(0, 21) {
      place(top + left, dx: xx * 10mm, box(width: 0.5pt, fill: blue.lighten(66%), height: 100%))
    }
  })





  #let __inner_content_text = [
    哈基米，，。哈。。。。。。。。。。。。\
    哈。。，，《哈基米》（？？？）南北\

    哈基米南北绿豆哈基米南北绿豆哈基米

    哈！基米南北绿豆！！。。。。。。（南北）。。。。《绿豆》

    哈基米南北绿豆？？。。。。（南北）。。。。。《绿豆》｛｝{}

    。。。。。。。《《《哈基米》》》

    他的 GPA 只有 3.25？你科（XXXXXXXXXXX）药丸。

    他的 GPA 只有 3.25？你科#box[（XXXXXXXXXXX）]药丸。



  ]

  #let small_hint_text(it) = text(size: 12 * kp, it)

  = Mode 1
  #small_hint_text[Default, untouched shrinking behavior.]

  #__inner_content_text
  #pagebreak()


  #[
    #show: cjk-unshrink.with(debug: true)
    #set par(justify: false)
    = Mode 2
    #small_hint_text[Simple unshrinking.]

    #__inner_content_text
  ]
  #pagebreak()

  #[
    #show: cjk-unshrink.with(debug: true, aggregate-punctuation: true)
    #set par(justify: true)
    = Mode 3
    #small_hint_text[Unshrinking with justified par. Best for pure Zhongwen/Nihongo text.\ `#show: cjk-unshrink.with(aggregate-punctuation: true)`]

    #__inner_content_text
  ]
  #pagebreak()

  #[
    #show: cjk-unshrink.with(debug: true, aggregate-punctuation: false)
    #set par(justify: true)
    = Mode 4
    #small_hint_text[Unshrinking with justified par, and avoid the aggregation so line wraps with alphanumerical sequences will be better. This approach spreads the stretching duty to script-boundary glues.\ `#show: cjk-unshrink.with(aggregate-punctuation: false)`]

    #__inner_content_text
  ]
]


#demo_doc


