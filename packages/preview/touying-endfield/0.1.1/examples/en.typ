#import "@preview/touying:0.6.3": *
#import "touying-endfield:0.1.1": *

#import "@preview/numbly:0.1.0": numbly
#import "@preview/zh-kit:0.1.0"
#import "@preview/sicons:16.0.0": *

// Footnote setting
#show footnote.entry: set text(size: 0.8em)

// Main theme settings
#show: endfield-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "mini-slides", // sidebar, mini-slides, none, if you have many subtitles and subsubtitles, choose mini-slides or none. default is none.
  mini-slides: (
    inline: true,
    spacing: .2em,
    current-slide-sym: $triangle.small.b.filled$, // symbol for current slide, default is a filled bottom-pointing triangle
    other-slides-sym: $triangle.small.t.stroked$, // symbol for other slides, default is a stroked top-pointing triangle
  ),
  config-store(
    title-height: 6em,
  ),
  config-info(
    title: [Interdimensional Dynamics and Phenomenological\ Impact of the Ætherside in Talos II],
    subtitle: [A Comprehensive Review],
    author: [
      #grid(
        columns: (auto, auto),
        align: center,
        gutter: 0.5em,
        [
          Endministrator#footnote(numbering: "*")[Equal contributions]<eq-contrib> #counter(footnote).update(0) #footnote[Endfield Industries, OMV Dijiang, Talos II Synchorous Orbit]<endfield> #h(1em)
          Perlica @eq-contrib @endfield #h(1em)
          Qin Jiangchi @eq-contrib @endfield #footnote[United Workers' Syndicates of Talos II (Valley IV Base), Valley IV, Talos II]<uwst> #h(1em)
          Andrew @eq-contrib @endfield @uwst #h(1em)
          Yvonne @eq-contrib @endfield @uwst
        ],
        [
          Zhuang Fangyi @eq-contrib #footnote[Hongshan Academy of Sciences, Wuling ASTD, Talos II]
        ],

        [`{endmin,perlica,jqin,andrew,yvonne}@endfield.co.ii.talos`], [`fzhuang@has.ac.ii.talos`],
      )
    ],
    date: [2026-01-22],
    institution: text("ENDFIELD", font: "Gilroy", weight: "bold") + text(" INDUSTRIES", font: "Gilroy", size: 0.8em),
  ),
  config-page(fill: luma(231)), // recommended to use pure color instead of gradient when using sidebar navigation and/or printing

  // you can set the default fonts for CJK and Latin scripts, and also specify the language and region for correct glyphs and localization. The default main font is `Harmony OS Sans`, you can set fallbacks or completely override it by this setting. `Arial` is not recommended for CJK for its bundled `Arial Unicode Sans MS` ugly CJK typeface; instead, use `Helvetica` or `Source Sans` for better display effect. For CJK fonts, `Source Han Sans` is a good free option, and `Harmony OS Sans` also has a good CJK typeface.
  // config-fonts(
  //   cjk-font-family: ("Source Han Sans",),
  //   latin-font-family: ("Helvetica",),
  //   lang: "zh",
  //   region: "cn",
  // )
)

// Heading numbering setting
#set heading(numbering: numbly("{1}.", default: "1.1"))

// Equation numbering setting
#set math.equation(numbering: "(1)")

#title-slide()

#outline-slide()

= Fundamental Phenomenology

== Dimensional Topology

The Ætherside represents a comprehensive dimensional state at Depth 1, overlapping with realspace (Depth 0) across subterranean, atmospheric, and orbital regions. @depth-equation shows the correlation between proximity to rift boundaries and local Depth readings.

$ D(x) = tanh(lambda x) $ <depth-equation>

Where $D$ represents the Depth field taking values in $[-1, 1]$, with $D = 0$ being realspace (normal conditions), $D = -1$ the Originium Internalization Universe, and $D = 1$ the Ætherside. The parameter $x$ denotes proximity to rift boundaries. Active Blight manifests most intensely when depth readings approach $0.5$, corresponding to the Ætherside-Realspace overlap zone where the Higgs-like scalar field undergoes significant deviation from the vacuum expectation value.

== Biological Hazards

=== Active Blight Etiology

Direct exposure to Ætherside matter causes *irreversible* termination of biological processes#footnote[Band Accord Resolution 934 strictly prohibits live-subject transposition experiments.].

Conversely, matter emerging from Ætherside generates Active Blight in realspace, presenting existential contamination risks.

= Engineering Applications

== Originium Modulation

Cultivating Originium deposits reduces local Depth readings, effectively stabilizing dimensional barriers and containing rift expansion. However, operational interference with Arts-dependent machinery remains problematic in overlap zones.

- some point
  - some subpoint
- some other point

+ some enumerated point
+ some other enumerated point

#focus-slide[
  #text(size: 2em, font: "Gilroy")[WARNING]\
  Active Blight Detected\
  #text(weight: "light")[Maintain Minimum Safe Distance from Undocumented Rift Formations]
]

== Experimental Methodologies

#block(
  fill: luma(250),
  inset: 1em,
  radius: 0.5em,
)[We can use `#pause` and `#meanwhile` to #pause demonstrate critical safety protocols.]

#pause

Personnel must don shielded exosuits when depth readings approach 0.3; erosion risk escalates dramatically beyond this threshold.

#meanwhile

Meanwhile, #pause energy extraction operations #pause require redundant containment arrays to prevent cascade failures.

#show: appendix

= Appendix

== Appendix

#block(fill: luma(250), inset: 1em, radius: 0.5em)[Please pay attention to the current slide number.]

Key sources include the Talos-II Research Consortium archives and Band Accord safety documentation.

== Notes

If your are new to Typst and Touying, you can check out:
- #link("https://typst.app/docs") for Typst, and
- #link("https://touying-typ.github.io/") for Touying.

I personally recommend you to use Visual Studio Code with a Typst extension for editing and real-time preview.

You may want to install `Harmony OS Sans` and `Gilroy` for better display effect. The default main font is `Harmony OS Sans`, and the focus slide uses a customized setting for the "WARNING" text with `Gilroy` for better emphasis. *Note that `Gilroy` is a commercial font*, you may need to purchase a license for non-personal use.

== Known Issues

1. Unfortunately, the HarmonyOS Sans family has a non-standarized font stretch metadata, and typst would interpret the font weight "light" to use a condensed variant of the font #text(weight: "light", "just like this"), and _italic_ style would also be affected. *Bold* renders correctly for now. You cannot fix this by using `#text(stretch: 100%)` since the condensed variant also has a `stretch: 1000` metadata. You may want to use `Source Sans` or `Source Han Sans` as an alternative, uninstall the condensed series, try a community workaround #footnote[#link("https://github.com/typst/typst/issues/2917")], or wait for an official fix from Typst in the future #footnote[#link("https://github.com/typst/typst/issues/2098"), still open by Feb 2026.]. Or, you can optimistically regard it as a feature of the font family.
#pagebreak()
2. Sidebar navigation does not work responsively (i.e. does not change outline depth or text size based on the number of slides, it _overflows_ as you can see in the left). Similar issue also exists for mini-slides, but you can customize like `mini-slides: (height: 3em)`. This is due to the limit of touying's built-in `custom-progressive-outline` and `mini-slides` components. Maybe in the future I can implement a more advanced version of these components to fix this. Any useful sugeggetions or PRs are welcome! But if you dont want the bother, just use `navigation: "none"`.
#pagebreak()
3. Also, the decoration bar of the title slide has a similar issue. Currently this can be fixed by setting a larger `title-height` in `config-store` when the title wraps to multiple lines, but this is not an ideal solution. Again, any useful suggestions or PRs are welcome!

== Disclaimer

_Arknigts: Endfield_ is a video game by #link("https://hypergryph.com", "Hypergryph") (or #link("https://gryphline.com/", "Gryphline") outside of China mainland). This typst touying theme is not affiliated with Hypergryph or any of its subsidiaries. All trademarks and registered trademarks are the property of their respective owners.

#heading(depth: 2, outlined: false)[Thank You!]
Issues and PR Welcome at #link("https://github.com/leostudiooo/typst-touying-theme-endfield", [#box(sicon(slug: "github")) `leostudiooo/typst-touying-theme-endfield`]).
