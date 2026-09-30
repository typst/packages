// States
#let sk-states = (
  app-slide-number: counter("appendix"),
  appendix: state("appendix", false),
  colors: state("colors", (:)),
  current-slide-title: state("current-slide-title", []),
  fonts: state("fonts", (:)),
  handout: state("handout", false),
  is-footcite: state("is-footcite", false),
  logo: state("logo"),
  localization: state("localization"),
  navigation-style: state("navigation-style", "topbar"),
  numbering-pattern: state("numbering-pattern"),
  pause-index: counter("pause-index"),
  pres-info: state("pres-info"),
  section-numbering: state("section-numbering", false),
  slide-number: counter("slide-number"),
  slide-index: counter("subslide-index"),
  subslide-total: counter("subslide-total"),
  subslide-step: counter("subslide-step"),
  theme: state("theme"),
)

// Defaults
#let margins = (
  left: 2cm,
  right: 2cm,
  top: 2cm,
  bottom: 2cm,
)

#let default-fonts = (
  size: 20pt,
  body: "New Computer Modern",
  math: "New Computer Modern Math",
  raw: "DejaVu Sans Mono",
)

#let default-pres-info = (
  title: "Title",
  subtitle: "Subtitle",
  short-title: "Short title",
  author: "Author",
  date: "Date",
  institution: "Institution",
  contact: "contact@example.com",
  logo: none,
  header-footer-logo: none
)

#let default-numbering-pattern = (
  section: "1.1.",
  appendix: "A.1.",
)

#let default-language = ("en", "de", "fr",  "es", "it", "pt", "zh")