// Color palettes + active-theme state.
// Two cards switch seamlessly via `scholia.with(theme: "light" | "dark")`.
// Scheme: "cool modern STEM" — blue (theorem) / teal (definition) / amber (example).
//
// Roles: bg (page) · ink (body) · muted (secondary) · hairline (faint rules) ·
//        thm/def/eg (knot accents) · rule (section rule) · tag · keyword.

#let palettes = (
  light: (
    dark: false,
    bg: white,
    ink: rgb("#16202E"),
    muted: rgb("#6B7686"),
    hairline: rgb("#D2D8E0"),
    thm: rgb("#2F5EA8"),
    def: rgb("#0F766E"),
    eg: rgb("#B45309"),
    rule: rgb("#2F5EA8"),
    tag: rgb("#0F766E"),
    keyword: rgb("#0F766E"),
  ),
  dark: (
    dark: true,
    bg: rgb("#141B27"), // deep blue-grey slate
    ink: rgb("#E3E8F0"),
    muted: rgb("#8893A4"),
    hairline: rgb("#2A3340"),
    thm: rgb("#74A6FF"),
    def: rgb("#54C8B6"),
    eg: rgb("#E0A458"),
    rule: rgb("#74A6FF"),
    tag: rgb("#54C8B6"),
    keyword: rgb("#54C8B6"),
  ),
)

// the active palette; the document wrapper updates it from the `theme` option.
#let active = state("scholia-palette", palettes.light)

// a soft box fill: blend an accent toward the page background.
#let tint(p, c, strength: auto) = {
  let s = if strength != auto { strength } else if p.dark { 16% } else { 9% }
  color.mix((c, s), (p.bg, 100% - s))
}
