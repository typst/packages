#import "../touying.typ": *
#import "../colors.typ"
#import "../components.typ" as ambrosia-components
#import "../utils.typ" as ambrosia-utils
#import "../citations.typ" as footcite
#import "slides.typ": *
#import "chrome.typ"
#import "numbering.typ": slide-number
#import "flavors.typ": get-flavor
#import "notes.typ": notes
#import "../palettes.typ"
#import "../assets.typ"
#import "../utils/people.typ": short-authors
#import "../navigation.typ": get-navigation
#import "../title-layouts.typ": get-title-layout
#import "../ending-layouts.typ": get-ending-layout
#import "content.typ": apply-code-style, apply-quote-style

/// Configure a flavor's layout and semantic palette, then apply user overrides.
/// Institution wrappers can supply a flavor descriptor and branding callbacks.
/// See docs/extensions.md and docs/palettes.md for supported configuration.
/// Outline leaders use outline-fill (content/none); see docs/agendas.md.
/// Appendix slide labels use appendix-numbering (pattern/function/none) and
/// appendix-total (boolean); see docs/people.md. A custom footer-ad overrides both.
#let ambrosia-theme(
  flavor: "minimal",
  palette: "light",
  aspect-ratio: "16-9",
  align: top,
  alpha: 20%,
  title: self => ambrosia-utils.display-current-heading(
    depth: self.slide-level,
    selector-filter: ambrosia-utils.appendix-filter,
  ),
  subtitle: self => ambrosia-utils.prose-display-current-headings(
    level: self.slide-level + 1,
    depth: self.slide-level + 1,
    selector-filter: ambrosia-utils.appendix-filter,
    numbered: false,
    dir: ltr,
    spacing: 0.5em,
  ),
  logos: none,
  primary-logos: auto,
  logo-focus: auto,
  header-logo: auto,
  header-a-columns: (1fr, 1fr),
  header-aa: self => ambrosia-utils.display-current-heading(
    depth: 1,
    level: 1,
    selector-filter: ambrosia-utils.appendix-filter,
  ),
  header-ab: self => ambrosia-utils.display-current-heading(
    depth: 2,
    level: 2,
    selector-filter: ambrosia-utils.appendix-filter,
    style: current-heading => current-heading.body,
  ),
  footer-a-columns: auto,
  footer-logo: auto,
  footer-logo-height: 1.1em,
  footer-aa: self => short-authors(self.info),
  footer-ab: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-ac: self => utils.display-info-date(self),
  footer-ad: self => slide-number(self),
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
  title-logo-distribution: "equal",
  title-fit: true,
  title-min-scale: 65%,
  ending-layout: auto,
  ending-logos: auto,
  block-style: auto,
  watermark: auto,
  watermark-logo: none,
  watermark-opacity: 5.5%,
  watermark-height: 50%,
  agenda-style: "list",
  agenda-text-size: 1.15em,
  outline-fill: none,
  outline-min-scale: 80%,
  footer-min-scale: 80%,
  author-columns: auto,
  affiliation-numbering: "1",
  brand-color: auto,
  ..args,
  body,
) = {
  footcite.footcite-once.update(footcite-once)
  assert(footcite-marker in footcite.marker-modes, message: "Unknown footcite marker mode: " + str(footcite-marker))
  footcite.footcite-marker.update(footcite-marker)
  assert(bibliography-marker in ("author-year", "native"), message: "Bibliography marker must be author-year or native.")
  assert(cite-marker in ("author-year", "native"), message: "Cite marker must be author-year or native.")
  assert(type(navigation-buttons) == bool, message: "Navigator must be true or false.")
  assert(type(navigation-buttons-opacity) == ratio and 0% <= navigation-buttons-opacity and navigation-buttons-opacity <= 100%,
    message: "Navigator opacity must be a percentage between 0% and 100%, such as 35%.")

  assert(type(agenda-text-size) == length, message: "Agenda text size must be a length, such as 1.15em or 20pt.")
  assert(agenda-style in ("list", "cards", "path"), message: "Agenda style must be list, cards, or path.")
  assert(outline-fill == none or type(outline-fill) in (content, str),
    message: "Outline fill must be content or none.")
  let definition = get-flavor(flavor)
  assert(code-style in ("surface", "plain"), message: "Code style must be surface or plain.")
  assert(quote-style in ("stripe", "plain"), message: "Quote style must be stripe or plain.")
  assert(primary-logos == auto or primary-logos == none or type(primary-logos) in (array, dictionary),
    message: "primary-logos must be auto, none, or a collection of logo content/callbacks.")
  assert(title-logo-distribution in ("equal", "grouped"), message: "Title logo distribution must be equal or grouped.")
  if title-layout != auto { let _ = get-title-layout(title-layout) }
  if ending-layout != auto { let _ = get-ending-layout(ending-layout) }
  assert(ending-logos == auto or ending-logos == none or type(ending-logos) in (array, dictionary),
    message: "ending-logos must be auto, none, or a collection of logo content/callbacks.")
  assert(title-logos == auto or title-logos == none or type(title-logos) in (array, dictionary),
    message: "title-logos must be auto, none, or a collection of logo content/callbacks.")
  let _ = get-navigation(if navigation == auto { definition.navigation } else { navigation })
  assert(appendix-numbering == none or type(appendix-numbering) in (str, function),
    message: "Appendix numbering must be a Typst numbering pattern, function, or none.")
  assert(type(appendix-total) == bool, message: "Appendix total must be true or false.")
  assert(type(section-progress) == bool, message: "Section progress must be true or false.")
  if navigation-side != auto { assert(navigation-side in ("left", "right"), message: "Navigation side must be left or right.") }
  if navigation-width != auto { assert(type(navigation-width) == length, message: "Navigation width must be a length.") }
  if navigation-depth != auto { assert(type(navigation-depth) == int and navigation-depth > 0, message: "Navigation depth must be a positive integer.") }
  assert(sidebar-background == auto or sidebar-background == none or type(sidebar-background) == color,
    message: "Sidebar background must be auto, none, or a color.")
  assert(footer-logo == auto or type(footer-logo) == bool, message: "Footer logo must be true, false, or auto.")
  assert(type(footer-logo-height) == length, message: "Footer logo height must be a length, such as 1.1em.")
  assert(watermark == auto or type(watermark) == bool, message: "Theme watermark must be true, false, or auto.")
  assert(type(watermark-opacity) == ratio and 0% <= watermark-opacity and watermark-opacity <= 100%,
    message: "Watermark opacity must be a percentage between 0% and 100%, such as 5.5%.")
  assert(0% < watermark-height and watermark-height <= 100%, message: "Watermark height must be between 0% and 100%.")
  assert(0% < outline-min-scale and outline-min-scale <= 100%, message: "Outline minimum scale must be between 0% and 100%.")
  assert(0% < footer-min-scale and footer-min-scale <= 100%, message: "Footer minimum scale must be between 0% and 100%.")
  assert(author-columns == auto or (type(author-columns) == int and 1 <= author-columns and author-columns <= 3),
    message: "Author columns must be auto, 1, 2, or 3.")
  let overrides = utils.merge-dicts((:), ..args.pos())
  let primary = overrides.at("colors", default: (:)).at("primary", default: brand-color)
  let palette = palettes.resolve(palette, primary: primary)
  let block-style = if block-style == auto { definition.block-style } else { block-style }
  assert(block-style in ambrosia-components.block-style-names, message: "Unknown default block style: " + str(block-style))
  assert(type(title-fit) == bool, message: "title-fit must be true or false.")
  assert(0% < title-min-scale and title-min-scale <= 100%, message: "title-min-scale must be between 0% and 100%.")
  show: touying-slides.with(
    config-info(affiliation-numbering: affiliation-numbering),
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      fill: overrides.at("colors", default: (:)).at("background", default: palette.background),
      header: if definition.header-renderer == auto { chrome.header } else { definition.header-renderer },
      footer: if definition.footer-renderer == auto { chrome.footer } else { definition.footer-renderer },
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: definition.top-margin, bottom: 1em, x: 2.5em),
    ),
    config-common(
      slide-level: definition.slide-level,
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      receive-body-for-new-section-slide-fn: true,
      notes-fn: notes,
      show-strong-with-alert: false,
    ),
    config-methods(
      cover: footcite.hiding-cover,
      init: (self: none, body) => {
        set text(size: self.store.text-size, fill: self.colors.foreground)
        set text(font: self.store.font) if self.store.font != auto
        show raw: set text(size: 0.88em)
        show raw: set text(font: self.store.mono-font)
        show raw: set raw(theme: if self.store.dark { assets.read-asset(assets.asset-paths.code-theme-dark) } else { auto })
        show table: set table(stroke: 0.03em + self.colors.border)
        show table: set text(size: self.store.table-text-size)
        show: ambrosia-components.apply-marker-style.with(color: self.colors.primary)
        show: ambrosia-components.apply-alert-style.with(color: self.colors.primary)
        show: ambrosia-components.apply-tone-style.with(muted: self.colors.muted)
        show: ambrosia-components.apply-context-components.with(self: self)
        show: apply-code-style.with(self: self)
        show: apply-quote-style.with(self: self)

        show figure.caption: set text(size: self.store.caption-text-size)
        show figure.where(kind: table): set figure.caption(position: top)
        set footnote.entry(
          separator: line(length: 30%, stroke: 0.03em + self.colors.muted),
          gap: 0.4em,
          indent: 0em,
        )
        show footnote.entry: set text(size: self.store.footnote-text-size, fill: self.colors.muted)
        show: footcite.apply-citation-entry-style
        show footnote.entry: it => context {
          let ink = if page.fill != self.page.fill and type(page.fill) == color and palettes.contrast(self.colors.muted, page.fill) < 4.5 {
            palettes.on-color(page.fill)
          } else { self.colors.muted }
          set text(fill: ink)
          it
        }
        show: footcite.apply-inline-citation-style.with(marker: self.store.cite-marker)
        show link: it => if type(it.dest) == str {
          context {
            let ink = if page.fill != self.page.fill and type(page.fill) == color and palettes.contrast(self.colors.primary, page.fill) < 4.5 {
              palettes.on-color(page.fill)
            } else { self.colors.primary }
            set text(fill: ink)
            it
          }
        } else {
          it
        }

        show outline.entry: set outline.entry(fill: repeat[#text(size: 0.5em)[.]])
        show heading: set text(fill: self.colors.primary)

        body
      },
      // alert: utils.alert-with-primary-color,
      alert: ambrosia-components.render-alert,
      ambrosia-block: ambrosia-components.render-ambrosia-block,
      footcite: (self: none, ..args) => footcite.footcite(..args),
    ),
    config-colors(
      primary: palette.accent,
      primary-light: palette.surface-alt,
      primary-lighter: if palette.dark { palette.muted } else { palette.surface-alt },
      primary-lightest: palette.at("primary-lightest", default: if palette.dark { palette.surface } else { palette.surface-alt }),
      primary-dark: if palette.dark { palette.accent } else { palette.accent.darken(20%) },
      secondary: palette.at("secondary", default: palette.surface-alt),
      tertiary: palette.at("tertiary", default: palette.surface-alt),
      neutral-light: colors.grey,
      neutral-lighter: colors.grey.mix(colors.white),
      neutral-lightest: colors.white,
      neutral-dark: colors.charcoal,
      neutral-darker: colors.charcoal.mix(colors.black),
      neutral-darkest: colors.black,
      background: palette.background,
      foreground: palette.foreground,
      surface: palette.surface,
      surface-alt: palette.surface-alt,
      muted: palette.muted,
      border: palette.border,
      on-accent: palette.on-accent,
      accent-strong: palette.accent-strong,
      on-accent-strong: palette.on-accent-strong,
      cover: palette.cover,
      on-cover: palette.on-cover,
      chrome: palette.chrome,
      on-chrome: palette.on-chrome,
      chrome-muted: palette.chrome-muted,
      info: palette.info,
      success: palette.success,
      warning: palette.warning,
      danger: palette.danger,
      neutral: palettes.readable-accent(palette.muted, (palette.background, palette.surface, palette.surface-alt), dark: palette.dark),
    ),
    // save the variables for later use
    config-store(
      flavor: definition.name,
      flavor-definition: definition,
      palette: palette.name,
      bibliography-marker: bibliography-marker,
      cite-marker: cite-marker,
      breadcrumb-title: auto,
      navigation: navigation,
      navigation-side: navigation-side,
      navigation-width: navigation-width,
      navigation-depth: navigation-depth,
      sidebar-background: sidebar-background,
      section-progress: section-progress,
      navigation-buttons: navigation-buttons,
      navigation-buttons-opacity: navigation-buttons-opacity,
      navigation-buttons-actions: navigation-buttons-actions,
      palette-definition: palette,
      dark: palette.dark,
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
      block-shadow: definition.block-shadow,
      block-style: block-style,
      watermark-slides: if watermark == auto { definition.watermark-slides }
        else if watermark { ("title", "outline", "section") } else { () },
      watermark-logo: watermark-logo,
      watermark-opacity: watermark-opacity,
      watermark-height: watermark-height,
      agenda-style: agenda-style,
      agenda-text-size: agenda-text-size,
      outline-fill: outline-fill,
      outline-min-scale: outline-min-scale,
      footer-min-scale: footer-min-scale,
      author-columns: author-columns,
      align: align,
      alpha: alpha,
      title: title,
      subtitle: subtitle,
      logo-focus: logo-focus,
      logos: logos,
      primary-logos: primary-logos,
      header-logo: header-logo,
      header-a-columns: header-a-columns,
      header-aa: header-aa,
      header-ab: header-ab,
      footer-a-columns: footer-a-columns,
      footer-logo: if footer-logo == auto { definition.footer-logo } else { footer-logo },
      footer-logo-height: footer-logo-height,
      footer-aa: footer-aa,
      footer-ab: footer-ab,
      footer-ac: footer-ac,
      footer-ad: footer-ad,
      appendix-numbering: appendix-numbering,
      appendix-total: appendix-total,
      progress-bar: progress-bar,
      header-a: chrome.header-a,
      header-b: chrome.header-b,
      footer-a: chrome.footer-a,
      footer-b: chrome.footer-b,
    ),
    ..args,
  )

  body
}
