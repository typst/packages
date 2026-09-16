// Font configuration and the fallback page shown when the ISC fonts are absent.

// Font stacks used by project(). Without the ISC fonts installed, compilation
// silently falls back to the trailing system fonts.
#let body-font = ("Source Sans Pro", "Source Sans 3", "Libertinus Serif")
#let sans-font = ("Source Sans Pro", "Source Sans 3", "Inria Sans")
#let raw-font = "Fira Code"
#let math-font = ("Asana Math", "Fira Math")

// Detect whether the ISC fonts are available using glyph-metric comparison.
// Source Sans Pro/3 (sans-serif) has markedly different capital widths from
// Libertinus Serif (always bundled in Typst). Equal widths means both ISC font
// names fell back to Libertinus Serif, i.e. the fonts are not installed.
// Works identically on the Typst web editor (has Source Sans Pro built in) and
// locally (has it after running install_fonts.sh).
// Must be called from within a `context` block (uses measure()).
#let isc-fonts-available() = {
  let _p   = "MMMMMMMMMM"
  let _isc = measure(text(font: ("Source Sans Pro", "Source Sans 3"), size: 12pt, _p)).width
  let _lib = measure(text(font: ("Libertinus Serif",),                size: 12pt, _p)).width
  _isc != _lib
}

// Warning page rendered instead of the full document when ISC fonts are absent.
// Deliberately uses only Libertinus Serif (always bundled in Typst) so the page
// itself renders correctly even without the custom fonts.
#let _missing-fonts-page(paper: "a4") = {
  // Wider margins on the large poster paper keep the warning box a sensible width.
  let margin = if paper == "a4" { (x: 3cm, y: 3cm) } else { (x: 18cm, y: 18cm) }
  set page(paper: paper, margin: margin, header: none, footer: none, numbering: none)
  set text(font: ("Libertinus Serif",), size: 11pt, fill: black)

  let accent = rgb("#E20571")

  align(center + horizon,
    rect(
      width: 100%,
      stroke: (left: 5pt + accent, rest: 0.8pt + luma(200)),
      radius: 4pt,
      inset: (x: 2em, y: 1.8em),
      {
        align(center,
          text(size: 1.8em, weight: "bold", fill: accent)[⚠ ISC Template — Fonts Not Installed]
        )
        v(1em)
        line(length: 100%, stroke: 0.5pt + luma(220))
        v(1em)

        [The fonts required by this template are *not installed* on this system.
        This document cannot be rendered with the correct typography.]
        v(0.6em)
        text(style: "italic", size: 0.9em, fill: luma(100))[
          (Yes — we appreciate the irony of a carefully typeset page telling you
          that typesetting is broken.)
        ]
        v(1.2em)

        [*Install the fonts by running this command once from the repository root:*]
        v(0.5em)
        block(width: 100%, fill: luma(245), inset: (x: 1em, y: 0.7em), radius: 3pt,
          align(left, raw(lang: "sh", "source src/fonts/install_fonts.sh"))
        )
        v(1.2em)

        [*Required fonts (all installed by the script above):*]
        v(0.3em)
        list(
          [*Source Sans Pro* / Source Sans 3 — body text],
          [*Fira Code* — source code listings],
          [*Inria Sans* — headings],
        )
        v(1.2em)

        text(style: "italic", size: 0.9em, fill: luma(100))[
          After installing the fonts, recompile the document.
          See #raw("README.md") for detailed instructions.
        ]
      }
    )
  )
}
