#import "layout.typ": body-margin, page-number-align, page-args
#import "locale.typ": assert-language, normalize-degree, labels
#import "typography.typ": default-fonts, chapterized, reference-heading
#import "frontmatter.typ": cover, approval, abstract-page, acknowledgement-page
#import "outlines.typ": contents-outline, table-outline, figure-outline
#import "appendix.typ": appendix-content

#let _require(name, value) = {
  assert(value != none, message: name + " is required")
}

#let _assert-affiliation-field(name, value, forbidden) = {
  assert(type(value) == str, message: name + " must be a string")
  assert(
    not value.contains(forbidden),
    message: name + " must not include " + forbidden + "; the template renders it automatically",
  )
}

#let _abstract-language(abstract-languages, body-language, key) = {
  if abstract-languages == none {
    if key == "primary" {
      if body-language == "ko" { "ko" } else { "en" }
    } else {
      if body-language == "ko" { "en" } else { "ko" }
    }
  } else {
    abstract-languages.at(key)
  }
}

#let _abstract-for(language, abstract-ko, abstract-en) = {
  if language == "ko" { abstract-ko } else { abstract-en }
}

#let _keywords-for(language, keywords-ko, keywords-en) = {
  if language == "ko" { keywords-ko } else { keywords-en }
}

#let _advisor-overlap(names, advisor, advisor-display) = {
  names.contains(advisor) or (advisor-display != none and names.contains(advisor-display))
}

#let _committee-signers(degree-info, committee, advisor, advisor-display) = {
  assert(committee != none, message: "committee is required for master and phd degrees")
  let chair = committee.at("chair")
  let vice-chair = committee.at("vice-chair")
  let members = committee.at("members")
  assert(type(members) == array, message: "committee.members must be an array")
  assert(members.len() == degree-info.external-member-count, message: degree-info.committee-message)

  let committee-names = (chair, vice-chair) + members
  assert(
    not _advisor-overlap(committee-names, advisor, advisor-display),
    message: "advisor must not duplicate committee chair, vice-chair, or members",
  )

  let advisor-name = if advisor-display == none { advisor } else { advisor-display }
  ((role: "위 원 장", name: chair), (role: "부위원장", name: vice-chair)) + members.map(name => (role: "위 원", name: name)) + ((role: "위 원", name: advisor-name),)
}

#let snu-thesis(
  body-language: "ko",
  cover-language: none,
  approval-language: "ko",
  abstract-languages: none,
  degree: "phd",
  title: none,
  title-alt: none,
  academic-ko: "학문",
  academic-en: "Academic Field",
  school-ko: "대학원",
  school-en: "The Graduate School",
  major-ko: "학과(부) 및 전공",
  major-en: "Major",
  author: none,
  author-display: none,
  student-number: none,
  advisor: none,
  advisor-display: none,
  grad-date-ko: none,
  grad-date-en: none,
  submission-date: none,
  approval-date: none,
  committee: none,
  abstract-ko: none,
  abstract-en: none,
  keywords-ko: (),
  keywords-en: (),
  acknowledgement: none,
  bibliography: none,
  show-figure-list: true,
  show-table-list: true,
  fonts: default-fonts,
  appendices: none,
  paper-size: "default",
  page-margin: none,
  draft: false,
  body,
) = {
  assert-language("body-language", body-language)
  let resolved-cover-language = if cover-language == none { body-language } else { cover-language }
  assert-language("cover-language", resolved-cover-language)
  assert(approval-language == "ko", message: "approval-language must be 'ko' for SNU graduate approval pages")
  let degree-info = normalize-degree(degree)

  assert(type(draft) == bool, message: "draft must be true or false")
  let resolved-page-margin = if page-margin == none { body-margin } else { page-margin }

  if not draft {
    _assert-affiliation-field("school-ko", school-ko, "서울대학교")
    _assert-affiliation-field("school-en", school-en, "Seoul National University")
    _require("title", title)
    _require("title-alt", title-alt)
    _require("author", author)
    _require("student-number", student-number)
    _require("grad-date-ko", grad-date-ko)
    _require("grad-date-en", grad-date-en)
    _require("abstract-ko", abstract-ko)
    _require("abstract-en", abstract-en)
    if resolved-cover-language == "en" {
      _require("title-alt", title-alt)
    }
  }

  let resolved-author = if author-display == none { author } else { author-display }
  let resolved-advisor = if advisor-display == none { advisor } else { advisor-display }
  let signers = if degree-info.requires-approval and not draft {
    _require("advisor", advisor)
    _require("submission-date", submission-date)
    _require("approval-date", approval-date)
    _committee-signers(degree-info, committee, advisor, advisor-display)
  } else {
    ()
  }

  let label-set = labels(body-language)
  let primary-abstract-language = _abstract-language(abstract-languages, body-language, "primary")
  let secondary-abstract-language = _abstract-language(abstract-languages, body-language, "secondary")
  assert-language("abstract-languages.primary", primary-abstract-language)
  assert-language("abstract-languages.secondary", secondary-abstract-language)
  assert(primary-abstract-language != secondary-abstract-language, message: "abstract-languages.primary and secondary must differ")
  let primary-abstract = _abstract-for(primary-abstract-language, abstract-ko, abstract-en)
  let secondary-abstract = _abstract-for(secondary-abstract-language, abstract-ko, abstract-en)
  let primary-keywords = _keywords-for(primary-abstract-language, keywords-ko, keywords-en)
  let secondary-keywords = _keywords-for(secondary-abstract-language, keywords-ko, keywords-en)

  set text(size: 11pt, font: fonts, lang: body-language, script: auto, top-edge: 0.8em, bottom-edge: -0.2em)
  set par(justify: true, first-line-indent: (amount: 0.5in, all: true), spacing: 1.04em, leading: 1.04em)
  set footnote(numbering: "1)")
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), clearance: 1em, gap: 0.35em)
  show footnote.entry: it => {
    let loc = it.note.location()
    text(size: 9pt)[#numbering("1)", ..counter(footnote).at(loc)) #it.note.body]
  }

  if not draft {
    set page(..page-args(paper-size: paper-size, margin: resolved-page-margin, numbering: none))
    cover(
      resolved-cover-language,
      degree-info,
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
      resolved-author,
      fonts,
    )

    pagebreak()
    set page(..page-args(paper-size: paper-size, margin: resolved-page-margin, numbering: none))
    cover(
      resolved-cover-language,
      degree-info,
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
      resolved-author,
      fonts,
    )

    if degree-info.requires-approval {
      pagebreak()
      set page(..page-args(paper-size: paper-size, margin: resolved-page-margin, numbering: none))
      approval(
        degree-info,
        title,
        title-alt,
        academic-ko,
        school-ko,
        major-ko,
        author,
        resolved-author,
        resolved-advisor,
        submission-date,
        approval-date,
        signers,
        fonts,
      )
    }

    pagebreak()
    set page(..page-args(paper-size: paper-size, margin: resolved-page-margin, numbering: "i", number-align: page-number-align))
    counter(page).update(1)
    abstract-page(primary-abstract-language, primary-abstract, primary-keywords, student-number)

    pagebreak()
    contents-outline(label-set, body-language, fonts)

    if show-table-list {
      pagebreak()
      table-outline(label-set, body-language, fonts)
    }

    if show-figure-list {
      pagebreak()
      figure-outline(label-set, body-language, fonts)
    }
    pagebreak()
  }

  set page(..page-args(paper-size: paper-size, margin: resolved-page-margin, numbering: "1", number-align: page-number-align))
  counter(page).update(1)
  chapterized(body-language, body)

  if bibliography != none {
    pagebreak()
    reference-heading(body-language)
    v(0.65em)
    bibliography
  }

  if appendices != none {
    pagebreak()
    appendix-content(body-language, appendices)
  }

  if not draft {
    pagebreak()
    abstract-page(secondary-abstract-language, secondary-abstract, secondary-keywords, student-number)

    if acknowledgement != none {
      pagebreak()
      acknowledgement-page(body-language, acknowledgement)
    }
  }
}
