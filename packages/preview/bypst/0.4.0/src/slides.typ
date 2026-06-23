// ===================================================================
// BYPST — SLIDE TYPE DEFINITIONS
// base-slide (the flexible base) plus presets and special slides.
// ===================================================================

#import "@preview/touying:0.7.3": (
  config-common, config-page, touying-slide, touying-slide-wrapper, utils,
)
#import "@preview/codetastic:0.2.2": qrcode
#import "config.typ": *
#import "helpers.typ": *

// -------------------------------------------------------------------
// Content Slides
// -------------------------------------------------------------------

/// The flexible base content slide: title/subtitle live in a native Touying
/// header block (the divider is the header's bottom edge), over a fully native
/// body. Every BIPS chrome component is independently toggleable. `bips-slide`
/// and `empty-slide` are presets over this function.
///
/// Because the body is native Touying content, `#pause`, `composer` (multi-pane
/// via multiple trailing blocks), and multi-block bodies all work directly.
///
/// Toggles:
/// - `show-logo` — top-right logo (default true).
/// - `page-number` — show the page number (default true).
/// - `show-line` — divider line under the header (default true; no-op with no header).
/// - `count` — advance the slide counter (default true; frozen if false).
///
/// With no `title`/`subtitle` the header is omitted and the body fills from the
/// top margin. Slide-level `config` / `repeat` / `composer` / `setting` overrides
/// are forwarded.
#let base-slide(
  title: none,
  subtitle: none,
  show-logo: true,
  page-number: true,
  show-line: true,
  count: true,
  content-align: none,
  title-size: none,
  subtitle-size: none,
  text-size: none,
  code-block-scale: none,
  code-inline-scale: none,
  ..args,
) = touying-slide-wrapper(self => {
  let named = args.named()
  let user-config = named.at("config", default: (:))
  let repeat = named.at("repeat", default: auto)
  let composer = named.at("composer", default: auto)
  let user-setting = named.at("setting", default: body => body)
  let has-header = title != none or subtitle != none

  let body-gap = 0.8cm
  let top-margin = (
    1.55cm + slide-title-area-height + _title-divider-gap + body-gap
  )

  // Resolve chrome sizes once from the theme store.
  let pn-size = self.store.page-number
  let the-title-size = pick-first(title-size, self.store.slide-title)
  let the-title-only-size = pick-first(title-size, self.store.slide-title-only)
  let the-subtitle-size = pick-first(subtitle-size, self.store.slide-subtitle)
  let the-align = self.store.title-align

  let header(self) = {
    if page-number {
      place(
        top + right,
        dx: 1.25cm,
        dy: 3.75cm,
        _page-number-content(size: pn-size),
      )
    }
    _title-area(
      title,
      subtitle,
      title-size: the-title-size,
      title-only-size: the-title-only-size,
      subtitle-size: the-subtitle-size,
      align: the-align,
      show-line: show-line,
    )
    v(body-gap)
  }

  let chrome-config = utils.merge-dicts(
    config-common(freeze-slide-counter: not count),
    config-page(background: bips-background(
      logo: self.store.logo,
      show-logo: show-logo,
    )),
  )

  let config = if has-header {
    utils.merge-dicts(
      chrome-config,
      config-common(zero-margin-header: false),
      config-page(
        margin: (top: top-margin, bottom: 1.55cm, left: 1.55cm, right: 1.75cm),
        header-ascent: 0pt,
        header: header,
      ),
      user-config,
    )
  } else {
    utils.merge-dicts(chrome-config, user-config)
  }

  let content-number = if not has-header and page-number {
    _page-number(size: pn-size)
  }

  let render-body(body) = {
    let styled = if text-size != none { text(size: text-size)[#body] } else {
      body
    }
    _aligned(content-align, styled)
  }

  if composer == auto {
    let body = args.pos().at(0, default: none)
    touying-slide(
      self: self,
      config: config,
      repeat: repeat,
      setting: user-setting,
    )[
      #content-number
      #show raw.where(block: true): set text(
        size: pick-first(code-block-scale, font-scale-code-block) * 1em,
      )
      #show raw.where(block: false): set text(
        size: pick-first(code-inline-scale, font-scale-code-inline) * 1em,
      )
      #render-body(body)
    ]
  } else {
    touying-slide(
      self: self,
      config: config,
      repeat: repeat,
      composer: composer,
      setting: body => {
        content-number
        user-setting(body)
      },
      ..args.pos(),
    )
  }
})

/// Standard BIPS content slide: title/subtitle header, logo, page number, and
/// gradient divider, over a native Touying body. A preset over `base-slide`
/// with all chrome enabled. Signature is unchanged from earlier versions.
#let bips-slide(
  title: none,
  subtitle: none,
  content-align: none,
  title-size: none,
  subtitle-size: none,
  text-size: none,
  code-block-scale: none,
  code-inline-scale: none,
  show-line: true,
  ..args,
) = base-slide(
  title: title,
  subtitle: subtitle,
  show-logo: true,
  page-number: true,
  show-line: show-line,
  count: true,
  content-align: content-align,
  title-size: title-size,
  subtitle-size: subtitle-size,
  text-size: text-size,
  code-block-scale: code-block-scale,
  code-inline-scale: code-inline-scale,
  ..args,
)

// -------------------------------------------------------------------
// Title Slide
// -------------------------------------------------------------------

#let title-slide(
  title: none,
  subtitle: none,
  author: none,
  authors: none,
  institute: none,
  institutes: none,
  date: none,
  occasion: none,
  title-size: none,
  subtitle-size: none,
  author-size: none,
  institute-size: none,
  date-size: none,
  ..args,
) = touying-slide-wrapper(self => {
  let o = _slide-overrides(args)
  let info = self.info
  let title = pick-first(title, info.at("title", default: none))
  let subtitle = pick-first(subtitle, info.at("subtitle", default: none))
  let author = pick-first(author, info.at("author", default: none))
  let date = pick-first(date, info.at("date", default: none))
  let institute = pick-first(institute, info.at("institution", default: none))

  let body = {
    v(1fr)

    if title != none {
      block(width: 85%, text(
        size: pick-first(title-size, font-size-title-slide-main),
        weight: font-weight-title-slide-main,
        fill: font-color-title-slide-main,
      )[#title])
    }

    v(0.5fr)

    if subtitle != none {
      block(width: 85%, text(
        size: pick-first(subtitle-size, font-size-title-slide-subtitle),
        weight: font-weight-title-slide-subtitle,
        fill: font-color-title-slide-subtitle,
      )[#subtitle])
    }

    v(1fr)

    if authors != none {
      block(text(
        size: pick-first(author-size, font-size-title-slide-author),
        weight: font-weight-title-slide-author,
        fill: font-color-title-slide-author,
      )[#authors.join([#h(1em)])])
    } else if author != none {
      block(text(
        size: pick-first(author-size, font-size-title-slide-author),
        weight: font-weight-title-slide-author,
        fill: font-color-title-slide-author,
      )[#author])
    }

    v(1fr)

    if institutes != none {
      block(text(
        size: pick-first(institute-size, font-size-title-slide-institute),
        weight: font-weight-title-slide-institute,
        fill: font-color-title-slide-institute,
      )[
        #for (i, inst) in institutes.enumerate() [
          #super[#(i + 1)] #inst
          #if i < institutes.len() - 1 [\ ]
        ]
      ])
    } else if institute != none {
      block(text(
        size: pick-first(institute-size, font-size-title-slide-institute),
        weight: font-weight-title-slide-institute,
        fill: font-color-title-slide-institute,
      )[#institute])
    }

    v(1fr)

    if date != none {
      block(text(
        size: pick-first(date-size, font-size-title-slide-date),
        weight: font-weight-title-slide-date,
        fill: font-color-title-slide-date,
      )[#date])
    }

    if occasion != none {
      block(text(
        size: pick-first(date-size, font-size-title-slide-date),
        weight: font-weight-title-slide-date,
        fill: font-color-title-slide-date,
      )[#occasion])
    }
  }

  // title-slide owns its layout, so only config/repeat are forwarded from
  // ..args; `setting` is intentionally not forwarded (it sets the centered
  // layout below). section-slide/thanks-slide do forward o.setting.
  touying-slide(
    self: self,
    config: utils.merge-dicts(
      config-common(freeze-slide-counter: true),
      o.config,
    ),
    repeat: o.repeat,
    setting: body => {
      set std.align(center)
      set text(size: font-size-base)
      body
    },
    body,
  )
})

// -------------------------------------------------------------------
// Section Slide
// -------------------------------------------------------------------

#let section-slide(
  section-title,
  show-logo: true,
  ..args,
) = touying-slide-wrapper(self => {
  let body = args.pos().at(0, default: none)
  if body == [] { body = none }
  let o = _slide-overrides(args)
  touying-slide(
    self: self,
    config: utils.merge-dicts(
      config-common(freeze-slide-counter: true),
      config-page(background: bips-background(
        logo: self.store.logo,
        show-logo: show-logo,
      )),
      o.config,
    ),
    repeat: o.repeat,
    setting: o.setting,
  )[
    #place(hide[#heading(level: 1, outlined: true)[#section-title]])

    #std.align(center + horizon)[
      #text(
        size: font-size-section-slide,
        weight: font-weight-section-slide,
        fill: font-color-section-slide,
      )[#section-title]
      #if body != none {
        v(0.6em)
        body
      }
    ]
  ]
})

// -------------------------------------------------------------------
// Bibliography Slide
// -------------------------------------------------------------------

/// Display a bibliography slide with references.
///
/// Two ways to supply the references:
///
/// 1. Pass the bib file via `bib:` and let the slide call `bibliography()`
///    for you, forwarding `style`/`full` and defaulting bibliography's own
///    heading off (the slide title already says "References"). You must read
///    the file in your own document with `read("references.bib")` — a bare
///    path string can't be forwarded because `bibliography()` resolves paths
///    relative to where it is *called* (here, inside the package), not your
///    document. `read()` runs in your document, so its path resolves there.
///
///    ```
///    #bibliography-slide(
///      bib: read("references.bib"),
///      text-size: 9pt,
///    )
///    ```
///
/// 2. Or build the bibliography yourself and pass it as content (useful for
///    full control over `bibliography()` arguments):
///
///    ```
///    #bibliography-slide(text-size: 14pt)[
///      #bibliography("references.bib", title: none, style: "apa", full: true)
///    ]
///    ```
#let bibliography-slide(
  title: "References",
  text-size: none,
  content-align: horizon,
  bib: none, // `read("references.bib")` (string or bytes); builds the bibliography internally
  style: "springer-basic-author-date", // forwarded to bibliography(); `auto` uses its built-in default
  full: false, // forwarded to bibliography() when `bib` is given
  bib-title: none, // bibliography()'s own heading; off by default (slide already has a title)
  ..body, // or pass pre-built bibliography content as a trailing block
) = {
  let refs = if bib != none {
    // read() returns a string by default; bibliography() needs bytes (a plain
    // string would be read as a path). bytes() preserves UTF-8 content.
    let src = if type(bib) == str { bytes(bib) } else { bib }
    // `style: auto` means "use bibliography's built-in default" — omit the arg.
    if style == auto {
      bibliography(src, title: bib-title, full: full)
    } else {
      bibliography(src, title: bib-title, style: style, full: full)
    }
  } else {
    body.pos().at(0, default: none)
  }
  bips-slide(title: title, text-size: text-size, content-align: content-align)[
    #refs
  ]
}

// -------------------------------------------------------------------
// Thanks Slide
// -------------------------------------------------------------------

#let thanks-slide(
  thanks-text: "Thank you for your attention!",
  contact-author: "",
  email: "",
  qr-url: none,
  ..args,
) = touying-slide-wrapper(self => {
  let o = _slide-overrides(args)
  let logo = self.store.logo
  touying-slide(
    self: self,
    config: utils.merge-dicts(
      config-common(freeze-slide-counter: true),
      config-page(background: none),
      o.config,
    ),
    repeat: o.repeat,
    setting: o.setting,
  )[
    #grid(
      rows: (1fr, 1fr, auto),
      row-gutter: 2em,
      [
        #std.align(center + horizon)[
          #text(
            size: font-size-thanks-slide-main,
            weight: font-weight-thanks-slide-main,
            fill: font-color-thanks-slide-main,
          )[#thanks-text]
        ]
      ],
      [
        #std.align(center + bottom)[
          #if qr-url != none [
            #qrcode(qr-url, width: 4cm, debug: false, quiet-zone: 0, colors: (
              white,
              bips-blue,
            ))
          ] else [
            #text(
              size: font-size-thanks-slide-website,
              weight: font-weight-thanks-slide-website,
              fill: font-color-thanks-slide-website,
            )[
              www.leibniz-bips.de
            ]
          ]
        ]
      ],
      [
        #grid(
          columns: (1fr, 1fr),
          align: (right, left),
          gutter: 2em,
          [
            #std.align(right)[
              #text(
                size: font-size-thanks-slide-contact,
                weight: font-weight-thanks-slide-contact,
                fill: font-color-thanks-slide-contact,
              )[
                *Contact*

                #text(fill: font-color-thanks-slide-website)[#contact-author]\
                Leibniz Institute for Prevention Research\
                and Epidemiology -- BIPS\
                Achterstraße 30\
                28359 Bremen\
                Germany

                #if email != "" [
                  #text(fill: font-color-thanks-slide-website)[#email]
                ]
              ]
            ]
          ],
          [
            #std.align(left)[
              #if logo != none { box(width: 5.5cm, logo) }
            ]
          ],
        )
      ],
    )
  ]
})

// -------------------------------------------------------------------
// Empty Slide
// -------------------------------------------------------------------

/// Minimal slide built on `base-slide`: no header, divider off, and (by default)
/// no logo or page number — just the body. Useful for full-bleed images or
/// transition screens.
///
/// By default the slide counter is frozen (unnumbered, does not advance). Set
/// `count: true` to keep it in the numbered sequence; the page number then
/// shows too (set `page-number: false` to suppress it). Toggle `show-logo: true`
/// to keep the BIPS logo on an otherwise minimal slide.
///
/// Pass a `composer` (e.g. `composer: (1fr, 1fr)`) with multiple trailing blocks
/// for a full-bleed multi-pane layout; in that mode `content-align` is ignored.
#let empty-slide(
  count: false,
  show-logo: false,
  page-number: auto, // auto = follow `count` (number shows iff counted)
  content-align: none,
  ..args,
) = base-slide(
  show-logo: show-logo,
  page-number: if page-number == auto { count } else { page-number },
  show-line: false,
  count: count,
  content-align: content-align,
  ..args,
)
