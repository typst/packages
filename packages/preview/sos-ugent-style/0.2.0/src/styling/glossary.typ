/*
 * See glossy for documentation. This is just a theme.
 * Glossy is well integrated into sos-ugent-style, use the documented entry-points.
 */

// TODO: This should be made possible:
// https://tex.stackexchange.com/questions/8946/how-to-combine-acronym-and-glossary

#let glossy-theme-ugent = (
  section: (title, body) => {
    heading(level: 1, title)
    body
  },

  group: (name, index, total, body) => {
    if name != "" and total > 1 {
      heading(level: 2, name)
    }

    table(columns: 2,
      stroke: none,
      fill: (_, y) => if calc.odd(y) { rgb("F0F0F0") },
      inset: (x: 3pt, y: 0.4em),
      ..body
    )
  },

  entry: (entry, index, total) => {
    // Array of (short, rest) to put into the 2 column table
    (heading(entry.short + entry.label, level: 99),
     // TODO: use heading? Heading might be semantically wrong... (screen readers!)
     // Alternative, no heading: text(weight: "bold", entry.short + entry.label),
     {
       set par(leading: 0.65em) // Reset to tighter
       entry.long
       if (entry.long != none and entry.description != none) [ --- ]
       entry.description
       // Dots.... TODO: ensure a minimum width of the dots?
       h(0.2em) // Give some spacing around the dots
       // Always right align the page numbers, this serves as breakpoint when needed.
       // See: https://forum.typst.app/t/how-can-i-right-align-the-qed-symbol/948/4
       box(width: 0pt)
       box(width: 1fr, text(fill: gray.darken(30%), repeat(gap: 0.1em,".")))
       h(0.2em) // Same: give spacing
       sym.wj // Same purpose as zero-width box
       // Pages
       text(size: 0.85em, entry.pages)
     }
    )
  }
)
