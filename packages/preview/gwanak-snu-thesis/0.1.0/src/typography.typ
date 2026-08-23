#let default-fonts = (
  // Korean serif/batang families only. Do not prepend Latin families: they make
  // font selection harder to reason about and are not needed for thesis output.
  "Noto Serif CJK KR",
  "Source Han Serif K",
  "NanumMyeongjo",
  "AppleMyungjo",
  "Batang",
  "바탕",
  "UnBatang",
  "Baekmuk Batang",
)


#let frontmatter-block(language, fonts, body) = {
  set text(font: fonts, lang: language, script: auto, top-edge: 0.8em, bottom-edge: -0.2em)
  set par(justify: false, first-line-indent: 0pt, spacing: 0pt, leading: 0.3em)
  body
}

#let major-heading(title, align-to: center) = {
  show heading.where(level: 1): it => align(align-to)[
    #text(size: 16pt, weight: "bold")[#it.body]
  ]
  heading(level: 1, numbering: none)[#title]
}

#let _heading-numbering(language) = (..nums) => {
  let values = nums.pos()
  if language == "ko" {
    if values.len() == 1 {
      "제 " + str(values.at(0)) + " 장"
    } else if values.len() == 2 {
      "제 " + str(values.at(1)) + " 절"
    } else {
      numbering("1.1.", ..values)
    }
  } else {
    if values.len() == 1 {
      "Chapter " + str(values.at(0))
    } else if values.len() == 2 {
      "Section " + str(values.at(1))
    } else {
      numbering("1.1.", ..values)
    }
  }
}

#let chapterized(language, body) = {
  let chapter-index = state("snu-thesis-body-chapter", 0)

  [
    #set heading(numbering: _heading-numbering(language))
    #show heading.where(level: 1): it => [
      #chapter-index.update(n => n + 1)
      #context {
        if chapter-index.get() > 1 {
          pagebreak()
        }
        block(width: 100%, below: 10mm)[
          #align(center)[#text(size: 16pt, weight: "bold")[#it]]
        ]
      }
    ]
    #show heading.where(level: 2): it => block(above: 1.2em, below: 0.6em)[
      #text(size: 14pt, weight: "bold")[#it]
    ]
    #body
  ]
}

#let reference-heading(language) = {
  let title = if language == "ko" { "참 고 문 헌" } else { "References" }
  align(center)[#text(size: 16pt, weight: "bold")[#title]]
}
