This is a fan-made Typst template for "ANR AAPG" templates, that is, templates for research funding grants provided by the French ANR (Agence Nationale de Recherche).


## Contents

The file [aapg.typ](./aapg.typ) provides a Typst template style that imitates the `.docx` documents proposed by the ANR. See a full example of file using this package below.

The files [first-proposal.typ](./first-proposal.typ) and [second-proposal.typ](./second-proposal.typ) can serve as templates to write the proposals in the first phase (pré-proposition) and in the second phase (proposition). They contain the advice and recommendations provided by the ANR as of 2025, that you should remove as you fill the corresponding sections. We recommend starting your own proposal from these files.

In our experience, such ANR recommendations evolve slowly, so it is reasonable to use them as a basis in future years as well -- but do look at the official .docx in case there was a sudden change.

## Example

```typst
#let Project = smallcaps[
  // change this to the acronym / short name of your project
  InterestingProject
]

#show: doc => aapg.style(
  short-project-name: Project,
  AAPG: [AAPG2099],
  instrument: [JCJC / PRCI / PRCE / PME], // select one
  coordinator: [Coordinator Name],
  duration: [99 years],
  funding-request: [999,999,999],
  CES: [CES 48 - Fondements du numérique : informatique, automatique, traitement du signal],
  doc
)

#aapg.title[#Project: a very interesting project]

#aapg.comment[
Utilisez une mise en page permettant une lecture confortable du document (page A4, Calibri 11 ou équivalent, interligne simple, marges 2 cm ou plus, numérotation des pages, pour les tableaux et figures minimum Calibri 9 ou équivalent).
]
```

## Language

A few words of explanation:

- The ANR recommends that you write your grant proposals in English, so that they can rely on non-French-speaking evaluators.

- The English prose provided by the ANR is not *bad* bad, but still bad enough that it will hurt your soul a little bit every time you try to read it. If you want to understand their recommendations, you should read the French version.

   (Choice quotes: "Building and ground costs"; "Position of the project as it relates to the state of the art"; "Methodology to reach the scientific objectives of the project, detailed description of the intended method(s) including its disciplinary coverage (mono-trans-inter-disciplinary)".)

- As a result, we made the choice to:
  + provide the French versions of the recommendations (that you will remove as you write your proposal),
  + provide the English wording for the titles of the recommended sections (that you will presumably keep in your proposal, if you write it in English as recommended),
  + but also provide French versions of those titles for your sanity.
