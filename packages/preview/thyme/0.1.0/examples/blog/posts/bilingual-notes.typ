#import "@preview/thyme:0.1.0": *
#import blog: *

#show: post.with(
  title: tr(
    en: [Noetherian Rings & Bilingual Static Prose],
    de: [Noethersche Ringe & zweisprachige statische Prosa],
  ),
  subtitle: tr(
    en: [Single-URL zero-JavaScript language switching via CSS radio state],
    de: [Einzel-URL-Sprachumschaltung ohne JavaScript über CSS-Radio-Zustände],
  ),
  author: "Emmy Noether",
  monograph: `EN-01`,
  lang: ("en", "de"),
  created: datetime(year: 2026, month: 10, day: 24),
  modified: datetime(year: 2026, month: 10, day: 28),
  summary: [Ascending chain conditions presented in English and German on one canonical URL without client-side scripts.],
  tags: ("algebra", "i18n"),
)

#toc(title: [Contents])

= Chain Conditions <chain-conditions>

#tr(
  en: [A commutative ring $R$ satisfies the ascending chain condition when every chain of ideals $I_1 subset.eq I_2 subset.eq dots.c$ stabilizes finitely#mcite(<noether1921>, supplement: [§1]). See also #link(<state-machine>)[Parity Automata] for a monolingual post where the language switcher automatically hides.],
  de: [Ein kommutativer Ring $R$ erfüllt die aufsteigende Kettenbedingung, wenn jede Idealkette $I_1 subset.eq I_2 subset.eq dots.c$ nach endlich vielen Schritten stationär wird#sidenote[Ein Klick auf `en · de` in der Kopfleiste schaltet Randnotizen, Überschriften und Fließtext gleichzeitig ohne JavaScript um.]. Siehe auch #link(<state-machine>)[Parity Automata] für einen einsprachigen Beitrag ohne Sprachumschalter.],
)

#let lang-db = toml("../lang.toml")

#emph(tr(from: lang-db, "series_note"))

= Basis Theorem <basis-theorem>

#theorem[Hilbert's Basis Theorem][
  #tr(
    en: [If $R$ is a Noetherian ring, then the polynomial ring $R[x]$ is also Noetherian.],
    de: [Ist $R$ ein noetherscher Ring, so ist auch der Polynomring $R[x]$ noethersch.],
  )
]

#bibliography("../refs.bib", title: [References])
