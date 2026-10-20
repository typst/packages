// The index (NBR 14724, 4.2.3.5; NBR 6034), the last element of a work, written by the author: each entry a term with
// its pages, its sub-headings and its cross-references, as the author reads them off the finished work. `index()`
// sets them under the title of a chapter, in two columns 35 pt apart, each entry a paragraph with a hanging indent of
// 40 pt, a sub-heading 20 pt in and a sub-sub-heading 30 pt in (6034, 6.7: "recuo progressivo da esquerda para a
// direita"), the entries of one initial together and 10 pt from the next. The distances are a decision of the
// package, in pt of a 12 pt body (`pt12`). The indicator as 6034, 6.12 writes it: the pages after a comma, as the
// author gives them, a range with a hyphen ("3-8") for consecutive pages and commas for the others ("3, 8"), each
// number a link to the page with that printed number; "ver" and "ver também" in italics (6.10, 6.11 and the note),
// after a comma. The order is that of NBR 6033: the letters without their accents (3.1.3), word by word and in it
// letter by letter (4.1), the numbers before the letters (3.5.1).
#import "words.typ": word-raw
#import "spacing.typ": line-spacing
#import "structure.typ": pt12, folded

// the keys of an entry, in English and in Portuguese
#let entry-keys = (term: "term", termo: "term", pages: "pages", paginas: "pages", sub: "sub", see: "see", ver: "see",
  "see-also": "see-also", "ver-tambem": "see-also")

// an entry with every key: the author's dictionary over the defaults, or the pair ("Termo", 3); the pages a list
#let entry(given) = {
  let base = (term: none, pages: (), sub: (), see: none, see-also: none)
  let pages(p) = if type(p) == array { p } else { (p,) }
  if type(given) == array and given.len() == 2 { return base + (term: given.first(), pages: pages(given.last())) }
  assert(type(given) == dictionary, message: "index: an entry is a dictionary, (term: \"Termo\", pages: (3, 8)), or "
    + "a pair, (\"Termo\", 3); got " + repr(given))
  let out = base
  for (key, value) in given {
    assert(key in entry-keys, message: "index: an entry takes the keys " + entry-keys.keys().join(", ") + "; got "
      + repr(key))
    let k = entry-keys.at(key)
    out.insert(k, if k == "sub" { value.map(entry) } else if k == "pages" { pages(value) } else { value })
  }
  assert(out.term != none, message: "index: an entry has a term; got " + repr(given))
  out
}

// the entries in the order of NBR 6033, the sub-headings too
#let ordered(entries) = entries.sorted(key: e => folded(e.term)).map(e => e + (sub: ordered(e.sub)))

// a page as a link to the page with that printed number (the count starts on the title page: the physical page is
// the printed one plus `offset`), each bound of a range ("5-7") to its own page, up to the last page of the work;
// what is not a number (content, a number past the last page) as it is. The links follow `hyperlink` of the main
// function, as every link of the work: `none` takes them out, a colour paints them.
#let page-link(p, offset: 0, last: 0) = {
  let one(n) = if n < 1 or n > last { str(n) } else { link((page: n + offset, x: 0pt, y: 0pt), str(n)) }
  if type(p) == int { return one(p) }
  if type(p) != str { return [#p] }
  let range = p.match(regex("^(\\d+)-(\\d+)$"))
  if range != none { return [#one(int(range.captures.first()))-#one(int(range.captures.last()))] }
  if p.match(regex("^\\d+$")) != none { one(int(p)) } else { [#p] }
}

// one entry: the term, its pages and its cross-references after commas, in a paragraph with a hanging indent of
// 40 pt, a sub-heading 20 pt in, a sub-sub-heading 30 pt in (in pt of a 12 pt body); the lines of the sub-headings
// after it, the group unbreakable, so that a heading does not part from its sub-headings at the foot of a page or a
// column (6034, 6.8 asks for the heading again, with "(continuação)", when they part)
#let lines(e, level, page) = {
  let out = ([#e.term],) + e.pages.map(page)
  out = out.join(", ")
  if e.see != none { out = [#out, #emph(word-raw("index-see")) #e.see] }
  if e.see-also != none { out = [#out, #emph(word-raw("index-see-also")) #e.see-also] }
  par(hanging-indent: pt12(40), [#h(pt12((0, 20, 30).at(calc.min(level, 2))))#out])
  for s in e.sub { lines(s, level + 1, page) }
}

// Two columns by default, a decision of the package. The ranges for consecutive pages, the commas for the others
// (6034, 6.12); `see` and `see-also` are the cross-references of 6034, 6.10 and 6.11, "ver" and "ver também";
// `sort: false` for the orders of 6034, 4.1. The keys are accepted in Portuguese too (`termo`, `paginas`, `sub`,
// `ver`, `ver-tambem`).
/// Creates the index (NBR 14724:2024, section 4.2.3.5; NBR 6034:2004), the last element of the work: the title,
/// centred and without a number, and the entries in alphabetical order, in two columns. The entries and the pages are
/// given by the author, and each page is a link.
///
/// An entry is a dictionary with the keys `term` (the heading), `pages` (a number, a range as in `"15-18"`, or a list
/// of them), `sub` (list of sub-headings, which are entries too), `see` and `see-also` (cross-references). A simple
/// entry can be given as a pair: `("Termo", 3)`.
///
/// ```typ
/// #index(
///   (term: "Entropia", pages: (12, "15-18"), sub: ((term: "de mistura", pages: 16),)),
///   (term: "Equilíbrio", see: "Entropia"),
///   ("Isolamento", 3),
/// )
/// ```
///
/// - ..entries (dictionary, array): Entries of the index.
/// - columns (int): Number of columns.
/// - sort (bool): If `true`, sorts the entries alphabetically, by NBR 6033:1989. Use `false` to keep the order given,
///   in a systematic or chronological index.
/// -> content
#let index(..entries, columns: 2, sort: true) = {
  assert(entries.named().len() == 0, message: "index: takes the entries as positional arguments, and only columns and "
    + "sort as named ones; got " + entries.named().keys().join(", "))
  assert(type(columns) == int and columns > 0, message: "index: columns is a positive integer; got " + repr(columns))
  assert(type(sort) == bool, message: "index: sort is true or false; got " + repr(sort))
  let all = entries.pos().map(entry)
  if sort { all = ordered(all) }
  context heading(level: 1, numbering: none, word-raw("index"))
  // the entries: no indent, no space between the paragraphs beyond that of the lines, a line each
  set par(first-line-indent: 0pt, justify: false, spacing: line-spacing - 1em)
  context {
    // the pages as links: the printed number of this page against its physical one gives the offset of the count
    // (the pages before the title page), the same for every page after it
    let page = page-link.with(offset: here().page() - counter(page).get().first(), last: counter(page).final().first())
    std.columns(columns, gutter: pt12(35), {
      let previous = none
      for e in all {
        // the entries of one initial together, 10 pt (beside the space of the paragraphs) before the next
        let initial = folded(e.term).clusters().at(0, default: "")
        if previous != none and initial != previous { v(pt12(10)) }
        previous = initial
        if e.sub.len() == 0 { lines(e, 0, page) } else { block(breakable: false, lines(e, 0, page)) }
      }
    })
  }
}
