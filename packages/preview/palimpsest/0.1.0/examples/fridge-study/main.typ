#import "@preview/palimpsest:0.1.0": *
#import "@preview/unequivocal-ams:0.1.2": ams-article, theorem, proof

// A lightweight letter template echoing the manuscript's own typeface,
// rather than reusing `ams-article` itself — the letter is a short
// reviewer-facing document, not a second article with its own title
// page, abstract, and author block.
#let letter-template(body) = {
  set text(font: "New Computer Modern", size: 10pt)
  set par(justify: true, first-line-indent: 0em)
  align(center, text(size: 1.3em, weight: 700)[Response to Reviewers])
  v(0.3em)
  align(center, emph[Association between fridge opening frequency and
  probability of finding something new inside])
  v(1.5em)
  body
}

#show: revisions.with(
  template: ams-article.with(
    title: [Association between fridge opening frequency and probability
    of finding something new inside],
    authors: (
      (
        name: "Ivana Snackwell",
        department: [Department of Kitchen Epidemiology],
        organization: [Institute of Domestic Sciences],
        location: [Fridgeport, IL],
        email: "ivana.snackwell@example.org",
      ),
      (
        name: "Tupper Ware",
        department: [Behavioral Nutrition Laboratory],
        organization: [University of Leftovers],
        location: [Crispington, OH],
        email: "tupper.ware@example.org",
      ),
    ),
    abstract: [
      Background: repeated refrigerator-door-opening behavior ("fridge-
      checking") is common, but its relationship to the subjective
      probability of discovering something new inside remains
      uncharacterized. Methods: we conducted a 30-day prospective
      observational study of 42 households, logging daily fridge-opening
      frequency and self-reported discovery of novel contents. Results:
      discovery probability increased steadily with opening frequency,
      despite grocery deliveries being held constant across groups.
      Conclusion: these findings are consistent with an intermittent-
      reinforcement account of fridge-checking behavior, in which
      occasional genuine discoveries maintain a high rate of
      unrewarded checking.
    ],
    bibliography: bibliography("manuscript.bib"),
  ),
  exchanges: include "responses.typ",
  letter-template: letter-template,
)

#include "manuscript.typ"
