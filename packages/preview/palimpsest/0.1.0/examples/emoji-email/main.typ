#import "@preview/palimpsest:0.1.0": *
#import "@preview/charged-ieee:0.1.3": ieee

// A lightweight letter template, independent of the two-column IEEE
// layout — the letter is a short reviewer-facing document, not a
// second article with its own title block and index terms.
#let letter-template(body) = {
  set par(justify: true, first-line-indent: 0em)
  align(center, text(size: 1.3em, weight: 700)[Response to Reviewers])
  v(0.3em)
  align(center, emph[Estimating the causal effect of replying "👍"
  versus "merci" to professional emails])
  v(1.5em)
  body
}

#show: revisions.with(
  template: ieee.with(
    title: [Estimating the causal effect of replying "👍" versus
    "merci" to professional emails],
    abstract: [
      Background: professional emails increasingly close with either a
      written sign-off or a bare emoji reaction, and whether this choice
      causally affects downstream communication outcomes is unknown.
      Methods: we analyzed metadata from 1,204 professional email
      threads across six organizations, comparing threads whose final
      message closed with a "👍" emoji, the word "merci," or no sign-off,
      using inverse-probability-weighted estimates of the probability of
      a further reply within 48 hours. Results: reply probability
      differed by sign-off group both before and after adjustment for
      measured confounders. Conclusion: these findings are consistent
      with sign-off choice being causally relevant to reply behavior in
      professional email correspondence.
    ],
    authors: (
      (
        name: "Constance Reply-All",
        department: [Department of Organizational Communication],
        organization: [Institute for Workplace Efficiency],
        location: [Inbox City, DE],
        email: "c.reply-all@example.org",
      ),
      (
        name: "Marcus Cc",
        department: [Behavioral Email Analytics Lab],
        organization: [University of Inbox Zero],
        location: [Threadford, NJ],
        email: "marcus.cc@example.org",
      ),
    ),
    index-terms: ("Causal inference", "Email etiquette", "Digital communication", "Propensity score"),
    bibliography: bibliography("manuscript.bib"),
    figure-supplement: [Fig.],
  ),
  exchanges: include "responses.typ",
  letter-template: letter-template,
)

#include "manuscript.typ"
