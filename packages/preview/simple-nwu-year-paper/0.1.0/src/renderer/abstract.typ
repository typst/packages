
#let render-abstract-page(cfg, zh-content: none, en-content: none) = {
  // 如果连中文摘要都没有，直接退出
  if zh-content == none { return none }

  let font-zh-title = cfg.fonts.abstract-zh-title
  let font-zh-body = cfg.fonts.abstract-zh-body

  let font-en-title = cfg.fonts.abstract-en-title
  let font-en-body = cfg.fonts.abstract-en-body

  {
    // --- 中文摘要渲染 ---
    let zh-keywords = cfg.meta.at("zh-keywords", default: ())

    align(center)[
      #text(..font-zh-title, weight: "bold")[摘#h(2em)要]
    ]
    v(1.5em)

    set text(font: font-zh-body.font, size: font-zh-body.size)
    set par(first-line-indent: 2em, justify: true)

    zh-content

    v(3em)
    if zh-keywords.len() > 0 {
      set par(first-line-indent: 0pt)
      text(weight: "bold")[关键词：]
      h(0.5em)
      zh-keywords.join(h(1em))
    }

    // --- 英文摘要渲染 ---
    let show-en = cfg.document.en-abstract
    if show-en and en-content != none {
      pagebreak(weak: true)

      let en-keywords = cfg.meta.en-keywords

      align(center)[
        #text(..font-en-title, weight: "bold")[Abstract]
      ]
      v(1.5em)

      set text(font: font-en-body.font, size: font-en-body.size)
      set par(first-line-indent: 2em, justify: true)

      en-content

      v(3em)
      if en-keywords.len() > 0 {
        set par(first-line-indent: 0pt)
        text(weight: "bold")[Keywords:]
        h(0.5em)
        en-keywords.join(h(1em))
      }
    }
  }
  // 收尾断页
  pagebreak(weak: true)
}
