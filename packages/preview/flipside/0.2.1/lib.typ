// flipside – Frank Fasbender <ffasbend@gmail.com>, MIT licence
// https://github.com/ffasbend/flipside
//
// Recto/verso flashcards on A4 or Letter sheets, in DIN, US, business-card
// or custom card sizes.
// Odd pages = questions, even pages = answers.
// Answers are printed upright, rows unchanged, columns mirrored, so each
// answer lands behind its question when the sheet is turned over sideways,
// like a book page: duplex "flip on short edge" for landscape sheets,
// "flip on long edge" for portrait sheets.
// With layout "list": one card per row, front and back side by side, each
// exactly as printed (to check the cards).
// With layout "calibrate": one test sheet to measure how far the printer
// shifts the back side (see `back-offset`).
//
// The template knows nothing about logos, classes or themes: each side of a
// card has a header and a footer with three slots (left, center, right), and
// the deck file says what goes into them (see `flipside` below).

// Card sizes (landscape; `orientation: "portrait"` turns them upright).
// The key is the name without spaces, in capitals; "DIN" may be left out.
// The DIN sizes are exact fractions of A4, so they fill the sheet:
//   DIN A8:  74 × 52 mm, 16 per A4     DIN A7: 105 × 74 mm, 8 per A4
//   DIN A6: 148 × 105 mm, 4 per A4     DIN A5: 210 × 148 mm, 2 per A4
// US index cards and business cards are centred on the sheet; the business
// cards match the usual perforated sheets (10 per sheet).
#let card-sizes = (
  A8: (name: "DIN A8", width: 297mm / 4, height: 210mm / 4, paper: "a4"),
  A7: (name: "DIN A7", width: 210mm / 2, height: 297mm / 4, paper: "a4"),
  A6: (name: "DIN A6", width: 297mm / 2, height: 210mm / 2, paper: "a4"),
  A5: (name: "DIN A5", width: 210mm, height: 297mm / 2, paper: "a4"),
  US3X5: (name: "US 3x5", width: 5in, height: 3in, paper: "us-letter"),
  US4X6: (name: "US 4x6", width: 6in, height: 4in, paper: "us-letter"),
  // perforated sheets: always 2 × 5 cards on a portrait sheet
  USBUSINESS: (name: "US business", width: 3.5in, height: 2in, paper: "us-letter", cols: 2, rows: 5),
  EUBUSINESS: (name: "EU business", width: 85mm, height: 54mm, paper: "a4", cols: 2, rows: 5),
)

// Papers (portrait width, height), as named in Typst
#let papers = (
  "a3": (297mm, 420mm),
  "a4": (210mm, 297mm),
  "a5": (148mm, 210mm),
  "us-letter": (8.5in, 11in),
  "us-legal": (8.5in, 14in),
)

// Size of an A8 card (the original size), kept for files that use it
#let cols = 4
#let rows = 4
#let card-w = 297mm / cols
#let card-h = 210mm / rows

// Helpers for card content
#let small(body) = text(size: 0.72em, body)
#let tiny(body) = text(size: 0.6em, body)
#let block-left(body) = align(left, { set par(justify: true); body })

// Colours for `stripe: auto`, one per theme, in the order the themes appear
// (Okabe–Ito palette, distinguishable also with colour blindness)
#let stripe-palette = (
  rgb("#0072B2"), rgb("#E69F00"), rgb("#009E73"), rgb("#CC79A7"),
  rgb("#56B4E9"), rgb("#D55E00"), rgb("#F0E442"), rgb("#999999"),
)

// ── Items, hints and notes ──
// These functions only mark their content with a label. `flipside` shows or
// hides the marked parts depending on the role of the side (question or
// answer), and the MyCards app reads the same labels (layout "report").

// Several items on one side. `kind` is what happens when the side is the
// question ("all": one card, items together; "any": one card per item), `a`
// what happens when it is the answer ("all": all needed; "any": any one right).
#let _items(kind, args) = {
  let a = args.named().at("a", default: kind)
  assert(args.named().keys().all(k => k == "a"),
    message: kind + " only takes the items and a: \"all\" or \"any\"")
  assert(a in ("all", "any"), message: "a: of " + kind + " must be \"all\" or \"any\", not \"" + str(a) + "\"")
  let items = args.pos()
  assert(items.len() >= 2, message: kind + " needs at least 2 items: " + kind + "[…][…]")
  let name = if a == kind { "fs-" + kind } else { "fs-" + kind + "-" + a }
  [#block(items.map(i => [#block(i)<fs-item>]).join())#label(name)]
}
/// Items that belong together: as the question shown together on one card, as
/// the answer all needed. `all(a: "any")[…][…]`: as the answer any one is right.
#let all(..args) = _items("all", args)
/// Alternatives: as the question one card per item, as the answer any one is
/// right. `any(a: "all")[…][…]`: as the answer all are needed.
#let any(..args) = _items("any", args)

/// Shown only when the side is the question. For plain text `[? …]` also works.
#let q-only(body) = [#box(body)<fs-q-only>]
/// Shown only when the side is the answer. For plain text `[! …]` also works.
#let a-only(body) = [#box(body)<fs-a-only>]
/// A note: on a line of its own, shown in both roles (not part of the answer).
#let note(body) = [#block(body)<fs-note>]
/// A note shown only when the side is the question.
#let q-note(body) = [#block(body)<fs-q-note>]
/// A note shown only when the side is the answer.
#let a-note(body) = [#block(body)<fs-a-note>]

// The functions above, for cells of a CSV file read as markup (markup: true)
#let _markup-scope = (
  all: all, any: any, q-only: q-only, a-only: a-only,
  note: note, q-note: q-note, a-note: a-note,
  small: small, tiny: tiny, block-left: block-left,
)

// A side as shown in a role: "q" (the side is asked) or "a" (the side is the
// answer). Hidden parts disappear; `[? …]` / `[! …]` lose their brackets, and
// a comma or space before a hidden one goes with it.
#let _in-role(role, body) = {
  let shown(r) = r == role
  show <fs-q-only>: it => if shown("q") { it }
  show <fs-a-only>: it => if shown("a") { it }
  show <fs-note>: it => text(size: 0.85em, it)
  show <fs-q-note>: it => if shown("q") { text(size: 0.85em, it) }
  show <fs-a-note>: it => if shown("a") { text(size: 0.85em, it) }
  show regex("[,;]?\s*\[\?[^\]]*\]"): it => if shown("q") {
    it.text.replace(regex("\[\?\s*"), "").replace(regex("\s*\]$"), "")
  }
  show regex("[,;]?\s*\[![^\]]*\]"): it => if shown("a") {
    it.text.replace(regex("\[!\s*"), "").replace(regex("\s*\]$"), "")
  }
  body
}

// A side written with all / any: (q: "all"|"any", a: "all"|"any", items: (…)),
// or none. `[#all[…][…]]` (the group alone in a content block) counts too.
#let _items-of(side) = {
  if type(side) != content { return none }
  if side.func() == [].func() {
    let parts = side.children.filter(c => c != [ ])
    if parts.len() != 1 { return none }
    side = parts.first()
  }
  if not side.has("label") { return none }
  let name = str(side.label)
  if not (name.starts-with("fs-all") or name.starts-with("fs-any")) { return none }
  let kinds = name.split("-")
  let body = side.body
  let children = if body.func() == [].func() { body.children } else { (body,) }
  (
    q: kinds.at(1),
    a: kinds.at(2, default: kinds.at(1)),
    items: children.filter(c => c.has("label") and str(c.label) == "fs-item").map(c => c.body),
  )
}

/// Lays out the cards as printable sheets, or as a list to check them.
///
/// - cards (array): the cards, each `(q: […], a: […])`. An entry without `q`
///   and `a`, e.g. `(theme: "Les chiffres"),`, is no card: its fields are
///   given to every card after it (until another entry changes them), so the
///   slots can show them. Empty cards `(q: [], a: [])` are blank places.
///   Cards can also come from a CSV file: `csv("cards.csv")` (rows
///   question, answer) or `csv("cards.csv", row-type: dictionary)` (columns
///   q, a and any others, e.g. theme; an empty cell keeps the value above).
/// - header, footer (dictionary): slots of the question side,
///   `(left: …, center: …, right: …)`. A slot is `none`, content, or a
///   function that gets the card and returns content. The card holds `q`,
///   `a`, the fields of the entries above it, `number` (1, 2, …; none for
///   empty cards) and `total` (number of cards).
/// - back-header, back-footer (dictionary): the same for the answer side.
/// - title (str, content): name of the deck; shown in the list's page footer.
/// - lang (str, dictionary): language of the cards, for hyphenation and
///   quotation marks: one for both sides, e.g. "fr", or one per side,
///   `(q: "de", a: "fr")` (question side, answer side). Default "en".
/// - font, size: text of the cards. slot-font, slot-size: text of the slots;
///   slots are designed for an A8 card and grow with larger cards. The
///   default fonts are built into Typst, so the cards look the same everywhere.
/// - back-borders (bool): outline the answer cards too.
/// - fit (bool): shrink a side whose content is too large for the card.
///   The list marks the shrunk cards (or, with `fit: false`, the cards that
///   overflow).
/// - stripe: coloured stripe on one edge of each card (on both sides), to
///   sort the cards: `none`, `auto` (one colour per theme), a dictionary
///   `("Opérations": blue, …)` (by theme) or a function card => colour.
/// - stripe-width (length): width of the stripe on an A8 card.
/// - markup (bool): read strings in cards (e.g. from CSV) as Typst markup,
///   so `$x^2$` or `*bold*` work. Default: plain text.
/// - back-offset (dictionary): moves the answer pages, `(x: 0.8mm, y: -0.5mm)`,
///   to make up for the printer; measured with `layout: "calibrate"`.
///   `--input back-offset=0.8mm,-0.5mm` wins.
/// - only (none, str, array, function): print only some cards, e.g. "5-12,17",
///   `(3, 8)` or `c => c.theme == "Cardinal"`. Numbers stay those of the whole
///   deck. `--input only=5-12,17` wins.
/// - dir (str): "forward" (side q is asked, default), "reverse" (side a is
///   asked) or "both" (every card twice, once each way); a card's own `dir`
///   wins. `--input dir=both` wins over the deck.
/// - count (function): what the question shows when more than 2 items of the
///   answer are needed, `n => …`; default "(3)".
/// - layout (str): "cards", "list", "calibrate" or "report" (the cards for the
///   MyCards app, as metadata <flipside-cards>, and one page per picture);
///   `typst compile --input layout=list` wins.
/// - card (str, dictionary): "DIN A8" (or "A8"), "DIN A7", "DIN A6", "DIN A5",
///   "US 3x5", "US 4x6", "US business", "EU business", or your own size:
///   `(width: 80mm, height: 50mm)`, optionally with `cols`, `rows`,
///   `gap` (length or (x: …, y: …)) and `margin` ((left: …, top: …); default:
///   centred). `typst compile --input card=A7` wins.
/// - paper (auto, str): the sheet: auto = A4 for DIN and EU sizes, "us-letter"
///   for US sizes; or "a4", "us-letter", "a3", "a5", "us-legal".
///   `--input paper=…` wins.
/// - orientation (str): "landscape" (default) or "portrait" (upright cards).
///   `--input orientation=…` wins.
#let flipside(
  cards,
  header: (:),
  footer: (:),
  back-header: (:),
  back-footer: (:),
  title: none,
  lang: "en",
  font: "New Computer Modern",
  size: 13pt,
  slot-font: "New Computer Modern",
  slot-size: 7pt,
  back-borders: false,
  fit: true,
  stripe: none,
  stripe-width: 2.5mm,
  markup: false,
  back-offset: (x: 0mm, y: 0mm),
  only: none,
  layout: "cards",
  card: "A8",
  paper: auto,
  orientation: "landscape",
  dir: "forward",
  count: n => text(size: 0.8em)[(#n)],
) = {
  let layout = sys.inputs.at("layout", default: layout)
  assert(layout in ("cards", "list", "calibrate", "report"),
    message: "layout must be \"cards\", \"list\", \"calibrate\" or \"report\", not \"" + layout + "\"")
  let dir = sys.inputs.at("dir", default: dir)
  let directions = ("forward", "reverse", "both")
  assert(dir in directions, message: "dir must be \"forward\", \"reverse\" or \"both\", not \"" + str(dir) + "\"")
  // ── The card and the sheet ──
  let card = sys.inputs.at("card", default: card)
  let spec = if type(card) == dictionary {
    assert("width" in card and "height" in card,
      message: "a card of your own needs width and height: (width: 80mm, height: 50mm)")
    (name: [#card.width × #card.height], paper: "a4") + card
  } else {
    let key = upper(card.replace(" ", ""))
    if key.starts-with("DIN") { key = key.slice(3) }
    assert(key in card-sizes, message: "card must be \"DIN A8\", \"DIN A7\", \"DIN A6\", " +
      "\"DIN A5\", \"US 3x5\", \"US 4x6\", \"US business\", \"EU business\" " +
      "or (width: …, height: …), not \"" + card + "\"")
    card-sizes.at(key)
  }
  let card-size = spec.name
  let orientation = sys.inputs.at("orientation", default: orientation)
  assert(orientation in ("landscape", "portrait"),
    message: "orientation must be \"landscape\" or \"portrait\"")
  // a fixed grid (perforated sheets) turns with the cards: the same sheet,
  // turned by 90°
  if type(card) != dictionary and orientation == "portrait" and "cols" in spec {
    (spec.cols, spec.rows) = (spec.rows, spec.cols)
  }
  // the card: landscape = the long side across
  let (long, short) = (calc.max(spec.width, spec.height), calc.min(spec.width, spec.height))
  let (card-w, card-h) = if orientation == "landscape" { (long, short) } else { (short, long) }

  let paper = sys.inputs.at("paper", default: paper)
  let paper = if paper == auto { spec.paper } else { lower(paper) }
  assert(paper in papers, message: "paper must be one of " + papers.keys().join(", "))
  let (paper-w, paper-h) = papers.at(paper)   // portrait

  let gap = spec.at("gap", default: 0mm)
  let gap = if type(gap) == dictionary { (x: gap.at("x", default: 0mm), y: gap.at("y", default: 0mm)) }
    else { (x: gap, y: gap) }
  // How many cards fit on the sheet, portrait or landscape: the way with more
  // cards wins; with as many, the sheet turned like the card.
  let fits(space, size, g) = calc.floor((space + g) / (size + g) + 1e-9)
  let ways = (false, true).map(flipped => {
    let (w, h) = if flipped { (paper-h, paper-w) } else { (paper-w, paper-h) }
    let cols = spec.at("cols", default: fits(w, card-w, gap.x))
    let rows = spec.at("rows", default: fits(h, card-h, gap.y))
    (flipped: flipped, cols: cols, rows: rows, fit: cols * card-w + (cols - 1) * gap.x <= w + 0.01mm
      and rows * card-h + (rows - 1) * gap.y <= h + 0.01mm)
  }).filter(w => w.fit and w.cols >= 1 and w.rows >= 1)
  assert(ways.len() > 0, message: "the card does not fit on the paper")
  let best = ways.sorted(key: w => 2 * w.cols * w.rows + if w.flipped == (orientation == "landscape") { 1 } else { 0 }).last()
  let (flipped, cols, rows) = (best.flipped, best.cols, best.rows)
  let (sheet-w, sheet-h) = if flipped { (paper-h, paper-w) } else { (paper-w, paper-h) }
  // Where the cards are: centred, or at the margin of a sheet of your own.
  // The back is mirrored, so its left margin is the front's right margin.
  let grid-w = cols * card-w + (cols - 1) * gap.x
  let grid-h = rows * card-h + (rows - 1) * gap.y
  let margin = spec.at("margin", default: (:))
  let margin = if type(margin) == length { (left: margin, top: margin) } else { margin }
  let front-left = margin.at("left", default: (sheet-w - grid-w) / 2)
  let sheet-top = margin.at("top", default: (sheet-h - grid-h) / 2)
  let back-left = sheet-w - front-left - grid-w

  // Slots and margins grow with the card (1 for A8)
  let k = calc.min(calc.max(card-w, card-h) / (297mm / 4), calc.min(card-w, card-h) / (210mm / 4))

  // Shift of the answer pages: (x: …, y: …), or "0.8mm,-0.5mm" (numbers = mm)
  let to-length(v) = {
    let v = if type(v) == str { eval(v.trim()) } else { v }
    if type(v) in (int, float) { v * 1mm } else { v }
  }
  let back-offset = sys.inputs.at("back-offset", default: back-offset)
  let offset = if type(back-offset) == str {
    let parts = back-offset.split(",")
    assert(parts.len() == 2, message: "back-offset must be like 0.8mm,-0.5mm")
    (x: to-length(parts.at(0)), y: to-length(parts.at(1)))
  } else {
    assert(type(back-offset) == dictionary and back-offset.keys().all(x => x in ("x", "y")),
      message: "back-offset must be (x: …, y: …)")
    (x: to-length(back-offset.at("x", default: 0mm)), y: to-length(back-offset.at("y", default: 0mm)))
  }

  // Slots: (left, center, right), every one defaulting to none
  let empty-slots = (left: none, center: none, right: none)
  let check(name, d) = {
    assert(type(d) == dictionary and d.keys().all(x => x in empty-slots),
      message: name + " must be (left: …, center: …, right: …)")
    empty-slots + d
  }
  let header = check("header", header)
  let footer = check("footer", footer)
  let back-header = check("back-header", back-header)
  let back-footer = check("back-footer", back-footer)
  let used(d) = d.values().any(v => v != none)

  // Cards from CSV: a row (question, answer) or a dictionary with q, a, …;
  // strings become content (one printed line per line of the cell).
  let to-content(v) = if type(v) != str { v } else {
    let s = v.replace("\r\n", "\n").trim()
    if s == "" { [] }
    else {
      let line(l) = if markup { eval(l.trim(), mode: "markup", scope: _markup-scope) } else { [#l.trim()] }
      s.split("\n").map(line).join(linebreak())
    }
  }
  // Returns the entries for one item of `cards` (a CSV row can give two: its
  // other columns, which also hold for the rows below, and the card).
  let normalize(c) = {
    if type(c) == array {
      c = (q: c.at(0, default: ""), a: c.at(1, default: ""))
    }
    if type(c) != dictionary { return (c,) }
    let from-csv = ("q", "a").any(key => type(c.at(key, default: none)) == str)
    if not from-csv { return (c,) }
    let q = to-content(c.at("q", default: ""))
    let a = to-content(c.at("a", default: ""))
    // other columns: an empty cell keeps the value of the rows above
    let others = c.pairs()
      .filter(((key, v)) => key not in ("q", "a") and key != "" and v != "")
      .to-dict()
    if q == [] and a == [] and others.len() > 0 { return (others,) }
    let entries = if others.len() > 0 { (others,) } else { () }
    entries + ((q: q, a: a),)
  }

  // Each card gets the fields of the entries above it (theme, dir, …)
  let fields = (:)
  let prepared = ()
  let items = ()
  for c in cards { items += normalize(c) }
  for c in items {
    if type(c) == dictionary and "q" not in c and "a" not in c {
      fields += c
      continue
    }
    if type(c) != dictionary { continue }
    prepared.push(fields + (q: [], a: []) + c)
  }

  // Language of the question side and of the answer side
  let (q-lang, a-lang) = if type(lang) == dictionary {
    assert(lang.keys().all(x => x in ("q", "a")), message: "lang must be \"fr\" or (q: \"de\", a: \"fr\")")
    (lang.at("q", default: "en"), lang.at("a", default: "en"))
  } else { (lang, lang) }

  // For the MyCards app: the cards as written, and every picture on a page of
  // its own (in the order of the cards: side q, then side a), like its own
  // template for the older flashcards.typ (mycards-app typstProject.ts).
  if layout == "report" {
    let picture-funcs = ("context", "image", "layout")
    let pictures(c) = {
      if type(c) != content { return () }
      if repr(c.func()) in picture-funcs { return (c,) }
      let out = ()
      for (k, v) in c.fields() {
        if type(v) == content { out += pictures(v) }
        else if type(v) == array { for x in v { out += pictures(x) } }
      }
      out
    }
    let all-pictures = prepared.map(c => pictures(c.q) + pictures(c.a)).flatten()
    return {
      set page(width: auto, height: auto, margin: 1mm)
      [#metadata((
        format: 1,
        title: title,
        lang: (q: q-lang, a: a-lang),
        dir: dir,
        cards: prepared,
      )) <flipside-cards>]
      for (i, p) in all-pictures.enumerate() { if i > 0 { pagebreak() }; p }
    }
  }

  // The printed cards: every card once per direction, and once per item when
  // the asked side is `any`. Each gets the content of its front (the asked
  // side, in its question role) and of its back (the other side, as answer).
  let expanded = ()
  for c in prepared {
    if c.q == [] and c.a == [] {
      expanded.push(c + (front: [], back: [], front-lang: q-lang, back-lang: a-lang, direction: none))
      continue
    }
    let d = c.at("dir", default: dir)
    assert(d in directions, message: "dir must be \"forward\", \"reverse\" or \"both\", not \"" + str(d) + "\"")
    let ways = if d == "forward" { (("q", "a"),) } else if d == "reverse" { (("a", "q"),) }
      else { (("q", "a"), ("a", "q")) }
    for (asked, other) in ways {
      let question = c.at(asked)
      let answer = c.at(other)
      let q-items = _items-of(question)
      let a-items = _items-of(answer)
      let questions = if q-items != none and q-items.q == "any" { q-items.items } else { (question,) }
      // any one right: the items on one line, " / " between them
      if a-items != none and a-items.a == "any" { answer = a-items.items.join(" / ") }
      // more than 2 items needed: the question says how many
      let needed = if a-items != none and a-items.a == "all" and a-items.items.len() > 2 {
        block(count(a-items.items.len()))
      } else { [] }
      let (front-lang, back-lang) = if asked == "q" { (q-lang, a-lang) } else { (a-lang, q-lang) }
      for qq in questions {
        expanded.push(c + (
          front: _in-role("q", qq) + needed,
          back: _in-role("a", answer),
          front-lang: front-lang,
          back-lang: back-lang,
          direction: if asked == "q" { "forward" } else { "reverse" },
        ))
      }
    }
  }
  // … then their number and the total (blank cards have none)
  let n = 0
  let numbered = ()
  for c in expanded {
    let blank = c.front == [] and c.back == []
    if not blank { n += 1 }
    numbered.push(c + (number: if blank { none } else { n }))
  }
  let total = n
  let cards = numbered.map(c => c + (total: total))

  // Colour of the stripe, from all cards (so it stays the same with `only`)
  let themes = ()
  for c in cards {
    if type(c) == dictionary and "theme" in c and c.theme not in themes { themes.push(c.theme) }
  }
  let stripe-color(card) = {
    if card.number == none or stripe == none { return none }
    if type(stripe) == function { return stripe(card) }
    let theme = card.at("theme", default: none)
    if theme == none { return none }
    if stripe == auto {
      stripe-palette.at(calc.rem(themes.position(t => t == theme), stripe-palette.len()))
    } else {
      assert(type(stripe) == dictionary,
        message: "stripe must be none, auto, a dictionary or a function")
      if type(theme) == str { stripe.at(theme, default: none) }
    }
  }

  // Only some cards: "5-12,17", 5, (3, 8) or a function card => bool
  let only = sys.inputs.at("only", default: only)
  if only != none {
    let keep = if type(only) == function { only } else {
      let numbers = if type(only) == int { (only,) }
        else if type(only) == array { only }
        else {
          str(only).split(",").map(p => p.trim()).filter(p => p != "").map(p => {
            let ends = p.split("-").map(x => int(x.trim()))
            range(ends.first(), ends.last() + 1)
          }).flatten()
        }
      c => c.number in numbers
    }
    cards = cards.filter(c => type(c) == dictionary and c.number != none and keep(c))
  }

  set text(font: font, size: size, lang: q-lang)
  set par(leading: 0.55em)

  let stroke = 0.6pt + black

  // What a slot shows for one card (none = nothing), at A8 size, scaled by k
  let slot(v, card) = {
    let v = if type(v) == function { v(card) } else { v }
    if v == none or v == [] { none } else {
      let t = text(font: slot-font, size: slot-size, v)
      // scale() shifts some text (e.g. "É") slightly even at 100 %: only scale when needed
      if k == 1 { t } else { scale(k * 100%, reflow: true, t) }
    }
  }
  // Places the header and footer of one side
  let slots(head, foot, card, hx, fx) = {
    for (pos, dx) in ((left, hx), (center, 0mm), (right, -hx)) {
      let v = slot(head.at(repr(pos)), card)
      if v != none { place(top + pos, dx: dx, dy: 3.4mm * k, v) }
    }
    for (pos, dx) in ((left, fx), (center, 0mm), (right, -fx)) {
      let v = slot(foot.at(repr(pos)), card)
      if v != none { place(bottom + pos, dx: dx, dy: -3.5mm * k, v) }
    }
  }
  // The stripe on one edge of the card (left on the front, right on the back:
  // the same edge of the cut card)
  let stripe-on(card, edge) = {
    let color = stripe-color(card)
    if color != none {
      place(top + edge, rect(width: stripe-width * k, height: card-h, fill: color, stroke: none))
    }
  }

  // The room for the content of each side (inside the margins)
  let front-in = (
    x: 5mm * k,
    top: if used(header) { 11mm * k } else { 5mm * k },
    bottom: if used(footer) { 8mm * k } else { 5mm * k },
  )
  let back-in = (
    x: 7mm * k,
    top: if used(back-header) { 11mm * k } else { 5mm * k },
    bottom: 5mm * k,
  )
  let room(m) = (w: card-w - 2 * m.x, h: card-h - m.top - m.bottom)

  // How much a side must shrink to fit its room (1 = it fits); needs context
  let fit-factor(body, r, lang) = {
    // measured in the text of the cards, wherever it is called from
    let height(f) = measure(block(width: r.w / f,
      text(font: font, size: size, lang: lang, body))).height * f
    if height(1.0) <= r.h { return 1.0 }
    let (lo, hi) = (0.25, 1.0)
    for _ in range(12) {
      let mid = (lo + hi) / 2
      if height(mid) <= r.h { lo = mid } else { hi = mid }
    }
    lo
  }
  // The content of a side, shrunk if it is too large (with fit: true)
  let fitted(body, r, lang) = if not fit { body } else {
    context {
      let f = fit-factor(body, r, lang)
      if f >= 1 { body } else { scale(f * 100%, reflow: true, block(width: r.w / f, body)) }
    }
  }

  // The question side of a card, as printed (none = empty place on the sheet).
  let front(card) = box(width: card-w, height: card-h, stroke: stroke, {
    set text(lang: if card != none { card.front-lang } else { q-lang })
    if card != none {
      stripe-on(card, left)
      slots(header, footer, card, 5mm * k, 3.5mm * k)
      // placed, so that content too large for the card (fit: false) can
      // never make the card, and with it the row of the sheet, larger
      place(top + left, block(width: card-w, height: card-h, inset: front-in,
        align(center + horizon, fitted(card.front, room(front-in), card.front-lang))))
    }
  })

  // The answer side of a card, as printed; `border` draws its outline.
  let back(card, border: back-borders) = box(width: card-w, height: card-h,
    stroke: if border { stroke } else { none }, {
    set text(lang: if card != none { card.back-lang } else { a-lang })
    if card != none {
      stripe-on(card, right)
      slots(back-header, back-footer, card, 3.5mm * k, 3.5mm * k)
      // placed, so that content too large for the card (fit: false) can
      // never make the card, and with it the row of the sheet, larger
      place(top + left, block(width: card-w, height: card-h, inset: back-in,
        align(center + horizon, fitted(card.back, room(back-in), card.back-lang))))
    }
  })

  // A printed sheet: the front grid at its place, the back grid mirrored
  // and moved by back-offset
  let at(left, g) = if calc.abs(left / 1mm) < 0.001 and calc.abs(sheet-top / 1mm) < 0.001 { g }
    else { pad(left: left, top: sheet-top, g) }
  let sheet-grid(cells) = grid(columns: cols, column-gutter: gap.x, row-gutter: gap.y, ..cells)
  let front-sheet(cells) = at(front-left, sheet-grid(cells))
  let back-sheet(cells) = {
    let g = at(back-left, sheet-grid(cells))
    if offset.x == 0mm and offset.y == 0mm { g } else { move(dx: offset.x, dy: offset.y, g) }
  }

  if layout == "list" {
    // Larger cards are shown smaller, so that front and back fit side by side
    // on the page, with at least 2 cards per page; their layout stays the same.
    let scale-on(w, h) = calc.min(1,
      (w - 20mm - 12mm) / (2 * card-w),
      (h - 28mm - 3mm) / (2 * card-h))
    // Portrait paper, unless the cards would be shown much smaller than on
    // landscape paper (e.g. DIN A6 and A5)
    let list-flipped = scale-on(paper-w, paper-h) < 0.75 and scale-on(paper-h, paper-w) > scale-on(paper-w, paper-h)
    let (list-w, list-h) = if list-flipped { (paper-h, paper-w) } else { (paper-w, paper-h) }
    set page(paper: paper, flipped: list-flipped,
      margin: (x: 10mm, top: 12mm, bottom: 16mm),
      footer: context text(font: slot-font, size: 8pt)[
        #title (#card-size) #h(1fr) #counter(page).display("1 / 1", both: true)
      ])
    let f = scale-on(list-w, list-h)
    let side(body) = scale(f * 100%, reflow: true, body)
    // Shrunk (fit: true) or overflowing (fit: false) sides are marked
    let mark(card) = context {
      let fq = fit-factor(card.front, room(front-in), card.front-lang)
      let fa = fit-factor(card.back, room(back-in), card.back-lang)
      let f = calc.min(fq, fa)
      if f < 1 {
        let which = if fq < 1 and fa < 1 [Q A] else if fq < 1 [Q] else [A]
        linebreak()
        if fit { text(fill: orange.darken(20%))[#which #calc.round(f * 100)%] }
        else { text(fill: red)[#which too large] }
      }
    }
    // Card number, and the sheet it is printed on (F1 = sheet 1, …);
    // empty cards are left out.
    let per-sheet = cols * rows
    let rows-list = cards.enumerate()
      .filter(((i, card)) => card != none and card.number != none)
      .map(((i, card)) => {
        let sheet = calc.div-euclid(i, per-sheet) + 1
        (
          align(center + horizon,
            text(font: slot-font, size: 8pt)[#card.number \ #text(fill: gray)[F#sheet]#mark(card)]),
          side(front(card)),
          side(back(card, border: true)),
        )
      })
    align(center, grid(
      columns: (12mm, card-w * f, card-w * f),
      rows: card-h * f,
      ..rows-list.flatten(),
    ))
  } else if layout == "calibrate" {
    // Front: an x ruler across the middle of each card and a y ruler to its
    // right. Back: a long line through each ruler. Seen through the sheet, the
    // lines cross the rulers at the values to add to back-offset (in mm).
    set page(paper: paper, flipped: flipped, margin: 0pt)
    let thin = 0.3pt + black
    let small-text(body) = text(font: slot-font, size: 5pt, body)
    let yx = 18mm   // where the y ruler stands, right of the middle
    let ruler = box(width: 0pt, height: 0pt, {
      for i in range(-16, 17) {
        let p = i * 0.5mm
        let len = if calc.rem(i, 2) == 0 { 2.4mm } else { 1.2mm }
        place(top + left, line(start: (p, -len / 2), end: (p, len / 2), stroke: thin))
        place(top + left, line(start: (yx - len / 2, p), end: (yx + len / 2, p), stroke: thin))
        // x as seen from the front; y: lower on the front = move the back up
        if calc.rem(i, 8) == 0 {
          place(top + left, dx: p - 3mm, dy: 1.8mm, box(width: 6mm, align(center, small-text(str(i / 2)))))
        }
        if calc.rem(i, 4) == 0 {
          place(top + left, dx: yx + 1.8mm, dy: p - 0.9mm, small-text(str(-i / 2)))
        }
      }
      place(top + left, line(start: (-8.5mm, 0mm), end: (8.5mm, 0mm), stroke: thin))
      place(top + left, line(start: (yx, -8.5mm), end: (yx, 8.5mm), stroke: thin))
      place(top + left, dx: 9.3mm, dy: -1.1mm, text(font: slot-font, size: 6pt)[x])
      place(top + left, dx: yx - 0.8mm, dy: -11.5mm, text(font: slot-font, size: 6pt)[y])
    })
    let mm(v) = calc.round(v.abs / 1mm, digits: 2)
    let cal-front = box(width: card-w, height: card-h, stroke: stroke, {
      place(center + horizon, dx: -yx / 2, ruler)
      place(top + left, dx: 3mm, dy: 2.5mm, block(width: card-w - 6mm, text(font: slot-font, size: 5.5pt)[
        #card-size · back-offset: (x: #mm(offset.x)mm, y: #mm(offset.y)mm) \
        Against the light, the lines of the back cross the rulers \
        at the values (mm) to add to back-offset.
      ]))
    })
    let cal-back = box(width: card-w, height: card-h, {
      // mirrored like the cards: the y ruler is left of the middle seen from the back
      place(center + horizon, dx: yx / 2, box(width: 0pt, height: 0pt, {
        place(top + left, line(start: (-yx - 6mm, 0mm), end: (10mm, 0mm), stroke: 0.4pt + black))
        place(top + left, line(start: (0mm, -11mm), end: (0mm, 11mm), stroke: 0.4pt + black))
      }))
    })
    front-sheet(range(cols * rows).map(_ => cal-front))
    pagebreak()
    back-sheet(range(cols * rows).map(_ => cal-back))
  } else {
    set page(paper: paper, flipped: flipped, margin: 0pt)

    let sheets = cards.chunks(cols * rows)
    for (i, sheet) in sheets.enumerate() {
      let sheet = sheet + ((none,) * (cols * rows - sheet.len()))
      let lines = sheet.chunks(cols)
      if i > 0 { pagebreak() }
      front-sheet(lines.flatten().map(front))
      pagebreak()
      // back: same rows, columns mirrored (first column ↔ last column, …)
      // → the sheet turned over sideways, like a book page;
      // moved by back-offset to make up for the printer
      back-sheet(lines.map(r => r.rev()).flatten().map(back))
    }
  }
}
