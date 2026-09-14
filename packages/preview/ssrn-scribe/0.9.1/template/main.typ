#import "@preview/ssrn-scribe:0.9.1": *

// if you do not want to use the integrated packages, you can comment out the following lines
#import "extra.typ": *
#show: great-theorems-init

#show: paper.with(
  font: "PT Serif",                 // core body font family
  fontsize: 12pt,                   // core body font size
  maketitle: true,                  // true → dedicate a cover page; false → inline title
  title: [#lorem(5)],               // document title
  subtitle: "A work in progress",   // optional subtitle line

  // Cover-page–only spacing and typography (ignored when maketitle=false)
  cover-text-width: 90%,            // width of the abstract/keywords block
  cover-line-leading: 1.32em,       // line height for cover/front matter paragraphs
  cover-paragraph-spacing: 0.7em,   // paragraph spacing on the cover/front matter

  // Author grid controls (shared across both modes)
  author-columns: 2,                // override the auto-detected column count
  author-alignment: center,         // column alignment for author details
  authors: (
    (
      name: "Theresa Tungsten",
      affiliation: "Artos Institute",
      email: "tung@artos.edu",
      note: "123",
    ),
    (
      name: "John Doe",
      affiliation: "Center for Applied Typstics",
      email: "john.doe@example.com",
    ),
  ),
  date: "July 2023",                // version/date string (shown in both modes)
  abstract: lorem(80),             // optional abstract (rendered front matter)
  keywords: [
    Imputation,
    Multiple Imputation,
    Bayesian,],                    // keyword list
  JEL: [G11, G12],                  // optional JEL codes
  acknowledgments: "This paper is a work in progress. Please do not cite without permission.", // footnote on title block
  frontmatter-gap: 12pt,            // spacing between abstract/keywords/JEL entries

  // Body typography (applies to both modes)
  body-line-leading: 1.32em,        // main-text line height
  body-paragraph-spacing: 0.7em,    // spacing between main-text paragraphs
  body-text-spacing: 106%,          // glyph tracking for the body text

  // bibliography: bibliography("bib.bib", title: "References", style: "apa"), // attach your references
)

// Your main content goes here
= Introduction
#lorem(10)

= Literature Review
#lorem(20)