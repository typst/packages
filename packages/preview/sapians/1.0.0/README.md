# sapians

Token-driven design system for slides, papers, and reports — the official
SAPIANS look: Crisp White canvas, Inter typography, 0.25 pt hairlines, and a
single terracotta accent, calibrated against DeepMind, Anthropic Research,
and Urban Institute publication standards.

## Quick start

```typst
#import "@preview/sapians:1.0.0": * // x-release-please-version

#show: sapians-slides.with(
  title: "Machine Intelligence",
  author: "Research Team",
)

#slide-cover(
  title: "SAPIANS",
  subtitle: "Foundations of Neural Systems",
)
```

Prefer starting from a template? Use `typst init @preview/sapians-slides`,
`@preview/sapians-paper`, or `@preview/sapians-report`.

## What's inside

- **Slide engine (16:9)** — `sapians-slides` plus 10 standardized slide
  families: `slide-cover`, `slide-problem`, `slide-definition`,
  `slide-equation`, `slide-three-column`, `slide-evidence`,
  `slide-limitation`, `slide-contrast`, `slide-takeaway`, `slide-index`.
- **Scientific paper** — `sapians-article`: two-column A4 layout with
  abstract box, author grid, and bibliography support.
- **Technical report / memo** — `sapians-report`: single-column layout with
  version and author headers.
- **Components** — `code-box`, `dark-card`, `light-card`, `accent-card`,
  `kicker`, `caps-label`, `step-item`, `def-row`, `contrast-pair`.
- **Design tokens** — every color, font stack, type size, radius, and stroke
  in `src/tokens.typ`; WCAG AA contrast throughout.

All branding strings (`kicker`, `journal`, `org`, section labels) and `lang`
are parameters with SAPIANS defaults, so the layouts work for any venue.

## Fonts

The system is designed for **Inter** and **JetBrains Mono** (both SIL OFL).
They are not bundled with this package — install them from their official
releases ([Inter](https://github.com/rsms/inter/releases),
[JetBrains Mono](https://github.com/JetBrains/JetBrainsMono/releases)) or,
in the source repository, run `scripts/install_fonts.sh`. Without them,
documents fall back to Helvetica Neue / Arial and Menlo.

## License

MIT. Part of [sapians-design](https://github.com/wbendinelli/sapians-design).
