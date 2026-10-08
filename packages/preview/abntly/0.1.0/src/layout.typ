// The layout of abntly: the page, the parts of the work, the start of the primary sections, the running header and
// the number of the page, the hyperlinks and the language.
//
// - The page: A4, 3 cm at the left and the top, 2 cm at the right and the bottom (NBR 14724, 5.1); on both sides of
//   the leaf (`two-sided`), 3 cm on the inside, mirrored on the verso (5.1 b).
// - The parts: the pre-textual pages are counted but carry no number (5.3); the number and the running header start
//   at the first numbered primary section, by themselves, or where the author writes `#show: main-matter`. The
//   headings are numbered "1.1", and `front-matter` and `back-matter` take the number from the headings after them.
//   A primary heading without a number is centred (14724, 5.2.3; 6024, 4.1 h).
// - Every primary section opens a new page, an odd one on both sides, the blank page before it empty (14724, 5.2.2;
//   5.1 for the pre-textual ones), and restarts the numbering of the notes (NBR 10520:2023, 8.1 and 8.2).
// - The number of the page at the top, 2 cm from the edge of the paper, its last figure at 2 cm from the side, on
//   the outside (5.3), in the size of the footnotes; beside it a running header, which no norm has: a decision of
//   the package. It gives the chapter on one side ("Capítulo 1. Introdução"), on both sides the chapter on the verso
//   and the section on the recto, in italics, over a rule of 0.4 pt; only the number on the page that opens a
//   primary section.
// - The links in one colour, `dark-indigo` (a dark indigo), or none at all.
// - The language: Portuguese or English, the words of src/lang.toml (src/words.typ).
//
// The `context`s: the running header of each page, with two queries (the primary sections and, on the recto of a
// work on both sides, the sections); without links, the call of each footnote, written again.

#import "fonts.typ": elements as text-styles
#import "words.typ": word, word-raw
#import "words.typ" as words
#import "elements.typ": sub-reference, sub-counter, appendix-kind

// The colour of the links, a dark indigo given in OKLCH: a decision of the package. Named `dark-indigo`, since Typst
// has no `indigo`; a name Typst already has, such as `blue`, would hide Typst's own in the work of whoever imports
// the package with `*`.
/// Default colour of the links: a dark indigo (`#372aac`). It is the default value of the `hyperlink` parameter of
/// `abntly`.
#let dark-indigo = oklch(39.8%, 0.195, 277.366deg)

/// Starts the pre-textual part: the headings after it take no number. It must be used with a `show` rule:
/// `#show: front-matter`.
///
/// The start of the work is already pre-textual, and the pre-textual elements of the package (abstract, lists,
/// summary) already have unnumbered titles. Use this function only if the work writes pre-textual titles as plain
/// headings, as in `= Presentation`.
///
/// - body (content): Rest of the work.
/// -> content
#let front-matter(body) = {
  set heading(numbering: none)
  body
}

// The page the textual part starts on carries the number even without a numbered heading on it.
/// Starts the textual part: what follows starts on a new page, the first to show the page number and the running
/// header, and the headings are numbered again ("1", "1.1"). It must be used with a `show` rule:
/// `#show: main-matter`.
///
/// Without this function, the textual part starts at the first numbered primary section. Use it when the text starts
/// without a numbered heading.
///
/// - body (content): Rest of the work.
/// -> content
#let main-matter(body) = {
  pagebreak(weak: true)
  [#metadata(none)<abntly-main-matter>]
  set heading(numbering: "1.1")
  body
}

/// Starts the post-textual part: the page numbering and the running header go on, and the headings after it take no
/// number (NBR 14724:2024, section 5.2.3). It must be used with a `show` rule: `#show: back-matter`.
///
/// The post-textual elements of the package (references, glossary, appendices, annexes and index) already have their
/// titles in the right form, and the list of references marks the start of this part for the summary. Use this
/// function only if the work writes post-textual titles as plain headings, as in `= References`.
///
/// - body (content): Rest of the work.
/// -> content
#let back-matter(body) = {
  [#metadata(none)<abntly-back-matter>]
  set heading(numbering: none)
  body
}

// where the post-textual part starts: the mark of `back-matter`, or else the list of references (the references are
// the first post-textual element and mark the part when nothing else does); `none` without either. The summary puts
// the entries from there on in the column of the titles
#let postextual-start() = {
  let marks = query(<abntly-back-matter>)
  if marks.len() > 0 { return marks.first().location() }
  let lists = query(bibliography)
  if lists.len() > 0 { lists.first().location() } else { none }
}

// the page the textual part starts on: the mark of `main-matter`, or the first numbered primary section
#let textual-start() = {
  let marks = query(<abntly-main-matter>)
  if marks.len() > 0 { return marks.first().location().page() }
  let first = query(heading.where(level: 1)).find(h => h.numbering != none)
  if first == none { none } else { first.location().page() }
}

// the marks of the running header: "Capítulo 1. Introdução" (the title alone for a primary heading without a number,
// "Referências"), "2.5. Figuras"
#let chapter-mark(h) = if h.numbering == none { h.body } else if appendix-kind.at(h.location()) != none {
  // an appendix or an annex: its own name and letter, then a period, "APÊNDICE A. Título" (the travessão belongs to
  // its title, not to the header)
  [#word-raw(appendix-kind.at(h.location())) #numbering("A", counter(heading).at(h.location()).first()). #h.body]
} else if type(h.numbering) == function {
  [#numbering(h.numbering, ..counter(heading).at(h.location()))#h.body]
} else {
  [#word-raw("chapter") #counter(heading).at(h.location()).first(). #h.body]
}
#let section-mark(h) = [#numbering(h.numbering, ..counter(heading).at(h.location())). #h.body]

// The running header and the number of the page: nothing before the textual part; on the page that opens a primary
// section only the number; on the others the mark in italics and the number, on one line, over a rule. The mark is
// the primary section in effect; on the recto of a work on both sides, the section (the first one that opens on the
// page, or the last one before it, in that primary section; none before the first), and an unnumbered primary
// section (the references) gives its title on both sides. The number is the one of the page counter, which the
// title page restarts (src/structure.typ): the cover is not counted.
#let running-header(two-sided) = context {
  let at = here().page()
  let start = textual-start()
  if start == none or at < start { return }
  let primary = query(heading.where(level: 1))
  let opens = primary.any(h => h.location().page() == at)
  let verso = two-sided and calc.even(at)
  // the primary section in effect: the last one before this page, in the textual part or after it (a title of the
  // pre-textual part, as the one of the abstract, is no mark of a page of the text)
  let chapter = primary.filter(h => start <= h.location().page() and h.location().page() < at).at(-1, default: none)
  let mark = if opens or chapter == none { none } else if two-sided and not verso and chapter.numbering != none {
    let sections = query(heading.where(level: 2).after(chapter.location()))
      .filter(h => h.numbering != none and h.location().page() <= at)
    let section = sections.find(h => h.location().page() == at)
    if section == none { section = sections.at(-1, default: none) }
    if section != none { section-mark(section) }
  } else { chapter-mark(chapter) }
  // the cap height of the number at 2 cm from the top of the paper (the header starts there), the baseline shared
  // with the mark; the rule 4.53 pt under the baseline, for a number of 10 pt (a decision of the package)
  set text(..text-styles.page-number, top-edge: "cap-height", bottom-edge: "baseline")
  set par(justify: false, first-line-indent: 0pt, leading: 0.2em)
  let number = counter(page).display()
  let mark = if mark != none { text(style: text-styles.header.style, mark) }
  place(top, dy: 2cm, stack(spacing: 4.53em / 10,
    if verso { grid(columns: (auto, 1fr), column-gutter: 1em, number, align(right, mark)) } else {
      grid(columns: (1fr, auto), column-gutter: 1em, mark, number)
    },
    if not opens { line(length: 100%, stroke: 0.4pt) }))
}

// whether the work is on both sides of the leaf, for the pages of the structure that open on a recto (the cover, the
// title page) and the card that goes on the verso of the title page
#let sides = state("abntly-two-sided", false)

// The blank page before a primary section on an odd page carries nothing, neither the running header nor the number:
// the `set` reaches only the page the break inserts.
#let odd-break() = {
  set page(header: none)
  pagebreak(to: "odd", weak: true)
}

/// The layout, for the main function: the page, the parts, the start of the primary sections, the running header,
/// the links and the language.
///
/// - lang (str): "pt" or "en".
/// - names (dictionary): the words the author replaces, from `config-names`.
/// - two-sided (bool): the work on both sides of the leaf.
/// - hyperlink (color, none): the colour of the links, or `none` for no link at all.
/// -> content
#let layout(body, lang: "pt", names: (:), two-sided: false, hyperlink: dark-indigo) = {
  set page(paper: "a4", margin: if two-sided { (top: 3cm, bottom: 2cm, inside: 3cm, outside: 2cm) } else {
    (top: 3cm, bottom: 2cm, left: 3cm, right: 2cm)
  }, header: running-header(two-sided), header-ascent: 0pt, numbering: "1", footer: none)
  set text(lang: lang, region: if lang == "pt" { "br" } else { none })
  set heading(numbering: "1.1")
  // the titles of the summary and of the list of references as text, known here (the word the author gave, or the
  // one of the language of the work), and not as content that reads the language where it lands: the bookmark of
  // the PDF takes the text of a title, and that content has none (the two bookmarks came out blank)
  let fixed(key) = names.at(key, default: words.database.lang.at(lang).at(key))
  set outline(title: fixed("contents"))
  set bibliography(title: fixed("references"))
  // a primary section on a new page, an odd one on both sides; the notes numbered again in each numbered one; a
  // primary heading without a number centred
  show heading.where(level: 1): it => {
    if two-sided { odd-break() } else { pagebreak(weak: true) }
    if it.numbering != none { counter(footnote).update(0) }
    if it.numbering == none { align(center, it) } else { it }
  }
  // the page of a part on the recto, on both sides
  show <abntly-part-start>: it => if two-sided { odd-break(); it } else { it }
  // the links: the colour on every kind of them, or no link at all. The addresses, the footnote that goes back to its
  // call and the calls of the notes of a table are `link`s; the outline, the references and the call of a footnote
  // are linked by Typst inside, so without links they are written again: the entry of the outline as Typst sets it,
  // less its link; the reference as the supplement and the number of what it names, or its page (the equations by
  // chapter write theirs with `link`); the call of the footnote as its number, which keeps the note. The citations
  // take the colour, and without links stay as Typst sets them
  show link: it => if hyperlink == none { it.body } else { text(fill: hyperlink, it) }
  show outline.entry: it => if hyperlink == none { it.indented(it.prefix(), it.inner()) } else {
    text(fill: hyperlink, it)
  }
  show ref: it => if hyperlink != none { text(fill: hyperlink, it) } else {
    let target = it.element
    if target == none { return it }
    // the name the reference gives: `auto-ref`'s is a function of the element
    let supplement = if it.supplement == auto { target.supplement } else if type(it.supplement) == function {
      (it.supplement)(target)
    } else { it.supplement }
    let at = target.location()
    // the page of anything, "5" (`ref(<label>, form: "page")`)
    if it.form == "page" {
      let number = numbering("1", ..counter(page).at(at))
      return if supplement in (none, []) { number } else [#supplement~#number]
    }
    // a footnote, its number as its call, against the word before it as Typst sets it: the norm indicates a note in
    // the text by its number (10520, 8), with a name or without it
    if target.func() == footnote {
      return h(0pt, weak: true) + super(numbering(target.numbering, ..counter(footnote).at(at)))
    }
    if target.func() not in (heading, figure, math.equation) or target.numbering == none { return it }
    let steps = if target.func() == figure { target.counter } else { counter(target.func()) }
    // a part of a set of subfigures (subpar: not outlined, numbered by a function that reads the counters where it is,
    // not where the reference is): the number of the set, which the part itself stepped once more, and its letter,
    // which subpar counts on its own before the part
    let number = if target.func() == figure and not target.outlined and type(target.numbering) == function {
      numbering(sub-reference, steps.at(at).first() - 1, sub-counter.at(at).first() + 1)
    } else { numbering(target.numbering, ..steps.at(at)) }
    if supplement in (none, []) { number } else [#supplement~#number]
  }
  show cite: it => if hyperlink == none { it } else { text(fill: hyperlink, it) }
  show footnote: it => if hyperlink != none { text(fill: hyperlink, it) } else {
    h(0pt, weak: true) + context super(numbering(it.numbering, ..counter(footnote).get()))
  }
  words.names.update(names)
  sides.update(two-sided)
  body
}
