#import "../core.typ": *
#import "../assets.typ"
#import "../colors.typ"
#import "flavors.typ": get-flavor
#import "../branding.typ"
#import "../palettes.typ"

#let greyc = context {
  let light = type(text.fill) == color and text.fill.rgb().components().slice(0, 3).sum() > 165%
  box[
    #box(branding.logo(variant: "small", light: light, height: .7em))
    #h(.1em)#text(fill: if light { colors.logo-light } else { colors.primary })[#strong("GREYC", delta: 200)]
  ]
}

/// Touying GREYC theme.
///
/// Shared options follow `ambrosia-theme`; GREYC supplies its own branding.
/// For logos, header-logo, logo-focus and watermark-logo, auto selects the
/// GREYC default; none hides the corresponding mark. Callback options with
/// auto inherit the core renderer. Positional Touying configurations apply last.
#let greyc-theme(
  flavor: "legacy",
  palette: "greyc-light",
  team: none,
  team-accent: false,
  // BEGIN GENERATED PARAMETERS
  aspect-ratio: "16-9",
  align: top,
  alpha: 20%,
  title: auto,
  subtitle: auto,
  logos: auto,
  primary-logos: auto,
  logo-focus: auto,
  header-logo: auto,
  header-a-columns: (1fr, 1fr),
  header-aa: auto,
  header-ab: auto,
  footer-a-columns: auto,
  footer-logo: auto,
  footer-logo-height: 1.1em,
  footer-aa: auto,
  footer-ab: auto,
  footer-ac: auto,
  footer-ad: auto,
  appendix-numbering: "i",
  appendix-total: false,
  progress-bar: true,
  navigation: auto,
  navigation-side: auto,
  navigation-width: auto,
  navigation-depth: auto,
  sidebar-background: none,
  section-progress: false,
  navigation-buttons: false,
  navigation-buttons-opacity: 35%,
  navigation-buttons-actions: ("previous", "section", "outline", "next"),
  footcite-once: true,
  footcite-marker: "author-year",
  cite-marker: "author-year",
  bibliography-marker: "author-year",
  font: auto,
  mono-font: "DejaVu Sans Mono",
  text-size: 18pt,
  table-text-size: 0.85em,
  caption-text-size: 0.8em,
  footnote-text-size: 0.65em,
  code-style: "surface",
  quote-style: "stripe",
  title-logo-height: 1.8em,
  title-layout: auto,
  title-logos: auto,
  title-logo-distribution: "grouped",
  title-fit: true,
  title-min-scale: 65%,
  ending-layout: auto,
  ending-logos: auto,
  block-style: auto,
  watermark: auto,
  watermark-logo: auto,
  watermark-opacity: 5.5%,
  watermark-height: 50%,
  agenda-style: "list",
  agenda-text-size: 1.15em,
  outline-fill: repeat[.],
  outline-min-scale: 80%,
  footer-min-scale: 80%,
  author-columns: auto,
  affiliation-numbering: "1",
  brand-color: auto,
  // END GENERATED PARAMETERS
  datetime-format: "[day]/[month]/[year]",
  ..args,
  body,
) = {
  assert(type(team-accent) == bool, message: "team-accent must be true or false.")
  let definition = get-flavor(flavor)
  let team = branding.normalize-team(team)
  let default-logo = self => context branding.logo(team: team, lang: text.lang,
    light: palettes.prefer-light(self.store.at("logo-background", default: self.page.fill)))
  let default-logo-light = self => context branding.logo(team: team, lang: text.lang, light: true)
  let default-logo-focus = self => context branding.logo(team: team, lang: text.lang, light: true, opacity: 60%)
  let default-header-logo = self => context {
    let definition = extensions.current-flavor(self)
    let style = definition.header-logo-style
    let background = self.store.at("logo-background", default: self.page.fill)
    let light = palettes.prefer-light(if background == none { self.page.fill } else { background })
    if style == "traits" and team == none {
      assets.logo-greyc-with-traits(height: 100%, transform: data => if light {
        bytes(assets.colorize-svg(data, source: colors.logo, target: colors.logo-light))
      } else { data })
    } else {
      branding.logo(team: team, variant: if team == none { "full" } else { "small" }, lang: text.lang,
        light: light)
    }
  }
  let logo-paths = (
    nu: assets.asset-paths.logo-nu,
    unicaen: assets.asset-paths.logo-unicaen,
    ensicaen: assets.asset-paths.logo-ensicaen,
    cnrs: assets.asset-paths.logo-cnrs,
  )
  let default-logos = (:)
  for (key, path) in logo-paths {
    default-logos.insert(key, self => {
      if palettes.prefer-light(self.store.at("logo-background", default: self.page.fill)) {
        image(bytes(assets.colorize-svg(path, source: colors.icons, target: colors.logo-light)))
      } else { image(assets.read-asset(path)) }
    })
  }
  let custom-primary = primary-logos != auto
  let options = (
    flavor: definition, palette: palettes.definition(palette),
    // BEGIN GENERATED FORWARDING
    aspect-ratio: aspect-ratio,
    align: align,
    alpha: alpha,
    primary-logos: primary-logos,
    header-a-columns: header-a-columns,
    footer-a-columns: footer-a-columns,
    footer-logo: footer-logo,
    footer-logo-height: footer-logo-height,
    appendix-numbering: appendix-numbering,
    appendix-total: appendix-total,
    progress-bar: progress-bar,
    navigation: navigation,
    navigation-side: navigation-side,
    navigation-width: navigation-width,
    navigation-depth: navigation-depth,
    sidebar-background: sidebar-background,
    section-progress: section-progress,
    navigation-buttons: navigation-buttons,
    navigation-buttons-opacity: navigation-buttons-opacity,
    navigation-buttons-actions: navigation-buttons-actions,
    footcite-once: footcite-once,
    footcite-marker: footcite-marker,
    cite-marker: cite-marker,
    bibliography-marker: bibliography-marker,
    font: font,
    mono-font: mono-font,
    text-size: text-size,
    table-text-size: table-text-size,
    caption-text-size: caption-text-size,
    footnote-text-size: footnote-text-size,
    code-style: code-style,
    quote-style: quote-style,
    title-logo-height: title-logo-height,
    title-layout: title-layout,
    title-logos: title-logos,
    title-logo-distribution: title-logo-distribution,
    title-fit: title-fit,
    title-min-scale: title-min-scale,
    ending-layout: ending-layout,
    ending-logos: ending-logos,
    block-style: block-style,
    watermark: watermark,
    watermark-opacity: watermark-opacity,
    watermark-height: watermark-height,
    agenda-style: agenda-style,
    agenda-text-size: agenda-text-size,
    outline-fill: outline-fill,
    outline-min-scale: outline-min-scale,
    footer-min-scale: footer-min-scale,
    author-columns: author-columns,
    affiliation-numbering: affiliation-numbering,
    brand-color: brand-color,
    ..if title == auto { (:) } else { (title: title,) },
    ..if subtitle == auto { (:) } else { (subtitle: subtitle,) },
    ..if header-aa == auto { (:) } else { (header-aa: header-aa,) },
    ..if header-ab == auto { (:) } else { (header-ab: header-ab,) },
    ..if footer-aa == auto { (:) } else { (footer-aa: footer-aa,) },
    ..if footer-ab == auto { (:) } else { (footer-ab: footer-ab,) },
    ..if footer-ac == auto { (:) } else { (footer-ac: footer-ac,) },
    ..if footer-ad == auto { (:) } else { (footer-ad: footer-ad,) },
    // END GENERATED FORWARDING
    watermark-logo: if watermark-logo == auto { branding.watermark-data } else { watermark-logo },
    header-logo: if header-logo != auto { header-logo }
      else if definition.footer-logo and not definition.header-logo { none }
      else if custom-primary { auto } else { default-header-logo },
    logos: if logos == auto { default-logos } else { logos },
    logo-focus: if logo-focus != auto { logo-focus } else if custom-primary { auto } else { default-logo-focus },
  ) + args.named()
  show: ambrosia-theme.with(
    ..options,
    config-common(datetime-format: datetime-format),
    config-info(logo: default-logo, logo-light: default-logo-light),
    config-store(
      greyc-team-color: if team == none { none } else { branding.team-color(team) },
      greyc-team-accent: team != none and team-accent,
      credit-project: (
        name: "touying-greyc-ambrosia",
        url: "https://github.com/inspiros/touying-greyc-ambrosia",
        // The dark-surface artwork lightens every hue, not only the purple.
        logo: self => image(assets.read-asset(if palettes.prefer-light(self.store.logo-background) {
          assets.asset-paths.theme-logo-dark
        } else { assets.asset-paths.theme-logo })),
        qr: image(assets.read-asset(assets.asset-paths.credit-qr)),
        based-on: (name: "Touying Ambrosia", url: "https://github.com/inspiros/touying-ambrosia"),
      ),
    ),
    ..args.pos(),
  )
  body
}
