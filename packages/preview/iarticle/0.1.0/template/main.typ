// Starter document for iarticle. This page is also what
// generate_thumbnail.sh renders for the package thumbnail, so it's
// written as a short self-introduction to the template (based on
// README.md) rather than bare TODO placeholders - it doubles as a
// working example of headings, a table, a figure, a citation, and
// appendix(..) before you replace it with your own content.
#import "@preview/iarticle:0.1.0": iarticle, appendix

#show: iarticle.with(
  lang: "en",
  title: [iarticle---an i18n-capable template inspired by LaTeX article/report],
  authors: ("Your Name",),
  abstract: [
    iarticle provides two localized Typst templates, `iarticle` and
    `ireport`, mirroring the LaTeX `article`/`report` distinction. This
    starter page is a quick tour - replace it with your own document.
  ],
)

= Two templates

`iarticle` (this one) is flat: it starts at "section", has no chapters,
no forced page breaks, and no automatic table of contents. It's meant
for papers and other short documents.

`ireport` is structured: "chapter" is the top level and each one starts
a new page, sections nest under it, and a table of contents is included
by default. Import it the same way, just with `ireport` in place of
`iarticle`:

```typst
#import "@preview/iarticle:0.1.0": ireport
#show: ireport.with(lang: "ja", title: "...")
```

== Supported locales

Chapter/section/appendix labels, figure/table captions, and the
abstract/contents/references headings are all localized based on
`lang`:

#figure(
  table(
    columns: 3,
    [*lang*], [*locale*], [*l10n file*],
    [en], [en], [`l10n/en.typ`],
    [ja], [ja], [`l10n/ja.typ`],
  ),
  caption: [
    `region` is also accepted and forwarded to Typst's own `text`
    state, but doesn't currently pick between locales - neither `en`
    nor `ja` is script-ambiguous the way e.g. Chinese would be.
  ],
)

#figure(
  rect(width: 4cm, height: 2.5cm, stroke: 0.5pt),
  caption: [
    Figure/table captions like this one are localized automatically
    (`show figure.where(kind: ..): set figure(supplement: ..)`) -
    replace this rectangle with a real image.
  ],
)

= Fonts

`serif-font`/`sans-font` default to `auto`: a Latin base, plus a
Japanese CJK addition for `lang: "ja"` only - so an English document
doesn't warn about missing Japanese fonts, but a Japanese one does if
none are found. Override either at the call site if your system has
different fonts installed.

#appendix[
  = Learn more

  This is `appendix(..)`: it relabels level-1 headings from "Section"
  to "Appendix" and switches numbering to letters. For more detail than
  fits on this page, see `README.md`, the fuller examples in
  `samples/`, and `l10n/` for the string tables themselves.

  For example, here's a citation, just to demonstrate the mechanism:
  @knuth1984. See also @tufte2001 for a second one.
]

#bibliography("refs.bib")
