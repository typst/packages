// Default configuration constants for NTU thesis formatting.
// Based on 國立臺灣大學碩博士學位論文格式規範 (112.10.20)

// Page layout
#let margin-top = 3cm
#let margin-bottom = 2cm
#let margin-left = 3cm
#let margin-right = 3cm

// Typography
#let body-size = 12pt
#let heading-size = 18pt
#let subheading-size = 14pt

// Font presets for different environments.
// - submission: Local build with NTU-preferred fonts.
// - web: Typst web app friendly fallback order.
// - portable: Open-font-first profile for CI and reproducible builds.
#let resolve-fonts(profile) = {
  if profile == "submission" {
    (
      en: ("Times New Roman", "TeX Gyre Termes", "STIX Two Text"),
      zh: ("BiauKaiTC", "DFKai-SB", "TW-MOE-Std-Kai", "Kaiti TC", "Kaiti SC"),
    )
  } else if profile == "web" {
    (
      en: ("TeX Gyre Termes", "STIX Two Text", "Times New Roman"),
      zh: ("TW-MOE-Std-Kai", "Kaiti TC", "Kaiti SC", "BiauKaiTC", "DFKai-SB"),
    )
  } else if profile == "portable" {
    (
      en: ("Libertinus Serif", "New Computer Modern", "Times New Roman"),
      zh: ("TW-MOE-Std-Kai", "Noto Serif CJK TC", "Noto Serif TC", "BiauKaiTC"),
    )
  } else {
    panic("Unknown font-profile. Use \"submission\", \"web\", or \"portable\".")
  }
}

// Spacing
#let line-spacing-zh = 1.5em  // 1.5 間距
#let line-spacing-en = 2em    // 雙行間距
