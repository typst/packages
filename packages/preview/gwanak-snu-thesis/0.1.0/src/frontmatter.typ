#import "locale.typ": abstract-heading, keyword-label, student-number-label
#import "typography.typ": frontmatter-block, major-heading

#let _university-ko = "서울대학교"
#let _university-en = "Seoul National University"

#let _join-items(items) = {
  for (index, item) in items.enumerate() {
    if index > 0 {
      [, ]
    }
    item
  }
}

#let cover(
  cover-language,
  degree,
  academic-ko,
  academic-en,
  title,
  title-alt,
  grad-date-ko,
  grad-date-en,
  school-ko,
  school-en,
  major-ko,
  major-en,
  author-display,
  fonts,
) = {
  let thesis-label = if cover-language == "ko" {
    academic-ko + degree.cover-ko-suffix
  } else {
    degree.cover-en-prefix + " " + academic-en
  }
  let grad-date = if cover-language == "ko" { grad-date-ko } else { grad-date-en }

  frontmatter-block(cover-language, fonts, align(center)[
    #text(size: 14pt)[#thesis-label]
    #v(20mm)
    #text(size: 22pt, weight: "bold")[#title]
    #v(10mm)
    #text(size: 16pt)[#title-alt]
    #v(1fr)
    #text(size: 14pt)[#grad-date]
    #v(32mm)
    #if cover-language == "ko" [
      #text(size: 16pt)[#_university-ko #school-ko]
      #v(5mm)
      #text(size: 14pt)[#major-ko]
      #v(5mm)
      #text(size: 16pt)[#author-display]
    ] else [
      #text(size: 14pt)[#school-en]
      #linebreak()
      #text(size: 14pt)[#_university-en]
      #linebreak()
      #text(size: 14pt)[#major-en]
      #v(5mm)
      #text(size: 16pt)[#author-display]
    ]
  ])
}

#let approval(
  degree,
  title,
  title-alt,
  academic-ko,
  school-ko,
  major-ko,
  author,
  author-display,
  advisor-display,
  submission-date,
  approval-date,
  signers,
  fonts,
) = {
  frontmatter-block("ko", fonts, align(center)[
    #text(size: 22pt, weight: "bold")[#title]
    #v(10mm)
    #text(size: 16pt)[#title-alt]
    #v(10mm)
    #text(size: 14pt)[지도교수 #advisor-display]
    #v(5mm)
    #text(size: 16pt)[#("이 논문을 " + academic-ko + degree.ko + " 학위논문으로 제출함")]
    #v(5mm)
    #text(size: 14pt)[#submission-date]
    #v(10mm)
    #text(size: 16pt)[#_university-ko #school-ko]
    #v(5mm)
    #text(size: 14pt)[#major-ko]
    #v(5mm)
    #text(size: 16pt)[#author-display]
    #v(10mm)
    #text(size: 16pt)[#(author + "의 " + academic-ko + degree.ko + " 학위논문을 인준함")]
    #v(5mm)
    #text(size: 14pt)[#approval-date]
    #v(1fr)
    #block(width: 92%)[
      #for signer in signers {
        let role = signer.at("role")
        let name = signer.at("name")
        let signature = box(width: 50mm)[#align(center)[#underline(name)]]
        grid(
          columns: (30mm, 1fr, 14mm),
          column-gutter: 5mm,
          [#role],
          [#signature],
          [(인)],
        )
        v(0.5em)
      }
    ]
  ])
}

#let abstract-page(abstract-language, abstract, keywords, student-number) = {
  let heading-title = abstract-heading(abstract-language)
  let keyword-title = keyword-label(abstract-language)
  let student-title = student-number-label(abstract-language)

  major-heading(heading-title, align-to: center)
  v(20mm)
  abstract
  v(1fr)
  block(width: 100%)[
    #set par(first-line-indent: 0pt, justify: false, spacing: 0pt)
    #stack(
      dir: ttb,
      spacing: 0.45em,
      [#text(weight: "bold")[#(keyword-title + ":")] #_join-items(keywords)],
      [#text(weight: "bold")[#(student-title + ":")] #student-number],
    )
  ]
}

#let acknowledgement-page(language, acknowledgement) = {
  let heading-title = if language == "ko" { "감사의 글" } else { "Acknowledgement" }

  major-heading(heading-title, align-to: center)
  v(20mm)
  acknowledgement
}
