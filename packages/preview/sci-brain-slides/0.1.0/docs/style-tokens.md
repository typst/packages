# Style tokens

All components read the same palette. `setup(theme: ...)` binds it to the page,
layouts, and gadgets. The palette is available as `deck.palette`.

## Page geometry

The default page is 16:9 with 48 pt side margins. The footer shows only a slide
number. Repeated footer text and the progress bar are optional. Body content begins 100 pt
from the top and ends 46 pt above the bottom. Header rules, body content, and
footers share the same left and right edges. A two-line header fits above the
body; longer headings should be shortened.

Title, section, and focus slides have no running header or footer. The title
uses the same 48 pt alignment as body pages. Focus slides use 64 pt margins.

The theme accepts Touying `config-page` overrides. Layouts follow their available
width, but the default gallery is designed for 16:9. Recheck the PDF after
changing the aspect ratio or margins.

## Typography

| Token | Size | Use |
|---|---|---|
| `sizes.xlarge` | 36 pt | Cover, section title, focus slide, punch statement |
| `sizes.large` | 24 pt | Slide heading, emphasis, pull quotes, statistics |
| `sizes.normal` | 20 pt | Body, table cells, theory boxes |
| `sizes.caption` | 14 pt | Figure captions, sources, portrait names, kicker labels |
| `sizes.chrome` | 12 pt | Footer metadata and rehearsal timing |

Use the three content sizes for the scientific argument. The two smaller sizes
are for supporting information. Math scripts follow the math font's proportions.
The template never scales an overfull body automatically. Labels and table
headers preserve the author's capitalization; kicker labels use normal letter
spacing.

The default body font is DejaVu Sans. Install it locally or pass another installed
family as the theme's `font` argument. Equations use New Computer Modern Math;
code and table values use DejaVu Sans Mono. Typst bundles the last two.

## Per-deck sizes

`setup(text-size: 22pt)` scales the defaults by `22 / 20`. All bound components
and theme pages receive the same absolute sizes, so nested components do not
compound the scale. Add `sizes: (caption: 16pt, chrome: 12pt)` to override selected
tokens after scaling. `deck.sizes` contains the resolved values; use it for custom
text and pass it to `pin-gadgets` through its `sizes` argument.

Margins and explicit component heights stay fixed. The six-slide starter fits at
20, 22, and 24 pt. Recompile and visually review any other content after
changing its text size. Check both extra pages and content that crosses
a card or figure boundary; page-count checks cannot catch every collision.

## Palette vocabulary

| Key | Role |
|---|---|
| `primary` | Main theme color, badges, focus background, progress bar |
| `primary_light` | A companion tint for Touying configuration |
| `secondary` | A second theme color, diagram and lemma accents |
| `on_primary` | Readable foreground on primary-filled surfaces |
| `accent` | Soft emphasis and callout borders |
| `accent_deep` | Emphasized text, quantities, kicker labels |
| `ink` | Headings and labels |
| `text` | Body text |
| `text_soft` | Captions, sources, footer metadata |
| `paper` | Page background |
| `paper_bg` | Card background |
| `hairline` | Header rules, separators, table rules |
| `success` | Proof and success callouts |
| `warning` | Warnings and rehearsal time labels |
| `neutral_lightest`, `neutral_dark`, `neutral_darkest` | Compatibility aliases for Touying colors |

Soft fills mix their color into `paper`. This works on both light and dark
backgrounds. Avoid lightening fills toward white in a component intended for
dark slides.

## Themes

| Theme | Primary | Deep accent | Paper |
|---|---|---|---|
| academic | `#2f2f7f` | `#7c5fdc` | `#ffffff` |
| dark | `#7c9cf0` | `#c8a13a` | `#1b2138` |
| minimal | `#111111` | `#222222` | `#ffffff` |
| vibrant | `#0d9488` | `#be185d` | `#ffffff` |
| brand | User-selected | Derived | `#ffffff` |

Brand palettes mix the primary into near-black for body text. Emphasis uses a
lavender mix darkened with that ink. Black or white foreground is selected by
relative luminance for badges and primary backgrounds. The default brand primary
is `#2f2f7f`. Use an opaque primary color.

## Extending a theme

Add a palette in `src/palettes/` and a wrapper around `src/themes/base.typ` in
`src/themes/`. Register both in `src/lib.typ`. Add a gallery sample and include
the theme in `tests/check.py`. All themes use the shared page geometry; keep
layout fixes there so they apply to every theme.
