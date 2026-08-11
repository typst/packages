#import "@preview/touying:0.6.3": *
#import "@preview/touying-endfield:0.1.1": *

#import "@preview/numbly:0.1.0": numbly

// Theme configuration
// See https://github.com/leostudiooo/typst-touying-theme-endfield/ or package examples directory for usage examples.
#show: endfield-theme.with(
  aspect-ratio: "16-9", // touying 0.6.3+ supports arbitary ratios like "4-3", "1-1", "3-4", etc.
  footer: self => self.info.institution, // or you can set title, author, date, etc. here
  navigation: "mini-slides", // mini-slides (recommended!), none, or sidebar (not recommended); default "mini-slides"
  // Mini-slides configuration (only effective when navigation: "mini-slides")
  // mini-slides: (
  //   height: auto, // default handled with inline property, adjust this if you have many subtitles and the mini-slides bar height is not enough to display them
  //   inline: true,
  //   spacing: .2em,
  //   current-slide-sym: $triangle.small.b.filled$, // symbol for current slide, default is a filled bottom-pointing triangle
  //   other-slides-sym: $triangle.small.t.stroked$, // symbol for other slides, default is a stroked top-pointing triangle
  // ),
  // config-store(
  //   // title-height: 6em, // adjust this if your title wraps to multiple lines
  // ),
  config-info(
    title: [Presentation Title],
    subtitle: [Presentation Subtitle],
    author: [Author Name],
    date: [2026-01-01],
    institution: [Institution Name],
  ),
  config-page(fill: luma(231)), // use pure color instead of gradient when printing, using sidebar navigation, or if you just prefer it
  
  // Uncomment and configure fonts for CJK and Latin scripts:
  // config-fonts(
  //   cjk-font-family: ("HarmonyOS Sans SC", "Source Han Sans"),
  //   latin-font-family: ("HarmonyOS Sans",),
  //   lang: "zh",
  //   region: "cn",
  // ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

#outline-slide()

= First Section

== First Slide

- First point
- Second point
- Third point

#focus-slide[
  Key takeaway or warning message.
]

= Second Section

== Summary

Thank you for your attention!
