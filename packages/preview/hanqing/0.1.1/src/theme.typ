// Theme: colors, fonts, icons, and shared components.

#let colors = (
  text: rgb("#333333"),
  muted: rgb("#757575"),
  accent: rgb("#D9534F"), // Warm red
  bg-panel: rgb("#F9F9F9"), // Very light gray for items panel
  line: rgb("#EEEEEE"),
)

#let fonts = (
  body: ("Zhuque Fangsong (technical preview)", "Times New Roman"),
  header: ("LXGW WenKai", "Arial"),
  mono: ("Courier New", "LXGW WenKai Mono", "Maple Mono NF CN"),
  sans: ("Sarasa Mono SC"),
)

#let icons = (
  time: box(height: 0.8em, baseline: 0.1em, image(bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='12' cy='12' r='10'/><polyline points='12 6 12 12 16 14'/></svg>"), format: "svg")),
  badge: box(height: 0.8em, baseline: 0.1em, image(bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'></path><circle cx='9' cy='7' r='4'></circle><path d='M23 21v-2a4 4 0 0 0-3-3.87'></path><path d='M16 3.13a4 4 0 0 1 0 7.75'></path></svg>"), format: "svg")),
)

// Shared checkbox component used in entry() sidebar.
#let checkbox = {
  box(
    height: 0.8em,
    width: 0.8em,
    stroke: 1pt + colors.muted.lighten(40%),
    radius: 2pt,
    baseline: 20%
  )
}
