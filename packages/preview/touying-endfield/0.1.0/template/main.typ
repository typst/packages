#import "@preview/touying:0.6.1": *
#import "@preview/touying-endfield:0.1.0": *

#import "@preview/numbly:0.1.0": numbly

// Theme configuration
#show: endfield-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "none", // sidebar, mini-slides, or none
  config-store(
    // title-height: 6em, // adjust this if your title wraps to multiple lines
  ),
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
  //   cjk-font-family: ("Source Han Sans",),
  //   latin-font-family: ("Helvetica",),
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
