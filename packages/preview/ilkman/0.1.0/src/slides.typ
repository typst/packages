// ilkman — slides (Touying theme)
#import "core.typ": *
#import "doc.typ": slot-content
#import "cover/cover.typ": render-cover, cover-options
#import "@preview/touying:0.8.0": *

#let _base-dense = state("ilkman-base-dense", 1.0)

/// Change density for the following slides: "low", "mid", "high", a number,
/// or `auto` to go back to the presentation default.
#let im-dense(d) = [#metadata((ilkman-dense: d))<ilkman-dense>]

// Effective density at this point: the slide's own `dense:` argument, else
// the last im-dense marker up to the end of the current slide.
#let _density-here(local) = {
  if local != auto { return local }
  let ends = query(selector(<ilkman-slide-end>).after(here()))
  let sel = if ends.len() > 0 { selector(<ilkman-dense>).before(ends.first().location()) } else { selector(<ilkman-dense>) }
  let ms = query(sel)
  if ms.len() > 0 { ms.last().value.ilkman-dense } else { auto }
}

/// Next step of an animation (alias of Touying's `pause`).
#let im-pause = pause

/// Speaker note (visible only in presenter view / pdfpc).
#let im-speaker(body) = speaker-note(body)

#let _apply-density(local, body) = context {
  let c = ctx()
  let d = _density-here(local)
  let f = if d == auto { _base-dense.get() } else { density-factor(d) }
  let sz = c.sizes
  set text(size: sz.body * f)
  set par(spacing: 0.9em * calc.max(0.7, f))
  set list(spacing: 0.75em * calc.max(0.6, f))
  set enum(spacing: 0.75em * calc.max(0.6, f))
  set block(spacing: 0.9em * calc.max(0.7, f))
  pad(x: 0.8cm * f, body)
  [#metadata("end")<ilkman-slide-end>]
}

#let _title-bar(self, title, local) = context {
  let c = ctx()
  let d = _density-here(local)
  let f = if d == auto { _base-dense.get() } else { density-factor(d) }
  let hf = heading-factor(f)
  block(below: 0.8em * f, {
    text(..font-args(c.fonts, "heading"), weight: c.fonts.heading.weight, size: c.sizes.body * c.sizes.h2 * hf, fill: c.pal.primary, title)
    v(-0.3em)
    line(length: 2.2cm, stroke: 2.5pt + c.pal.accent)
  })
}

/// A content slide.
///
/// ```typst
/// #im-slide(title: "SIP nedir?", dense: "high")[ ... ]
/// ```
/// Slides are also created by `==` headings.
#let im-slide(title: auto, dense: auto, config: (:), repeat: auto, setting: body => body, composer: auto, ..bodies) = touying-slide-wrapper(self => {
  let t = if title == auto { utils.display-current-heading(level: 2) } else { title }
  let self = utils.merge-dicts(self, config-common(subslide-preamble: _title-bar(self, t, dense)))
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: body => _apply-density(dense, setting(body)),
    composer: composer,
    ..bodies,
  )
})

/// Title slide: same ten styles as im-cover, laid out for 16:9.
#let im-title-slide(..args) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(margin: 0pt, header: none, footer: none))
  touying-slide(self: self, context {
    let c = ctx()
    let r = cover-options(c, args)
    let out = render-cover(c, r.info, r.opts, page.width, page.height, wide: true)
    place(top + left, rect(width: page.width, height: page.height, fill: out.bg, stroke: none))
    out.body
  })
})

/// Section divider slide (also produced by `=` headings).
#let im-section-slide(config: (:), body) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(fill: self.colors.primary, header: none, footer: none, margin: 2cm))
  touying-slide(self: self, config: config, context {
    let c = ctx()
    set align(left + horizon)
    text(size: c.sizes.body * 0.8, fill: white.transparentize(30%), weight: "bold", tracking: 0.06em, upper(tr(c, "chapter")) + " " + str(calc.max(1, query(heading.where(level: 1).before(here())).len())))
    v(0.2em)
    text(..font-args(c.fonts, "heading"), weight: c.fonts.heading.weight, size: c.sizes.body * c.sizes.h1, fill: white, utils.display-current-heading(level: 1))
    body
  })
})

/// Start a new section: `#im-section[SIP Temelleri]` (same as `= SIP Temelleri`).
#let im-section(title) = heading(depth: 1, title)

/// One big message on a colored slide.
#let im-focus(config: (:), body) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(self, config-common(freeze-slide-counter: true), config-page(fill: self.colors.primary, header: none, footer: none, margin: 2cm))
  touying-slide(self: self, config: config, context {
    let c = ctx()
    set align(center + horizon)
    text(..font-args(c.fonts, "heading"), weight: c.fonts.heading.weight, size: c.sizes.body * 1.6, fill: white, body)
  })
})

#let _notes(self: none, ..args) = touying-notes(
  self: self,
  header: self => pad(x: 32pt, y: 16pt, text(fill: white, utils.display-current-heading(depth: self.slide-level))),
  header-fill: self.colors.primary,
  fill: white,
  ..args,
)

/// Presentation setup.
///
/// ```typst
/// #show: im-slides.with(title: [SIP Temelleri], author: "ilker",
///   fonts: "fira", colors: "okyanus", dense: "mid")
/// ```
#let im-slides(
  lang: "tr",
  fonts: "fira",
  colors: "okyanus",
  aspect: "16-9",
  dense: "mid",
  mode: "light",
  progress: true,
  footer: (left: "title", center: none, right: "page"),
  title: none,
  subtitle: none,
  author: none,
  date: auto,
  version: none,
  ..args,
  body,
) = {
  let pal0 = resolve-palette(colors)
  let pal = if mode == "dark" {
    (ink: pal0.wash, primary: pal0.accent, accent: pal0.tint, tint: pal0.primary.darken(10%), wash: pal0.ink.lighten(8%))
  } else { pal0 }
  let page-bg = if mode == "dark" { pal0.ink } else { white }
  let fnt = resolve-fonts(fonts)
  let sz = size-scales.slides
  let the-date = if date == auto { datetime.today() } else { date }
  let info = (title: title, subtitle: subtitle, author: author, date: the-date, version: version)
  let c = (mode: "slides", lang: lang, pal: pal, fonts: fnt, sizes: sz, note-column: 0, info: info,
    page-bg: page-bg, box-ink: pal0.ink, light: pal0)
  let base-f = density-factor(dense)

  let footer-fn(self) = context {
    let c = ctx()
    let s = (left: none, center: none, right: none) + (if footer == none { (:) } else { footer })
    let key(k) = if k == "page" { utils.slide-counter.display() } else if k == "page-total" { utils.slide-counter.display() + " / " + utils.last-slide-number } else if k == "section" or k == "chapter" { utils.display-current-heading(level: 1) } else { slot-content(c, k) }
    set text(size: 0.55em, fill: c.pal.ink.lighten(45%))
    block(width: 100%, inset: (x: 1.2cm, bottom: 0.5em), grid(
      columns: (1fr, auto, 1fr),
      align(left, key(s.left)), align(center, key(s.center)), align(right, key(s.right)),
    ))
    if progress {
      place(bottom + left, components.progress-bar(height: 3pt, c.pal.primary, c.pal.tint))
    }
  }

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect),
      margin: (x: 0.6cm, top: 1.1cm, bottom: 2.1cm),
      fill: page-bg,
      footer: footer-fn,
      footer-descent: 0.8cm,
    ),
    config-common(
      slide-fn: im-slide,
      new-section-slide-fn: im-section-slide,
      notes-fn: _notes,
      zero-margin-footer: true,
    ),
    config-colors(
      primary: pal.primary,
      neutral-lightest: page-bg,
      neutral-darkest: pal.ink,
    ),
    config-methods(
      init: (self: none, body) => {
        ctx-state.update(c)
        _base-dense.update(base-f)
        set document(title: if title != none { plain(title) } else { none }, author: if author != none { plain(author) } else { () })
        set text(lang: lang, ..font-args(fnt, "body"), size: sz.body * base-f, fill: pal.ink)
        set par(justify: false, leading: 0.6em)
        set list(marker: (text(fill: pal.primary, sym.square.filled.small), text(fill: pal.accent, sym.dash.en)))
        show raw: set text(..font-args(fnt, "code"))
        show raw.where(block: true): set text(size: raw-em(sz.code))
        show raw.where(block: false): it => box(fill: pal.wash, stroke: 0.4pt + pal.tint, inset: (x: 3pt), outset: (y: 3pt), radius: 2pt, text(size: raw-em(sz.inline), fill: pal.ink, it))
        show link: set text(fill: pal.accent)
        show strong: set text(fill: pal.primary)
        show footnote.entry: set text(size: 0.6em)
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    ..args,
  )
  body
}
