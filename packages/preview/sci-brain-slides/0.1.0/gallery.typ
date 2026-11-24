#import "@preview/sci-brain-slides:0.1.0": *

#let deck = setup(
  theme: sys.inputs.at("theme", default: "academic"),
  text-size: float(sys.inputs.at("text-size", default: "20")) * 1pt,
)
#let sizes = deck.sizes
#let pal = deck.palette
#let (rail_pull, callout, codebox, quote_pull, figbox, portrait, clip_image,
      stat, stat_row, spec_list, theorem, definition, lemma, example, proof_box,
      badge, tag, time_badge, data_table, conclusion_grid, key_links, toc,
      pacing, kicker, progress_dots) = deck.gadgets
#let (spread, twocol, threecol, hero, band, cards, card, punch, centered_figure) = deck.layouts

#show: deck.theme.with(
  footer: [sci-brain-slides / Component gallery],
  footer-progress: true,
  config-info(title: [A place for every idea],
    subtitle: [The sci-brain-slides component gallery],
    author: [Version 0.1.0], institution: [Scientific talks / Lectures / Briefings], date: none),
)
#title-slide()

== Choose a layout by its _purpose_
#toc(columns: 2)

= Color themes

#let swatches(p) = grid(columns: (1fr,) * 5, column-gutter: 14pt,
  ..(("Primary", p.primary), ("Accent", p.accent_deep), ("Ink", p.ink),
     ("Muted", p.text_soft), ("Paper", p.paper_bg)).map(((label, c)) => [
    #rect(width: 100%, height: 45pt, radius: 3pt, fill: c, stroke: 0.5pt + p.hairline)
    #v(6pt)
    #text(sizes.caption, fill: p.text)[#label]
    #linebreak()
    #text(sizes.chrome, font: "DejaVu Sans Mono", fill: p.text_soft)[#c.to-hex()]
  ]))
#let sample(p, description) = block(width: 100%, inset: 22pt, radius: 4pt,
  fill: p.paper, stroke: 0.7pt + p.hairline)[
  #swatches(p)
  #v(22pt)
  #text(sizes.large, weight: "bold", fill: p.ink)[#description]
  #v(10pt)
  #text(sizes.normal, fill: p.text_soft)[Body text stays readable. Emphasis follows the palette.]
]

== Academic / the default research talk
#sample(palettes.academic, [Indigo, lavender, and white.])

== Dark / a low-light presentation
#sample(palettes.dark, [Slate, pale blue, and warm gold.])

== Minimal / a printable lecture
#sample(palettes.minimal, [Black ink. Quiet rules.])

== Vibrant / teaching and outreach
#sample(palettes.vibrant, [Teal with a magenta accent.])

== Brand / start with a house color
#sample(brand-palette(rgb("#aa1e2b")), [A palette derived from your primary color.])

= Layouts

#let placeholder(label, height: 130pt) = rect(width: 100%, height: height,
  radius: 3pt, fill: pal.paper_bg, stroke: 0.7pt + pal.hairline)[
  #align(center + horizon, text(sizes.large, fill: pal.text_soft, label))
]

== Spread / evidence beside interpretation
#spread(
  figbox([The evidence], placeholder([Your figure]), caption: [Tell the reader what to compare.]),
  [#kicker[Interpretation] #v(12pt) One claim belongs beside the figure.
   #v(14pt) #rail_pull[Name what changes.]],
)

== Two columns / a direct comparison
#twocol(
  [#kicker[Before] #v(14pt) #card[Describe the baseline in one short paragraph.]],
  [#kicker[After] #v(14pt) #card[Explain what the new method changes.]],
)

== Three columns / parallel concepts
#threecol(
  [#kicker[01 / Question] #v(14pt) What remains unknown?],
  [#kicker[02 / Method] #v(14pt) What can we measure?],
  [#kicker[03 / Evidence] #v(14pt) What would settle it?],
)

== Hero / one statement to remember
#hero[#punch([4×], [lower standard error], label: [16 independent samples instead of one])]

== Cards / a compact comparison
#cards(
  [#kicker[Assumption] #v(10pt) Independent samples.],
  [#kicker[Estimator] #v(10pt) The sample mean.],
  [#kicker[Uncertainty] #v(10pt) Standard error.],
  [#kicker[Limitation] #v(10pt) Correlated noise.],
)

== Centered figure / give the visual room
#centered_figure(placeholder([One figure, one comparison], height: 190pt),
  caption: [A caption explains how to read the evidence.])

= Callouts

== Pull quote / a sentence worth pausing on
#quote_pull([A claim becomes useful when we know how to test it.], source: [Example text])
#v(26pt)
#rail_pull[Put the interpretation next to the evidence.]

== Callouts / a consistent visual language
#grid(columns: (1fr, 1fr), gutter: 16pt,
  callout([Context], [State what the audience needs to know.], height: 112pt),
  callout([Verified], [Name the check that passed.], kind: "success", height: 112pt),
  callout([Limitation], [Explain where the result stops.], kind: "warning", height: 112pt),
  callout([Takeaway], [Make one claim easy to find.], kind: "accent", height: 112pt),
)

== Code / show only the relevant lines
#codebox[#raw(lang: "typst", "#let deck = setup(theme: \"dark\")\n#show: deck.theme.with(\n  config-info(title: [My research talk]),\n)")]
#v(20pt)
#text(sizes.caption, fill: pal.text_soft)[Long code belongs in the paper or repository.]

= Numbers and evidence

== Stats / quantities with their meaning
#stat_row(
  (value: [16], unit: [samples], label: [averaged together]),
  (value: [4×], label: [lower standard error]),
  (value: [0.25], unit: [$sigma$], label: [remaining uncertainty]),
)
#v(30pt)
#stat([1], [assumption to check], unit: [critical])

== Specifications / short, numbered statements
#spec_list(
  (term: [Collect], desc: [Repeat the same measurement.], tag: [data]),
  (term: [Check], desc: [Test for correlated errors.], tag: [model]),
  (term: [Report], desc: [Show units and uncertainty.], tag: [result]),
)

== Table / make the comparison explicit
#data_table(
  ("Samples", "Standard error", "Relative gain"),
  ("1", "1.00 σ", "1×"),
  ("4", "0.50 σ", "2×"),
  ("16", "0.25 σ", "4×"),
  highlight: (2,),
)
#v(18pt)
#text(sizes.caption, fill: pal.text_soft)[Analytical values for independent samples with variance $sigma^2$.]

= Theory

== Definition and theorem / separate their jobs
#definition(title: [Sample mean], [$ hat(mu) = 1/N sum_(i=1)^N x_i $])
#v(16pt)
#theorem(title: [Unbiasedness], [If every sample has mean $mu$, then $EE[hat(mu)] = mu$.])

== Lemma and proof / keep the argument readable
#lemma[The variance of a sum of independent variables is the sum of their variances.]
#v(16pt)
#proof_box[Expand the squared centered sum. Independence makes all cross terms zero.]

== Example / connect a formula to a scale
#example(title: [Sixteen measurements], [
  With independent unit-variance noise,
  $ "SE"(hat(mu)) = 1 / sqrt(16) = 0.25. $
])
#v(24pt)
#rail_pull[State the assumptions with the number.]

= Small components

== Labels / lightweight context
#band(badge([Result]), tag([Independent samples]), time_badge([12:00]))
#v(28pt)
#kicker[Progress through the argument]
#v(12pt)
#progress_dots(5, 2)
#v(28pt)
#key_links(("Code", [#link("https://github.com/GiggleLiu")[github.com/GiggleLiu]]),
  ("Docs", [See the package README and layout guide.]))

#let portrait-art(c) = rect(width: 64pt, height: 64pt,
  fill: c, radius: 3pt, stroke: none)[#align(center + horizon, text(white, [AB]))]

== Portraits / keep the names together
#band(
  portrait(portrait-art(pal.primary), [A. Researcher]),
  portrait(portrait-art(pal.accent_deep), [B. Collaborator]),
  portrait(portrait-art(pal.secondary), [C. Investigator]),
)
#v(26pt)
#text(sizes.caption, fill: pal.text_soft)[Pass an image element from your project. The package never resolves your image paths.]

== Cropping / trim the original visual
#centered_figure(
  clip_image(rect(width: 380pt, height: 170pt, stroke: none,
    fill: gradient.linear(pal.primary, pal.accent_deep)), top: 24pt, bottom: 24pt),
  caption: [The same content, clipped by 24 points above and below.],
)

= Reveals

== Reveal one step at a time
#pacing(2)
The question comes first.
#pause

#v(16pt)
Then the evidence.
#pause

#v(16pt)
#rail_pull[Each reveal is another page in the PDF.]

#focus-slide[Leave the audience with one clear claim.]

= Diagrams

#import "@preview/cetz:0.5.2": canvas
#let (tensor, automaton-state, edge, flowbox) = cetz-gadgets(pal)

== Tensor network / structure before detail
#centered_figure(canvas(length: 1.5cm, {
  tensor((0, 0), "A", [$A$])
  tensor((2.5, 1.2), "B", [$B$])
  tensor((2.5, -1.2), "C", [$C$])
  tensor((5, 0), "D", [$D$])
  edge("A", "B"); edge("A", "C"); edge("B", "D"); edge("C", "D")
}), caption: [Nodes are tensors. Edges are contracted indices.])

== State machine / label the transitions
#centered_figure(canvas(length: 1.6cm, {
  automaton-state((0, 0), "q0", [$q_0$])
  automaton-state((3, 0), "q1", [$q_1$])
  automaton-state((6, 0), "q2", [$q_2$], accept: true)
  edge("q0", "q1", mark: (end: "straight"))
  edge("q1", "q2", mark: (end: "straight"))
}), caption: [The double ring marks the accepting state.])

== Flow / connect the sides of the boxes
#centered_figure(canvas(length: 1.2cm, {
  flowbox((0, 0), "data", [Data])
  flowbox((5, 0), "model", [Model])
  flowbox((10, 0), "check", [Check])
  edge("data.east", "model.west", mark: (end: "straight"))
  edge("model.east", "check.west", mark: (end: "straight"))
}), caption: [Arrows stop at the box borders.])

= Annotations

#let (pin, highlight, note) = pin-gadgets(pal, sizes: sizes)

== Point to the phrase that _matters_
#v(24pt)
The estimate assumes #pin(1)independent samples#pin(2).
#highlight(1, 2)
#note(2, dx: 0pt, dy: 65pt)[Check this assumption.]

= Closing

== Conclusion / a result and a next step
#conclusion_grid(
  (label: "Question", title: [What did we ask?], body: [Name the uncertainty.]),
  (label: "Evidence", title: [What did we learn?], body: [Point to the result.]),
  (label: "Scope", title: [Where does it hold?], body: [State the assumptions.]),
  (label: "Next", title: [What should we test?], body: [Propose one experiment.]),
  highlight: 3,
)
