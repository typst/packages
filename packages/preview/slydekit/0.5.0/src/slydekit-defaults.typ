// States
#let sk-states = (
  activate-parser: state("activate-parser", true),
  app-slide-number: counter("appendix"),
  appendix: state("appendix", false),
  colors: state("colors", (:)),
  current-slide-title: state("current-slide-title", []),
  fonts: state("fonts", (:)),
  frozen-counters: state("frozen-counters", ()),
  handout: state("handout", false),
  hide-section-slide: state("sk-hide-section-slide", false),
  is-footcite: state("is-footcite", false),
  logo: state("logo"),
  localization: state("localization"),
  navigation-style: state("navigation-style", "topbar"),
  numbering-hidden: state("sk-numbering-hidden", false),
  numbering-pattern: state("numbering-pattern"),
  pause-index: counter("pause-index"),
  pres-info: state("pres-info"),
  section-numbering: state("section-numbering", false),
  slide-level: state("slide-level", 2),
  slide-number: counter("slide-number"),
  subslide-step: counter("subslide-step"),
  theme: state("theme"),
)

// Defaults
#let default-margins = (
  left: 1.5cm,
  right: 1.5cm,
  top: 2cm,
  bottom: 2cm,
)

#let default-fonts = (
  size: 20pt,
  body: "New Computer Modern",
  math: "New Computer Modern Math",
  raw: "DejaVu Sans Mono",
)

#let default-frozen-counters = (
    counter(heading),
    counter(figure.where(kind: image)),
    counter(figure.where(kind: table)),
    counter(math.equation),
)

#let default-numbering-pattern = (
  section: "1.1.",
  appendix: "A.1.",
)

#let default-language = ("en", "de", "fr",  "es", "it", "pt", "zh")
