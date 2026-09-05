#import "@preview/touying:0.7.4": *
#import "themes/base.typ": slide, section-slide as new-section-slide

#import "palettes/academic.typ" as _pal-academic
#import "palettes/dark.typ" as _pal-dark
#import "palettes/minimal.typ" as _pal-minimal
#import "palettes/vibrant.typ" as _pal-vibrant
#import "palettes/brand.typ" as _pal-brand

#import "themes/academic.typ": theme as _theme-academic
#import "themes/dark.typ": theme as _theme-dark
#import "themes/minimal.typ": theme as _theme-minimal
#import "themes/vibrant.typ": theme as _theme-vibrant
#import "themes/brand.typ": theme as _theme-brand

#import "gadgets.typ": make as make-gadgets
#import "layouts.typ": make as make-layouts

// Content sizes, captions, and footer metadata share one type scale.
#import "scale.typ": sizes

// Palettes: pure colour data. Pick one and bind gadgets/layouts to it.
#let palettes = (
  academic: _pal-academic.palette,
  dark: _pal-dark.palette,
  minimal: _pal-minimal.palette,
  vibrant: _pal-vibrant.palette,
  brand: _pal-brand.palette,
)

// Fonts per theme (sans/serif/mono stacks).
#let fonts = (
  academic: _pal-academic.fonts,
  dark: _pal-dark.fonts,
  minimal: _pal-minimal.fonts,
  vibrant: _pal-vibrant.fonts,
  brand: _pal-brand.fonts,
)

// Themes: touying show-rules. `themes.<name>.with(config-info(...))`.
#let themes = (
  academic: _theme-academic,
  dark: _theme-dark,
  minimal: _theme-minimal,
  vibrant: _theme-vibrant,
  brand: _theme-brand,
)

// Factories: call with the chosen palette to get bound gadget/layout dicts.
#let gadgets = make-gadgets
#let layouts = make-layouts

// Cover metadata uses the same palette as the content slides.
#let title-slide(config: (:), extra: none, ..args) = touying-slide-wrapper(self => {
  let pal = self.store.palette
  let sizes = self.store.sizes
  let info = self.info + args.named()
  self.info = info
  touying-slide(self: self, config: utils.merge-dicts(
    config-common(freeze-slide-counter: true),
    config-page(header: none, footer: none, margin: 48pt), config), {
    set align(left + horizon)
    let parts = ()
    if info.institution != none {
      parts += (text(size: sizes.caption, fill: pal.text_soft, info.institution), 24pt)
    }
    parts += (text(size: sizes.xlarge, weight: "bold", fill: pal.ink, info.title),)
    if info.subtitle != none {
      parts += (14pt, text(size: sizes.large, fill: pal.text_soft, info.subtitle))
    }
    parts += (22pt, rect(width: 52pt, height: 3pt, fill: pal.accent_deep, stroke: none), 22pt)
    if info.author != none { parts += (text(size: sizes.normal, info.author),) }
    if info.date != none {
      parts += (10pt, text(size: sizes.caption, fill: pal.text_soft, utils.display-info-date(self)))
    }
    if extra != none { parts += (12pt, extra) }
    stack(dir: ttb, spacing: 0pt, ..parts)
    if info.logo != none { place(top + right, utils.call-or-display(self, info.logo)) }

  })
})

#let focus-slide(body) = touying-slide-wrapper(self => {
  let pal = self.store.palette
  let sizes = self.store.sizes
  touying-slide(self: self, config: config-page(
    fill: pal.primary, header: none, footer: none, margin: 64pt), {
    set align(left + horizon)
    text(size: sizes.xlarge, weight: "bold", fill: pal.on_primary, body)
  })
})
