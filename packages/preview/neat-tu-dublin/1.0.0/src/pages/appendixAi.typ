#import "../lib.typ": *

#let appendix-ai(
  report-writing: (),
  research: (),
  design: (),
  coding: (),
  other: (),
) = {
  heading("Prompts used with Gen AI", level: 1, numbering: none)

  heading("Prompts related to Report Writing", level: 2, numbering: none, outlined: false)

  if report-writing.len() == 0 {
    [No Generative AI was used in the creation of this report.]
  } else {
    [Generative AI was used in the creation of this report using the following prompts:]
    list(..report-writing)
  }

  if research.len() != 0 {
    pagebreak()
  } else {
    linebreak()
    linebreak()
  }

  heading("Prompts related to Research", level: 2, numbering: none, outlined: false)

  if research.len() == 0 {
    [No Generative AI was used in the research of this project.]
  } else {
    [Generative AI was used in the research of this project using the following prompts:]
    list(..research)
  }

  if design.len() != 0 {
    pagebreak()
  } else {
    linebreak()
    linebreak()
  }

  heading("Prompts related to Design", level: 2, numbering: none, outlined: false)

  if design.len() == 0 {
    [No Generative AI was used in the design of this project.]
  } else {
    [Generative AI was used in the design of this project using the following prompts:]
    list(..design)
  }

  if coding.len() != 0 {
    pagebreak()
  } else {
    linebreak()
    linebreak()
  }

  heading("Prompts related to Coding", level: 2, numbering: none, outlined: false)

  if coding.len() == 0 {
    [No Generative AI was used in the development of this project.]
  } else {
    [Generative AI was used in the development of this project using the following prompts:]
    list(..coding)
  }

  if other.len() != 0 {
    pagebreak()
  } else {
    linebreak()
    linebreak()
  }

  heading("Other Prompts Related to Project", level: 2, numbering: none, outlined: false)

  if other.len() == 0 {
    [No Generative AI was used in other sections of the project.]
  } else {
    [Generative AI was used in other sections of the project using the following prompts:]
    list(..other)
  }
  pagebreak(weak: true)
}