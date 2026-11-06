// The elements of the structure of a work (NBR 14724, 4) that print the data of the work: the cover, the title page,
// the catalog card on its verso and the approval sheet. The design and the arrangement of these pages are a decision
// of the package, with the top of the cover of the works of the universities (the institution and the programme above
// the author). The three pages with a top, a middle and a bottom come out of one master, `_sheet`, which is not
// exported: each of them takes `top:`, `middle:` and `bottom:` to put the author's own content in a part, and
// `middle-height:`, the height of the box of its middle and its foot. The data come from the state of `config-info`
// (info.typ), read with one `context` per page.

#import "info.typ": (get, full-title, year-volume, full-name, inverted-name, reference-name, role-label, keywords-of,
  keywords as kept)
#import "words.typ": word-raw
#import "fonts.typ": elements
#import "spacing.typ": line-spacing, single-spacing, paragraph-skip, in-size, indent, scale, heading-after
#import "layout.typ": sides, postextual-start, odd-break
#import "elements.typ": nature-text, signatures, stamp, appendix-kind
#import "@preview/glossarium:0.5.10": register-glossary, print-glossary

// the nature of the work the title page gives, for the approval sheet
#let nature = state("abntly-preamble", none)

// a person without the academic title in front of the name ("Prof. Dr. Nome do Orientador" → "Nome do Orientador"),
// for the tracings of the catalog card, which name the person
#let titles = ("Prof.", "Profa.", "Professor", "Professora", "Dr.", "Dra.", "Me.", "Ma.", "Msc.", "MSc.", "Esp.")
#let untitled(p) = if type(p.name) != str { p } else {
  let words = p.name.split(" ").filter(w => w != "")
  while words.len() > 1 and words.first() in titles { words = words.slice(1) }
  (..p, name: words.join(" "))
}

// the size of a style of fonts.typ as a multiple of the body
#let scale-of(key) = elements.at(key).size.em

// A distance of the pages of the structure, given in pt of a body of 12 pt and kept in em of the body, so that it
// follows the size of the text. These pages have distances of their own, from a baseline to the next, as a decision
// of the package: the steps of their lines and the space around the title and the nature; the 1.5 of the text (NBR
// 14724, 5.2) holds elsewhere in the package.
#let pt12(x) = x * 1em / 12

// the steps of the lines of these pages, from a baseline to the next: the body and the size above it (`large`, that
// of the author and of the place) in the spacing of 1.5, the body in single spacing
#let steps = (body: pt12(17.93), large: pt12(22.25), single: pt12(14.45))

// Text in one of the styles of fonts.typ (`cover-author`, `title-page-title`...), its lines `line` apart from
// baseline to baseline and its paragraphs `line` and `gap` (in em of the body): by default 1.5 of its own size and
// the space of a paragraph of the body.
#let styled(key, body, line: auto, gap: paragraph-skip) = {
  let s = scale-of(key)
  let line = if line == auto { line-spacing * s } else { line }
  set par(leading: in-size(line, s) - 1em, spacing: in-size(line + gap, s) - 1em)
  text(..elements.at(key), body)
}

// A row of a page, its first baseline `dist` (in em of the body) under the last baseline before it, in the style
// `key` (whose size the first line has); a block of its own, so that no space of a paragraph comes around it
#let row(dist, key, body) = {
  v(dist - scale-of(key) * 1em)
  block(width: 100%, above: 0pt, below: 0pt, body)
}

// the place and the year (with the volume beside it), a paragraph each, in a style, `line` apart
#let place-year(data, key, line) = styled(key, line: line, {
  if data.location != none { data.location; parbreak() }
  year-volume(data)
})

// the nature of the work as the pages print it: the text of the author, and the area of concentration in a paragraph
// of its own, the space of a paragraph under the text
#let nature-of(body, data) = align(right, block(width: 50%, above: 0pt, below: 0pt, nature-text({
  body
  if data.area != none { parbreak(); word-raw("area") + [: ] + data.area }
})))

// A bookmark of the PDF for a page without a title (the title page, the approval sheet, the dedication and the
// epigraph): a primary heading out of sight, without a number and out of the summary. The rule that hides it comes
// before those of the layout, so it opens no page; the key is the one of its word in src/lang.toml.
#let page-bookmark(key) = {
  show heading: none
  context heading(level: 1, numbering: none, outlined: false, bookmarked: true, word-raw(key))
}

// A page of its own, without a number and without the running header, on a recto in a work on both sides: the cover
// and the title page.
#let leaf(body, background: none, bookmark: none) = context {
  // the blank verso before it empty, as the layout's (the `set` reaches only the page the break inserts)
  if sides.get() { odd-break() } else { pagebreak(weak: true) }
  page(header: none, footer: none, numbering: none, background: background, {
    if bookmark != none { page-bookmark(bookmark) }
    body
  })
}

// The stamp of a draft of the approval sheet or of the catalog card (`draft: true`): the word and its note; never in
// the print version (`two-sided: true` of the main function wins: the work that goes to the press is the final one).
#let draft-stamp(draft, key) = context if draft and not sides.get() {
  stamp(word-raw(key + "-provisional"), note: word-raw(key + "-provisional-note"))
}

// The master of the pages with three parts, each of them `auto` or content: centred, the top at the top of the text
// block, the bottom at its foot, and the middle in the space between, which `v(1fr)` divides (a `v(1fr)` inside a
// part takes its share too). Its `auto` parts are the author, the title, the place and the year.
//
// - first: the style of the first line of the page, whose baseline goes 1 em of the body under the top of the text
//   block, whatever the size of that line.
// - below: from the last baseline to the foot of the text block; each page gives its own.
// - middle-height: `none`, or the page in two invisible boxes (the cover): the bottom one as high as
//   this, the middle at its top and the bottom at its foot, `v(1fr)` between them; the top one with the rest of the
//   text block, the top at its top. Whatever the top holds, the middle stays where it is; a top too high for its box
//   asks for a lower `middle-height`.
#let _sheet(top: auto, middle: auto, bottom: auto, first: "cover-author", below: pt12(23.15), middle-height: none) = {
  context {
    let data = get("_sheet", "title", "author")
    let top = if top == auto { styled("cover-author", full-name(data.author)) } else { top }
    let middle = if middle == auto { row(pt12(49.1), "cover-title", styled("cover-title", full-title(data))) } else {
      middle
    }
    let bottom = if bottom == auto {
      row(pt12(40.44), "cover-place", place-year(data, "cover-place", steps.large))
    } else { bottom }
    set align(center)
    set text(overhang: false)
    set par(first-line-indent: 0pt, justify: false)
    let head = row(1em, first, top)
    let foot = { middle; v(1fr); bottom; v(below) }
    if middle-height == none { head; v(1fr); foot } else {
      block(width: 100%, height: 100% - middle-height, above: 0pt, below: 0pt, breakable: false, head)
      block(width: 100%, height: middle-height, above: 0pt, below: 0pt, breakable: false, foot)
    }
  }
}

// The design of the cover, a decision of the package: the sans serif, the author, the place and the year a size above
// the body, the title larger and in bold (the styles `cover-*` of fonts.typ); the institution (4.1.1 a, optional) in
// the type of the author, 3.5 cm above it. The page goes in the two boxes of `_sheet`: `55%` puts the title in the
// middle of the page (`50%` puts it 36 pt lower, `60%` 34 pt higher).
/// Creates the cover of the work (NBR 14724:2024, section 4.1.1) from the data of `config-info`. From top to bottom,
/// the cover has: the mark of the institution (if given), the institution and the programme, the author, the title
/// with the subtitle, the version of the work (if given), the location and the year. The title and the author are
/// required.
///
/// The parameters `top`, `middle` and `bottom` replace the matching part of the cover with custom content. Use
/// `with-info` to reach the data of the work in that content:
///
/// ```typ
/// #cover()
/// #cover(top: with-info(d => [#upper(d.institution) \ #d.author]))
/// ```
///
/// - top (auto, content): Content of the top part, in the place of the institution and the author.
/// - middle (auto, content): Content of the middle part, in the place of the title and the version.
/// - bottom (auto, content): Content of the bottom part, in the place of the location and the year.
/// - middle-height (ratio, length, relative): Height of the area that goes from the title to the end of the text
///   block. Larger values move the title up. The default, `55%`, places the title in the middle of the page.
/// -> content
#let cover(top: auto, middle: auto, bottom: auto, middle-height: 55%) = {
  assert(type(middle-height) in (ratio, length, relative),
    message: "cover: middle-height is a ratio or a length, like 50% or 12cm; got " + repr(middle-height))
  leaf(context {
    let data = get("cover", "title", "author")
    let top = if top != auto { top } else {
      let head = (data.institution, data.program).filter(x => x != none)
      styled("cover-author", line: steps.large, {
        if data.logo != none { data.logo; parbreak() }
        if head.len() > 0 { head.join(linebreak()); v(3.5cm - steps.large + pt12(22.25)) }
        full-name(data.author)
      })
    }
    // the title at the top of its box (the top of its line, 1 em of its size above its baseline), the version a line
    // of the size of the author (`steps.large`) and a paragraph under it, as on the title page
    let middle = if middle != auto { middle } else {
      block(width: 100%, above: 0pt, below: 0pt, styled("cover-title", full-title(data)))
      if data.version != none {
        row(steps.large + paragraph-skip, "cover-author", text(font: elements.cover-title.font, weight: "bold",
          size: elements.cover-author.size, data.version))
      }
    }
    _sheet(top: top, middle: middle, bottom: bottom, middle-height: middle-height)
  })
}

// The institution goes in the nature, as 4.2.1.1.1 e) puts it, and not again in a line of its own. The page goes in
// the two boxes of `_sheet`, with the middle spread down the bottom one: the same space above the version and under
// the advisors, and the nature midway between the version and the advisors. The design, a decision of the package:
// the author in the sans serif and a size above the body, the title larger and in bold, the advisors, the place and
// the year a size above the body, their lines at the step of the body (the styles `title-page-*` of fonts.typ).
/// Creates the title page (NBR 14724:2024, section 4.2.1.1). From top to bottom, the page has: the author, the title
/// with the subtitle, the version of the work (if given), the nature of the work, the advisor and the co-advisor, the
/// location and the year. The text of the nature is passed as the content of the function; the other elements come
/// from `config-info`.
///
/// The nature is set in single spacing, aligned from the middle of the text block to the right margin (section 5.2),
/// and it is reused by the approval sheet. The page count of the work starts on the title page, and the catalog card
/// goes on its verso.
///
/// ```typ
/// #title-page[Tese apresentada ao Programa de Pós-Graduação da Universidade do Brasil,
///   como requisito parcial para a obtenção do título de Doutor.]
/// ```
///
/// - body (content): Text of the nature of the work: type of the work, aim and institution it is submitted to.
/// - top (auto, content): Content of the top part, in the place of the author.
/// - middle (auto, content): Content of the middle part, in the place of the title, the version, the nature and the
///   advisors.
/// - bottom (auto, content): Content of the bottom part, in the place of the location and the year.
/// - middle-height (ratio, length, relative): Height of the area that goes from the title to the end of the text
///   block, as on the cover. The default, `85%`, places the title in the upper part of the page.
/// -> content
#let title-page(body, top: auto, middle: auto, bottom: auto, middle-height: 85%) = {
  assert(type(middle-height) in (ratio, length, relative),
    message: "title-page: middle-height is a ratio or a length, like 85% or 20cm; got " + repr(middle-height))
  nature.update(body)
  leaf(bookmark: "title-page", {
    counter(page).update(1)
    context {
      let data = get("title-page", "title", "author")
      let top = if top == auto { styled("title-page-author", full-name(data.author)) } else { top }
      // the middle spread down its box: the title at its top; the version after a `v(1fr)`, as the foot; the nature
      // midway between the version (or the title) and the advisors: the same fill above it and above them, 50/85 of
      // a whole one each, and the same clearance, from the baseline above to the top of the line (1 em of its size
      // above its baseline): 10.97 pt of a 12 pt body
      let clearance = pt12(10.97)
      let middle = if middle != auto { middle } else {
        block(width: 100%, above: 0pt, below: 0pt, styled("title-page-title", full-title(data)))
        if data.version != none {
          v(1fr)
          row(steps.large + paragraph-skip, "title-page-author",
            text(font: elements.cover-title.font, weight: "bold", size: elements.cover-author.size, data.version))
        }
        v(0.5fr / 0.85)
        row(clearance + scale-of("title-page-preamble") * 1em, "title-page-preamble", nature-of(body, data))
        // the advisors under the nature, after the other half of that space (the two fills come to a whole one and
        // 15/85 of one); no institution of its own: the nature names it (4.2.1.1.1 e)
        let people = ((data.advisor, "advisor"), (data.co-advisor, "co-advisor")).filter(p => p.first() != none)
        if people.len() > 0 {
          v(0.5fr / 0.85)
          row(clearance + scale-of("title-page-advisor") * 1em, "title-page-advisor", styled("title-page-advisor", line: steps.body,
            people.map(((p, key)) => [#role-label(p, key): #full-name(p)]).join(parbreak())))
        }
      }
      // the place and the year on the last lines of the page: the baseline of the year 7.35 pt (of a 12 pt body) above
      // the foot of the text block
      let bottom = if bottom != auto { bottom } else {
        row(steps.body + paragraph-skip, "title-page-place", place-year(data, "title-page-place", steps.body))
      }
      _sheet(top: top, middle: middle, bottom: bottom, first: "title-page-author", below: pt12(7.35),
        middle-height: middle-height)
    }
  })
}

// The design, a decision of the package: the page in single spacing, the author in the sans serif and a size above
// the body, the title larger and in bold, the place and the year a size above the body (the styles `approval-*` of
// fonts.typ). The free space of the page is divided in four equal parts, two above the title, one above the nature
// and one under it, and the approval, the board, the place and the year follow at the foot. With `middle-height`,
// the two invisible boxes of the cover instead: the title at the top of the bottom one, wherever the free space
// falls (`83%` of the text block puts it near where the four parts do). The date and the signatures "devem ser
// colocadas após a aprovação" (4.2.1.3): until then the page takes the stamp of a draft.
/// Creates the approval sheet (NBR 14724:2024, section 4.2.1.3). From top to bottom, the page has: the author, the
/// title with the subtitle, the nature of the work (the one of the title page, with the area of concentration), the
/// approval line with the location and the date, the signatures of the members of the board, the location and the
/// year. The page is set in single spacing.
///
/// The date of the approval and the signatures are filled in after the work is approved. So the date is blank by
/// default, and the page takes the stamp "FOLHA PROVISÓRIA" until `draft: false` is given.
///
/// ```typ
/// #approval-page(
///   (title: [Prof. Dr.], name: [Fulano de Tal], role: [Orientador],
///     institution: [Universidade do Brasil]),
///   (title: [Profa. Dra.], name: [Beltrana de Tal], institution: [Universidade do Brasil]),
/// )
/// ```
///
/// - ..members (dictionary, content): Members of the board, in the format `signature` takes.
/// - date (str, content, none): Date of the approval, as in "30 de setembro de 2026". With `none`, a blank line is
///   shown, to be filled in.
/// - top (auto, content): Content of the top part, in the place of the author.
/// - middle (auto, content): Content of the middle part, in the place of the title and the nature.
/// - bottom (auto, content): Content of the bottom part, in the place of the approval line, the signatures, the
///   location and the year.
/// - middle-height (auto, ratio, length, relative): Height of the area that goes from the title to the end of the
///   text block, as on the cover. With `auto`, the free space of the page is shared between the author, the title and
///   the nature.
/// - draft (bool): If `true`, shows the stamp "FOLHA PROVISÓRIA" in the background of the page. Use `false` in the
///   final version. The stamp is never shown with `two-sided: true`.
/// -> content
#let approval-page(..members, date: none, top: auto, middle: auto, bottom: auto, middle-height: auto,
  draft: true) = {
  assert(members.named().len() == 0, message: "approval-page: takes the members of the board, each a dictionary "
    + "(title, name, role, institution), and date, top, middle, bottom, middle-height and draft; got "
    + repr(members.named()))
  assert(middle-height == auto or type(middle-height) in (ratio, length, relative), message: "approval-page: "
    + "middle-height is auto, or a ratio or a length, like 83% or 20cm; got " + repr(middle-height))
  assert(type(draft) == bool, message: "approval-page: draft is true or false; got " + repr(draft))
  leaf(background: draft-stamp(draft, "approval"), bookmark: "approval-page", context {
    let data = get("approval-page", "title", "author")
    let top = if top == auto { styled("approval-author", full-name(data.author)) } else { top }
    let body = nature.get()
    // the arrangement: two fills above the title, one above the nature and one under it. Here a `v(1fr)` above the
    // title, with the one `_sheet` puts above the middle, one above the nature, and the one `_sheet` puts under the
    // middle, added to the fixed distances of the rows (40.11 pt of a 12 pt body from the author to the title). In
    // the two boxes (`middle-height`), the title at the top of the bottom one
    let boxed = middle-height != auto
    let middle = if middle != auto { middle } else {
      if boxed { block(width: 100%, above: 0pt, below: 0pt, styled("approval-title", full-title(data))) } else {
        v(1fr)
        row(pt12(40.11), "approval-title", styled("approval-title", full-title(data)))
      }
      if body != none or data.area != none {
        v(1fr)
        row(pt12(27.42), "title-page-preamble", nature-of(body, data))
      }
    }
    let bottom = if bottom != auto { bottom } else {
      let place = if data.location != none [#data.location, ] else []
      // the line of the approval, a paragraph of the text with its indent (the paragraph is alone in its block,
      // where Typst sets no first-line indent)
      row(pt12(29.74), "title-page-preamble", {
        set align(left)
        set par(leading: steps.single - 1em)
        [#h(indent)#word-raw("approved"). #place#if date == none [#box(width: 4cm, repeat[\_])] else { date }:]
      })
      // the signatures after the line of the approval in single spacing; nothing under them, the place following at
      // the distance of its row
      if members.pos().len() > 0 {
        block(above: single-spacing + paragraph-skip, below: 0pt, signatures(members.pos(), line: single-spacing))
      }
      row(pt12(45.57), "approval-place", place-year(data, "approval-place", steps.single))
    }
    _sheet(top: top, middle: middle, bottom: bottom, first: "approval-author", below: pt12(32.19),
      middle-height: if boxed { middle-height } else { none })
  })
}

// The card of the package: in the sans serif and small, with the author by the surname, the title and the author, the
// place and the year, the number of pages, the advisor, the note of the work and the tracings: the keywords of the
// abstract in figures, the advisor, the institution, the programme and the title in roman numerals. With
// `draft: auto`, the stamp goes on the card of the package and not on the one of the library.
/// Creates the page with the international cataloguing-in-publication data (catalog card), on the verso of the title
/// page (NBR 14724:2024, section 4.2.1.1.2). It must be called right after the title page.
///
/// The card is a box of 13.5 cm by 8 cm at the bottom of the page, built from the data of `config-info`: author,
/// title, location, year, number of pages, advisor, type of the work, institution and subjects. The subjects are the
/// keywords of the abstract in the language of the work.
///
/// The final card is usually issued by the library of the institution. To use it, give it in the `card` parameter:
/// `catalog-card(card: image("card.pdf", width: 13.5cm))`.
///
/// - card (auto, content): Card issued by the library, in the place of the card created by the package.
/// - draft (auto, bool): If `true`, shows the stamp "FICHA PROVISÓRIA" in the background of the page. With `auto`,
///   the stamp is shown on the card created by the package and left out on the card given in `card`. The stamp is never
///   shown with `two-sided: true`.
/// -> content
#let catalog-card(card: auto, draft: auto) = {
  assert(draft == auto or type(draft) == bool,
    message: "catalog-card: draft is auto, true or false; got " + repr(draft))
  let draft = if draft == auto { card == auto } else { draft }
  // on the verso of the title page (no break to a recto), with the stamp of a draft
  page(header: none, footer: none, numbering: none, background: draft-stamp(draft, "card"), context {
    set align(center + bottom)
    // the card of the library at the foot of the page too (returned, it would leave the alignment behind)
    if card != auto { return align(center + bottom, card) }
    let data = get("catalog-card", "title", "author")
    let pages = counter(page).final().first()
    // the box, around a content of 13.5 cm by 8 cm: its rule of 0.4 pt drawn 3.2 pt out of the text (3 pt clear of
    // it, and half the rule), 7.5 pt of a 12 pt body above the foot of the text block
    set text(..elements.catalog-card)
    // the paragraphs of the card: each one after the first opens 0.5 cm and a space in, its other lines at the edge
    // of the box; the lines in single spacing, 13.55 pt apart in a 12 pt body, where the small size of the card is
    // 10.95 pt (hence `13.55em / 10.95`, in em of that size)
    set par(first-line-indent: (amount: 0.5cm + 0.3333em, all: true), justify: false,
      leading: 13.55em / 10.95 - 1em, spacing: 13.55em / 10.95 - 1em)
    let tracings = keywords-of(text.lang).enumerate().map(((i, k)) => [#(i + 1). #k.]) + {
      let names = ()
      if data.advisor != none { names.push(inverted-name(untitled(data.advisor)) + [.]) }
      if data.institution != none { names.push(data.institution + [.]) }
      if data.program != none { names.push(data.program + [.]) }
      names.push(word-raw("card-title"))
      names.enumerate().map(((i, n)) => [#numbering("I", i + 1). #n])
    }
    let kind = if data.work-type == none { none } else if type(data.work-type) == str {
      word-raw(data.work-type)
    } else { data.work-type }
    // a blank line after the extent and after the advisor, and a little after the note
    let blank = v(13.55em / 10.95)
    // the content centred in the box from the top of the letters of its first line to the bottom of those of its
    // last: a quarter of an em above the middle of the lines of Typst, which go from 1 em above the first baseline
    // down to the last one
    pad(bottom: 7.5em / 12 * 12 / 10.95, block(width: 13.5cm + 6.4pt, height: 8cm + 6.4pt, stroke: 0.4pt, inset: 3.2pt,
      align(left + horizon, move(dy: -0.25em, {
        par(first-line-indent: 0pt, inverted-name(data.author))
        [#full-title(data) / #full-name(data.author). -- #if data.location != none [#data.location, ]#data.year\-]
        parbreak()
        [#pages p. : il. ; 30 cm.]
        parbreak()
        blank
        if data.advisor != none {
          [#role-label(data.advisor, "advisor"): #full-name(data.advisor)]
          parbreak()
          blank
        }
        if kind != none {
          // the note of the work in a box at the indent, the institution and the programme a line each
          let place = (data.institution, data.program).filter(x => x != none).join(linebreak())
          pad(left: 0.5cm + 0.3333em, par(first-line-indent: 0pt, [#kind -- #place, #data.year.]))
          v(3.12em / 10.95)
        }
        tracings.join[ ]
      }))))
  })
}

// A title of the pre-textual part, centred and without a number, out of the summary but in the bookmarks of the PDF:
// the errata, the acknowledgments, the abstracts, the lists. The layout opens a page for it (a recto in a work on
// both sides) and centres it (src/layout.typ).
#let pre-heading(key, title: auto) = context heading(level: 1, numbering: none, outlined: false, bookmarked: true,
  if title == auto { word-raw(key) } else { title })

// The package gives only the title: the errata itself is written by hand.
/// Creates the errata (NBR 14724:2024, section 4.2.1.2): the title "Errata", centred and without a number, followed
/// by the content. The content is written by the author: the reference of the work and the table of the corrections.
///
/// - body (content): Reference of the work and table of the corrections.
/// -> content
#let errata(body) = {
  pre-heading("errata")
  body
}

// NBR 14724 recommends the right half of the foot of the page (5.2.4); the package sets the text centred in the middle
// of the page and in italic, as a decision of the package: an emphasis inside it (`_..._`) comes out upright.
/// Creates the page of the dedication (NBR 14724:2024, section 4.2.1.4). The page has no title. The text is set in
/// italics, centred, in the middle of the page.
///
/// - body (content): Text of the dedication.
/// -> content
#let dedication(body) = leaf(bookmark: "dedication", {
  // the punctuation at the end of a line inside the measure, which centres the line on its letters (Typst hangs it
  // out of the line by default)
  set text(style: "italic", overhang: false)
  set par(first-line-indent: 0pt, justify: false)
  // the fixed distances around the two fills, in pt of a 12 pt body: above, 35.6 pt from the top of the text block
  // to the first baseline (a line of the text and the space of a paragraph under the first line of a page); below,
  // the depth of the letters of the last line (2.3 pt) less 5.2 pt, which takes the lower fill 2.9 pt past the foot
  // of the text block
  v(pt12(35.6) - 1em)
  v(1fr)
  align(center, body)
  v(pt12(2.3 - 5.2))
  v(1fr)
})

/// Creates the acknowledgments (NBR 14724:2024, section 4.2.1.5): the title "Agradecimentos", centred and without a
/// number, followed by the text.
///
/// - body (content): Text of the acknowledgments.
/// -> content
#let acknowledgments(body) = {
  pre-heading("acknowledgments")
  body
}

// NBR 14724 recommends a block from the middle of the text block (5.2.4); the package sets the text against the right
// margin, at the foot of the page, as a decision of the package.
/// Creates the page of the epigraph (NBR 14724:2024, section 4.2.1.6). The page has no title. The text is aligned to
/// the right, at the bottom of the page. The line breaks and the italics are set by the author.
///
/// - body (content): Text of the epigraph, with its source.
/// -> content
#let epigraph(body) = leaf(bookmark: "epigraph", {
  set text(overhang: false)
  set par(first-line-indent: 0pt, justify: false)
  v(1fr)
  align(right, body)
  // the space under the last line, in pt of a 12 pt body: 15.51 pt less the 5.2 pt the dedication takes off too
  v(pt12(15.51 - 5.2))
})

// The title out of the summary; the paragraphs without indent and a blank line apart, a decision of the package.
/// Creates an abstract (NBR 14724:2024, sections 4.2.1.7 and 4.2.1.8; NBR 6028:2021): the title, centred and without
/// a number, followed by the text, without paragraph indent. The keywords go at the end of the text, with the
/// function `keywords`.
///
/// The title follows the language of the abstract: "Resumo", "Abstract", "Resumen" or "Résumé". In an abstract in a
/// foreign language, the `lang` parameter sets the hyphenation of the text too.
///
/// ```typ
/// #abstract[
///   Texto do resumo.
///
///   #keywords[primeira][segunda][terceira]
/// ]
/// #abstract(lang: "en")[
///   Abstract text.
///
///   #keywords[first][second][third]
/// ]
/// ```
///
/// - body (content): Text of the abstract, with the keywords.
/// - lang (auto, str): Language of the abstract, as in `"en"`, `"es"` or `"fr"`. With `auto`, it is the language of
///   the work.
/// - title (auto, content): Title of the abstract. Give it for a language whose term the package does not have.
/// -> content
#let abstract(body, lang: auto, title: auto) = {
  let inside = {
    // the distances, in pt of a 12 pt body: the title where the chapter's goes, the text 39.89 pt under it (not the
    // distance of a chapter to its text); the paragraphs a line and 17.93 pt, the step of a line of the body, apart
    show heading.where(level: 1): set block(below: in-size(pt12(39.89) - 1em, scale.heading.at(0)))
    pre-heading("abstract", title: title)
    set par(first-line-indent: 0pt, spacing: line-spacing - 1em + pt12(17.93))
    body
  }
  if lang == auto { inside } else {
    set text(lang: lang, region: if lang == "pt" { "br" } else { none })
    inside
  }
}

// 6028, 4.1.7: "seguida de dois-pontos, separadas entre si por ponto e vírgula e finalizadas por ponto". They are
// kept by the language of the text.
/// Creates the keywords line of an abstract (NBR 6028:2021, section 4.1.7): the label in bold, followed by a colon,
/// with the keywords separated by semicolons and ended by a period. The label follows the language of the abstract
/// ("Palavras-chave", "Keywords").
///
/// The keywords of the abstract in the language of the work are used as the subjects of the catalog card and written
/// to the metadata of the PDF.
///
/// - ..words (str, content): Keywords, one in each argument.
/// - sep (str, content): Separator between the keywords.
/// - end (str, content): Punctuation after the last keyword.
/// - label (auto, content): Label shown before the colon. Give it for a language whose term the package does not
///   have.
/// -> content
#let keywords(..words, sep: "; ", end: ".", label: auto) = context {
  let given = words.pos()
  assert(words.named().len() == 0 and given.len() > 0,
    message: "keywords: takes the keywords, and sep, end and label; got " + repr(words))
  let lang = text.lang
  kept.update(k => { k.insert(lang, given); k })
  par[*#if label == auto { word-raw("keywords") } else { label }*: #given.join(sep)#end]
}

// An entry of a list, a decision of the package: the designative word and the number in a box, the travessão between
// the number and the title, the title in lines under its first, the dots and the page.
/// Creates the list of the illustrations of one kind, or the list of tables (NBR 14724:2024, sections 4.2.1.9 and
/// 4.2.1.10): the title, centred and without a number, and an entry for each item, in the order they come in the
/// text, as in "Figura 1 — Título ..... 9".
///
/// The standard recommends a list for each kind of illustration. The functions `list-of-figures`, `list-of-tables`
/// and `list-of-frames` create the most common lists.
///
/// - target (str, function, selector): Kind of the figures to list (`image`, `table`, `"quadro"`, `raw` or the `kind`
///   of a kind of your own) or a selector.
/// - title (auto, content): Title of the list. With `auto`, it is the term of the package for the kind ("Lista de
///   ilustrações", "Lista de tabelas", "Lista de quadros"). It is required for the other kinds.
/// -> content
#let list-of(target, title: auto) = {
  let key = if target == image { "list-of-figures" } else if target == table { "list-of-tables" } else if (
    target == "quadro") { "list-of-frames" } else { none }
  assert(title != auto or key != none, message: "list-of: a list of another kind takes its title: list-of("
    + repr(target) + ", title: [...])")
  let selector = if type(target) in (str, function) { figure.where(kind: target) } else { target }
  pre-heading(key, title: title)
  // an entry: the word and a space, then the number and the travessão in a box of 2.3 quads, the title in lines that
  // stop 2.55 quads before the margin, the dots, and the page at the margin; `quad`, the unit of these widths, is
  // 11.7487 pt in a 12 pt body
  let quad = 11.7487em / 12
  show outline.entry: it => {
    let fig = it.element
    let number = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    let prefix = [#fig.supplement#sym.space] + box(width: 2.3 * quad, number + h(1fr) + [—] + h(1fr))
    link(fig.location(), block(inset: (right: 2.55 * quad), it.indented(prefix, {
      it.body()
      h(0.4em)
      box(width: 1fr, it.fill)
      // the page in the 2.55 quads the title leaves, out of the line (a box wider than the empty one it is in)
      box(width: 0pt, box(width: 2.55 * quad, align(right, it.page())))
    }, gap: 0pt)))
  }
  outline(title: none, target: selector)
}

/// Creates the list of illustrations with the figures of the work. The same as `list-of(image)`.
///
/// -> content
#let list-of-figures() = list-of(image)

/// Creates the list of tables. The same as `list-of(table)`.
///
/// -> content
#let list-of-tables() = list-of(table)

/// Creates the list of quadros. The same as `list-of("quadro")`.
///
/// -> content
#let list-of-frames() = list-of("quadro")

// the letters of a label without their accents, for the alphabetical order of the acronyms, the glossary and the
// index (NBR 6033, 3.1.3), in lower case
#let accents = {
  let from = "ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç".clusters()
  let to = "AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiiooooouuuuc".clusters()
  let map = (:)
  for (i, c) in from.enumerate() { map.insert(c, to.at(i)) }
  map
}
#let folded(x) = {
  let t = if type(x) == str { x } else if type(x) == content and x.has("text") { x.text } else { repr(x) }
  lower(t.clusters().map(c => accents.at(c, default: c)).join(default: ""))
}

// The entries with a key of the lists (the acronyms, the symbols, the glossary), registered with glossarium at the
// start of the work: glossarium looks a key up where it is cited (`@typst`), and the glossary comes after the text
// that cites it. Each list leaves its entries in a metadata; the main function registers them all before the body.
#let keyed-entries = <abntly-keyed-entries>
#let register-keyed() = context {
  let entries = query(keyed-entries).map(m => m.value).flatten()
  if entries.len() > 0 { register-glossary(entries) }
}

// The list of the acronyms or of the symbols: a title of the pre-textual part and an entry each, as a decision of the
// package: the label in a box of 5 quads, 2 quads from the margin, the description 8 quads from it, in lines under
// its first; the items a line and a fixed skip apart. The entries are pairs, `("ABNT", [Associação Brasileira de
// Normas Técnicas])`, written by hand; or dictionaries, `(key: "abnt", short: "ABNT", long: [...])`, given to the
// package glossarium, so that `@abnt` in the text gives the acronym, and its long form at the first mention (the mode
// comes from the form of the entries).
#let entry-list(key, entries, sort: false) = {
  let keyed = entries.len() > 0 and type(entries.first()) == dictionary
  assert(entries.all(e => (type(e) == dictionary) == keyed and (keyed or (type(e) == array and e.len() == 2))),
    message: key + ": the entries are all pairs, (\"ABNT\", [Associação...]), or all dictionaries, (key: \"abnt\", "
      + "short: \"ABNT\", long: [...]); got " + repr(entries))
  let pairs = if keyed { entries.map(e => (e.short, e.long)) } else { entries }
  if sort { pairs = pairs.sorted(key: p => folded(p.first())) }
  pre-heading(key)
  if keyed {
    [#metadata(entries) #keyed-entries]
    print-glossary(entries, invisible: true, show-all: true, disable-back-references: true)
  }
  set par(first-line-indent: 0pt, justify: true)
  // `quad`, the unit of the widths, is 11.7487 pt in a 12 pt body; the items a line and 9.63 pt (of that body) apart
  let quad = 11.7487em / 12
  for (label, description) in pairs {
    block(above: line-spacing - 1em + pt12(9.63), below: line-spacing - 1em + pt12(9.63),
      grid(columns: (8 * quad, 1fr), pad(left: 2 * quad, box(width: 5 * quad, label)), description))
  }
}

/// Creates the list of abbreviations and acronyms (NBR 14724:2024, section 4.2.1.11): the title, centred and without
/// a number, and the acronyms in alphabetical order, each followed by its expression in full.
///
/// The entries can be given in two ways. As pairs, the list is only printed:
/// `("ABNT", [Associação Brasileira de Normas Técnicas])`. As dictionaries, the acronyms can also be cited in the
/// text by the key (`@abnt`), and the first mention shows the expression in full, followed by the acronym between
/// parentheses: `(key: "abnt", short: "ABNT", long: [Associação Brasileira de Normas Técnicas])`.
///
/// - ..entries (array, dictionary): Acronyms, all as pairs or all as dictionaries.
/// -> content
#let list-of-acronyms(..entries) = entry-list("list-of-acronyms", entries.pos(), sort: true)

/// Creates the list of symbols (NBR 14724:2024, section 4.2.1.12): the title, centred and without a number, and the
/// symbols in the order given, each followed by its meaning.
///
/// The entries are pairs, as in `($c$, [Velocidade da luz no vácuo])`, or dictionaries, as in `list-of-acronyms`.
///
/// - ..entries (array, dictionary): Symbols, all as pairs or all as dictionaries.
/// -> content
#let list-of-symbols(..entries) = entry-list("list-of-symbols", entries.pos())

// --- the data for the pages of the author ------------------------------------------------------------------------

/// Gives access to the data of the work to build custom content. The function given is called in a context of its own
/// (`context`), with a dictionary `d`, and the content it returns is inserted in the page. It is used in the
/// parameters `top`, `middle` and `bottom` of the cover, the title page and the approval sheet, and in the parameter
/// `card` of the catalog card.
///
/// ```typ
/// #cover(top: with-info(d => [#upper(d.institution) \ #d.author]))
/// ```
///
/// Fields available in `d`. A field that was not given is `none`.
///
/// - `title`, `subtitle`, `full-title`: title, subtitle and full title ("Título: subtítulo");
/// - `author`, `author-inverted`, `author-reference`: name of the author in direct order, inverted ("Autor, Nome do")
///   and in the format of a reference ("AUTOR, Nome do");
/// - `advisor`, `co-advisor`: names of the advisor and of the co-advisor;
/// - `advisor-label`, `co-advisor-label`: their labels ("Orientador", "Orientadora" or the custom label);
/// - `institution`, `program`, `area`, `location`, `year`, `volume`, `version`, `logo`: fields of `config-info`;
/// - `area-label`: the term "Área de concentração";
/// - `year-volume`: year with the volume ("2026, v. 2");
/// - `work-type`: type of the work in full ("Tese (Doutorado)");
/// - `preamble`: nature of the work given on the title page (`none` before it);
/// - `keywords`: keywords of the abstract in the language of the work;
/// - `pages`: number of pages, counted from the title page;
/// - `data`: original dictionary of `config-info`.
///
/// - fn (function): Function that receives the data and returns the content.
/// -> content
#let with-info(fn) = context {
  let data = get("with-info")
  let person(p) = if p == none { none } else { full-name(p) }
  let label(p, key) = if p == none { none } else { role-label(p, key) }
  fn((
    title: data.title,
    subtitle: data.subtitle,
    full-title: if data.title == none { none } else { full-title(data) },
    author: person(data.author),
    author-inverted: if data.author == none { none } else { inverted-name(data.author) },
    author-reference: if data.author == none { none } else { reference-name(data.author) },
    advisor: person(data.advisor),
    advisor-label: label(data.advisor, "advisor"),
    co-advisor: person(data.co-advisor),
    co-advisor-label: label(data.co-advisor, "co-advisor"),
    institution: data.institution,
    program: data.program,
    area: data.area,
    area-label: word-raw("area"),
    location: data.location,
    year: data.year,
    volume: data.volume,
    year-volume: year-volume(data),
    version: data.version,
    work-type: if data.work-type == none { none } else if type(data.work-type) == str {
      word-raw(data.work-type)
    } else { data.work-type },
    logo: data.logo,
    preamble: nature.get(),
    keywords: keywords-of(text.lang),
    pages: counter(page).final().first(),
    data: data,
  ))
}

// --- the post-textual part --------------------------------------------------------------------------------------

// The page that opens the appendices or the annexes ("Apêndices", "Anexos"), which no norm asks for, a decision of
// the package: the word in the type of the chapter, centred, its baseline 269.98 pt (of a 12 pt body) under the top
// of the text block; on a recto in a work on both sides. A heading of its own, out of sight, gives its entry to the
// summary, where the part's go.
#let divider-page(key) = leaf({
  set align(center)
  set par(first-line-indent: 0pt, justify: false)
  // the heading in the type the package gives a primary heading (its sizes are relative: set again, they grow), its
  // baseline 1 em under the space before it (not at the height of its letters, as a chapter at the top of a page)
  show heading: set text(top-edge: 1em)
  show heading: it => it.body
  v(pt12(269.98) - elements.chapter.size)
  context [#heading(level: 1, numbering: none, outlined: true, bookmarked: true, word-raw(key)) <abntly-divider>]
})

// the numbering of the appendices and of the annexes: "APÊNDICE A — ", the word and the letter (NBR 14724, 4.2.3.3
// and 4.2.3.4), then the travessão, two spaces between each; a section of an appendix by the letter and its numbers,
// "A.1", "A.1.1", a decision of the package (NBR 6024 gives the numbers of the sections; the letter is the indicative
// of the appendix). The word is read where the numbering is applied, without a `context` of its own: Typst applies a
// numbering inside one, and content that reads the language where it lands has no text for the bookmark of the PDF,
// which would come out without "APÊNDICE A —"
#let appendix-numbering(key) = (..n) => if n.pos().len() == 1 {
  [#word-raw(key)~~#numbering("A", n.pos().first())~~—~]
} else { numbering("A.1", ..n.pos()) }

// the appendices or the annexes from here on, after their page, if there is one
#let appendices(key, divider-key, body, divider: true) = {
  assert(type(divider) == bool, message: key + ": divider is true or false; got " + repr(divider))
  if divider { divider-page(divider-key) }
  appendix-kind.update(key)
  counter(heading).update(0)
  set heading(numbering: appendix-numbering(key))
  show heading.where(level: 1): set align(center)
  body
}

// The page that opens them is `divider-page`.
/// Starts the appendices (NBR 14724:2024, section 4.2.3.3). It must be used with a `show` rule: `#show: appendix`.
/// From there on, each primary heading is identified by the word "APÊNDICE", a consecutive capital letter and a dash,
/// as in "APÊNDICE A — Título", centred. The sections of an appendix are numbered with its letter ("A.1").
///
/// By default, a page with the title "Apêndices" is put before the first appendix.
///
/// - body (content): Rest of the work.
/// - divider (bool): If `true`, puts the page "Apêndices" before the first appendix. The standard does not ask for
///   this page. Use `#show: appendix.with(divider: false)` to leave it out.
/// -> content
#let appendix(body, divider: true) = appendices("appendix", "appendices", body, divider: divider)

/// Starts the annexes (NBR 14724:2024, section 4.2.3.4). It must be used with a `show` rule: `#show: annex`. From
/// there on, each primary heading is identified as "ANEXO A — Título", centred, and the sections of an annex are
/// numbered with its letter ("A.1").
///
/// By default, a page with the title "Anexos" is put before the first annex.
///
/// - body (content): Rest of the work.
/// - divider (bool): If `true`, puts the page "Anexos" before the first annex. The standard does not ask for this
///   page. Use `#show: annex.with(divider: false)` to leave it out.
/// -> content
#let annex(body, divider: true) = appendices("annex", "annexes", body, divider: divider)

// An entry of the glossary, a decision of the package: the definition on the line of the term, half a quad after it
// and a period after it, its other lines 2.5 quads in (`quad`, the unit of these widths, is 11.7487 pt in a 12 pt
// body), the terms a line and 14.78 pt (of that body) apart.
/// Creates the glossary (NBR 14724:2024, section 4.2.3.2): the title, centred and without a number, and the terms in
/// alphabetical order, each in bold, followed by its definition.
///
/// The entries can be given in two ways. As pairs, the glossary is only printed:
/// `("Typst", [sistema de composição tipográfica])`. As dictionaries, the terms can also be cited in the text by the
/// key (`@typst`): `(key: "typst", short: "Typst", description: [sistema de composição tipográfica])`.
///
/// - ..entries (array, dictionary): Terms and definitions, all as pairs or all as dictionaries.
/// -> content
#let glossary(..entries) = {
  let given = entries.pos()
  let keyed = given.len() > 0 and type(given.first()) == dictionary
  assert(given.all(e => (type(e) == dictionary) == keyed and (keyed or (type(e) == array and e.len() == 2))),
    message: "glossary: the entries are all pairs, (\"Typst\", [...]), or all dictionaries, (key: \"typst\", short: "
      + "\"Typst\", description: [...]); got " + repr(given))
  let pairs = if keyed { given.map(e => (e.short, e.at("description", default: e.at("long", default: [])))) } else {
    given
  }
  pairs = pairs.sorted(key: p => folded(p.first()))
  context heading(level: 1, numbering: none, word-raw("glossary"))
  if keyed {
    [#metadata(given) #keyed-entries]
    print-glossary(given, invisible: true, show-all: true, disable-back-references: true)
  }
  let quad = 11.7487em / 12
  set par(first-line-indent: 0pt, hanging-indent: 2.5 * quad, justify: true)
  for (term, definition) in pairs {
    block(above: line-spacing - 1em + pt12(14.78), below: line-spacing - 1em + pt12(14.78),
      par[*#term*#h(0.5 * quad)#definition.])
  }
}

// --- the summary --------------------------------------------------------------------------------------------------

// The entries of the summary (NBR 6027): the number of a section at the margin and its title in a column 59.66 pt in
// (of a 12 pt body), its lines under its first; the primary sections in capitals and bold, the secondary in bold, the
// rest in the body and smaller, all in the sans serif (the styles `toc-*` of fonts.typ); the dots, and the page at
// the margin; a primary section a line and a quad (11.75 pt of a 12 pt body) under the entry before it, the others a
// line. From the start of the post-textual part (the references, or `back-matter`) the entries go in the column of
// the titles: an unnumbered primary section (the references, the glossary) a quad more apart, the page of the
// appendices or the annexes as a part (a size above the body and bold, 44.27 pt apart), and an appendix as
// "APÊNDICE A — TÍTULO". The parts (`part`) have no entry of their own here.
#let summary(body) = {
  let styles = ("toc-chapter", "toc-section", "toc-subsection", "toc-subsubsection", "toc-paragraph")
  // the space under the title of the summary: the chapter's to its text and the quad of the first entry; the title
  // among the bookmarks of the PDF, though out of the summary itself
  show outline: it => {
    set heading(bookmarked: true)
    show heading.where(level: 1): set block(below: in-size(heading-after.at(0) + 11.7487em / 12 + line-spacing - 1em,
      scale.heading.at(0)))
    it
  }
  show outline.entry: it => context {
    let head = it.element
    if head.func() != heading { return it }
    // the lengths in em of the body, resolved before the size of the entry changes
    let quad = 11.7487 / 12 * text.size
    let column = 59.66 / 12 * text.size
    let level = calc.min(it.level, 5)
    let key = styles.at(level - 1)
    let start = postextual-start()
    let loc = head.location().position()
    let post = start != none and {
      let at = start.position()
      loc.page > at.page or (loc.page == at.page and loc.y >= at.y)
    }
    let divider = head.has("label") and head.label == <abntly-divider>
    // the number of a section at the margin, also of a section of an appendix, "A.1"; a primary heading of the
    // post-textual part has none there (its letter goes with the title)
    let number = if head.numbering == none or (post and level == 1) { none } else {
      numbering(head.numbering, ..counter(heading).at(head.location()))
    }
    let title = if level == 1 { upper(it.body()) } else { it.body() }
    // an appendix as the summary writes it, "APÊNDICE  A — TÍTULO" (two spaces after the word)
    if post and level == 1 and head.numbering != none {
      let kind = appendix-kind.at(head.location())
      let letter = numbering("A", counter(heading).at(head.location()).first())
      title = [#word-raw(if kind == none { "appendix" } else { kind })~~#letter — #upper(it.body())]
    }
    let style = if divider { "toc-part" } else { key }
    let above = if divider { pt12(44.27) } else if level == 1 and post and head.numbering == none {
      line-spacing + 2 * quad
    } else if level == 1 { line-spacing + quad } else { line-spacing }
    // the dots of the primary sections in their bold sans, the others in the regular serif
    let dots = if divider { none } else if level == 1 { it.fill } else {
      text(..elements.toc-leaders, it.fill)
    }
    // the page in the style of the entry (its sizes are relative: set again inside it, they would grow)
    let page = it.page()
    // (the link inside the paragraph: around the block, a link is set in a line of the size of the summary, which
    // moves a larger entry down)
    block(above: above - elements.at(style).size, below: 0pt, {
      set text(..elements.at(style))
      set par(first-line-indent: 0pt, justify: false, leading: line-spacing - 1em, hanging-indent: column)
      block(inset: (right: 2.55 * quad), link(head.location(), {
        box(width: column, if number != none { number })
        title
        if dots != none { h(0.4em); box(width: 1fr, dots) } else { h(1fr) }
        box(width: 0pt, box(width: 2.55 * quad, align(right, page)))
      }))
    })
  }
  body
}
