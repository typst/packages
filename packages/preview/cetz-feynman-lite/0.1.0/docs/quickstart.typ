#set document(title: "CeTZ Feynman Lite: User Guide and API Reference", author: "Zhou Rui")
#set page(
  paper: "a4",
  margin: (x: 18mm, top: 20mm, bottom: 20mm),
  header: context if counter(page).get().first() > 1 {
    text(size: 8pt, fill: luma(45%))[CeTZ Feynman Lite #h(1fr) User Guide]
  },
  footer: context if counter(page).get().first() > 1 {
    align(center, text(size: 9pt, counter(page).display()))
  },
)
#set text(font: "Libertinus Serif", lang: "en", size: 11pt)
#set par(leading: 0.55em)
#show raw: set text(font: "Cascadia Mono", size: 9pt)
#set heading(numbering: "1.1")
#show heading.where(level: 1): set text(size: 19pt)
#show heading.where(level: 2): set text(size: 13pt)

#v(25mm)
#text(size: 12pt, tracking: 1pt, fill: luma(40%))[USER GUIDE AND API REFERENCE]
#v(8mm)
#text(size: 36pt, weight: "bold")[CeTZ Feynman Lite]
#v(5mm)
#text(size: 15pt)[Feynman diagrams with Typst and CeTZ]
#v(16mm)
#align(center, include "snippets/compton.typ")
#v(1fr)
#text(size: 12pt)[Rotor]

Development edition · September 2026

Examples verified with Typst 0.15.0 and CeTZ 0.5.2.
The API reference is generated with tidy 0.4.3.
#pagebreak()
#outline(title: [Contents], depth: 2)
#v(8mm)
*Using this guide*

Examples use the versioned package import. Before publication, install the local release
candidate under a Typst package path to use these examples.
The library draws diagrams; it does not calculate amplitudes or validate physical processes.
#pagebreak()

// Both the printed code and the preview use the same source.
#let demo(title, path, note) = {
  heading(level: 1, title)
  note
  v(5mm)
  grid(
    columns: (108mm, 60mm),
    gutter: 6mm,
    block(width: 100%, inset: 3mm, radius: 2pt, fill: luma(96%), raw(read(path), lang: "typst")),
    align(center + horizon, scale(x: 80%, y: 80%, reflow: true, include path)),
  )
}

#demo("Your first diagram", "snippets/first.typ", [
  Call #raw("feynman") inside a CeTZ canvas. Each edge specifies its start ID,
  end ID and options. Vertices are inferred from these IDs;
  #raw("incoming") and #raw("outgoing") identify the external legs.
])
#pagebreak()
#demo("Customizing vertices", "snippets/vertices.typ", [
  Add #raw("vertices") to set markers and labels. Coordinates remain optional.
  With explicit vertices, set each vertex's #raw("role") instead of passing
  top-level #raw("incoming") or #raw("outgoing").
  A blob is circular, and #raw("size") is its radius.
])
#pagebreak()
#demo("Propagator styles", "snippets/styles.typ", [
  #raw("particle") selects a preset; #raw("style") overrides its appearance.
  Line thickness uses physical lengths such as pt. Amplitude, wavelength and
  offsets use canvas units, whose physical size is set by #raw("length").
  #raw("gluon-aspect") controls the longitudinal excursion of the coil.
])
#pagebreak()
#demo("Fermion flow and momentum", "snippets/momentum.typ", [
  In #$Z -> e^- e^+$, the positron's fermion-flow arrow points toward the vertex,
  while its momentum points outward. Set #raw("arrow") and #raw("momentum") independently.
  Directions and sides are relative to the edge's start → end order.
])
#pagebreak()
#demo("Parallel edges and layout", "snippets/loop.typ", [
  In this electron self-energy diagram, the electron and photon connect the same
  pair of vertices. #raw("main-lines") aligns the electron line, and #raw("route")
  places the photon above it. No vertex coordinates are required.
  An edge cannot combine route with bend or controls.
])
#pagebreak()
#demo("Compton scattering: s channel", "snippets/compton.typ", [
  #$e^- gamma -> e^- gamma$: incoming particles are on the left, outgoing particles on the right.
  Following the electron line, absorption precedes emission.
  The internal momentum is #$q_s = p_1 + k_1$, with #$s = q_s^2$.
  The tree-level amplitude is #$cal(M) = cal(M)_s + cal(M)_u$.
])
#pagebreak()
#demo("Compton scattering: u channel", "snippets/compton-u.typ", [
  Following the electron line, emission precedes absorption.
  The internal momentum is #$q_u = p_1 - k_2 = p_2 - k_1$, with #$u = q_u^2$.
  The crossing of the two photon lines is not a vertex;
  #raw("crossing-gap") opens a gap in the lower line.
])
#pagebreak()
#include "api-reference.typ"
