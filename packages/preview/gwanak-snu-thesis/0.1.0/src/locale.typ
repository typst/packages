#let assert-language(name, language) = {
  assert(language == "ko" or language == "en", message: name + " must be 'ko' or 'en'")
}

#let normalize-degree(degree) = {
  assert(
    degree == "bachelor" or degree == "master" or degree == "phd",
    message: "degree must be 'bachelor', 'master', or 'phd'",
  )

  if degree == "bachelor" {
    (
      kind: "bachelor",
      ko: "학사",
      cover-ko-suffix: "사 학위논문",
      cover-en-prefix: "Bachelor's Thesis of",
      requires-approval: false,
      external-member-count: 0,
      committee-message: "bachelor theses do not use committee metadata by default",
    )
  } else if degree == "master" {
    (
      kind: "master",
      ko: "석사",
      cover-ko-suffix: "석사 학위논문",
      cover-en-prefix: "Master's Thesis of",
      requires-approval: true,
      external-member-count: 0,
      committee-message: "master committees must provide chair and vice-chair only; advisor is appended as the third signer",
    )
  } else {
    (
      kind: "phd",
      ko: "박사",
      cover-ko-suffix: "박사 학위논문",
      cover-en-prefix: "Ph.D. Dissertation of",
      requires-approval: true,
      external-member-count: 2,
      committee-message: "phd committees must provide exactly two members; advisor is appended as the fifth signer",
    )
  }
}

#let labels(language) = {
  assert-language("body-language", language)

  if language == "ko" {
    (
      contents: "목    차",
      figures: "그 림 목 차",
      tables: "표    목    차",
      references: "참 고 문 헌",
      acknowledgement: "감사의 글",
      appendix: "부록",
    )
  } else {
    (
      contents: "Contents",
      figures: "List of Figures",
      tables: "List of Tables",
      references: "References",
      acknowledgement: "Acknowledgement",
      appendix: "Appendix",
    )
  }
}

#let abstract-heading(abstract-language) = {
  assert-language("abstract language", abstract-language)
  if abstract-language == "ko" { "국문초록" } else { "Abstract" }
}

#let keyword-label(abstract-language) = {
  assert-language("abstract language", abstract-language)
  if abstract-language == "ko" { "주요어" } else { "Keywords" }
}

#let student-number-label(abstract-language) = {
  assert-language("abstract language", abstract-language)
  if abstract-language == "ko" { "학번" } else { "Student Number" }
}
