// Configuration helpers for Touying Endfield Theme.

#import "@preview/touying:0.6.3": *

/// Font configuration helper that can be passed to the theme.
///
/// Example:
/// ```typst
/// #show: endfield-theme.with(
///   config-fonts(
///     cjk-font-family: ("Source Han Sans", "Noto Sans CJK"),
///     lang: "zh",
///     region: "cn",
///   ),
/// )
/// ```
#let config-fonts(
  cjk-font-family: ("HarmonyOS Sans",),
  latin-font-family: ("HarmonyOS Sans",),
  lang: "en",
  region: "us",
) = config-store(
  fonts: (
    cjk: cjk-font-family,
    latin: latin-font-family,
    combined: latin-font-family + cjk-font-family,
  ),
  text-lang: lang,
  text-region: region,
)

