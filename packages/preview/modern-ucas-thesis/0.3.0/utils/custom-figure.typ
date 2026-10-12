#import "bilingual-figured.typ"
#import "style.typ": 字号, 行距

#let bifigure = bilingual-figured.bifigure
#let bitable = bilingual-figured.bitable

#let thesis-bilingual-caption-style(
  fonts,
  // 1.25 倍行距：Typst leading 是额外间隙，取 行距.正文，勿写 1.25em。
  leading: 行距.正文,
  keep_together: true,
  caption_par: auto,
  note_par: auto,
  zh_block: auto,
  en_block: auto,
  note_block: auto,
  note_inset: (left: 2em),
) = {
  let cap-par = if caption_par == auto {
    (leading: leading)
  } else {
    caption_par
  }
  let note-par = if note_par == auto {
    cap-par
  } else {
    note_par
  }
  // 块外间距：取规范值，但中英标题之间需保留一行行距。Typst 的 leading
  // 只在段落内部行间生效，两个单行 block 之间基线距 = 行盒 + max(段后, 段前)，
  // 不含 leading；其实测见 docs/CUSTOMIZE.md（SVG/PDF 基线法）。
  // 故中文题段前 6pt / 段后 0pt（规范值），英文题段前取一个 leading
  // （中英题基线距 ≈ 行盒 + leading，随正文行距口径，即规范"1.25 倍行距"），
  // 英文题段后 12pt（规范值）。勿再叠加旧式 1.25em（会远超规范）。
  let zh = if zh_block == auto {
    (above: 6pt, below: 0pt)
  } else {
    zh_block
  }
  let en = if en_block == auto {
    (above: leading, below: 12pt)
  } else {
    en_block
  }
  let note = if note_block == auto {
    (above: 6pt, below: 0pt, inset: note_inset)
  } else if "inset" in note_block {
    note_block
  } else {
    note_block + (inset: note_inset)
  }

  bilingual-figured.bilingual-caption-style(
    caption_par: cap-par,
    note_par: note-par,
    zh_text: (font: fonts.宋体, size: 字号.五号, weight: "bold"),
    en_text: (font: fonts.宋体, size: 字号.五号, weight: "bold"),
    note_text: (font: fonts.宋体, size: 字号.五号),
    note_prefix: [*注：* ],
    note_align: left,
    zh_block: zh,
    en_block: en,
    note_block: note,
    keep_together: keep_together,
    float_clearance: 1.5em,
    float_align: center,
    float_width: 100%,
  )
}

#let _thesis-style(fonts) = thesis-bilingual-caption-style(fonts)

#let show-bifigure(
  fonts,
  kind: "bifigure",
) = it => bilingual-figured.show-bifigure(
  it,
  kind: kind,
  style: _thesis-style(fonts),
)

#let show-bitable(
  fonts,
  kind: "bitable",
) = it => bilingual-figured.show-bitable(
  it,
  kind: kind,
  style: _thesis-style(fonts),
)

#let show-bilingual-outline-entry(
  _fonts,
) = it => bilingual-figured.show-bilingual-outline-entry(
  it,
)

#let bilingual-figure-rules(fonts) = {
  let style = _thesis-style(fonts)
  show figure: bilingual-figured.show-bilingual.with(
    figure_style: style,
    table_style: style,
  )
  show outline.entry.where(level: 1): show-bilingual-outline-entry(fonts)
}
