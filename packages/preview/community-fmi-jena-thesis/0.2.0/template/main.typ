#import "@preview/community-fmi-jena-thesis:0.2.0": *

// Your own changes to the template (e.g. a different link style or your own `todo`).
// Open custom.typ for a step-by-step guide.
#import "custom.typ": *

// Set your language as required ("en" or "de"). This also switches the language of
// the headings and the declaration of academic integrity inserted by the template.
#set text(lang: "en", region: "GB")

// Define your assessors and degree here, for use on the cover page(s).
#let assessor = [Prof. Dr. First Person\ M.Sc. Second Person]
#let degree = [Bachelor of Science (B.Sc.)]

#show: fsu.with(
  title: [Title of Your Thesis],
  author: "Your Name",

  // The university logo is not included in this package. Download
  // "Bildmarke_blue_23cm.png" from the university's corporate design templates
  // (see the package README, section "Getting the logo"), save it next to this file
  // and uncomment this line:
  // uni-logo: image("Bildmarke_blue_23cm.png", width: 10cm),

  cover-english: (
    faculty: "Faculty of Mathematics and Computer Science",
    university: "Friedrich Schiller University Jena",
    type-of-work: "Bachelor Thesis",
    academic-degree: degree,
    field-of-study: "Computer Science",
    author-info: "1 April 2001 in Wolkenkuckucksheim, Germany",
    assessor: assessor,
    place-and-submission-date: "Jena, 1 April 2025",
  ),

  // You can add a German cover page with the same keys:
  // cover-german: (
  //   faculty: "Fakultät für Mathematik und Informatik",
  //   university: "Friedrich-Schiller-Universität Jena",
  //   type-of-work: "Bachelorarbeit",
  //   academic-degree: degree,
  //   field-of-study: "Informatik",
  //   author-info: "1. April 2001 in Wolkenkuckucksheim",
  //   assessor: assessor,
  //   place-and-submission-date: "Jena, 1. April 2025",
  // ),

  abstract: [
    #lorem(80)

    #todo[Put your actual abstract here.]
  ],

  // A German abstract ("Zusammenfassung") is MANDATORY if your thesis is not written
  // in German (PO § 20 Abs. 8). The document will not compile without it unless the
  // language above is set to "de".
  abstract-german: [
    #lorem(80)

    #todo[Put your German abstract here.]
  ],

  preface: [
    #lorem(60)

    #todo[Put your own preface here or remove it.]
  ],

  appendix: [
    == Use of Generative AI
    #todo[If permitted by your examiner, document the use of generative AI here.]

    == Additional Material
    #lorem(40)
  ],

  abbreviations: (
    ("API", "Application Programming Interface"),
    ("RDF", "Resource Description Framework"),
    ("WWW", "World Wide Web"),
  ),

  // Turn this on for the version you hand in on paper. Turning on `print` turns off
  // `external-link-circle` and turns on `use-print-margins`. You can set those
  // individually as you wish.
  print: false,

  // Page margins. Uncomment and change them if you like.
  // Template defaults:
  // screen-margin: (x: 3cm, y: 2.8cm),
  // print-margin: (inside: 4cm, outside: 2cm, top: 3cm, bottom: 3cm),
  // Recommended by the examination office (Gestaltungshinweise, § 5), used by default
  // for the print version: left 40 mm, right 20 mm, top and bottom 30 mm each.
  // screen-margin: (left: 4cm, right: 2cm, top: 3cm, bottom: 3cm),
  // print-margin: (inside: 4cm, outside: 2cm, top: 3cm, bottom: 3cm), // two-sided
  // print-margin: (left: 4cm, right: 2cm, top: 3cm, bottom: 3cm), // one-sided

  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
  bibliography: bibliography("bib.yaml", style: "ieee"),
)

// Apply the rules from custom.typ to your text.
#show: custom-rules

= Introduction <introduction>

This template follows the design guidelines for theses at the Faculty of Mathematics and Computer Science. Abbreviations such as API are written out on their first use and link to the list of abbreviations; later uses of API only show the short form. Citations work as usual @knuth1984. Links to #link("https://typst.app/docs")[external websites] are marked with a small circle.

#todo[Write your introduction.]

== Problem
#lorem(120)

== Contribution
#lorem(120)

= Preliminaries

#lorem(80)

#figure(
  caption: [A small example table.],
  table(
    columns: 2,
    [Feature], [Status],
    [Cover page], [#sym.checkmark],
    [Declaration], [#sym.checkmark],
  ),
)

#figure(
  caption: [A code listing.],
  ```rust
  fn main() {
      println!("Hello, Jena!");
  }
  ```,
)

$ sum_(k=1)^n k = (n(n+1)) / 2 $

= Conclusion <conclusion>

As discussed in @introduction, #lorem(60)
