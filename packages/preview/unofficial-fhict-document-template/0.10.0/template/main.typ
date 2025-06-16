#import "@preview/unofficial-fhict-document-template:0.10.0": *

// #import "./terms.typ": term-list

#show: fhict-doc.with(
  title: "",
  subtitle: "",
  // subtitle-lines: 1,
  authors: (
    (
      name: "",
    ),
  ),
  version-history: (
    (
      version: "",
      date: "",
      author: [],
      changes: "",
    ),
  ),
  // pre-toc: [#include "./pre-toc.typ"],
  // table-of-figures: false,
  // table-of-listings: false,
  // appendix: [#include "./appendix.typ"],
  // bibliography-file: bibliography("my-sources.bib"),
  // citation-style: "ieee",
  // glossary-terms: term-list,
  // glossary-front: false,
  // toc-depth: 3,
  // disable-toc: false,
  // disable-chapter-numbering: false,
  // watermark: none,
  // censored: 0,
  // print-extra-white-page: false,
  // secondary-organisation-color: none,
  // secondary-organisation-logo: none,
  // secondary-organisation-logo-height: 6%,
  // enable-index: false,
  // index-columns: 2,
)

= Chapter
