#import "/src/constants/document-settings-constants.typ": SINGLE-LINE-PARAGRAPH-LEADING-SIZE
#import "/src/constants/numbering-constants.typ": FOOTNOTE-NUMBERING

// Dipnot stili. [Footnote style.]
#let footnote-style(content) = {
  // Dipnot numaralandırma stili. [Footnote numbering style.]
  set footnote(numbering: FOOTNOTE-NUMBERING)

  // Dipnot girdisi stili. [Footnote entry style.]
  set footnote.entry(
    clearance: 1em,
    // Dipnotlarda paragraflardaki satırlar arasındaki mesafeyi 1 (tek) satırlık aralık olacak şekilde ayarla. [Set the line spacing between paragraphs in footnotes to 1 (single) line gap.]
    gap: SINGLE-LINE-PARAGRAPH-LEADING-SIZE,
    indent: 0.25em,
    separator: line(length: 40%, stroke: 0.5pt + black),
  )

  content
}
