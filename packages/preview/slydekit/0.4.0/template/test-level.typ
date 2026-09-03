#import "../src/slydekit.typ": *

#show heading.where(level: 1): it => {
  pagebreak(weak: true)

  set page(header: none, footer: none)

  progressive-outline(it, luma(80%), slide-level: 2, display-subsection: true)
}

#show heading.where(level: 2): it => {
  pagebreak(weak: true)
  set page(header: none, footer: none)

  progressive-outline(it, luma(80%), slide-level: 3, display-subsection: true)
}

#show: slydekit.with(
  title: "Slydekit",
  subtitle: "An example of a presentation template using Typst",
  author: "John Doe",
  date: "2024-06-01",
  institution: "Université de Typst",
  contact: "john.doe@univ.typst.fr",
  // theme: metropolis,
  // theme: fancy,
  // theme: simple,
  // theme: cambfurt,
  // theme: chalkboard,
  // fonts: (body: "New Computer Modern"),
  // colors: chalkboard-colors-variant,
  lang: "en",
  navigation-style: "minislide",
  title-logo: (image("images/slydekit-full.svg", height: 2.5cm),),
  slide-logo: image("images/slydekit-mini.svg", height: 1.25cm),
  slide-level: 4,
  // handout: true
  section-numbering: true,
  // numbering-pattern: (section: "I.1.1.", appendix: "A.1.1."),
)

#title-slide



= Part 1

== Main section 1

#tableofcontents

=== Section 1

==== Slide 1

#lorem(10)

==== Slide 2

#lorem(10)

// == Second section

=== Section 2

==== Slide 3

#lorem(10)

= Part 2

== Main section 2

#tableofcontents

=== Section 1

==== Slide 4

#lorem(10)

=== Section 2

==== Slide 5

#lorem(10)

#show: appendix

= Appendix 1

== Appendix main section 1

=== Appendix section 1

==== Appendix slide 1

#lorem(10)