// Design tokens of the YSU defense theme: colors, gradients, fonts and
// brand marks. Values follow the LaTeX defense deck (ysu-defense-modern.sty,
// theme v3). Geometry is written in the deck's own units: the slide is
// 16 cm x 9 cm, so positions read as literal cm and font sizes as literal pt.

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------
#let ysu-navy = rgb("#1F296A")
#let ysu-red = rgb("#B42318")
#let ysu-ink = rgb("#1B1E2B")
#let ysu-muted = rgb("#5A6072")
#let ysu-tint = rgb("#F2F4F9")
#let ysu-line = rgb("#D9DCE5")
#let ysu-base = rgb("#A9B1C9")
#let ysu-night = rgb("#0E1433")
#let ysu-night-dot = rgb("#3A4370")

/// `mix(c, p)` is the xcolor mix `c!p!white`: p percent of c over white.
#let mix(c, p, base: white) = color.mix((c, p), (base, 100% - p))

// Text on navy grounds.
#let ysu-kicker = mix(white, 78%, base: ysu-navy)
#let ysu-faint = mix(white, 55%, base: ysu-navy)

// ---------------------------------------------------------------------------
// Gradients: two stops, horizontal or 45 degrees.
// ---------------------------------------------------------------------------
#let grad-head = gradient.linear(ysu-navy, mix(ysu-navy, 80%, base: ysu-tint))
#let grad-bar = gradient.linear(ysu-navy, mix(ysu-navy, 85%, base: ysu-night))
#let grad-key = gradient.linear(ysu-navy, ysu-red)
#let grad-page = gradient.linear(ysu-navy, mix(ysu-navy, 70%))
// Structure pages: night at the lower left to navy at the upper right.
#let grad-diag = gradient.linear(ysu-night, ysu-navy, angle: -45deg)
// Chapter opener: navy right of and below the center, night at the edges.
#let grad-opener = gradient.radial(
  (ysu-navy, 0%),
  (ysu-navy, 18%),
  (ysu-night, 100%),
  center: (58%, 62%),
  radius: 90%,
)

// ---------------------------------------------------------------------------
// Fonts. Latin faces only cover Latin text, so CJK punctuation falls through
// to the CJK face.
//
// Projected defense slides stay sans-serif. The YSU dissertation rule
// (宋体 / 黑体 / Times New Roman) is for the printed thesis, and Songti's thin
// strokes blur on a projector. Source Sans 3 is not in that rule and is absent
// on a typical Windows lab machine; Typst warns for every unknown family, so
// it is not in the default list. Pass it via `font.latin` after installing it.
// SimHei is the system "黑体" but has no real bold, so it is omitted.
// ---------------------------------------------------------------------------
#let font-latin = ("Arial",)
#let font-cjk = ("Source Han Sans", "Noto Sans SC", "Microsoft YaHei")
#let _font-stack(latin, cjk) = latin.map(name => (name: name, covers: "latin-in-cjk")) + cjk

// The 900 weight of the structural pages (cover title, opener number).
#let heavy = 900

// ---------------------------------------------------------------------------
// Brand marks. Paths resolve relative to this file.
// ---------------------------------------------------------------------------
#let seal(white: false, ..args) = image(
  if white { "assets/ysu-seal-white.png" } else { "assets/ysu-seal.png" },
  ..args,
)

#let wordmark(white: false, ..args) = image(
  if white { "assets/ysu-wordmark-only-white.png" } else { "assets/ysu-wordmark-only.png" },
  ..args,
)

/// Horizontal logo: seal and wordmark side by side, `height` is the seal
/// height.
#let logo(white: false, height: 0.75cm) = box(
  height: height,
  stack(
    dir: ltr,
    spacing: 0.12 * height,
    seal(white: white, height: height),
    std.align(horizon, wordmark(white: white, height: 0.62 * height)),
  ),
)
