/// Numbering display and reference resolution.
///
/// Every numbered division gets an invisible *anchor* that carries its full
/// address (e.g. question 2, part a → `(1, 0)`) and updates the
/// "current address" state. A reference (`@label`) compares the target's
/// address with the address at the reference site and displays the shortest
/// distinguishing suffix: `@q1p1` from inside question 2 shows "1 (a)", but
/// from inside question 1 part 2 it shows just "(a)".

#import "prelude.typ": *

#import "config.typ": DEFAULT_NUMBERING

// `numbering`, below, is `config`'s: a pattern, a function, or an array of
// them, one per level. Typst's own `numbering` function is `std.numbering`.

/// The pieces of a numbering pattern: each counting symbol (`1`, `a`, `i`,
/// `*`, …) with the text before it, and the text after the last, as Typst
/// reads it. Which characters count is asked of Typst itself: `c` counts
/// when `c1` takes it as a symbol of its own.
#let _pattern(pattern) = {
  let pieces = ()
  let text = ""
  for c in pattern.clusters() {
    if std.numbering(c + "1", 5) != c + "5" {
      pieces.push((prefix: text, symbol: c))
      text = ""
    } else {
      text += c
    }
  }
  assert(pieces.len() > 0, message: "examy: the numbering pattern " + repr(pattern) + " has no counting symbol, such as `1`, `a`, or `i`")
  (pieces: pieces, suffix: text)
}

/// `pattern` applied to the number `n` of its level `k` (0-based) alone, as
/// Typst numbers a nested `enum`: the pattern's first prefix, the symbol of
/// level `k` (the last symbol, past the end), and its suffix. `"1.a.i."`
/// numbers level 1 "b." for 2, and `"(1)(a)"` "(b)".
#let _apply_kth(pattern, k, n) = {
  let p = _pattern(pattern)
  let symbol = p.pieces.at(calc.min(k, p.pieces.len() - 1)).symbol
  p.pieces.first().prefix + std.numbering(symbol, n) + p.suffix
}

/// The number `n` (counted from 1) of level `level` (1-based) on its own.
#let _level_label(level, n, numbering) = {
  let entry = if type(numbering) == array { numbering.at(level - 1, default: "1.") } else { numbering }
  if type(entry) == function { entry(n) } else if type(numbering) == str {
    _apply_kth(numbering, level - 1, n)
  } else { std.numbering(entry, n) }
}

/// A label without its trailing "." (a function's result is kept as is).
#let _strip(s) = if type(s) == str and s.ends-with(".") { s.slice(0, -1) } else { s }

/// Whether `s`, a level's own label, is a number in digits alone, but for a
/// trailing "." or ",".
#let _numeric(s) = {
  if type(s) != str { return false }
  let digits = if s.ends-with(".") or s.ends-with(",") { s.slice(0, -1) } else { s }
  digits != "" and digits.clusters().all(c => c in "0123456789")
}

/// The number of the division at `address` (root first: 0-based ints for
/// numbered levels, content for custom numbers), as displayed in the gutter
/// (trailing dot kept); `none` for an unnumbered one. With `full`, it is
/// numbered with every level's number, as `enum`'s `full` does, when they
/// are all counted. An array's entry for the level with fewer counting
/// symbols than levels (the default's `"(a)"`) would repeat its last one
/// for each, so then it is the full number of the level above followed by
/// the level's own. When every level's own label is a number in digits,
/// the full number above keeps its punctuation, and is followed by the
/// level's own directly when it ends in "." or ",": "2.1.3.". Otherwise it
/// drops a trailing "." or ",", and a thin space parts them: "2 (b) ii.".
///
/// `levels`, when given, is the numbering each level of `address` is drawn
/// with (see `level_numberings`), the last its own, in place of `numbering`
/// for them all. The full number of a division numbered otherwise than a
/// division it is in is put together as above, that of the level above
/// followed by its own.
#let display_number(address, numbering: DEFAULT_NUMBERING, full: false, levels: none) = {
  let number = address.last()
  if number == none { return none }
  if type(number) != int { return [#number] }
  let level = address.len()
  let levels = if levels == none { (numbering,) * level } else { levels }
  let numbering = levels.last()
  if full and address.all(n => type(n) == int) {
    if levels.all(n => n == numbering) {
      let entry = if type(numbering) == array { numbering.at(level - 1, default: "1.") } else { numbering }
      let numbers = address.map(n => n + 1)
      if type(entry) == function { return entry(..numbers) }
      if type(numbering) == str or _pattern(entry).pieces.len() >= level { return std.numbering(entry, ..numbers) }
    }
    let above = display_number(address.slice(0, -1), full: true, levels: levels.slice(0, -1))
    let own = _level_label(level, number + 1, numbering)
    let numeric = range(level).all(i => _numeric(_level_label(i + 1, address.at(i) + 1, levels.at(i))))
    let ends = type(above) == str and (above.ends-with(".") or above.ends-with(","))
    if numeric and ends { return above + own }
    let trimmed = if ends { above.slice(0, -1) } else { above }
    return trimmed + str(sym.space.thin) + own
  }
  _level_label(level, number + 1, numbering)
}

/// How an `enum` inside a division of level `level` (1-based) is numbered:
/// as the level below it, its number on its own.
#let enum_numbering(numbering, level) = {
  if type(numbering) == array { numbering.at(level, default: "(a)") } else if type(numbering) == function {
    numbering
  } else { n => _apply_kth(numbering, level, n) }
}

/// One address component as displayed in a reference (trailing "." stripped,
/// so a question+part reference reads "1 (a)", not "1. (a)").
/// `level_index` is 0-based.
#let format_component(level_index, number, numbering: DEFAULT_NUMBERING) = {
  if type(number) == int {
    [#_strip(_level_label(level_index + 1, number + 1, numbering))]
  } else if number == none {
    [??]
  } else {
    [#number]
  }
}

/// Pure resolution rule: given the target's full address and the address of
/// the reference site (both root-first arrays), return the
/// `(level_index, number)` pairs to display. The common prefix is dropped,
/// but at least the last component is always shown.
#let relative_components(target, current) = {
  let i = 0
  while i < target.len() - 1 and i < current.len() and target.at(i) == current.at(i) {
    i += 1
  }
  target.enumerate().slice(i)
}

/// Render the reference body for a target address as seen from `current`.
/// With `full`, a counted target reads as its full number wherever it is
/// referenced from ("1.a"), as the gutter shows it, less its trailing ".".
/// `levels`: as `display_number` takes it.
#let reference_body(target, current, numbering: DEFAULT_NUMBERING, full: false, levels: none) = {
  if full and target.all(n => type(n) == int) {
    return [#_strip(display_number(target, numbering: numbering, full: true, levels: levels))]
  }
  relative_components(target, current)
    .map(((lvl, n)) => format_component(lvl, n, numbering: if levels == none { numbering } else { levels.at(lvl) }))
    .join(sym.space.thin)
}

/// The numbering each level of division `d`'s address is drawn with, as
/// `display_number` takes it: `numbering`, the exam's, but where it, or a
/// division it is in, gives one of its own (see `localize` in render.typ);
/// `none` when none does.
#let level_numberings(d, numbering) = {
  let levels = d.at("own", default: (:)).at("numberings", default: none)
  if levels != none { levels.map(n => if n == auto { numbering } else { n }) }
}

/// State holding the address of the most recently started division (or
/// continuation segment) — the "where am I" for relative references.
#let _current_address = state(PREFIX + "/current-address", ())

/// Emit a (invisible) state update marking that subsequent content belongs
/// to the division at `address`.
#let update_current_address(address) = _current_address.update(address)

/// A reference to the division whose anchor has `fields`, as it reads from
/// here, a link to `dest` (or none). Needs context.
#let _reference(fields, dest) = {
  let current = _current_address.get()
  let body = reference_body(fields.full_address, current, numbering: fields.numbering, full: fields.full, levels: fields.levels)
  if dest != none { link(dest, body) } else { body }
}

/// Invisible anchor placed at the start of a numbered division. Carries the
/// user's label so `@label` references resolve to a smart relative number.
#let division_anchor = e.element.declare(
  "division-anchor",
  prefix: PREFIX,
  doc: "Invisible anchor marking a division's position and address; the target of `@label` references.",
  display: it => {
    _current_address.update(it.full_address)
  },
  reference: (
    custom: it => context _reference(it, it.label_name),
  ),
  fields: (
    e.field(
      "label_name",
      e.types.option(label),
      doc: "The division's user label (repeated here so references can link to it)",
    ),
    e.field(
      "full_address",
      e.types.array(e.types.any),
      doc: "The full address of the division, root first, e.g. (1, 0) for question 2 part a. 0-based ints for numbered levels; content for custom numbers.",
    ),
    e.field(
      "numbering",
      e.types.any,
      doc: "The `numbering` the division is drawn with, which its references are numbered with too.",
      default: DEFAULT_NUMBERING,
      folds: false,
    ),
    e.field(
      "levels",
      e.types.any,
      doc: "The numbering each level of its address is drawn with, when not all `numbering` (see `level_numberings`), or `none`.",
      default: none,
      folds: false,
    ),
    e.field(
      "full",
      bool,
      doc: "`numbering-full`, as the division is drawn with.",
      default: false,
    ),
  ),
)

/// A show rule on references, for an exam's content: a label that several
/// exams' divisions carry, as a bundle's exam and its key made from the same
/// questions do, refers to the division in the exam the reference is about,
/// which `exam_of` tells of a location (see `exam_index` in points.typ).
/// Typst finds such a label ambiguous: labels are global to a document, and
/// to a bundle. A label also used by something other than a division is left
/// to Typst, which reports it (one used twice in an exam is an error of its
/// own, see `check_duplicate_labels`).
#let own_exam_refs(exam_of) = it => context {
  let found = query(it.target)
  if found.len() < 2 { return it }
  let eid = e.data(division_anchor).eid
  let anchors = found.map(x => (x, e.data(x)))
  if anchors.any(((_, d)) => d.at("eid", default: none) != eid) { return it }
  let here_exam = exam_of(here())
  let mine = anchors.filter(((x, _)) => exam_of(x.location()) == here_exam)
  if mine.len() != 1 { return it }
  let (x, d) = mine.first()
  _reference(d.fields, x.location())
}
