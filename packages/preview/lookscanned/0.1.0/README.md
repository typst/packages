# lookscanned

Make a Typst document look scanned, photocopied, faxed or typewritten: paper grain, foxing, stains, dust, scanner
shadows, drum bands, fax lines and bleeding ink. Textures and randomness come from a small WebAssembly plugin; the
effects are applied by Typst, so:

- text and equations stay **real text**: selectable, searchable, accessible;
- the **layout does not move**: line and page breaks are those of the clean document;
- rendering is **deterministic**: the same `seed` always gives the same PDF.

![A textbook excerpt with the old-paper preset and a photocopied problem sheet](https://raw.githubusercontent.com/kornstein/lookscanned/main/assets/hero.png)

## Quick start

```typst
#import "@preview/lookscanned:0.1.0"

#show: lookscanned.scan.with(preset: "old-paper", seed: 3)

= Cauchy sequences
A sequence $(u_n)$ is a _Cauchy sequence_ if for every $epsilon > 0$ there
exists $N$ such that $abs(u_p - u_q) <= epsilon$ for all $p, q >= N$.
```

Place `scan` after your `set page` rules. With a template whose rule must come last, such as `mousse-notes`, place
`scan` just before it:

```typst
#show: lookscanned.scan.with(preset: "old-paper", edges: (binding: true))
#show: style
```

## Presets

![The seven presets on the same excerpt](https://raw.githubusercontent.com/kornstein/lookscanned/main/assets/presets.png)

| Preset | Look |
|---|---|
| `"clean-scan"` | Off-white paper, little grain, minimal rotation |
| `"office-scan"` (default) | Moderate grain, edge shadow, slight drift between pages |
| `"photocopy"` | Heavy bleed, drum bands, dust, scratches |
| `"fax"` | Transmission lines, per-word jitter, low legibility |
| `"typewriter"` | Per-character jitter, uneven inking, worn ribbon |
| `"old-paper"` | Yellowing, foxing, stains, vignette |
| `"phone-scan"` | Strong rotation, uneven lighting |

`lookscanned.presets` is a plain dictionary; any dictionary of the same shape can be passed as `preset`.

## Settings

`intensity` scales every amount, angle and offset (`0` disables the effect, `1` is the preset, `> 1` exaggerates).
`seed` selects the variant. Every other setting belongs to a theme; omitted keys keep the preset's value:

```typst
#show: lookscanned.scan.with(
  preset: "office-scan",
  intensity: 0.7,
  seed: 7,
  paper: (color: rgb("#f4efe4"), grain: 0.4, aging: 0.2, fibers: 0),
  stains: (color: rgb("#8b5a2b"), amount: 0.3, size: (min: 2mm, max: 15mm), dust: 0.5, scratches: 0),
  ink: (bleed: 0.4, fade: 0.2, legibility: 0.8, wear: 0, ghosting: false),
  skew: (page-rotation: 0.6deg, line-jitter: 0.15deg, char-jitter: 0pt, drift: 0.3),
  edges: (shadow: 0.5, vignette: 0.3, uneven: 0, binding: false, punch-holes: false),
  scanner: (lines: 0, bands: 0),
  quality: (resolution: 150, tile: true, granularity: "line"),
)
```

| Key | Effect |
|---|---|
| `paper.grain`, `aging`, `fibers` | Grain and mottling; yellowing and foxing; paper fibres |
| `stains.amount`, `size`, `color` | Blotches, coffee rings and splatters |
| `stains.dust`, `scratches` | Specks and hairs, long scratches on the scanner glass |
| `ink.bleed` | Ink spreading into the paper: glyphs grow unevenly |
| `ink.fade` | Uneven inking per word (per character with `"char"`) |
| `ink.legibility` | `1` sharp to `0` barely readable: halo, dropouts, fading |
| `ink.wear` | Pinholes and dropouts inside the glyphs |
| `ink.ghosting` | Faint offset copies. Off by default: text extractors read them |
| `skew.page-rotation`, `drift` | Maximum rotation per page; `1` makes it wander slowly across pages |
| `skew.line-jitter`, `char-jitter` | Rotation per block or word; offset per word or character |
| `edges.*` | Edge shadow, vignette, uneven light, binding shadow, two ISO 838 punch holes |
| `scanner.lines`, `bands` | Fax lines, photocopier bands |
| `quality.resolution`, `tile` | Texture DPI; one shared grain tile for all pages |
| `quality.granularity` | `"page"`, `"line"`, `"word"` or `"char"` jitter |

Unknown themes or keys and values of the wrong type stop compilation with an explicit error.

## Pages, regions and decorations

```typst
// Page-level effects for the pages spanned by the body.
#lookscanned.page(stains: (amount: 0.8), skew: (page-rotation: 2deg))[
  = Appendix: tables
]

// Text effects on a single block, without the global rule.
#lookscanned.region(preset: "typewriter")[
  *Proof.* Let $epsilon > 0$ …
]

#lookscanned.stamp("Library copy", color: rgb("#5b3a8c"), angle: -12deg)
#lookscanned.scribble(body: "see Thm 1.4", color: blue)  // wobbly italic
#lookscanned.scribble(width: 3cm)                       // scrawl
#lookscanned.stain(at: (x: 60%, y: 20%), size: 25mm)
```

`stamp` and `scribble` also accept `at: (x: .., y: ..)` for absolute placement.

## Raw textures

```typst
#set page(background: lookscanned.texture("paper", seed: 3, color: rgb("#f0e6d2"), grain: 0.5))
#set page(foreground: lookscanned.texture("dust", seed: 3, amount: 0.4))
```

Kinds: `"paper"`, `"grain"`, `"toner"`, `"ink"`, `"stains"`, `"dust"`, `"lines"`, `"edges"`. Without `width` and
`height`, a texture takes the page size.

## Limitations

- No true blur or perspective: bleed and blur use textured strokes; `phone-scan` uses rotation and lighting only.
- `"line"` granularity rotates whole blocks (Typst has no per-line hook). `"word"` boxes words, which prevents
  hyphenation in justified text; `"char"` shifts characters vertically only.
- Fraction bars and radical lines in equations are shapes and do not bleed.
- `scan` replaces the page `background` and `foreground`.
- Page-sized textures need a fixed page height; with `height: auto`, only paper colour and grain are drawn.
- Poppler-based viewers draw the textured ink outline as plain ink. Typst 0.15.1 cannot export textured text to
  PNG; export a PDF and convert it with Ghostscript.

## Documentation

Full guide, API and settings reference, and internals: <https://kornstein.github.io/lookscanned/>.

## Credits

Part of the Rust texture algorithms and most of the Typst code were written by hand. The rest was built with
[Claude](https://claude.ai).

The text remains real text, but a "scanned" document is harder to read: keep a clean version available
(`intensity: 0`). This package is meant for design, fiction, games, props and OCR testing; do not use it to forge
documents.
