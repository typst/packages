# Touying GREYC Ambrosia

[![Typst Universe](https://img.shields.io/badge/Universe-0.2.0-239DAE?logo=typst)](https://typst.app/universe/package/touying-greyc-ambrosia) [![Continuous integration status for Touying GREYC Ambrosia tests](https://github.com/inspiros/touying-greyc-ambrosia/actions/workflows/checks.yml/badge.svg?branch=master)](https://github.com/inspiros/touying-greyc-ambrosia/actions/workflows/checks.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

<img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.2.0/assets/thumbnail.svg" alt="Touying GREYC Ambrosia: project logo, legacy cover, team branding, and modern slide layouts" width="1000">

An unofficial [Typst](https://typst.app/) presentation theme for the [GREYC laboratory](https://www.greyc.fr/en/home/), built on [Touying Ambrosia](https://github.com/inspiros/touying-ambrosia). Its default `legacy` flavor preserves the lab's earlier LaTeX/PPT appearance. It also supports the core's seven neutral layouts and configurable light/dark palettes.

This package adds lab/team/partner logos, GREYC color presets, and the legacy cover. Shared layouts, components, citation helpers, and metadata handling live in the core and are re-exported here.

**Requirements:** Typst 0.15+, Touying 0.8.0, and Touying Ambrosia 0.1.0. [Start from the template on Typst Universe](https://typst.app/universe/package/touying-greyc-ambrosia).

<details>
<summary>Explore The Legacy Cover</summary>

<img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.2.0/assets/gallery/legacy-cover.webp" width="1000" alt="GREYC legacy title slide with the laboratory photograph, linked authors, and institutional logos">

</details>

[Browse the full legacy demo](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/examples/demo.pdf) · [Edit its source](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/examples/demo.typ)

## Start A Presentation

```typst
#import "@preview/touying-greyc-ambrosia:0.2.0": *
#show: greyc-theme.with(
  flavor: "legacy",
  palette: "greyc-light",
  // team: "safe",
  config-info(title: [Research Presentation], author: [Presenter],
    institution: [GREYC · Université de Caen Normandie · ENSICAEN · CNRS],
    date: datetime.today()),
)

#title-slide()
#outline-slide()

= Research
== A Useful Result
#ambrosia-block(style: "poster", kind: "success", title: [Finding])[Evidence.]
#ending-slide(title: [Questions?])[]

#show: appendix
== Supporting Evidence
Additional material.
```

The complete starter can also be initialized locally:

```sh
typst init @preview/touying-greyc-ambrosia:0.2.0 my-slides
```

GREYC outlines use dotted leaders by default. Set `outline-fill: none` on the theme, or `fill:` on an individual `outline-slide`, to customize them.

`flavor` selects geometry: `legacy` (default), `simple`, `cambridge`, `darmstadt`, `dewdrop`, `stargazer`, `minimal`, or `portico`.

<img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.2.0/assets/gallery/flavors.webp" width="1000" alt="GREYC content in Legacy, Stargazer, Cambridge with Ocean colors, and Minimal with dark GREYC colors">

`palette` selects colors independently. Four lab presets keep the GREYC purple: **`greyc-light`** (default, white), **`greyc-ivory`** (warm paper), **`greyc-nocturne`** (cool dark surfaces), and **`greyc-charcoal`** (neutral dark gray). Neutral names such as `light`, `ocean`, and `midnight` use the core's colors. Use `ambrosia-palette(base: "greyc-ivory", primary: ..., name: ...)` to compose a lab variation, or any of the core's twelve presets. See [palette configuration](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/palettes.md).

<img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.2.0/assets/gallery/palettes.webp" width="1000" alt="The same GREYC slide in Light, Ivory, Nocturne, and Charcoal palettes">

`team` selects `amacc`, `codag`, `diamant`, `electronique`, `image`, `mad`, or `safe`, replacing the lab logos while preserving every palette color. `team-accent: true` optionally adds the team's original color as a thin stripe on the legacy cover. Logos adapt to their surface: primary purple becomes `#FBF7F8` on dark backgrounds while team accents are preserved.

<img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.2.0/assets/gallery/teams.webp" width="1000" alt="GREYC team branding: AMACC, CODAG, DIAMANT, ELECTRONIQUE, IMAGE, MAD, and SAFE">

Horizontal title rows group the lab/team mark on the left and institution partners
on the right. The legacy row stays inside its palette-colored text region; team
color can appear in a separate narrow edge strip with `team-accent: true`. The cover follows the resolved primary color with contrasting text and logos. Featured partners remain centered. `primary-logos` can replace the lab mark with several repeated marks;
`logos` holds opening partners. The neutral core offers the same grouping as an
option, while GREYC enables it by default.

See [the compact branding example](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/examples/branding.typ), [the longer legacy demo](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/examples/demo.typ), [the team sheet](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/examples/teams.typ) and [GREYC branding options](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/docs/branding.md). The complete starter is in [template/template.typ](template/template.typ).

The [user guide](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/docs/README.md) links the branding reference and shared core
documentation.

## Shared Features And Examples

<img src="https://raw.githubusercontent.com/inspiros/touying-greyc-ambrosia/v0.2.0/assets/gallery/demo.webp" width="1000" alt="Legacy slides showcasing semantic containers, figures and tables, a roadmap, and an optional package credit card">

The [longer demo](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/examples/demo.typ) keeps the legacy flavor while showcasing
selected shared features: linked authors, tree navigation, nested reveals,
semantic blocks, text hierarchy, code, citations, a palette showcase, a roadmap,
image/focus slides, credits, and a working appendix. Edit its defaults in an IDE;
the [rendered PDF](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/examples/demo.pdf) is available for a quick overview.

The **[Touying Ambrosia repository](https://github.com/inspiros/touying-ambrosia)** is the main home for shared examples and documentation:

- [Illustrated manual](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/manual.pdf), [public API](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/api.md), and [complete demo](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/demo.typ).
- [Palettes and showcase](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/palettes.md).
- [Blocks, citations, and slide helpers](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/utilities.md).
- [Image caption placement](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/image-slides.md), including bands and inset corner cards.
- [Authors, linked affiliations, and fitted footers](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/people.md).
- [Institution wrapper extensions](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/extensions.md).

Use `greyc-theme` in place of `ambrosia-theme` in those examples. All core authoring helpers are available, including scoped forms such as `ambrosia.block`, `ambrosia.palette-showcase`, `ambrosia.affiliation`, and `ambrosia.navigation-buttons`. Native `#cite` / `@key` citations share the compact author-year labels by default. Configurable header/sidebar navigation, breadcrumbs, section progress, and optional transparent PDF controls are documented in the core's [navigation guide](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/docs/navigation.md).

The optional `#ambrosia-credit-card()` uses GREYC Ambrosia branding, a static
repository QR, and a link to the neutral core. `qr: false` hides the code. It
works in ordinary slides and endings; nothing is inserted automatically. See
the core's [credit/acknowledgement example](https://github.com/inspiros/touying-ambrosia/blob/v0.1.0/examples/credits.typ).

The [GREYC card example](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/examples/credits.typ) reuses that renderer for a separate
lab-information card with the laboratory website QR.

## Contributing

For checkout setup, tests, artwork generation, and release preparation, see
[CONTRIBUTING.md](https://github.com/inspiros/touying-greyc-ambrosia/blob/v0.2.0/CONTRIBUTING.md).

## License

Source code is MIT licensed; see [LICENSE](LICENSE). GREYC/team logos under
`assets/logos/greyc/`, partner marks under `assets/logos/institutions/`, the lab
website QR (`assets/qr/qr-code-greyc-light.svg`), and the
legacy cover photograph (`assets/greyc-cover.webp`) retain their respective
owners' rights and are not relicensed by this software license.

Lab and institutional logos and the cover photograph come from GREYC's
[LaTeX and PowerPoint templates](https://www.greyc.fr/intranet/#1647886250909-16337474-b9c8).
Team logos and their usage guidelines are available from the
[GREYC communication resources](https://giguete.users.greyc.fr/com/).
