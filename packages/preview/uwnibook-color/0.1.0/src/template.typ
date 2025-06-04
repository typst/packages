#import "components.typ": *
#import "packages/marginalia.typ": *
#import "index.typ": use_word_list
#import "environments.typ": _reset_env_counting, _env_state

#let _page_geo(config) = (
  inner: (far: config._page_margin, width: 0mm, sep: 0mm),
  outer: (far: config._page_margin, width: config._page_margin_note_width, sep: config._page_margin_sep),
  top: config._page_top_margin,
  bottom: config._page_bottom_margin,
  clearance: config._main_size,
)
/// text properties for the main body
#let _pre_chapter() = {
  counter(math.equation).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: raw)).update(0)
  _reset_env_counting()
  justify_page()
}

#let preamble(body) = {
  set page(numbering: "I")
  set heading(
    numbering: none,
    supplement: none,
    depth: 1,
  )
  body
}

#let page-number(config, offset: 0pt) = context {
  let number = text(config._page_num_size, font: config._sans_font, weight: "semibold", current_page())

  if is_even_page() [
    #h(-offset)#number#h(1fr)
  ] else [
    #h(1fr)#number#h(-offset)
  ]
}

#let template(
  config,
  title,
  author,
  date,
  draft,
  two_sided,
  chap_imgs,
  body,
) = {
  ///utilities
  let sans = text.with(font: config._sans_font)
  let italic = if "_italic_font" in config { text.with(font: { _italic_font }) } else { text }
  let semi = text.with(weight: "semibold")

  /// Set the document's basic properties.
  let author_en = if type(author) == dictionary {
    author.at("en")
  } else if type(author) == string {
    author
  } else if type(author) == array {
    author.at(0)
  } else {
    panic("cannot resolve author info")
  }

  set document(title: title.at(config._lang), author: author_en, date: date)
  let marginaliaconfig = (
    .._page_geo(config),
    book: two_sided,
    numbering: note-numbering.with(config),
  )

  marginalia.configure(..marginaliaconfig)

  set page(
    // explicitly set the paper
    paper: "a4",
    ..marginalia.page-setup(..marginaliaconfig),
    header: context if not is_starting() and current_chapter() != none {
      marginalia.notecounter.update(0)
      let (index: (chap_idx, sect_idx), body: (chap, sect)) = current_chapter()
      let chap_prefix = upper[
        #if chap_idx > 0 {
          semi[#chap_idx #h(1em, weak: true)]
        }
        #chap
      ]
      let sect_prefix = upper[
        #if sect_idx != none and sect_idx > 0 {
          semi[#numbering("1.1", chap_idx, sect_idx)] + h(1em, weak: true)
          sect
        }
      ]
      let book = marginalia._config.get().book
      let book_left = book and is_even_page()
      let x_alignmnent = if book_left {
        left
      } else {
        right
      }
      set align(x_alignmnent)
      set text(font: config._sans_font)

      let leftm = marginalia.get-left()
      let rightm = marginalia.get-right()
      let page_num = semi(config._page_num_size, current_page())

      _wideblock(
        double: true,
        {
          box(
            width: leftm.width,
            if book_left [
              #page_num
            ],
          )
          h(leftm.sep)
          box(
            width: 1fr,
            text(config._main_size, if book_left { chap_prefix } else { sect_prefix }),
          )
          h(rightm.sep)
          box(
            width: rightm.width,
            if not book_left {
              page_num
            },
          )
        },
      )
    },
    footer: context if is_starting() {
      let leftm = marginalia.get-left()
      let rightm = marginalia.get-right()

      _wideblock(
        double: true,
        page-number(config),
      )
    },
    footer-descent: 30% + 0pt, // default
    header-ascent: 30% + 0pt, // default
    numbering: "1",
  )

  counter(page).update(1)

  // set the font for main texts
  set text(
    size: config._main_size,
    font: config._serif_font,
    weight: config._default_weight,
    lang: config._lang,
  )

  set text(_region) if "_region" in config

  /*-- Math Related --*/
  set math.equation(numbering: (..num) => numbering("(1.1.a)", counter(heading).get().first(), ..num))
  set math.equation(supplement: config.i18n.equation) if "i18n" in config and "equation" in config.i18n

  show math.equation: set text(..config._math_text_opts)
  show math.equation: set block(spacing: config._eq_spacing)
  show math.equation: it => {
    if it.block {
      let eq = if it.has("label") { it } else [
        #counter(math.equation).update(v => if v == 0 { 0 } else { v - 1 })
        #math.equation(it.body, block: true, numbering: none)#label("")
      ]
      eq
    } else {
      it
    }
  }
  set math.cases(gap: config._lineskip)


  // set paragraph style
  set par(leading: config._lineskip, spacing: config._parskip, first-line-indent: 1em, justify: true)
  show raw: set text(font: config._mono_font, weight: "regular")

  show figure.caption: set text(font: config._caption_font) if "_caption_font" in config

  set heading(numbering: "1.1")
  set heading(supplement: it => if it.depth == 1 { config.i18n.chapter } else { config.i18n.section }) if (
    "i18n" in config and "section" in config.i18n and "chapter" in config.i18n
  )
  set heading(supplement: config._chapter) if "_chapter" in config

  show heading.where(level: 1): it => {
    _pre_chapter()
    _wideblock(
      _standalone_heading(
        config,
        it,
      ),
    )
  }

  show heading.where(level: 2): it => block(
    spacing: 1.5em,
    width: 100%,
    {
      set text(config._heading2_size, weight: "bold", font: config._sans_font, fill: config._color_palette.accent)
      if it.numbering != none { text(counter(heading).display(it.numbering)) } else { [○] }
      h(.5em)
      it.body
    },
  )

  show heading.where(level: 3): it => {
    show: block.with(above: 1.5em, below: 1em)
    set text(weight: 600, font: config._sans_font, fill: black, tracking: 0.07em)
    upper(it.body)
  }

  set bibliography(title: config.i18n.bibliography) if "i18n" in config and "bibliography" in config.i18n
  show bibliography: it => {
    justify_page()
    it
  }

  /*-- emph --*/
  show emph: italic
  // show strong: set text(_color_palette.accent)

  /// Main body.
  body
}

#let _outline(config, ..args) = {
  set outline(indent: auto, depth: 2)
  set outline(title: config._toc) if "toc" in config

  set page(
    margin: (top: config._page_top_margin, x: config._page_margin + config._page_margin_sep),
    header: none,
    footer: page-number(config, offset: config._page_margin_sep),
    numbering: "I",
  )
  set par(leading: 1em, spacing: 0.5em)

  show outline.entry.where(level: 1): it => {
    set text(font: config._sans_font, weight: "bold", fill: config._color_palette.accent)
    set block(above: 1.25em)
    let prefix = if it.element.numbering == none { none } else if config._lang == "zh" {
      it.element.supplement + it.prefix()
    }
    let body = upper(it.body() + h(1fr) + it.page())
    link(
      it.element.location(),
      it.indented(prefix, body),
    )
  }
  _toc_heading(config, heading(outlined: false, numbering: none, config.i18n.toc, depth: 1))
  columns(2, [#outline(..args, title: none)#v(1pt)])
}

#let mainbody(config, body, two_sided, chap_imgs) = {
  // make sure the page is start at right
  justify_page()
  let sans = text.with(font: config._sans_font)

  let marginaliaconfig = (
    .._page_geo(config),
    book: two_sided,
  )

  marginalia.configure(..marginaliaconfig)

  set page(
    ..marginalia.page-setup(..marginaliaconfig),
    //for draft
    background: context if is_starting() {
      set image(width: 100%)
      place(
        top + center,
        block(
          chap_imgs.at(counter(heading).get().at(0)),
          clip: true,
          width: 100%,
          height: config._chap_top_margin,
          radius: (bottom-right: config._page_margin),
        ),
      )
    },
    numbering: "1", // setup margins:
  )

  show heading.where(level: 1): it => {
    _pre_chapter()
    _wideblock(
      double: true,
      _fancy_chapter_heading(
        config,
        it,
      ),
    )
    marginalia.note(
      text-style: note_text_style(config),
      par-style: note_par_style,
      numbered: false,
      shift: false,
      keep-order: true,
      {
        let nexth2 = heading.where(level: 2).after(here())
        let nexth1 = heading.where(level: 1, outlined: true).after(here(), inclusive: false)
        set text(font: config._sans_font)
        outline(target: nexth2.before(nexth1), indent: 0pt, depth: 2, title: none)
      },
    )
    // marginalia leaves a blank space here. therefore, we need to
    // eliminate the space.
    h(0pt, weak: true)
  }

  /* ---- Customization of Table&Image ---- */
  set figure(
    gap: 0pt,
    numbering: (..num) => numbering("1.1", counter(heading).get().first(), num.pos().first()),
  )
  show figure.where(kind: image): set block(spacing: config._figure_spacing, breakable: false)
  show figure.where(kind: table): set block(spacing: config._figure_spacing, breakable: false)

  set figure.caption(position: top, separator: sym.space)
  show figure.caption: it => [
    #set text(..note_text_style(config))
    #set par(..note_par_style)
    #box(
      sans(weight: "medium")[
        #it.supplement
        #context counter(figure.where(kind: it.kind)).display()
      ]
        + it.separator,
    )
    #it.body
  ]

  show figure: it => layout(((width, height)) => {
    let f_height = measure(width: width, height: height, it.body).height
    let overheight = 2 * f_height > height
    set figure(gap: 0pt)

    show figure.caption.where(position: top): it => context {
      let height = measure(width: marginaliaconfig.outer.width, block(it)).height
      _note(
        config,
        numbered: false,
        dy: if overheight { 0pt } else { f_height - height },
        align-baseline: false,
        keep-order: true,
        it,
      )
    }

    it
  })

  set table(stroke: none, align: horizon + center)
  show figure.where(kind: table): set figure(supplement: config._i18n.table) if (
    "_i18n" in config and "table" in _i18n
  )
  show figure.where(kind: image): set figure(supplement: config._i18n.figure) if (
    "_i18n" in config and "figure" in _i18n
  )

  // reset the counter for the main body
  counter(page).update(1)
  counter(heading).update(0)
  body
}


// TODO: specify the appendix heading
#let appendix(config, body) = {
  justify_page()

  context {
    let offset = counter(heading).get().first()
    set heading(
      supplement: config.i18n.appendix,
      numbering: (..num) => numbering(
        config._appendix_numbering,
        ..{
          let num = num.pos()
          (num.remove(0) - offset, ..num)
        },
      ),
    )
    pagebreak()
    show heading.where(level: 1): it => {
      _pre_chapter()
      _wideblock(
        _appendix_heading(
          config,
          it,
        ),
      )
    }

    body
  }
}

#let subheading(config, body) = {
  set par(leading: 0.5em)
  v(0pt, weak: true)
  block(text(font: config._sans_font, config._subheading_size, style: "italic", weight: 500, black, body))
  v(config._lineskip)
}

#let make-index(config, group: "default", indent: 1em, separator: [, ], columns: 3) = {
  justify_page()
  set page(
    margin: (top: config._page_top_margin, x: config._page_margin + config._page_margin_sep),
    header: none,
    footer: page-number(config, offset: config._page_margin_sep),
  )
  heading(depth: 1, numbering: none, supplement: none, config.i18n.index)
  show: std.columns.with(columns)
  use_word_list(
    group,
    it => {
      for (id, entries) in it {
        heading(
          level: 3,
          depth: 1,
          numbering: none,
          id,
        )
        for entry in entries {
          let (word, children, min_page, max_page) = entry
          let _entry = {
            let page_range = if min_page == max_page {
              min_page
            } else {
              [#min_page\-#max_page]
            }
            block[#word#separator#page_range]
            for child in children {
              let (modifier, loc) = child
              if modifier == none { continue }
              block[#h(indent)#modifier#separator#loc.join(",")]
            }
          }
          block(_entry)
        }
      }
    },
  )
}

#let asterism(config) = align(center, block(spacing: 2em, text(config._color_palette.accent)[✻ #h(1em) ✻ #h(1em) ✻]))
