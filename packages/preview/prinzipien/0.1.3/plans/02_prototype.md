# 02 Prototype

Build a working prototype of **Prinzipien**, a [touying](https://github.com/touying-typ/touying) theme and typst template for presentations following the design principles of Jean-luc Doumont's _Trees, maps, and theorems_. The package name is a homage to <https://www.principiae.be>.

This plan is meant to be executed by an agent and reviewed by a human. Work through the steps in order; each checkpoint requires human confirmation before continuing.

## Environment

- Target touying **0.7.4** (latest on typst preview index) and typst **0.15.0**.

## Design reference (Doumont)

These principles are the definitive reference; every layout decision must trace back to one of them:

- Plan for a (very) wide margin and set everything left against it.
- Coordinate all sizes and positions, for structure and harmony.
- With each slide, convey one message (only) — the message *is* the slide title.
- A presentation has one main message, supported by 2–5 main points, each developed by 2–5 subpoints; each subpoint gets one slide.
- The canonical presentation structure is: attention getter → need (gap between actual and desired situation) → task → main message (the one sentence to remember) → preview (map of the body) → point 1 → transition → point 2 → transition → … → review (recap leading to the conclusion) → conclusion (what it means to the audience) → close.
- Use a limited set of colours: one accent colour only, plus tints derived from it.

## Product requirements

### Template priorities

The template should be **simple**, **composable**, and **configurable** — in that order. Configuration must compose with typst-native mechanisms wherever possible: prefer `#set text(font: "Noto Sans", size: ...)` working as expected over a `text:` dict parameter on the theme function. Read <https://typst.app/docs/tutorial/advanced-styling/> and <https://typst.app/docs/tutorial/making-a-template/> before writing the theme, and keep <https://typst.app/docs/reference/> at hand for idiomatic typst.

### Layout

- Every non-title slide reserves a configurable left margin area, default **33%** of the slide width. All main content sits to its right, set flush against the margin edge (strong left alignment, no centring).
- Provide a way to place content *into* the left margin when needed — the driving use case is an image on the right with labels in the margin. In touying terms this is a slide function parameter (e.g. `margin-content` or a positional composer cell), not a global setting.
- Coordinate all sizes and positions from a small set of shared dimensions (the margin width, a baseline grid / spacing unit) so that title, content, and footer align across slides.

### Slides and structure

- **Title slide**: no left-margin treatment (exception: logo, see below); shows title, author, date, etc.
- **Content slide**: the slide's *message* (one full sentence) is the title. Support optimized linebreaks in the message — at minimum via typst's `par(linebreaks: "optimized")`, and allow the author to insert manual breaks.
- **Overview slides** (the common term for preview/transition/review) are first-class:
  - The presentation's 2–5 main points are **derived from the headings**: a top-level heading's text is the point's **statement** (what the audience should take away). A point may additionally carry an optional **substatement** (support for the statement); provide a small helper to attach it when the heading is written, since typst headings carry no extra fields. Build on touying's section/heading utilities (`utils.display-current-heading`, the sections state used by `new-section-slide-fn`) rather than a parallel bookkeeping mechanism.
  - `preview` and `review` slides show *all* points: statement in the accent colour, substatement below it in the foreground colour.
  - `transition` slides show the same map but mute (suppress) points using the suppressed colour. Which points are emphasized is configurable per transition; by default only the upcoming point is emphasized.
- **Backmatter**: optional Q&A slides and bibliography after the close. Backmatter slides are numbered with roman numerals and are excluded from the main slide total.

### Footer

All non-title slides show `current / total` in the bottom right, where total excludes the backmatter. Touying's `utils.slide-counter` and `utils.last-slide-number` handle this; for the backmatter, follow touying's appendix pattern (freeze the last-slide counter and switch the displayed numbering to roman numerals) — consult the touying source for the established idiom rather than inventing one.

### Logo

- The user can configure a logo and, optionally, a square variant. If the square variant is omitted, derive it from the full logo (e.g. crop/fit into a square box).
- Title slide and overview slides: logo in the margin area.
- Other slides: the square logo sits left of the slide title.

### Colours

Defaults (all configurable):

| role       | value     |
| ---------- | --------- |
| background | `#ffffff` |
| foreground | `#221f21` |
| accent     | `#f9ab1a` |
| suppressed | `#7a7d80` |

Accent **tints** are derived automatically from the accent colour (similar hue, less saturation, similar value — the reference derives `#fdd9a3` from the default accent), but the user can override each derived tint explicitly. Implement the derivation with typst's colour functions (e.g. `color.mix` or HSV manipulation) in a small helper.

### Fonts

Defaults: _Noto Sans_ (main), _Noto Serif_ (serif), _Noto Sans Mono_ (monospace). Set them via `set text` / `show raw` rules inside the theme so users can override them with their own `set` rules after the theme show rule.

## Package structure

```
lib.typ       package entrypoint (re-exports the public API)
src/          contributing modules/functions (if necessary)
theme.typ     theme implementation
examples/     showcase/testing
typst.toml    typst package manifest
```

Read <https://github.com/typst/packages/blob/main/docs/manifest.md> before writing `typst.toml` to ensure adherence to typst packaging standards. Key facts (verify against the document): `name`, `version` (semver triple), and `entrypoint` are required; Universe submission additionally requires `authors`, `license` (SPDX-2 expression), and a short `description`; optional fields include `homepage`, `repository`, `keywords`, `categories` (max 3), `compiler`, and `exclude`. Package names must not be canonical descriptors ("slides" is forbidden), must not contain "typst", and use kebab-case — `prinzipien` satisfies all of these. If a `[template]` section is added later it needs `path`, `entrypoint`, and a `thumbnail` (PNG/WebP, ≥1080 px longest edge, ≤3 MiB).

## Touying integration notes

Read the touying documentation at <https://touying-typ.github.io/docs/intro> and follow the conventions of touying's stock themes (read `themes/simple.typ` in the touying repository as a model):

- The theme is a function `prinzipien-theme(..args, body)` applied via `#show: prinzipien-theme.with(...)`. It composes `touying-slides.with(...)` from `config-page` (margins, aspect ratio), `config-common` (`slide-fn`, `new-section-slide-fn`, counters), `config-methods` (init, `alert`), `config-colors`, `config-info`, and `config-store` (theme-specific state: margin width, logo, derived tints).
- Each slide function (`slide`, `title-slide`, `preview`, `transition`, `review`, focus/Q&A variants) wraps `touying-slide-wrapper(self => ...)`, merges per-slide config into `self`, and calls `touying-slide`.
- Reuse touying's `alert` mechanism for accent emphasis instead of a custom marker.

## Steps

1. **Skeleton.** Create `typst.toml` (name `prinzipien`, version `0.1.0`, entrypoint `lib.typ`, compiler `0.15.0`, license and description matching the repository), an empty-but-importing `lib.typ`, and a minimal `theme.typ` that wraps touying with the page geometry (16:9, wide left margin), colour defaults, and font defaults. Add `examples/demo.typ` that imports the theme via a relative path and compiles with `typst compile`.
2. **Content slide.** Implement the default `slide` function: message as title (optimized linebreaks), 33% margin, left-aligned content, footer with `current / total`, optional `margin-content`. Extend the example to exercise a plain slide and a margin-label + image slide.
3. **Title slide.** Implement `title-slide` with the info from `config-info`, no margin treatment, no footer numbering.
4. **Overview slides.** Derive points from top-level headings, add the substatement helper, and implement `preview`, `transition` (configurable emphasis, defaulting to the upcoming point), and `review` on top of one shared overview layout.
5. **Logo.** Add logo configuration (full + derived-or-explicit square), place it per the rules above.
6. **Backmatter.** Implement the appendix switch: roman numbering, excluded from the main total; add Q&A and bibliography slides to the example.
7. **Colour derivation.** Implement the tint-derivation helper with user overrides; use the tints somewhere visible (e.g. overview muting or alert backgrounds).
8. **Polish & lint.** Apply formatter/linter fixes across all files and resolve or report the remaining findings. Make the example a small but complete Doumont-structured deck (attention getter through close) so it doubles as documentation.

## Verification and checkpoints

The agent must not judge visual details itself. At the end of each step, compile `examples/demo.typ` to PNG/PDF with `typst compile`, tell the user which file/pages to look at, and ask a **yes/no question with room for explanation**, e.g. after step 2: "Open `examples/demo.pdf`, page 2 — does the content sit flush against a left margin of roughly one third of the slide width, with the message as the title? (yes/no + what looks off)". Only proceed to the next step after a yes, and fold any "no" explanation back into the current step.

Compilation success, absence of typst warnings, and clean linter output are the agent-verifiable criteria; everything visual is the human's call.
