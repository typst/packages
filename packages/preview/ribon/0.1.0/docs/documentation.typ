#import "@preview/mantys:1.0.2": *
#import "@preview/codly:1.3.0"
#import "../lib.typ" as ribon

#let infos = toml("../typst.toml")

#let styled-theme = create-theme(
  fonts: (
    serif: ("Times New Roman", "Georgia"),
    sans: ("Helvetica Neue", "Arial"),
    mono: ("Menlo", "Courier New"),
  ),
  text: (
    size: 10pt,
    font: ("Times New Roman", "Georgia"),
    fill: rgb(35, 31, 32),
  ),
  heading: (
    font: ("Helvetica Neue", "Arial"),
    fill: rgb(35, 31, 32),
  ),
  emph: (
    link: rgb("#315eaa"),
  ),
  code: (
    size: 8.5pt,
    font: ("Menlo", "Courier New"),
    fill: rgb("#4c5563"),
  ),
)

#let my-theme = create-theme(
  base-theme: styled-theme,
  title-page: (doc, theme) => {
    let license = doc.package.license
    let patched-doc = doc + (
      package: doc.package + (
        license: [
          #h(-4 * theme.text.size)
          #linebreak()
          #license
        ],
      ),
    )
    (styled-theme.title-page)(patched-doc, theme)
  },
)

#show: mantys(
  ..infos,
  title: [Ribon],
  subtitle: [RNA secondary-structure visualization and analysis],
  date: datetime.today(),
  abstract: [
    `ribon` visualizes and analyzes RNA and DNA secondary structures in Typst. It draws supplied extended dot-bracket structures, predicts structures from sequence alone, computes ensemble observables, and connects results directly to annotations, comparisons, and quantitative plots.

    This manual covers data conventions, layout, thermodynamic models, constraints, core and advanced analyses, quantitative plots, error handling, reproducibility, validation, and the complete public API.
  ],
  wrap-snippets: true,
  examples-scope: (
    scope: (
      ribon: ribon,
    ),
    imports: (
      ribon: "*",
    ),
  ),
  theme: my-theme,
)

#show cite: set text(fill: rgb(35, 31, 32))

#let example = example.with(side-by-side: false, breakable: false)
#let doc-code(..args, body) = frame(
  breakable: true,
  codly.local(number-format: none, breakable: true, ..args, body),
)

#import ribon: *

#let note(title, body, color: rgb("#315eaa")) = {
  if color == rgb("#8a5a00") {
    warning-alert[*#title* #body]
  } else {
    info-alert[*#title* #body]
  }
}

#let parameter(name, default, body) = [
  - #raw(name) #if default != none { [ (default: #raw(default))] }: #body
]

#let api(name, signature, body, returns: none) = command(name)[
  #doc-code(raw(signature, lang: "typst", block: true))
  #body
  #if returns != none [
    *Returns:* #returns
  ]
]

#let panel(title, body) = figure(
  body,
  caption: text(size: 7pt, weight: "semibold", title),
)

#let paired(source, result) = example(
  breakable: false,
  raw(source, lang: "typ", block: true),
  result,
)
#let sequence = "GGGAAACCCGGGAAACCC"
#let reference = "(((...)))(((...)))"
#let alternative = "((....)).(((...)))"
#let prediction = analyze(sequence)
#let perturbed = analyze(
  sequence,
  constraints: folding-constraints(force-unpaired: (1, 2)),
)
#let decoder-sequence = "GCGCCUUGAAAGUCCAGAGGACUUGGUUUUAUUGGGUAGUUGAGGUUGGUGGCCCAUCUC"
#let decoder-prediction = analyze(decoder-sequence)
#let decoder-data = data(decoder-prediction)
#assert(decoder-data.mfe_structure != decoder-data.centroid_structure)
#assert(decoder-data.mfe_structure != decoder-data.mea_structure)
#assert(decoder-data.centroid_structure != decoder-data.mea_structure)
#let scale = color-scale(
  minimum: 0.0,
  maximum: 1.0,
  colors: (rgb("#2166ac"), rgb("#f7f7f7"), rgb("#b2182b")),
  label: [SHAPE reactivity],
)
#let values = (
  0.02, 0.08, 0.12, 0.86, 0.91, 0.72, 0.15, 0.09, 0.03,
  0.04, 0.07, 0.14, 0.74, 0.88, 0.81, 0.16, 0.06, 0.02,
)

= Overview

Ribon is a Typst package for two related tasks:

- drawing an RNA or DNA secondary structure from a sequence and extended dot-bracket notation;
- computing thermodynamic and ensemble properties from a sequence, then rendering the result without a conversion step.

The public API is deliberately split into analysis, layout, rendering, annotation, and plot layers. A document can use only #raw("draw") with a supplied structure, or can run #raw("analyze") and send the returned response to #raw("render"), #raw("dot-plot"), or #raw("mountain-plot").

== Architecture and responsibility boundaries

#table(
  columns: (28mm, 46mm, 1fr),
  inset: 5pt,
  stroke: luma(84%) + 0.35pt,
  table.header([*Layer*], [*Implementation*], [*Responsibility*]),
  [Public entry], [#raw("lib.typ")], [Stable imports only; no algorithm or renderer implementation.],
  [Protocol], [#raw("src/protocol.typ")], [One versioned JSON request/response envelope over a single-export WASM ABI.],
  [Constraints], [#raw("src/constraints.typ")], [Hard, soft, and probing constraint constructors.],
  [Analysis], [#raw("src/analysis.typ")], [Typed wrappers, structure decomposition, and result-derived annotation helpers.],
  [Annotations], [#raw("src/annotations.typ")], [Themes, labels, colors, legends, base/pair/region metadata.],
  [Rendering], [#raw("src/render.typ")], [Scene transformation and native Typst primitives.],
  [Chart geometry], [#raw("src/chart.typ")], [Scientific and matrix axes, data-coordinate transforms, ticks, and categorical legends.],
  [Plots], [#raw("src/plots.typ")], [RNA-specific plot data, structure differences, dot plots, and mountain plots.],
  [Engine], [Rust/WASM], [Thermodynamics, dynamic programming, decoding, validation, and coordinates.],
)

Visible output is generated with Typst #raw("curve"), #raw("line"), #raw("circle"), #raw("polygon"), #raw("rect"), and #raw("text") primitives. No bitmap is embedded by the renderer.

== Supported capabilities

Ribon includes:

- six layouts: #raw("naview"), #raw("simple"), #raw("circular"), #raw("linear"), #raw("turtle"), and #raw("puzzler");
- extended dot-bracket validation, crossing pairs, strand breaks, and editable scene coordinates;
- MFE folding and energy evaluation;
- log-domain partition functions, base-pair and unpaired probabilities, centroid and MEA decoding;
- hard/soft constraints, SHAPE/DMS pseudo-energies, sampling, suboptimal enumeration, accessibility, and local analysis;
- duplex, cofold, circular RNA, comparative folding, modified bases, and G-quadruplex analysis;
- pseudoknot prediction/evaluation, conditional density-2 ensembles, exact fatgraph topology, exact landscapes, inverse design, and ligand microstates;
- continuous color tracks, motif annotations, structure comparison, probability dot plots, mountain plots, and composable multi-panel figures.

#note(
  [Exactness policy.],
  [An operation is never silently replaced by a smaller approximate state space. Inputs predicted to exceed document-time limits return a stable #raw("resource_limit") error unless the caller explicitly opts in.],
  color: rgb("#8a5a00"),
)

= Installation and first document

== Typst Universe

Once released, import the package by version:

#doc-code(raw("#import \"@preview/ribon:0.1.0\": *", lang: "typ", block: true))

The runtime consists of Typst source plus #raw("ribon_plugin.wasm"). It does not need a Python interpreter, native shared library, shell command, or network request while compiling a document.

== Smallest drawing

#example[
  ```typ
  #import "@preview/ribon:0.1.0": draw

  #draw(
    "GGGAAACCC",
    structure: "(((...)))",
    width: 8cm,
    height: 4.7cm,
  )
  ```
][
  #align(center, draw("GGGAAACCC", structure: "(((...)))", width: 80mm, height: 47mm))
]

Positions in every public API are one-based. Strand breaks are written as #raw("&") in both sequence and structure and do not consume a nucleotide index.

== Prediction to annotated figure

#example[
  ```typ
  #import "@preview/ribon:0.1.0": *

  #let result = analyze("GGGAAACCC")

  #render(
    result,
    which: "mea",
    method: "naview",
    width: 8cm,
    height: 4.7cm,
    theme: varna-theme,
    annotations: (
      highlight(4, 6),
      label-annotation(5, [hairpin], dx: 22pt, dy: -20pt),
    ),
  )
  ```
][
  #align(center, render(
    analyze("GGGAAACCC"),
    which: "mea",
    width: 80mm,
    height: 47mm,
    theme: varna-theme,
    annotations: (highlight(4, 6), label-annotation(5, [hairpin], dx: 22pt, dy: -20pt)),
  ))
]

The response retains the resolved model and constraints. Result-driven rendering therefore uses the same sequence, structure, probabilities, and execution metadata as the analysis call.

= Sequences and structures

== Sequence alphabet

The accepted sequence alphabet is #raw("ACGUTRYSWKMBDHVN"), case-insensitively. Whitespace is removed, while #raw("T") is preserved in public results and drawings and uses the #raw("U")-shaped thermodynamic lookup index. In built-in models, ambiguity symbols are valid placeholders but do not form base pairs. #raw("&") separates non-empty strands for structure validation and drawing; single-strand prediction operations reject strand separators. Modified-nucleotide calculations receive a canonical sequence plus explicit #raw("modified-base") descriptors.

#let dna-sequence-example = data(validate("a t g t", "...."))
#paired(
  "#let parsed = data(validate(\"a t g t\", \"....\"))

#table(
  columns: 2,
  [Sequence], [#raw(parsed.sequence)],
  [Length], [#parsed.length],
)" ,
  table(
    columns: 2,
    [Sequence], [#raw(dna-sequence-example.sequence)],
    [Length], [#dna-sequence-example.length],
  ),
)

== Extended dot-bracket notation

Parenthesis pairs describe the planar layer. Additional matching bracket alphabets describe crossing pairs. #raw("validate") returns a normalized structure, pair records, bracket levels, strand breaks, and sequence length.

#let parsed-example = data(validate("GCGCAAAAGCGC", "(([[..))..]]"))
#paired(
  "#let parsed = data(validate(
  \"GCGCAAAAGCGC\",
  \"(([[..))..]]\",
))

#table(
  columns: 2,
  [Structure], [#raw(parsed.structure)],
  [Base pairs], [#parsed.pairs.len()],
)" ,
  table(
    columns: 2,
    [Structure], [#raw(parsed-example.structure)],
    [Base pairs], [#parsed-example.pairs.len()],
  ),
)

#note(
  [Validation first.],
  [Call #raw("try-request") when parsing untrusted user input. It returns an error envelope instead of stopping document compilation.],
)

== Structure elements

#raw("structure-elements") derives stems and planar hairpin, bulge, internal, multiloop, and exterior elements. Crossing pairs remain in the parsed result; motif classification uses the well-defined planar layer.

#let elements-example = structure-elements(sequence, reference)
#let hairpin-example = elements-example.loops.find(it => it.kind == "hairpin")
#paired(
  "#let elements = structure-elements(sequence, reference)
#let hairpin = elements.loops.find(it => it.kind == \"hairpin\")

#draw(
  sequence,
  structure: reference,
  width: 12cm,
  height: 5cm,
  numbering: none,
  annotations: element-annotations(
    hairpin,
    fill: rgb(\"#ffe082\").transparentize(25%),
  ),
)" ,
  align(center, draw(
    sequence,
    structure: reference,
    width: 120mm,
    height: 50mm,
    numbering: none,
    annotations: element-annotations(
      hairpin-example,
      fill: rgb("#ffe082").transparentize(25%),
    ),
  )),
)

= Drawing and layouts

== Layout methods

#table(
  columns: (25mm, 1fr, 43mm),
  inset: 5pt,
  stroke: luma(84%) + 0.35pt,
  table.header([*Method*], [*Use*], [*Geometry*]),
  [#raw("naview")], [General secondary-structure diagrams and loop/stem balance.], [Loop-aware planar geometry.],
  [#raw("simple")], [RNAplot-like regular-bond radial layout.], [Deterministic radial geometry.],
  [#raw("circular")], [Crossing structures and global topology.], [Bases on a circle; chords show pairs.],
  [#raw("linear")], [Duplexes, strand interactions, and long sequences.], [Single strands use pair arcs; multiple strands use alternating antiparallel rows, interstrand rungs, and outward intramolecular arcs.],
  [#raw("turtle")], [Affine loop/stem construction.], [Loop-centered recursive geometry.],
  [#raw("puzzler")], [Crowded long structures.], [Collision-reduced loop layout.],
)

The layout methods expose distinct geometric models rather than cosmetic presets. #raw("naview") follows the modified radial formulation of Bruccoleri and Heinrich @bruccoleri1988; #raw("puzzler") follows the collision-aware outerplanar construction introduced with RNApuzzler @wiegreffe2019; and #raw("simple") follows the regular-bond radial convention used by RNAplot @lorenz2011.#footnote[ViennaRNA, “RNAplot command documentation,” #raw("https://viennarna.readthedocs.io/en/latest/man/RNAplot.html").]

#paired(
  "#grid(
  columns: (1fr, 1fr),
  gutter: 4mm,
  ..(\"naview\", \"simple\", \"circular\", \"linear\", \"turtle\", \"puzzler\").map(method =>
    figure(
      draw(
        \"GGGAAACCC\",
        structure: \"(((...)))\",
        method: method,
        width: 7.5cm,
        height: 3.9cm,
        numbering: none,
      ),
      caption: method,
    )
  ),
)" ,
  grid(
    columns: (1fr, 1fr),
    gutter: 4mm,
    ..("naview", "simple", "circular", "linear", "turtle", "puzzler").map(method =>
      panel(
        method,
        draw(
          "GGGAAACCC",
          structure: "(((...)))",
          method: method,
          width: 75mm,
          height: 39mm,
          numbering: none,
        ),
      )
    ),
  ),
)

== Geometry controls

#raw("draw"), #raw("render"), and #raw("render-scene") share figure controls:

#parameter("width", "10cm", [Target width.])
#parameter("height", "auto", [Optional target height.])
#parameter("fit", "\"contain\"", [Preserves the natural aspect ratio inside the target box.])
#parameter("rotation", "0deg", [Rotates coordinates before fitting.])
#parameter("mirror-x / mirror-y", "false", [Reflects coordinates before fitting.])
#parameter("clip", "false", [Clips geometry to the requested box when enabled.])
#parameter("detail", "auto", [Controls long-sequence level of detail.])
#parameter("node-radius", "5pt", [Nucleotide circle radius.])
#parameter("font-size", "6.8pt", [Nucleotide label size.])

#paired(
  "#draw(
  sequence,
  structure: reference,
  width: 12cm,
  height: 6cm,
  rotation: 24deg,
  mirror-x: true,
  fit: \"contain\",
)" ,
  align(center, draw(
    sequence,
    structure: reference,
    width: 120mm,
    height: 60mm,
    rotation: 24deg,
    mirror-x: true,
    fit: "contain",
  )),
)

== Numbering and direction

#raw("numbering-style") supports fixed intervals, explicit positions, per-strand numbering, first/last labels, size, and fill. The renderer measures labels and chooses outward anchors. Terminus and direction indicators use separate controls.

#paired(
  "#draw(
  \"GGGG&CCCC\",
  structure: \"((((&))))\",
  method: \"linear\",
  width: 12.5cm,
  height: 4.8cm,
  show-direction: true,
  numbering: numbering-style(every: 2, per-strand: true),
  annotations: (
    strand-label(1, [guide], dx: -20pt, dy: -14pt, leader: false),
    strand-label(2, [target], dx: 20pt, dy: 14pt, leader: false),
  ),
)" ,
  align(center, draw(
    "GGGG&CCCC",
    structure: "((((&))))",
    method: "linear",
    width: 125mm,
    height: 48mm,
    show-direction: true,
    numbering: numbering-style(every: 2, per-strand: true),
    annotations: (
      strand-label(1, [guide], dx: -20pt, dy: -14pt, leader: false),
      strand-label(2, [target], dx: 20pt, dy: 14pt, leader: false),
    ),
  )),
)

== Editable scenes

#raw("layout") returns normalized coordinates without drawing them. Modify #raw("points") and pass the dictionary or original response to #raw("render-scene").

#let edited-scene-example = data(layout(sequence, reference))
#let edited-points-example = edited-scene-example.points.enumerate().map(((i, point)) => {
  if i == 3 { (x: point.x - 0.15, y: point.y - 0.12) }
  else { point }
})
#edited-scene-example.insert("points", edited-points-example)
#paired(
  "#let scene = data(layout(sequence, reference))
#let moved = scene.points.enumerate().map(((i, point)) => {
  if i == 3 { (x: point.x - 0.15, y: point.y - 0.12) }
  else { point }
})
#scene.insert(\"points\", moved)

#render-scene(scene, width: 10cm, height: 5cm)" ,
  align(center, render-scene(edited-scene-example, width: 100mm, height: 50mm)),
)

= Themes and annotations

== Themes

#raw("default-theme") is restrained and print-oriented. #raw("varna-theme") adds a nucleotide palette informed by the visual conventions of VARNA @darty2009. A theme is a Typst dictionary, so project-specific overrides are ordinary dictionary addition.

#let journal-theme-example = default-theme + (
  pair-stroke: (paint: black, thickness: 0.8pt),
  node-fill: white,
  text-fill: black,
  node-text-contrast: "fixed",
)
#paired(
  "#let journal-theme = default-theme + (
  pair-stroke: (paint: black, thickness: 0.8pt),
  node-fill: white,
  text-fill: black,
  node-text-contrast: \"fixed\",
)

#draw(
  sequence,
  structure: reference,
  width: 12cm,
  height: 5cm,
  theme: journal-theme,
  numbering: none,
)" ,
  align(center, draw(
    sequence,
    structure: reference,
    width: 120mm,
    height: 50mm,
    theme: journal-theme-example,
    numbering: none,
  )),
)

== Annotation constructors

#table(
  columns: (44mm, 1fr),
  inset: 5pt,
  stroke: luma(84%) + 0.35pt,
  table.header([*Constructor*], [*Purpose*]),
  [#raw("highlight(from, to)")], [Background region for one contiguous range.],
  [#raw("highlight-positions(positions)")], [Background region for an arbitrary set.],
  [#raw("base-annotation(at)")], [Base fill, stroke, text color, and per-node WCAG contrast policy.],
  [#raw("pair-annotation(i, j)")], [Base-pair edge override.],
  [#raw("interaction-annotation(i, j)")], [Non-secondary interaction with bend and optional label.],
  [#raw("coaxial-annotation(...)")], [Coaxially stacked helices.],
  [#raw("label-annotation(at, body)")], [Measured free-form label with optional leader.],
  [#raw("strand-label(strand, body)")], [Start/end label for a strand.],
)

Labels are kept on one line by default. For a hand-finished figure, use #raw("dx") and #raw("dy") to set the label center relative to its nucleotide; #raw("leader-bend"), #raw("leader-stroke"), and the two leader-gap values adjust the connector independently. Set #raw("width") only when intentional wrapping is wanted, and use the #raw("box-*") values for a background or outline. Interaction labels use #raw("label-position") to move along the curve and #raw("label-dx")/#raw("label-dy") for the final offset. Strand labels expose the same placement controls as nucleotide labels.

Nucleotide text defaults to #raw("node-text-contrast: \"aa\""). For every solid node fill, the renderer computes WCAG 2.2 relative luminance and chooses black or white, whichever yields the larger contrast ratio; this guarantees the 4.5:1 threshold for small text. #raw("\"aaa\"") requires 7:1 and reports the nucleotide index, fill, and best achievable ratio when neither black nor white can satisfy it.#footnote[W3C, “WCAG 2.2 Success Criterion 1.4.3: Contrast (Minimum),” #raw("https://www.w3.org/TR/WCAG22/#contrast-minimum"). W3C, “Success Criterion 1.4.6: Contrast (Enhanced),” #raw("https://www.w3.org/TR/WCAG22/#contrast-enhanced"). W3C, “Understanding relative luminance,” #raw("https://www.w3.org/WAI/WCAG21/Understanding/relative-luminance.html"). W3C, “Guidance on Applying WCAG 2.2 to Non-Web Information and Communications Technologies,” #raw("https://www.w3.org/TR/wcag2ict-22/").] #raw("node-text-contrast: \"fixed\"") retains #raw("theme.text-fill"). A per-node #raw("text-contrast") overrides the global policy, while an explicit #raw("text-fill") has highest priority. Transparent fills require #raw("contrast-background") so the effective color can be computed; gradients and patterns require an explicit #raw("text-fill"). #raw("contrast-on-failure: \"best\"") is an explicit opt-out from strict AAA failure.

#paired(
  "#draw(
  sequence,
  structure: reference,
  width: 14.5cm,
  height: 6.1cm,
  theme: varna-theme,
  annotations: (
    highlight(4, 6, fill: rgb(\"#ffe082\").transparentize(25%)),
    base-annotation(13, fill: rgb(\"#313695\"), text-contrast: \"aaa\"),
    pair-annotation(10, 18, stroke: (paint: rgb(\"#d73027\"), thickness: 1.2pt)),
    label-annotation(5, [apical loop], dx: -34pt, dy: -22pt, leader-bend: 0.08),
    interaction-annotation(
      5,
      14,
      label: [tertiary contact],
      label-position: 0.62,
      label-dx: 12pt,
      label-dy: 14pt,
    ),
  ),
)" ,
  align(center, std.scale(
    90%,
    origin: center,
    draw(
      sequence,
      structure: reference,
      width: 145mm,
      height: 61mm,
      theme: varna-theme,
      annotations: (
        highlight(4, 6, fill: rgb("#ffe082").transparentize(25%)),
        base-annotation(13, fill: rgb("#313695"), text-contrast: "aaa"),
        pair-annotation(10, 18, stroke: (paint: rgb("#d73027"), thickness: 1.2pt)),
        label-annotation(5, [apical loop], dx: -34pt, dy: -22pt, leader-bend: 0.08),
        interaction-annotation(
          5,
          14,
          label: [tertiary contact],
          label-position: 0.62,
          label-dx: 12pt,
          label-dy: 14pt,
        ),
      ),
    ),
  )),
)

== Continuous values and legends

#raw("color-scale") defines one reusable numerical mapping. #raw("value-annotations") retains that scale with its base annotations, so #raw("draw") and #raw("render") generate an exact matching legend automatically. Pass #raw("legend: false") to the renderer to hide it or a #raw("legend-style") value to control placement and framing. #raw("color-legend") and #raw("with-legend") remain available for legends shared by several figures; suppress the local legend on each component drawing before composing the shared one. #raw("reactivity-annotations"), #raw("accessibility-annotations"), #raw("local-accessibility-annotations"), and #raw("entropy-annotations") create the same metadata-bearing tracks.

#paired(
  "#let scale = color-scale(
  minimum: 0,
  maximum: 1,
  label: [SHAPE reactivity],
)

#draw(
  sequence,
  structure: reference,
  width: 12.5cm,
  height: 5cm,
  annotations: value-annotations(
    values,
    scale: scale,
    legend: (width: 4.2cm),
  ),
  numbering: none,
  legend: legend-style(stroke: none),
)" ,
  align(center, draw(
    sequence,
    structure: reference,
    width: 125mm,
    height: 50mm,
    annotations: value-annotations(
      values,
      scale: scale,
      legend: (width: 42mm),
    ),
    numbering: none,
    legend: legend-style(stroke: none),
  )),
)

= Prediction and thermodynamic analysis

== Stable response envelope

Every engine call uses #raw("ribon.analysis/1"). Successful responses contain #raw("ok"), #raw("engine"), the resolved #raw("model"), resolved #raw("constraints"), execution metadata, and #raw("result.(kind, data)"). Use #raw("data(response)") to extract the typed payload.

#let response-example = data(analyze("GGGAAACCC"))
#paired(
  "#let response = analyze(\"GGGAAACCC\")
#let result = data(response)

#table(
  columns: 2,
  [MFE], [#raw(result.mfe_structure)],
  [Energy], [#calc.round(result.mfe_energy_kcal_mol, digits: 1) kcal/mol],
  [Centroid], [#raw(result.centroid_structure)],
  [MEA], [#raw(result.mea_structure)],
  [Pair records], [#result.pair_probabilities.len()],
)" ,
  table(
    columns: 2,
    [MFE], [#raw(response-example.mfe_structure)],
    [Energy], [#calc.round(response-example.mfe_energy_kcal_mol, digits: 1) kcal/mol],
    [Centroid], [#raw(response-example.centroid_structure)],
    [MEA], [#raw(response-example.mea_structure)],
    [Pair records], [#response-example.pair_probabilities.len()],
  ),
)

== Integrated analysis

#raw("analyze") combines thermodynamic dynamic programming for minimum-free-energy folding @zuker1981 with the equilibrium partition function and pair marginals @mccaskill1990. It then decodes the same probability matrix as a generalized centroid structure @hamada2009 and a maximum expected accuracy structure @lu2009, returning ensemble free energy and entropy summaries in the same request.

#paired(
  "#let decoder-sequence = \"GCGCCUUGAAAGUCCAGAGGACUUGGUUUUAUUGGGUAGUUGAGGUUGGUGGCCCAUCUC\"
#let result = analyze(decoder-sequence)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 3mm,
  ..((\"MFE\", \"mfe\"), (\"Centroid\", \"centroid\"), (\"MEA\", \"mea\")).map(((title, which)) => figure(
    render(
      result,
      which: which,
      width: 5.1cm,
      height: 4cm,
      node-radius: 1.8pt,
      font-size: 2.6pt,
      detail: \"full\",
      numbering: none,
      show-ends: false,
    ),
    caption: title,
  )),
)" ,
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 3mm,
    ..(("MFE", "mfe"), ("Centroid", "centroid"), ("MEA", "mea")).map(((title, which)) => panel(
      [#title],
      render(
        decoder-prediction,
        which: which,
        width: 51mm,
        height: 40mm,
        node-radius: 1.8pt,
        font-size: 2.6pt,
        detail: "full",
        numbering: none,
        show-ends: false,
      ),
    )),
  ),
)

== Thermodynamic models

#raw("analysis-model") constructs an immutable nearest-neighbor model descriptor. Temperature, minimum loop length, dangle treatment, monovalent salt concentration, and MEA gamma are explicit. The bundled families are generated from the RNAstructure 6.6 standard RNA and DNA tables documented by NNDB and RNAstructure @turner_mathews2010 @reuter_mathews2010. The RNA family follows the Turner 2004 lineage, including the revision described by Mathews et al. @mathews2004 and subsequent RNAstructure updates; #raw("dna-model") selects the distinct standard DNA family compiled by the Mathews group. Non-reference monovalent salt concentrations are available only for RNA and apply the loop, stack, multiloop, and duplex-initiation correction model of Yao et al. @yao2023. The DNA API exposes no salt parameter, and low-level DNA requests reject non-default #raw("salt_molar") values. #raw("custom-model") applies a normalized, fingerprinted table overlay to an RNA or DNA base family.#footnote[University of Rochester, “Nearest Neighbor Database,” #raw("https://rna2.urmc.rochester.edu/NNDB/"). University of Rochester, “Nearest Neighbor Database: Download,” #raw("https://rna2.urmc.rochester.edu/NNDB/download.html"). University of Rochester, “RNAstructure Version History,” #raw("https://rna.urmc.rochester.edu/Overview/Updates.html").]

#let physiological-example = analysis-model(
  temperature: 37,
  min-loop: 3,
  dangles: 2,
  salt: 0.15,
  mea-gamma: 1,
)
#let dna-example = dna-model(temperature: 25)
#paired(
  "#let physiological = analysis-model(
  temperature: 37,
  min-loop: 3,
  dangles: 2,
  salt: 0.15,
  mea-gamma: 1,
)

#let dna = dna-model(temperature: 25)

#table(
  columns: 3,
  [Model], [Temperature], [Salt handling],
  [#physiological.id], [#physiological.temperature_celsius °C], [#physiological.salt_molar M],
  [#dna.id], [#dna.temperature_celsius °C], [not applied],
)" ,
  table(
    columns: 3,
    [Model], [Temperature], [Salt handling],
    [#raw(physiological-example.id)], [#physiological-example.temperature_celsius °C], [#physiological-example.salt_molar M],
    [#raw(dna-example.id)], [#dna-example.temperature_celsius °C], [not applied],
  ),
)

Model provenance and table SHA-256 fingerprints are returned by #raw("parameters").

== Hard, soft, and probing constraints

Probing reactivities can be converted either to paired/stacked pseudo-energies using the SHAPE-directed model of Deigan et al. @deigan2009 or to probabilistic soft constraints using the mapping of Zarringhalam et al. @zarringhalam2012. Explicit hard constraints and direct per-position or per-pair energies remain available independently of either conversion.

#let constraint-example = folding-constraints(
  force-unpaired: (4, 5, 6),
  force-pairs: (constraint-pair(1, 9),),
  soft: soft-constraints(
    unpaired: (position-energy(5, -0.8),),
    pairs: (pair-energy(1, 9, -1.2),),
  ),
  probing: probing-data(
    (0.1, 0.2, 0.8, 0.9, 0.7, 0.2, 0.1, 0.1, 0.0),
    kind: "shape",
    method: "deigan",
  ),
)
#let constrained-example = analyze("GGGAAACCC", constraints: constraint-example)
#paired(
  "#let constraints = folding-constraints(
  force-unpaired: (4, 5, 6),
  force-pairs: (constraint-pair(1, 9),),
  soft: soft-constraints(
    unpaired: (position-energy(5, -0.8),),
    pairs: (pair-energy(1, 9, -1.2),),
  ),
  probing: probing-data(
    (0.1, 0.2, 0.8, 0.9, 0.7, 0.2, 0.1, 0.1, 0.0),
    kind: \"shape\",
    method: \"deigan\",
  ),
)

#render(
  analyze(\"GGGAAACCC\", constraints: constraints),
  width: 8cm,
  height: 4.7cm,
  numbering: none,
)" ,
  align(center, render(
    constrained-example,
    width: 80mm,
    height: 47mm,
    numbering: none,
  )),
)

The same constraint object can be passed to folding, partition, sampling, suboptimal, accessibility, and fixed-structure evaluation operations.

== Specialized ensemble operations

#table(
  columns: (37mm, 1fr),
  inset: 5pt,
  stroke: luma(84%) + 0.35pt,
  table.header([*Operation*], [*Purpose*]),
  [#raw("fold")], [MFE only.],
  [#raw("evaluate")], [Energy and decomposition for a supplied planar structure.],
  [#raw("sample")], [Reproducible stochastic backtracking with explicit seed.],
  [#raw("suboptimal")], [Deterministic k-best structures within an energy band.],
  [#raw("accessibility")], [Exact joint-unpaired probabilities and opening energies for requested windows.],
  [#raw("local")], [Sliding-window pair and accessibility probabilities.],
  [#raw("circular")], [Circular-RNA MFE and ensemble analysis.],
  [#raw("duplex")], [Connected intermolecular duplex ensemble without intramolecular pairs.],
  [#raw("cofold")], [Unrestricted two-strand ensemble and optional mass-action concentrations.],
)

Energy-band enumeration follows the complete suboptimal-folding formulation of Wuchty et al. @wuchty1999. Local pair probabilities follow the window-averaged ensemble construction of Bernhart et al. @bernhart2006local, while heterodimer partition functions and pair probabilities follow the cofold formulation of Bernhart et al. @bernhart2006cofold.

= Quantitative and comparative figures

Quantitative figures separate data, coordinate transforms, plot-area geometry, legend composition, and visual styling. This keeps values invariant while the figure is adapted to a page, column, panel grid, or shared legend.

== Structure comparison

#raw("structure-difference") returns shared, reference-only, and alternative-only pair arrays. #raw("compare-structures") displays all three classes on reference coordinates.

#paired(
  "#compare-structures(
  sequence,
  reference,
  alternative,
  width: 13cm,
  height: 5.3cm,
  numbering: none,
)" ,
  align(center, compare-structures(
    sequence,
    reference,
    alternative,
    width: 130mm,
    height: 53mm,
    numbering: none,
  )),
)

== Pair-probability dot plot

The plotted matrix contains McCaskill base-pair marginals @mccaskill1990. The upper triangle shows the primary ensemble. A second ensemble may be placed in the lower triangle. Without a comparison, the lower triangle marks pairs in a reference or inferred MFE structure.

#paired(
  "#dot-plot(
  sequence,
  probabilities: prediction,
  comparison: perturbed,
  width: 9.2cm,
  threshold: 0.005,
)" ,
  align(center, dot-plot(
    sequence,
    probabilities: prediction,
    comparison: perturbed,
    width: 92mm,
    threshold: 0.005,
  )),
)

== Mountain plot

#raw("mountain-plot") uses the mountain representation introduced by Hogeweg and Hesper @hogeweg1984. It draws the expected number of enclosing pairs at each position and can overlay discrete profiles from one or more supplied structures.
#raw("mountain-profile") returns those exact numerical series when they are needed for a table, assertion, or another visualization.

#paired(
  "#mountain-plot(
  sequence,
  probabilities: prediction,
  reference-structures: (
    (label: [Reference], structure: reference),
    (label: [Alternative], structure: alternative),
  ),
  width: 14.5cm,
  height: 4.8cm,
)" ,
  align(center, mountain-plot(
    sequence,
    probabilities: prediction,
    reference-structures: (
      (label: [Reference], structure: reference),
      (label: [Alternative], structure: alternative),
    ),
    width: 145mm,
    height: 48mm,
  )),
)

== Axes and plot-area geometry

#raw("axis-style") independently configures each axis. Domains may ascend or descend; transforms may be linear or logarithmic; major and minor ticks may be generated from a step or supplied as values and labels. Formatters accept a function or the built-in #raw("\"scientific\"") formatter. Grid visibility, line visibility, tick visibility, and axis labels are independent.

#raw("plot-layout") controls the data viewport rather than its data. It accepts automatic, uniform, or per-side padding, an optional width-to-height aspect ratio, a closed frame or independent axis lines, and clipping at the viewport boundary.

#paired(
  "#mountain-plot(
  sequence,
  probabilities: prediction,
  width: 14.5cm,
  height: 4.8cm,
  x-axis: axis-style(
    domain: (1, 18),
    tick-step: 5,
    minor-tick-step: 1,
    grid: \"both\",
  ),
  y-axis: axis-style(domain: (0, 6), tick-step: 1),
  layout: plot-layout(aspect: 2.2),
)" ,
  align(center, mountain-plot(
    sequence,
    probabilities: prediction,
    width: 145mm,
    height: 48mm,
    x-axis: axis-style(
      domain: (1, 18),
      tick-step: 5,
      minor-tick-step: 1,
      grid: "both",
    ),
    y-axis: axis-style(domain: (0, 6), tick-step: 1),
    layout: plot-layout(aspect: 2.2),
  )),
)

A descending domain reverses an axis. #raw("mode: \"log\"") selects a positive logarithmic domain. #raw("mountain-plot") also accepts #raw("x2-axis") and #raw("y2-axis"); each supplied reference series can select a pair through #raw("axes: (\"x\", \"y2\")"). The expected series uses #raw("expected-axes").

== Legend layout and sharing

#raw("legend-style") places a legend on #raw("top"), #raw("bottom"), #raw("left"), or #raw("right"); at any of nine #raw("inner-*") anchors; or at an explicit #raw("(x, y)") ratio inside the data viewport. #raw("anchor") and #raw("offset") refine placement. #raw("direction"), #raw("columns"), #raw("max-columns"), #raw("width"), and spacing fields control flow without changing plot geometry.

#paired(
  "#mountain-plot(
  sequence,
  probabilities: prediction,
  width: 14.5cm,
  height: 4.8cm,
  legend: legend-style(
    position: \"inner-north-east\",
    direction: \"column\",
    offset: (-3pt, 3pt),
  ),
)" ,
  align(center, mountain-plot(
    sequence,
    probabilities: prediction,
    width: 145mm,
    height: 48mm,
    legend: legend-style(
      position: "inner-north-east",
      direction: "column",
      offset: (-3pt, 3pt),
    ),
  )),
)

The #raw("legend") argument accepts #raw("true"), #raw("false"), or a #raw("legend-style") dictionary. #raw("plot-legend") creates a standalone categorical legend; #raw("place-legend") composes it around multiple plots. #raw("legend-panel") accepts arbitrary Typst content for a custom shared legend.

#pagebreak()

#paired(
  "#place-legend(
  grid(
    columns: (1fr, 1fr),
    mountain-plot(sequence, probabilities: prediction, width: 6.8cm, height: 3.2cm, legend: false),
    mountain-plot(sequence, probabilities: perturbed, width: 6.8cm, height: 3.2cm, legend: false),
  ),
  plot-legend((
    legend-item([Control], stroke: blue + 1pt),
    legend-item([Perturbed], stroke: red + 1pt),
  )),
  style: legend-style(position: \"bottom\", columns: 2),
)" ,
  align(center, place-legend(
    grid(
      columns: (1fr, 1fr),
      mountain-plot(sequence, probabilities: prediction, width: 68mm, height: 32mm, legend: false),
      mountain-plot(sequence, probabilities: perturbed, width: 68mm, height: 32mm, legend: false),
    ),
    plot-legend((
      legend-item([Control], stroke: blue + 1pt),
      legend-item([Perturbed], stroke: red + 1pt),
    )),
    style: legend-style(position: "bottom", columns: 2),
  )),
)

The visual theme remains independent of both geometry and placement:

#let quantitative-example = plot-theme(legend-fill: luma(98%))
#paired(
  "#let quantitative = plot-theme(legend-fill: luma(98%))

#mountain-plot(
  sequence,
  probabilities: prediction,
  width: 14.5cm,
  height: 4.8cm,
  theme: quantitative,
)" ,
  align(center, mountain-plot(
    sequence,
    probabilities: prediction,
    width: 145mm,
    height: 48mm,
    theme: quantitative-example,
  )),
)

== Composing alternatives

Ribon returns each decoder, sample, and suboptimal structure through #raw("render"). Use ordinary Typst layout primitives when several results belong in one figure.

#paired(
  "#let decoder-sequence = \"GCGCCUUGAAAGUCCAGAGGACUUGGUUUUAUUGGGUAGUUGAGGUUGGUGGCCCAUCUC\"
#let decoder-prediction = analyze(decoder-sequence)

#grid(
  columns: 3,
  gutter: 3mm,
  ..(\"mfe\", \"centroid\", \"mea\").map(which => render(
    decoder-prediction,
    which: which,
    width: 4.9cm,
    height: 3.7cm,
    node-radius: 1.8pt,
    font-size: 2.6pt,
    detail: \"full\",
    numbering: none,
    show-ends: false,
  )),
)" ,
  align(center, grid(
    columns: 3,
    gutter: 3mm,
    ..("mfe", "centroid", "mea").map(which => render(
      decoder-prediction,
      which: which,
      width: 49mm,
      height: 37mm,
      node-radius: 1.8pt,
      font-size: 2.6pt,
      detail: "full",
      numbering: none,
      show-ends: false,
    )),
  )),
)

= Advanced analyses

Advanced operations use the same response envelope and renderer connection as the core folding API.

#table(
  columns: (42mm, 1fr),
  inset: 5pt,
  stroke: luma(84%) + 0.35pt,
  table.header([*Operation*], [*Result and use*]),
  [#raw("modified")], [Measured nearest-neighbor terms for m6A @kierzek2022, pseudouridine @hudson2013, inosine @wright2018, 7-deaza-adenosine @richardson2016, and purine/nebularine @jolley2017; plus the model-based dihydrouridine stack penalty motivated by conformational measurements @dalluge1996 and the sparse-parameter framework @varenyk2023.],
  [#raw("gquad")], [Integrated secondary-structure/G-quadruplex ensemble following the 2D-meets-4G model @lorenz2013gquad.],
  [#raw("comparative")], [Gap-aware aligned-sequence folding with covariation pseudo-energies @hofacker2002.],
  [#raw("pseudoknot")], [Probability-directed ProbKnot decoding @bellaousov2010, restricted H-type components, Hungarian-method matching decoders @kuhn1955, and opt-in arbitrary matching.],
  [#raw("conditional-density2")], [Fixed-seed density-2 ensembles based on hierarchical folding @jabbari2008, DP09 energies @andronescu2010, and the CParty conditional decomposition @gray2025.],
  [#raw("fatgraph-topology")], [Orientable genus, boundary components, Euler characteristic, and crossing components under the fatgraph classification @bon2008.],
  [#raw("landscape")], [Globally minimum-saddle path over the complete planar structure graph using minimax Dijkstra search @dijkstra1959.],
  [#raw("inverse-design")], [Exhaustive IUPAC-template design ranked by exact target ensemble probability.],
  [#raw("ligand")], [Joint structure/ligand microstate ensemble with concentration-dependent chemical potential.],
)

== Pseudoknot rendering

Extended dot-bracket structures can be drawn directly. Crossing-component annotations from #raw("fatgraph-topology") give each interacting component a consistent edge color.

#paired(
  "#draw(
  \"GCGCAAAAGCGC\",
  structure: \"(([[..))..]]\",
  method: \"circular\",
  width: 9cm,
  height: 6.8cm,
  theme: varna-theme,
  annotations: (
    label-annotation(5, [crossing pairs], dx: 31pt, dy: -16pt, leader-bend: -0.08),
  ),
)" ,
  align(center, draw(
    "GCGCAAAAGCGC",
    structure: "(([[..))..]]",
    method: "circular",
    width: 90mm,
    height: 68mm,
    theme: varna-theme,
    annotations: (
      label-annotation(5, [crossing pairs], dx: 31pt, dy: -16pt, leader-bend: -0.08),
    ),
  )),
)

== Computational scope

#raw("landscape"), #raw("inverse-design"), arbitrary matching, and some nonlocal dangle variants have intrinsically exponential state spaces. The default execution policy guards document compilation. Opt in only after bounding the input:

#let landscape-example = data(landscape(
  "GGGAAACCC",
  ".........",
  "(((...)))",
  execution: execution-policy(allow-expensive: true),
))
#paired(
  "#let exact = execution-policy(allow-expensive: true)

#let result = data(landscape(
  \"GGGAAACCC\",
  \".........\",
  \"(((...)))\",
  execution: exact,
))

#table(
  columns: 2,
  [Complete states], [#result.state_count],
  [Path steps], [#result.path.len()],
  [Saddle energy], [#result.saddle_energy_kcal_mol kcal/mol],
)" ,
  table(
    columns: 2,
    [Complete states], [#landscape-example.state_count],
    [Path steps], [#landscape-example.path.len()],
    [Saddle energy], [#landscape-example.saddle_energy_kcal_mol kcal/mol],
  ),
)

= API reference: protocol and models

#api(
  "execution-policy",
  "execution-policy(allow-expensive: false)",
  [Constructs document-time resource policy. The default returns #raw("resource_limit") for guarded requests.],
)

#api(
  "analysis-model",
  "analysis-model(id: \"ribon-rnastructure-6.6-rna\", temperature: 37.0, min-loop: 3, dangles: 2, salt: 1.021, mea-gamma: 1.0)",
  [Constructs the RNA model descriptor shared across operations.],
)

#api(
  "dna-model",
  "dna-model(temperature: 37.0, min-loop: 3, dangles: 2, mea-gamma: 1.0)",
  [Constructs the RNAstructure 6.6 standard DNA model descriptor. Thymine remains #raw("T") in results and drawings; no additional monovalent-salt correction is applied.],
)

#api(
  "thermodynamic-parameter-overrides",
  "thermodynamic-parameter-overrides(name, fingerprint-sha256, tables: (:))",
  [Builds a normalized custom-table overlay. Omitted tables inherit the selected base family.],
)

#api(
  "custom-model",
  "custom-model(parameter-overrides, base: \"rna\", temperature: 37.0, min-loop: 3, dangles: 2, salt: 1.021, mea-gamma: 1.0)",
  [Constructs a model backed by a validated overlay.],
)

#api(
  "try-request",
  "try-request(operation, input, model: analysis-model(), constraints: none, options: (:), execution: execution-policy(), id: none)",
  [Runs one raw protocol operation and always returns an envelope. Inspect #raw("ok") and #raw("error.(code, message)") for invalid input.],
)

#api(
  "request",
  "request(operation, input, model: analysis-model(), constraints: none, options: (:), execution: execution-policy(), id: none)",
  [Runs one raw protocol operation and panics with a stable error code when the response is unsuccessful.],
)

#api(
  "data",
  "data(response)",
  [Validates a successful #raw("analysis/1") response and extracts #raw("result.data").],
)

= API reference: constraints

#api("constraint-pair", "constraint-pair(i, j)", [Creates a one-based pair entry for hard constraints.])
#api("position-energy", "position-energy(position, energy)", [Creates a position-specific pseudo-energy in kcal/mol.])
#api("pair-energy", "pair-energy(i, j, energy)", [Creates a pair-specific pseudo-energy in kcal/mol.])
#api(
  "soft-constraints",
  "soft-constraints(unpaired: (), paired: (), pairs: (), stack: ())",
  [Builds generic unpaired, paired, pair, and stack energy terms.],
)
#api(
  "probing-data",
  "probing-data(reactivities, kind: \"shape\", method: \"deigan\", slope: 1.8, intercept: -0.6, beta: 0.89, conversion: \"O\", default-probability: 0.5)",
  [Builds SHAPE or DMS input. Null and negative values are treated as missing.],
)
#api(
  "folding-constraints",
  "folding-constraints(force-unpaired: (), force-paired: (), force-pairs: (), forbid-pairs: (), max-span: none, no-gu: false, no-lonely-pairs: false, soft: soft-constraints(), probing: none)",
  [Builds the common hard/soft/probing constraint dictionary.],
)

= API reference: core analysis

#api("capabilities", "capabilities()", [Returns supported operations, layouts, and decoders.])
#api("parameters", "parameters()", [Returns parameter metadata and SHA-256 fingerprints.])
#api("validate", "validate(sequence, structure, execution: execution-policy(), id: none)", [Parses and validates extended dot-bracket notation.])
#api("analyze", "analyze(sequence, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Runs integrated MFE, partition, probability, centroid, MEA, and ensemble analysis.])
#api("fold", "fold(sequence, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Predicts only the MFE structure.])
#api("evaluate", "evaluate(sequence, structure, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Evaluates a supplied planar structure.])
#api("sample", "sample(sequence, count: 100, seed: 0, unique: false, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Performs reproducible stochastic backtracking.])
#api("suboptimal", "suboptimal(sequence, energy-band: 5.0, limit: 100, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Returns deterministic k-best structures within an energy band.])
#api("accessibility-window", "accessibility-window(from, to)", [Constructs a one-based inclusive accessibility interval.])
#api("accessibility", "accessibility(sequence, windows, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Computes joint-unpaired probabilities and opening energies.])
#api("local", "local(sequence, window-size: 150, max-pair-span: 100, max-unpaired: 30, model: analysis-model(), execution: execution-policy(), id: none)", [Computes sliding-window pair and accessibility probabilities.])
#api("circular", "circular(sequence, model: analysis-model(dangles: 0), constraints: none, execution: execution-policy(), id: none)", [Analyzes a circular RNA ensemble.])
#api("duplex", "duplex(sequence-a, sequence-b, model: analysis-model(), execution: execution-policy(), id: none)", [Computes the connected intermolecular duplex ensemble.])
#api("cofold", "cofold(sequence-a, sequence-b, concentration-a: none, concentration-b: none, model: analysis-model(), execution: execution-policy(), id: none)", [Computes the unrestricted two-strand ensemble and optional mass-action solution.])

= API reference: advanced analysis

#api("modified-base", "modified-base(position, symbol, canonical-base, kind: none, paired-energy: 0.0, unpaired-energy: 0.0, stack-energy: 0.0)", [Describes one modified nucleotide and optional calibrated family.])
#api("modified", "modified(sequence, modifications, model: analysis-model(), execution: execution-policy(), id: none)", [Analyzes a canonical sequence with position-specific modification effects.])
#api("gquad", "gquad(sequence, model: analysis-model(), execution: execution-policy(), id: none)", [Analyzes the integrated G-quadruplex/secondary-structure ensemble.])
#api("comparative-options", "comparative-options(covariance-weight: 1.0, incompatible-penalty: 1.0, minimum-pair-occupancy: 0.5)", [Configures alignment covariation scoring.])
#api("comparative", "comparative(alignment, options: comparative-options(), model: analysis-model(), execution: execution-policy(), id: none)", [Folds a gap-aware alignment.])
#api("pseudoknot-options", "pseudoknot-options(threshold: 0.0, iterations: 1, min-helix: 3, gamma: 1.0, initiation: -1.38, crossing: 2.46, unpaired: 0.06, evidence-weight: 0.0, max-components: none, max-ensemble-states: none, exact-arbitrary-ensemble: false)", [Configures pseudoknot decoding and ensemble scope.])
#api("pseudoknot", "pseudoknot(sequence, options: pseudoknot-options(), model: analysis-model(), execution: execution-policy(), id: none)", [Predicts crossing pairs as extended dot-bracket notation.])
#api("evaluate-pseudoknot", "evaluate-pseudoknot(sequence, structure, options: pseudoknot-options(), model: analysis-model(), execution: execution-policy(), id: none)", [Evaluates a supplied extended-dot-bracket matching.])
#api("conditional-density2-options", "conditional-density2-options(gamma: 1.0, pk-only: false, ..energy-coefficients)", [Constructs fixed-seed density-2 coefficients. See the source signature for all explicit DP09 terms.])
#api("conditional-density2", "conditional-density2(sequence, structure, options: conditional-density2-options(), model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Computes the complete fixed-seed density-2 ensemble.])
#api("conditional-density2-sample", "conditional-density2-sample(sequence, structure, count: 100, seed: 0, unique: false, options: conditional-density2-options(), model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Samples exact Boltzmann structures from the fixed-seed ensemble.])
#api("conditional-density2-suboptimal", "conditional-density2-suboptimal(sequence, structure, energy-band: 5.0, limit: 100, options: conditional-density2-options(), model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Returns the lowest-energy fixed-seed extensions.])
#api("evaluate-conditional-density2", "evaluate-conditional-density2(sequence, seed-structure, added-structure, options: conditional-density2-options(), model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Evaluates an explicit pair of planar layers.])
#api("fatgraph-topology", "fatgraph-topology(sequence, structure, execution: execution-policy(), id: none)", [Computes exact orientable fatgraph invariants and crossing components.])
#api("landscape", "landscape(sequence, start-structure, target-structure, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Computes the globally minimum-saddle path over the planar structure graph.])
#api("inverse-design", "inverse-design(target-structure, template: none, minimum-gc-fraction: 0.0, maximum-gc-fraction: 1.0, return-count: 10, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Exhaustively designs compatible sequences from an IUPAC template.])
#api("ligand-motif", "ligand-motif(id, start, sequence, structure, standard-binding-energy, concentration: 1.0)", [Defines a concentration-dependent ligand-bound motif.])
#api("ligand", "ligand(sequence, motifs, model: analysis-model(), constraints: none, execution: execution-policy(), id: none)", [Computes the joint structure/ligand microstate ensemble.])

= API reference: structure and rendering

#api("structure-elements", "structure-elements(sequence, structure, execution: execution-policy())", [Identifies planar stems, loop motifs, and exterior segments.])
#api("element-annotations", "element-annotations(element, fill: auto, stroke: auto, radius: auto, pair-stroke: auto)", [Converts a structure element to renderer layers.])
#api("layout", "layout(sequence, structure, method: \"naview\", execution: execution-policy(), id: none)", [Returns normalized scene geometry without rendering.])
#api("draw", "draw(sequence, structure: auto, model: analysis-model(), constraints: none, method: \"naview\", execution: execution-policy(), ..render-arguments)", [Draws a supplied structure or predicts and draws the MFE when #raw("structure") is #raw("auto"). Metadata-bearing annotation tracks generate their legends automatically; pass #raw("legend: false") or a #raw("legend-style") through the render arguments.])
#api("render-scene", "render-scene(scene, ..render-arguments)", [Renders layout geometry, including user-edited coordinates and automatic annotation-track legends.])
#api("render", "render(response, which: \"mfe\", item: 1, method: \"naview\", width: 10cm, height: auto, node-radius: 5pt, font-size: 6.8pt, theme: default-theme, node-text-contrast: auto, node-contrast-background: auto, node-contrast-on-failure: auto, annotations: (), legend: auto, legend-theme: plot-theme(), probabilities: auto, fit: \"contain\", rotation: 0deg, mirror-x: false, mirror-y: false, clip: false, detail: auto, label-padding: auto, numbering: 10, start-number: 1, show-ends: true, show-direction: false, show-backbone: true, show-pairs: true, show-nucleotides: true)", [Renders a supported protocol response as native Typst vectors. Annotation-track legends are generated automatically; #raw("legend") accepts #raw("auto"), a Boolean, or #raw("legend-style"). Node contrast arguments override the corresponding theme values.])
= API reference: annotations and plots

#api("highlight", "highlight(from, to, fill: auto, stroke: auto, radius: auto)", [Builds a contiguous region annotation.])
#api("highlight-positions", "highlight-positions(positions, fill: auto, stroke: auto, radius: auto)", [Builds an arbitrary-position region annotation.])
#api("base-annotation", "base-annotation(at, fill: auto, stroke: auto, text-fill: auto, text-contrast: auto, contrast-background: auto, contrast-on-failure: auto)", [Overrides one nucleotide. #raw("text-fill") takes precedence over the per-node #raw("text-contrast") policy; transparent fills can name the opaque color behind the node.])
#api("pair-annotation", "pair-annotation(i, j, stroke: auto)", [Overrides one pair edge.])
#api("interaction-annotation", "interaction-annotation(i, j, stroke: auto, bend: 0.18, label: none, label-position: 0.5, label-dx: 0pt, label-dy: 0pt, label-fill: auto, label-size: auto, label-width: auto, label-align: center, label-box-fill: auto, label-box-stroke: none, label-box-inset: 1pt, label-box-radius: 1pt)", [Adds a non-secondary interaction. The label can be moved along the curve and offset independently.])
#api("coaxial-annotation", "coaxial-annotation(first-i, first-j, second-i, second-j, stroke: auto)", [Marks adjacent helices as coaxially stacked.])
#api("coaxial-annotations", "coaxial-annotations(result, stroke: auto)", [Converts selected coaxial stacks in an energy result to annotations.])
#pagebreak()
#api("label-annotation", "label-annotation(at, body, dx: auto, dy: auto, anchor: \"auto\", distance: 13pt, leader: true, leader-stroke: auto, leader-bend: 0.0, leader-start-gap: 1pt, leader-end-gap: 1pt, fill: auto, size: auto, width: auto, text-align: left, box-fill: none, box-stroke: none, box-inset: 0pt, box-radius: 0pt)", [Attaches a measured free-form label to a nucleotide. Offsets, leader geometry, wrapping width, and label box styling are independently adjustable.])
#api("strand-label", "strand-label(strand, body, at: \"start\", dx: auto, dy: auto, anchor: \"auto\", distance: 13pt, leader: true, leader-stroke: auto, leader-bend: 0.0, leader-start-gap: 1pt, leader-end-gap: 1pt, fill: auto, size: auto, width: auto, text-align: left, box-fill: none, box-stroke: none, box-inset: 0pt, box-radius: 0pt)", [Labels either end of one strand with the same placement controls as a nucleotide label.])
#api("numbering-style", "numbering-style(every: 10, positions: (), per-strand: false, show-first: false, show-last: false, size: 5.3pt, fill: auto)", [Configures nucleotide numbering.])
#api("color-scale", "color-scale(minimum: 0.0, maximum: 1.0, colors: (...), missing: luma(88%), label: none)", [Defines a continuous value-to-color mapping.])
#api("wcag-contrast-ratio", "wcag-contrast-ratio(foreground, background, background-behind: auto)", [Returns the WCAG 2.2 sRGB contrast ratio. Foreground and effective background must be opaque solid colors.])
#api("wcag-text-fill", "wcag-text-fill(background, level: \"aa\", background-behind: auto, on-failure: \"error\")", [Chooses black or white for maximum WCAG contrast. AA requires 4.5:1; AAA requires 7:1 and fails unless #raw("on-failure: \"best\"") is explicitly selected.])
#api("value-annotations", "value-annotations(values, scale: color-scale(), positions: auto, legend: auto)", [Converts values to a metadata-bearing annotation track. #raw("legend") may disable the metadata or provide #raw("width"), #raw("height"), #raw("ticks"), #raw("text-size"), #raw("orientation"), #raw("reverse"), and #raw("format") options.])
#api("color-legend", "color-legend(scale, width: 3.2cm, height: 6pt, ticks: 3, text-size: auto, orientation: \"horizontal\", reverse: false, format: auto, theme: plot-theme(), inset: auto, fill: auto, stroke: auto, radius: auto)", [Draws the exact scale legend horizontally or vertically. A formatter function receives each numerical tick value. Panel geometry and paint can inherit from the theme or be overridden directly; for example, #raw("stroke: none") removes the legend frame.])
#api("with-legend", "with-legend(body, legend, position: \"bottom\", gutter: 6pt, style: auto)", [Composes a manually constructed or shared legend without rasterization. #raw("style") accepts the complete #raw("legend-style") placement model; component drawings with metadata-bearing tracks should use #raw("legend: false").])
#api("reactivity-annotations", "reactivity-annotations(values, low: 0.0, high: 1.0, missing-fill: luma(88%), scale: auto, legend: auto)", [Converts probing values to a metadata-bearing color track.])
#api("accessibility-annotations", "accessibility-annotations(result, window-length: 1, scale: auto, legend: auto)", [Converts accessibility results to a metadata-bearing color track.])
#api("local-accessibility-annotations", "local-accessibility-annotations(result, window-length: 1, scale: auto, legend: auto)", [Converts local accessibility data to a metadata-bearing color track.])
#api("entropy-annotations", "entropy-annotations(result, high: auto, missing-fill: luma(88%), scale: auto, legend: auto)", [Converts positional entropy to a metadata-bearing color track.])
#api("ensemble-defect", "ensemble-defect(sequence, target, result)", [Computes normalized nucleotide ensemble defect from an existing analysis result.])
#api("topology-annotations", "topology-annotations(topology, palette: (...), thickness: 1.15pt)", [Colors crossing components from a fatgraph topology result.])
#api("plot-theme", "plot-theme(text-size: 6.5pt, label-size: 7pt, text-fill: ..., label-fill: ..., grid-stroke: ..., minor-grid-stroke: ..., frame-stroke: ..., tick-stroke: ..., minor-tick-stroke: ..., background: none, legend-fill: white, legend-stroke: ..., legend-radius: 2pt)", [Defines independent visual properties for plot frames, grids, ticks, text, backgrounds, and legend panels.])
#api("axis-style", "axis-style(domain: auto, ticks: auto, tick-step: auto, minor-ticks: none, minor-tick-step: none, tick-count: 5, format: auto, label: auto, mode: \"linear\", base: 10, grid: \"major\", show-line: true, show-ticks: true, show-labels: true)", [Configures one ascending or descending linear/logarithmic axis. Tick entries may be numbers or #raw("(value, label)") pairs; #raw("format") accepts #raw("auto"), #raw("none"), #raw("\"scientific\"") or a function.])
#api("plot-layout", "plot-layout(padding: auto, aspect: auto, frame: true, clip: true)", [Configures data-viewport padding, width-to-height aspect, frame composition, and clipping.])
#api("legend-style", "legend-style(position: \"bottom\", anchor: auto, offset: (0pt, 0pt), direction: \"row\", columns: auto, max-columns: auto, gutter: 6pt, item-gap: auto, row-gap: 3pt, width: auto, inset: auto, fill: auto, stroke: auto, radius: auto)", [Configures four outer sides, nine inner anchors, an explicit #raw("(x, y)") viewport ratio, or #raw("none"), together with flow and panel styling.])
#api("legend-panel", "legend-panel(body, style: legend-style(), theme: plot-theme())", [Wraps arbitrary Typst content in a measured legend panel.])
#api("legend-item", "legend-item(label, kind: \"line\", stroke: ..., fill: black, radius: 2.6pt, preview: none)", [Constructs a line, circle, square, or custom-content entry for #raw("plot-legend").])
#api("plot-legend", "plot-legend(items, style: legend-style(), theme: plot-theme())", [Builds a standalone categorical legend with explicit columns and row/column flow.])
#api("place-legend", "place-legend(body, legend, style: legend-style())", [Places a standalone legend around or over arbitrary composed content.])
#api("structure-difference", "structure-difference(sequence, reference, alternative, execution: execution-policy())", [Classifies shared and unique pairs.])
#api("compare-structures", "compare-structures(sequence, reference, alternative, method: \"naview\", common-color: ..., reference-color: ..., alternative-color: ..., legend: true, legend-position: \"bottom\", legend-theme: plot-theme(), execution: execution-policy(), ..render-arguments)", [Overlays two pair sets on reference coordinates. #raw("legend") accepts a Boolean or #raw("legend-style").])
#api("dot-plot", "dot-plot(sequence, probabilities: auto, comparison: none, reference-structure: auto, width: 8cm, height: auto, threshold: 0.01, model: analysis-model(), constraints: none, execution: execution-policy(), scale: color-scale(colors: (rgb(\"#dbe9f6\"), rgb(\"#315eaa\")), label: [Pair probability]), comparison-scale: color-scale(colors: (rgb(\"#fee8c8\"), rgb(\"#d7301f\")), label: [Comparison probability]), legend: true, legend-position: \"bottom\", x-label: ..., y-label: ..., x-axis: axis-style(), y-axis: axis-style(), layout: plot-layout(), theme: plot-theme(), grid-stroke: auto, frame-stroke: auto)", [Draws pair probabilities in an exact square data viewport and optionally compares two ensembles. Axes, viewport, and legend placement are independent.])
#api("mountain-profile", "mountain-profile(sequence, probabilities: auto, reference-structures: auto, model: analysis-model(), constraints: none, execution: execution-policy())", [Returns the expected and discrete mountain values used for drawing.])
#api("mountain-plot", "mountain-plot(sequence, probabilities: auto, reference-structures: auto, width: 10cm, height: 3.8cm, model: analysis-model(), constraints: none, execution: execution-policy(), stroke: ..., reference-strokes: (...), y-ticks: 4, legend: true, legend-position: \"bottom\", x-label: ..., y-label: ..., expected-axes: (\"x\", \"y\"), x-axis: axis-style(), y-axis: axis-style(), x2-axis: none, y2-axis: none, layout: plot-layout(), theme: plot-theme())", [Draws expected and discrete mountain profiles. Reference dictionaries select primary or secondary axes through #raw("axes").])

= Errors, reproducibility, and performance

== Error handling

#raw("request") panics with a stable error code and message. #raw("try-request") returns the same information as data:

#let error-example = try-request(
  "validate",
  (sequence: "GGG", structure: "((."),
)
#paired(
  "#let response = try-request(
  \"validate\",
  (sequence: \"GGG\", structure: \"((.\"),
)

#if not response.ok {
  [#response.error.code: #response.error.message]
}" ,
  [#error-example.error.code: #error-example.error.message],
)

Common categories include invalid input, unsupported options, constraint conflicts, and resource limits. Do not parse prose to branch on failures; use #raw("error.code").

== Determinism

Layouts and deterministic decoders are stable for the same package version and input. Sampling is reproducible when #raw("seed") is fixed. Model and parameter fingerprints are included in responses. For archival work, record the package version, model dictionary, constraints, operation options, and input sequence/structure.

== Performance guidance

- Prefer one #raw("analyze") call when MFE, probabilities, centroid, and MEA are all needed.
- Reuse its response for rendering and plots.
- Use #raw("fold") when only an MFE structure is needed.
- Use local analysis for long targets when a global ensemble is not scientifically required.
- Keep #raw("allow-expensive") local to a deliberately bounded call.
- For long figures, leave #raw("detail: auto") enabled unless every nucleotide label is essential.

= Validation and reproducible export checklist

The release validation suite includes 24 diverse families selected from Rfam @kalvari2021 and 24 published pseudoknot records. It checks numerical invariants, external reference values, six structure layouts, all result-to-render paths, every inner and outer legend anchor, explicit legend coordinates, linear/logarithmic/reversed/secondary axes, vector-only PDFs, clipping and blank pages, semantic metadata, and pixel-exact golden images.

Before submitting a figure:

- state package version and thermodynamic model in methods or supplementary material;
- report temperature, salt, dangle model, constraints, and probing conversion;
- use a legend for every continuous annotation scale;
- distinguish predicted, comparative, and experimentally constrained structures;
- inspect label collisions after the final page size is chosen;
- retain vector PDF/SVG output instead of taking a screenshot;
- record seeds for sampled structures;
- avoid implying that a pseudoknot decoder and a full thermodynamic ensemble are interchangeable.

Repository validation details are maintained in #raw("docs/VALIDATION.md"). The model and recurrence boundary is documented in #raw("docs/MODEL.md").

= License, provenance, and citation

Ribon is distributed under #raw("GPL-2.0-only"). The bundled standard RNA and DNA parameter families @turner_mathews2010 @reuter_mathews2010 are generated from the official RNAstructure 6.6 distribution.#footnote[University of Rochester, “RNAstructure,” #raw("https://rna2.urmc.rochester.edu/RNAstructure.html"). The reference Bioconda archive and normalized table-bundle hashes are recorded in the package #raw("NOTICE.md").]

When citing Ribon, cite the archived release of the package and the specific thermodynamic, layout, probing, decoding, or pseudoknot model used in the reported analysis. The bibliography below is maintained in #raw("docs/references.bib"). Web-only standards and source archives are cited in footnotes at the claims they support.

#{
  set text(size: 9pt)
  bibliography("references.bib", style: "plos", title: [References])
}
