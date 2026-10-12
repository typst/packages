// The elements of the text of abntly: the form of the illustrations and tables, of what goes under them (source,
// legend, notes), of the displayed equations and of the alíneas, where the norms (NBR 14724, NBR 6024 and the IBGE's
// tabular norm) say something about the form; the distances are in src/spacing.typ and the sizes in src/fonts.typ.
//
// Rules: the title of a figure or a table above it, "Figura 1 — Title"; tables with no rule of their own; equations
// numbered "(1.1)" by chapter at the right, or "(1)" through the work, only those with a label (over the package
// equate); a list inside an alínea as a subalínea, with a dash. Functions, the only ones the author calls: `source`,
// `legend` and `note`, written inside the body of the figure after the illustration; `frame`, the figure of a
// quadro; `fitted`, the figure in a box as wide as its illustration, so that its title and its foot respect the
// margins of the illustration (14724, 5.8); a table with a header inside it takes the horizontal rules of the package
// (`ibge`) and goes on over pages with the header, the title and "(continua)" / "(continuação)" / "(conclusão)" on
// each (IBGE, 8.3); `ibge-table`, the same rules for a table in a plain `figure`; `preamble`, the nature of the work
// on the title page and the approval sheet, from the middle of the text block to the right margin (14724, 5.2).
// Beyond the norms: `algorithm`, `subfigures` (over the package
// subpar), `part`, `sideways`, `signature` and `stamp` (the watermark of a draft, for the background of a page). The
// only `context`: the number of each title, the width of a `fitted`, the cell of such a table that names its page,
// the call of a note in a table, the numbering by chapter and the alignment of the parts of a set of subfigures.
//
// The main function (src/abntly.typ) applies `elements` after `spacing`, with its three options.

#import "@preview/subpar:0.2.2"
#import "@preview/equate:0.3.3": equate
#import "fonts.typ": elements as text-styles
#import "spacing.typ": single-spacing, line-spacing, paragraph-skip, figure-spacing, heading-after
#import "words.typ" as words

// A label followed by its text, the lines after the first under the first letter of the text, as the norms ask for
// the titles of sections (6024, 4.1 i), the notes (14724, 5.2.1) and the alíneas (6024, 4.2 g), and as the package
// sets the title of an illustration: the label in a column of its own, the text in the other. A short text shrinks
// with its column, and the whole stays where the paragraph would be (centred in a figure); a long one fills the
// width.
#let hanging(label, body) = grid(columns: (auto, auto), align: top, label, align(left, body))

// --- the table of the IBGE ----------------------------------------------------------------------------------------
// the number of columns of a table, from its `columns` argument
#let column-count(columns) = if type(columns) == int { columns } else if type(columns) == array { columns.len() } else { 1 }
// the number of rows of a header: its cells (what is not a rule: Typst makes a cell of every other child), each as
// wide as its colspan and as tall as its rowspan, over the columns
#let row-count(header, n) = calc.ceil(header.children.filter(c => c.func() != table.hline and c.func() != table.vline)
  .map(c => c.at("colspan", default: 1) * c.at("rowspan", default: 1))
  .sum(default: 0) / n)

// The horizontal rules of a table of the IBGE: heavy at the top and the bottom (0.08 em), light between the rows
// (0.05 em), a double light rule under the header, 2 pt apart in a 12 pt body, all in em of the body, not of the
// reduced text of the table (inside a table they are divided by its `table-font-size`). The IBGE asks for three of
// them at least (4.3.1) and none at the sides (4.3.3).
#let rules = (heavy: 0.08, light: 0.05, double: 2 / 12)

// The cell at the top of the header, repeated with it on every page (IBGE, 8.3): on the first page "(continua)" at
// the right, between the title of the figure and the first rule; on the next ones the title again, with
// "(continuação)", or "(conclusão)" on the last; nothing when the table fits one page. The page of the cell is
// compared with the pages of two markers `ibge` puts in the table: one in its first row, one in its footer, which
// only appears on its last page (the figure itself could open on the page before the table).
#let continuation(table-font-size) = context {
  let page = here().page()
  let end = query(selector(<abntly-table-end>).after(here())).first().location()
  let first = query(selector(<abntly-table-start>).before(end)).last().location().page()
  let last = end.page()
  if first == last { return }
  // a little room over the rule, only when there is a word (the cell has no inset, so that it has no height otherwise)
  show: pad.with(bottom: 0.25em)
  if page == first { align(right, words.word-raw("continues")) } else {
    let fig = query(selector(figure).before(here())).last()
    let number = numbering(fig.numbering, ..counter(figure.where(kind: fig.kind)).at(fig.location()))
    // the title in its size and single spacing, not in those of the text of the table around it
    {
      set text(size: 1em / table-font-size.em, top-edge: 1em)
      set par(leading: single-spacing - 1em, justify: false)
      hanging([#fig.supplement~#number#fig.caption.separator], fig.caption.body)
    }
    align(right, words.word-raw(if page == last { "conclusion" } else { "continuation" }))
  }
}

// a row of no height holding a marker
#let marker(n, label) = table.cell(colspan: n, inset: 0pt, [#metadata(none)#label])

// A table of the IBGE, rebuilt from the author's table (with its header in a `table.header`): the rules of `rules`
// (heavy at the top and the bottom, a double one under the header, light ones between the rows, none at the sides)
// and the continuation over pages (IBGE, 8.3): the header on every page, "(continua)" on the first, the title again
// with "(continuação)" or "(conclusão)" on the next ones, the closing rule only on the last (the source and the
// notes, after the table in the figure, too). The rebuilt table carries a label, so that the rule that calls this
// and the one of the size of the text leave it alone; its lengths are in em of that text, the rules divided by it.
#let ibge(it, table-font-size) = {
  let fields = it.fields()
  let cells = fields.remove("children")
  let _ = fields.remove("stroke", default: none)
  // the label of the author's table (the one of `ibge-table`, or one of their own): a field too, which `table` refuses
  let _ = fields.remove("label", default: none)
  let n = column-count(fields.at("columns", default: 1))
  let i = cells.position(c => c.func() == table.header)
  let header = cells.at(i)
  // the rows: the continuation cell, the header, a spacer of no content between the two rules under it, the marker
  // of the start; the body from row `first` on, with a light rule over each row after the first
  let first = 1 + row-count(header, n) + 2
  let (heavy, light) = (rules.heavy * 1em / table-font-size.em, rules.light * 1em / table-font-size.em)
  cells.at(i) = table.header(
    table.cell(colspan: n, inset: 0pt, continuation(table-font-size)),
    table.hline(stroke: heavy), ..header.children,
    // the gap between the two light rules is `rules.double`: the rules stand on the edges of a row that high and
    // the thickness of one (each rule straddles its edge)
    table.hline(stroke: light), table.cell(colspan: n, inset: 0pt, block(height: rules.double * 1em / table-font-size.em + light)),
    table.hline(stroke: light))
  cells.insert(i + 1, marker(n, <abntly-table-start>))
  let end = table.footer(repeat: false, marker(n, <abntly-table-end>))
  [#table(..fields, stroke: (x, y) => if y > first { (top: light) }, ..cells, table.hline(stroke: heavy),
    end)<abntly-ibge>]
}

// "(1.1)": a pattern with two numbers counts by chapter (the first heading level); "(1)", or a function, counts
// through the work
#let by-chapter(numbering) = type(numbering) == str and numbering.matches("1").len() == 2

// Which of the two the headings from here on are, "appendix" or "annex" (`appendix` and `annex` of structure.typ),
// `none` before them: for their entries in the summary, the letter in the numbers of their equations and their
// references.
#let appendix-kind = state("abntly-appendix", none)

// a pattern by chapter in an appendix or an annex: the letter of the appendix in the place of the number of the
// chapter, "(A.1)"
#let lettered(pattern, kind) = if kind == none { pattern } else { pattern.replace("1", "A", count: 1) }

// The rules of the elements, for the size of the text of a table (`table-font-size`, in em of the body: 10em / 12,
// the reduced text of the package, 10 pt in a 12 pt body), the numbering of the equations (`equation-numbering`:
// "(1.1)", "(1.1a)", "(1)", "(1a)" or a function of the numbers) and which of them take a number
// (`equation-number-mode`: "label" or "line").
#let elements(body, table-font-size: 10em / 12, equation-numbering: "(1.1)",
  equation-number-mode: "label") = {
  // the title before the illustration or the table (14724, 5.8 and 5.9): the travessão (—) between no-break spaces,
  // as NBR 14724:2024 writes it ("Quadro 1 —"); in the size of the body (5.1 reduces only the sources and the
  // legends). "Figura 2 — " is a label followed by text: a title of more than one line hangs under the first letter
  // of its text; the `context` only writes the number. A figure without a number keeps the plain title
  set figure.caption(position: top, separator: [~---~])
  // The title sticks to what follows it, so that a figure that breaks (a long algorithm, a table of the IBGE) never
  // leaves it alone at the foot of a page.
  show figure.caption: it => block(sticky: true, if it.numbering == none { it } else {
    let supplement = if it.supplement in (none, []) { [] } else { [#it.supplement~] }
    hanging([#supplement#context it.counter.display(it.numbering)#it.separator], it.body)
  })
  // algorithms: a figure of code, or of pseudocode as the author writes it, "Algoritmo 1 — Title" (14724, 5.8: the
  // designative word is free, "entre outros"), one counter for `algorithm` and for a `figure` of a raw block. The
  // code across the text block, at the margin, its lines 1.5 apart as the code of the text, the source the `gap`
  // under it; the figure breaks with a long algorithm, its title on the first page only. The code goes in a block of
  // that width, from its margin (the figure centres what it holds), and not under a `set block`, which would reach
  // every block a rule of the author sets the code with (the blocks of the lines of a numbered listing, for example)
  show figure.where(kind: raw): set figure(supplement: words.word("algorithm"))
  show figure.where(kind: raw): set block(breakable: true)
  show figure.where(kind: raw): it => {
    show raw.where(block: true): code => block(width: 100%, below: figure-spacing.gap, align(start, code))
    it
  }
  // tables: no rule of their own (IBGE 4.3.3: none at the sides); a table with a header in a `fitted` takes the
  // rules of a table of the IBGE (`ibge`), and a `table.hline()` or `table.vline()` the author writes is a light
  // rule (`rules.light`); the text of a table in `table-font-size` (its rows and lines are in src/spacing.typ, in em
  // of that text); a quadro keeps the size of the body
  set table(stroke: none)
  set table.hline(stroke: rules.light * 1em)
  set table.vline(stroke: rules.light * 1em)
  // the text of the table in `table-font-size`, once: the rule leaves alone the table `ibge` rebuilds, which comes
  // out of the author's table after this rule and so inside it; the rules in em of that text, divided by it
  show figure.where(kind: table): it => {
    show table: t => if t.at("label", default: none) == <abntly-ibge> { t } else {
      set text(size: table-font-size)
      t
    }
    set table.hline(stroke: rules.light * 1em / table-font-size.em)
    set table.vline(stroke: rules.light * 1em / table-font-size.em)
    it
  }
  // the box of a `fitted` (which labels it): a table with a header is a table of the IBGE (the one `ibge` rebuilt
  // carries its own label), and the figure breaks with a table that goes on over pages (an image does not break,
  // so this is harmless there)
  show <abntly-fitted>: it => {
    show table: t => if t.at("label", default: none) != <abntly-ibge> and (
      t.children.any(c => c.func() == table.header)) { ibge(t, table-font-size) } else { t }
    show figure: set block(breakable: true)
    // the title unjustified in the box
    show figure.caption: set par(justify: false)
    it
  }
  // the table of an `ibge-table` (which labels it), in a figure of the author's own: rebuilt as the one of a `fitted`.
  // The rule of the figure above, deeper than this one, sets the size of the text first, and the rebuilt table, which
  // that rule leaves alone, comes out inside it
  show <abntly-ibge-table>: t => ibge(t, table-font-size)
  // the quadro: closed lines of 0.4 pt, an absolute thickness as the rule of the footnotes (no norm asks for them
  // nor gives their thickness: a decision of the package); a `stroke` the author gives to the table wins
  show figure.where(kind: "quadro"): set table(stroke: 0.4pt)
  // equations: the number in parentheses at the right (14724, 5.7), and only the number in a reference ("nas
  // menções subsequentes, pode-se utilizar somente o número"), over the package equate: with
  // `equation-number-mode: "label"` (the default) only an equation, or a line of one, with a label takes a number;
  // with "line", every line, and `#<equate:revoke>` takes the number from one. By chapter ("(1.1)", the default),
  // the number of the chapter comes from the heading counter and the equation counter starts again at each chapter.
  // A letter at the end of the pattern ("(1.1a)", "(1a)") numbers the lines of one equation with letters after its
  // number (equate's sub-numbering). The numbering is a function of one number, or two for a line (the number and
  // the letter), because a reference to a string pattern loses its parentheses
  let sub = type(equation-numbering) == str and equation-numbering.ends-with("a)")
  let whole = if sub { equation-numbering.replace("a)", ")") } else { equation-numbering }
  let pattern(n) = if n.len() > 1 { equation-numbering } else { whole }
  set math.equation(supplement: none, numbering: if type(equation-numbering) == function { equation-numbering }
    else if by-chapter(equation-numbering) {
      (..n) => context numbering(lettered(pattern(n.pos()), appendix-kind.get()),
        counter(heading).get().at(0, default: 0), ..n.pos())
    } else { (..n) => numbering(pattern(n.pos()), ..n.pos()) })
  show heading.where(level: 1): it => {
    if by-chapter(equation-numbering) { counter(math.equation).update(0) }
    it
  }
  show: equate.with(breakable: true, sub-numbering: sub, number-mode: equation-number-mode)
  // a reference gives only the number, a decision of the package: "1" for a figure, a table, an algorithm or a
  // section, "(1.1)" for an equation (14724, 5.7: "somente o número"); the author writes the word, `Figura~@fig`, or
  // gives it to the reference, `@fig[Figura]`, which links the word too; `auto-ref(<fig>)` finds the word itself
  set ref(supplement: none)
  // a reference by chapter recomposes the number where the equation is (the `context` of the numbering would read
  // the chapter where the reference is): of an equation, from the counters there; of a line, from the numbers
  // equate keeps in a figure of kind `math.equation` (a line of one number without sub-numbering, as equate); the
  // word the author gives, `@eq[Equação]`, or the one of `auto-ref`, before it. Defined after equate, so that it
  // comes first. An outline of equations would show the chapter of the outline, which no element of the ABNT asks for
  show ref: it => {
    let e = it.element
    // the page of an element (`form: "page"`) is Typst's
    if e == none or it.form == "page" { return it }
    let loc = e.location()
    // an appendix or an annex by its letter, "A", and a section of one by its number, "A.1": the numbering of the
    // heading writes its name before it, "APÊNDICE A — ", which is for its title
    if e.func() == heading and e.numbering != none and appendix-kind.at(loc) != none {
      let number = numbering("A.1", ..counter(heading).at(loc))
      let supplement = if type(it.supplement) == function { (it.supplement)(e) } else { it.supplement }
      return link(loc, if supplement in (none, auto) { number } else [#supplement~#number])
    }
    if not by-chapter(equation-numbering) { return it }
    let n = if e.func() == math.equation { counter(math.equation).at(loc) } else if (e.func() == figure
      and e.kind == math.equation and e.body != none and e.body.func() == metadata) {
      let v = e.body.value
      if sub { v } else { (v.first() + v.slice(1).sum(default: 1) - 1,) }
    } else { return it }
    let number = numbering(lettered(pattern(n), appendix-kind.at(loc)), counter(heading).at(loc).at(0, default: 0),
      ..n)
    // the name `auto-ref` gives is a function of the element
    let supplement = if type(it.supplement) == function { (it.supplement)(e) } else { it.supplement }
    link(loc, if supplement in (none, auto) { number } else [#supplement~#number])
  }
  // subalíneas (6024, 4.3): a list, or an enum, inside an alínea starts with a dash, at the first letter of the text
  // of the alínea, its text 0.5 em after the dash, as the text of an alínea after its letter; the lists outside keep
  // their bullet, and the alíneas their letters: a `set` inside the rule reaches only what is inside the alíneas (a
  // `show enum: set enum(...)` would reach the alíneas themselves)
  show enum: it => {
    set list(marker: [--], indent: 0pt, body-indent: 0.5em)
    set enum(numbering: n => [--], indent: 0pt)
    it
  }
  body
}

// --- what goes under an illustration or a table ---------------------------------------------------------------------
// 14724, 5.8: "Imediatamente após a ilustração, deve ser indicada a fonte consultada …, legenda, notas"; 5.1: in
// the smaller size; 5.2: in single spacing. Each one is "Word: text" in the alignment of the figure: centred in the
// native `figure`, at the left in a `fitted`; a text of more than one line fills the width and goes on under its
// first letter. The `gap` of the figure (the one between the title and the illustration) under the illustration,
// `between` from one to the next (the space between two paragraphs of the text). The spacing of a block counts from
// the baseline above to the top of its first line, which is its size over the baseline; of the `below` of one and
// the `above` of the next, the larger holds. The block carries a label, so that a `fitted` measures the illustration
// without it.
#let under(word, body) = [#block(above: figure-spacing.gap - text-styles.source-and-note.size,
  below: figure-spacing.between - text-styles.source-and-note.size, width: 100%, {
  set text(size: text-styles.source-and-note.size)
  set par(leading: single-spacing - 1em, first-line-indent: 0pt, justify: true)
  // the text at the left of its column, whatever the alignment of the figure: the last line of a justified text of
  // more than one line would otherwise be centred in a centred figure
  grid(columns: (auto, auto), align: top, [#word~], align(left, body))
})<abntly-under>]

// 14724, 5.8 and 5.9; IBGE, 4.10. The norms accept the work of the author for a figure and for a table.
/// Creates the source line of an illustration or a table: "Fonte: …" (NBR 14724:2024, sections 5.8 and 5.9). It must
/// be called inside the figure, after the illustration. Without an argument, it says that the illustration was made
/// by the author: "Fonte: Elaboração própria.".
///
/// - ..body (content): Source consulted, with the final period.
/// -> content
#let source(..body) = {
  assert(body.pos().len() <= 1 and body.named().len() == 0,
    message: "source: takes at most one argument, the source itself; got " + repr(body))
  under([#words.word("source"):], body.pos().at(0, default: words.word("own-work")))
}

/// Creates the legend line of an illustration: "Legenda: …" (NBR 14724:2024, section 5.8). It must be called inside
/// the figure, after the source.
///
/// - body (content): Text of the legend.
/// -> content
#let legend(body) = under([#words.word("legend"):], body)

// 14724, 5.8; IBGE, 4.11 and 4.12. `word: [Anotações]` changes the word before the colon. The number of a specific
// note does not link back to its call, which is right above it in the same table.
/// Creates a note under an illustration or a table: "Nota: …" (NBR 14724:2024, section 5.8). It must be called inside
/// the figure, after the source and the legend.
///
/// With the `call` parameter, it creates a specific note of a table, identified by a superscript number in the place
/// of the word "Nota". The matching call is put in the cell of the table with the function `call`.
///
/// - body (content): Text of the note.
/// - word (auto, content): Word shown before the colon. The default is "Nota", in the language of the text. Example:
///   `[Notas]`.
/// - call (none, int, str): Number of the call of a specific note. With `1`, the note starts with "¹" and shows no
///   word.
/// -> content
#let note(body, word: auto, call: none) = under(if call != none [#metadata(call)<abntly-call>#super[#call]] else {
  [#if word == auto { words.word("note") } else { word }:]
}, body)

// IBGE, 4.9 and 4.12: the number as an exponent, one of the three forms of the norm (4.9.1: "entre parênteses, entre
// colchetes, exponencial"), glued to the element it marks as the call of a footnote; the link goes to the first note
// with that call after it (a `context` for each call, which looks for it).
/// Creates the call of a specific note in a cell of a table: a superscript number, as in "São Paulo¹". The number is
/// a link to the note created with `note(call: 1)` under the same table.
///
/// - n (int, str): Number of the call.
/// -> content
#let call(n) = h(0pt, weak: true) + context {
  let target = query(selector(<abntly-call>).after(here())).find(m => m.value == n)
  if target == none { super[#n] } else { link(target.location(), super[#n]) }
}

// --- a reference with its name ------------------------------------------------------------------------------------
// the name of what a reference names, in `auto-ref`: the supplement of a figure (Figura, Tabela, Quadro, Algoritmo), a
// word of the language of the text for the rest (src/lang.toml): by the level of a heading, the chapter, the section,
// the subsection, and the appendix or the annex for a primary heading of theirs ("Apêndice A"); the equation, and a
// line of one (a figure of equate); the footnote
#let auto-name(element) = {
  let f = element.func()
  if f == heading {
    context {
      let kind = appendix-kind.at(element.location())
      words.word-raw(if kind != none and element.level == 1 { kind + "-name" } else {
        ("chapter", "section", "subsection", "subsubsection").at(calc.min(element.level, 4) - 1)
      })
    }
  } else if f == math.equation or (f == figure and element.kind == math.equation) { words.word("equation") }
  else if f == footnote { words.word("footnote") }
  else { element.supplement }
}

// The name of the element before its number, by `auto-name`; the page as NBR 10520 writes it (6.2.4). A footnote
// keeps its call, the number glued to the word before it, as `@nota`: the norm indicates a note in the text by its
// number (10520, 8).
/// Creates a cross-reference with the name of the element and its number, as in "Figura 1", with one link over both.
/// A plain reference (`@fig`) gives only the number.
///
/// The name comes from the kind of the element, in the language of the text: "Figura", "Tabela", "Quadro" and
/// "Algoritmo" for the illustrations; "Capítulo", "Seção", "Subseção" and "Subsubseção" for the headings, by level;
/// "Apêndice" and "Anexo"; "Equação". With `form: "page"`, it gives the page of the element, as in "p. 5". A
/// reference to a footnote gives the number of the note. The names can be replaced in the `names` parameter of
/// `abntly`.
///
/// A semicolon right after the call ends the expression in markup and is not printed. Write it as
/// `#auto-ref(<fig>)\;`.
///
/// - target (label): Label of the element.
/// - form (str): Form of the reference: `"normal"`, for the name and the number, or `"page"`, for the page.
/// -> content
#let auto-ref(target, form: "normal") = ref(target, form: form,
  supplement: if form == "page" { words.word("page") } else { auto-name })

// 14724, 5.8 lists the quadro among the illustrations, apart from the tables of the IBGE. A `figure` of kind
// `"quadro"`; its closed lines come from the rule of `elements`.
/// Creates a quadro: an illustration with textual information arranged in rows and columns, with the title "Quadro 1
/// — Title" above it and a numbering of its own (NBR 14724:2024, section 5.8). A table inside the quadro takes closed
/// lines of 0.4 pt on every cell, and its text keeps the size of the body.
///
/// The function takes the same arguments as `figure`. For numerical data, use a table, with `fitted`.
///
/// - ..args (arguments): Arguments of `figure`: the content and `caption`, among others.
/// -> content
#let frame(..args) = figure(kind: "quadro", supplement: words.word("frame"), ..args)

// --- the figure in a box as wide as its illustration --------------------------------------------------------------
// The "devem respeitar as margens da ilustração" of 14724 (5.8): the figure in a box as wide as its illustration,
// with the title, the source and the notes at the left. The width comes from `measure`: the figure without its
// title, its source, its legend and its notes, in the width at hand, with the rules of the document (the reduced
// text of a table). The native `figure` keeps its own form: the title, the source and the notes centred on the text
// block. A table with a header takes the rules and the continuation of a table of the IBGE (8.3), from the rule of
// `elements` on the box.
/// Creates a figure whose title, source, legend and notes stay within the width of the illustration, as NBR
/// 14724:2024 asks (section 5.8). The set is centred on the page, and the title, the source and the notes are aligned
/// to the left. The width of the illustration is measured automatically and does not go beyond the width of the text
/// block.
///
/// A table with a header (`table.header(...)`) inside this function is formatted by the tabular presentation
/// standards of the IBGE (NBR 14724:2024, section 5.9): it takes the horizontal rules automatically and, if it takes
/// more than one page, it repeats the header and the title with the marks "(continua)", "(continuação)" and
/// "(conclusão)". A table without a header and a quadro keep the lines set by the author.
///
/// - ..args (arguments): Arguments of `figure`: the content, `caption`, `kind` and `supplement`, among others.
/// - width (auto, length, ratio): Width of the set. With `auto`, it is the measured width of the illustration. Give a
///   smaller width to make the text wrap in the cells of a table with `auto` columns.
/// - label (none, label): Label of the figure, for cross-references (`@label`). In this function, the label is given
///   as a parameter, not after the call.
/// -> content
#let fitted(..args, width: auto, label: none) = {
  // the box is a block around the figure (a `set block(width:)` on the figure would reach the cells of a table
  // inside it, and its header would stop wrapping), with the space of a figure around it, since the block of
  // src/spacing.typ ends up inside it; its label brings the rules of `elements` for the tables inside it, unless
  // the figure is a quadro. The measure happens inside that block, where the width at hand is known (`layout`);
  // the blocks inside it lose their space at its edges
  show figure: set align(left)
  let quadro = args.named().at("kind", default: auto) == "quadro"
  let fig = [#figure(..args)#label]
  // the figure without its title, for the measure
  let bare = args.named()
  let _ = bare.remove("caption", default: none)
  align(center, block(above: figure-spacing.before - 1em, below: figure-spacing.after - 1em, layout(size => {
    let w = if width != auto { width } else {
      calc.min(size.width, measure(width: size.width, {
        show <abntly-under>: none
        figure(..args.pos(), ..bare)
      }).width)
    }
    let box = block(width: w, fig)
    if quadro { box } else { [#box<abntly-fitted>] }
  })))
}

// --- the table of the IBGE in a plain figure -------------------------------------------------------------------------
// The rules of `ibge` for a table the author puts in a `figure` of their own (the title and the foot at the width of
// the text block, the figure free to float with `placement`), where `fitted` would box it: the table carries a label,
// and the rule of `elements` on that label rebuilds it as `ibge` does for the tables of a `fitted`, in the size of the
// text of the tables, which only that rule knows (the rule of the figure sets the size first, the rebuilt table comes
// out inside it). Written inside a figure: outside one the text keeps the size of the body, and a break over pages
// would look for the title of a figure that is not there.
/// Creates a table in the pattern of the IBGE for a plain `figure`: the horizontal rules of the tabular presentation
/// standards (NBR 14724:2024, section 5.9) — a heavy one at the top and at the bottom, a double one under the header,
/// light ones between the rows, none at the sides — and the text in the reduced size of the tables. It takes the
/// arguments of `table`, with the header in `table.header(...)`, which it requires. Write it inside a `figure`, with
/// `source` and `note` after it as usual: the title, the source and the notes keep the width of the text block, and
/// the figure may float with `placement`. A `figure` does not break over pages.
///
/// For a table whose title, source and notes stay within the width of the table itself, or that goes on over pages
/// with its header and "(continua)", use `fitted`, where a table with a header takes this form by itself.
///
/// - ..args (arguments): Arguments of `table`: `columns`, `align`, the header in `table.header(...)` and the cells,
///   among others. A `stroke` is ignored: the rules are those of the IBGE.
/// -> content
#let ibge-table(..args) = {
  assert(args.pos().any(c => type(c) == content and c.func() == table.header),
    message: "ibge-table: takes the arguments of table with the header in table.header(...), under which the "
      + "IBGE puts a rule; got a table without table.header")
  [#table(..args)<abntly-ibge-table>]
}

// --- elements beyond the norms ---------------------------------------------------------------------------------------
/// Creates an algorithm: an illustration of code or pseudocode, with the title "Algoritmo 1 — Title" above it and a
/// numbering of its own. As in the other illustrations (NBR 14724:2024, section 5.8), the source goes under it, with
/// `source`. The code takes the width of the text block, and a long algorithm goes on on the next page.
///
/// A `figure` whose content is a block of code is treated as an algorithm too, with the same numbering.
///
/// - ..args (arguments): Arguments of `figure`: the content and `caption`, among others.
/// -> content
#let algorithm(..args) = figure(kind: raw, ..args)

// the number of a part of a set of subfigures in a reference, "1a"; subpar keeps the letter in a counter of its own
#let sub-reference = "1a"
#let sub-counter = counter("__subpar:sub-figure-counter")

// what subpar reads among the positional arguments of the set: a figure, a label, an element of a grid
#let grid-parts = (figure, grid.cell, grid.hline, grid.vline, grid.header, grid.footer)

// Over the package subpar. The title of a part under it, in the size of the sources, hanging under its first letter
// when it takes more than a line. In a row, the bottoms of the parts aligned and the first lines of their titles on
// one line. A source of one part goes between the part and its title. A part keeps the width of its column: a title
// longer than the part widens it, unless the author gives the widths of the columns (`columns: (5cm, 5cm)`), as the
// width of a `fitted`. No norm gives the form of a set of subfigures: a decision of the package, as the gutter of
// 1 em.
/// Creates a figure made of parts (subfigures). The title of the set goes above it ("Figura 1 — Title"), and the
/// title of each part goes under the part ("(a) Title"). The source, the legend and the notes of the set go under the
/// parts. A reference to a part gives the number of the set and the letter of the part ("1a").
///
/// Each part is a `figure`, followed by its label. The source of a part goes inside its figure. The last positional
/// argument can be content with the source, the legend and the notes of the set. This function cannot be used inside
/// `fitted`.
///
/// - ..args (arguments): Parts (`figure(...)`, each followed by its label) and, last, the content that goes under the
///   set (`source`, `legend`, `note`).
/// - columns (int, array): Number of columns, or a list with the width of each column.
/// - gutter (length): Horizontal and vertical space between the parts.
/// - caption (content): Title of the set.
/// - label (none, label): Label of the set.
/// -> content
#let subfigures(..args, columns: 2, gutter: 1em, caption: none, label: none) = {
  let pos = args.pos()
  let last = pos.at(-1, default: none)
  let below = if type(last) == content and last.func() not in grid-parts { pos.pop() }
  // each part joined to its label, as subpar wants them
  let parts = ()
  while pos.len() > 0 {
    let part = pos.remove(0)
    if pos.len() > 0 and type(pos.first()) == std.label { parts.push([#part#pos.remove(0)]) } else { parts.push(part) }
  }
  subpar.super(numbering-sub: "(a)", numbering-sub-ref: sub-reference, caption: caption, label: label,
    // the title of a part in the size of the sources
    show-sub-caption: (number, it) => {
      set text(size: text-styles.source-and-note.size)
      hanging([#number~], it.body)
    },
    context {
      // the title of a part under it: from the part to the baseline of its title, 12.35 pt of a 12 pt body (the gap
      // and the line of the title, 10 pt)
      set figure.caption(position: bottom)
      set figure(gap: 2.35em / 12)
      // in each row, the bottoms of the parts aligned and the first lines of their titles on one line, so each part
      // at the top of its cell with a space above it up to the tallest part of its row (the only measure of the
      // element: the height of each part at its own width, without a source of its own, which goes under the part
      // and pushes its title down); a grid of ours (the one of `subpar.grid` would reach the grids of the titles)
      let n = if type(columns) == int { columns } else { columns.len() }
      let height(p) = if p.func() != figure { 0pt } else {
        let body = {
          show <abntly-under>: none
          p.body
        }
        let w = measure(body).width
        measure(body, width: if w == 0pt { auto } else { w }).height
      }
      let heights = parts.map(height)
      let tallest = range(calc.ceil(heights.len() / n)).map(r => calc.max(..heights.slice(r * n,
        calc.min(heights.len(), r * n + n))))
      let cells = parts.enumerate().map(((i, p)) => if p.func() != figure { p } else {
        grid.cell(align: top, { v(tallest.at(calc.div-euclid(i, n)) - heights.at(i)); p })
      })
      // what goes under the set a paragraph apart from the titles of the parts, as a source from a legend (with the
      // space from an illustration to its source, the source read as one more line of the titles)
      block(below: figure-spacing.between - text-styles.source-and-note.size,
        grid(columns: if type(columns) == int { (auto,) * columns } else { columns }, gutter: gutter, ..cells))
      below
    })
}

// the count of the parts, apart from the headings: the chapters go on across them
#let part-counter = counter("abntly-part")

// The opening page of a part. No norm gives its form: a decision of the package. The baseline of "Parte I" at
// 35.54 % of the text block, the one of the title 57 pt of a 12 pt body under it, in the type of the chapter. On
// both sides of the leaf the page of the part is a recto (the mark before it, for the layout). A `metadata` with the
// number and the title waits for the summary.
/// Creates the opening page of a part, a division of the text above the primary sections. The page has no header and
/// no number, and shows "Parte I" and the title, centred. The primary section after it starts on a new page, and the
/// numbering of the sections goes on from one part to the next. The ABNT standards say nothing about this element.
///
/// - title (content): Title of the part.
/// -> content
#let part(title) = [#metadata(none)<abntly-part-start>] + page(numbering: none, header: none, footer: none, {
  part-counter.step()
  set align(center)
  set par(first-line-indent: 0pt, justify: false)
  set text(..text-styles.chapter)
  // `em` is the size of the chapter from here: the lengths of the body are divided by it; the line box of each
  // line goes 1 em up from its baseline, so the space above one is its baseline less 1 em
  v(35.54% - 1em)
  stack(spacing: 57em / 12 / text-styles.chapter.size.em - 1em,
    context [#words.word-raw("part") #part-counter.display("I")], title)
  context [#metadata((number: part-counter.get().first(), title: title))<abntly-part>]
})

// The page stays upright, with its margins, and only what is on it turns: the top to the binding (the left of a
// recto). It starts at the top of the page as it is read lying down, centred across it.
/// Turns the content by 90° on a page of its own, for a figure or a table wider than the text block. The page stays
/// upright, with the same margins, and the top of the content faces the binding side. The text goes on on the next
/// page. The ABNT standards say nothing about this element.
///
/// - body (content): Content to turn: a figure or a table in `fitted`, for example.
/// -> content
#let sideways(body) = page(align(left + horizon, rotate(-90deg, reflow: true, body)))

// The form of the stamp is a decision of the package: the word at 40 pt of a 12 pt body and the note at 0.35 of it
// (14 pt), a line of the text of 1.5 apart, in a red mixed with 70 % of white, turned by 45°. The author puts it
// where it goes.
/// Creates a stamp (watermark), such as "RASCUNHO" or "DRAFT", for the background of a page. The text is shown in
/// bold, in a light colour, turned and centred on the page. The ABNT standards say nothing about this element.
///
/// The stamp is used in the `background` parameter of the page. Use `#set page(background: stamp[DRAFT])` to apply it
/// to every page from there on, or `#page(background: stamp[DRAFT])[...]` for a single page.
///
/// - body (content): Text of the stamp.
/// - note (none, content): Smaller text, shown under the main text.
/// - color (color): Colour of the stamp. It is lightened (mixed with 70% of white) before it is applied.
/// - angle (angle): Angle of the turn. The default, `-45deg`, turns the text anticlockwise.
/// - size (length): Size of the main text, in `em` of the body. The default is 40 pt in a body of 12 pt.
/// -> content
#let stamp(body, note: none, color: rgb(255, 0, 0), angle: -45deg, size: 10em / 3) = {
  // `std.color`: the parameter hides the type, and `color.mix` would be the method of the value, which mixes it in too
  let fill = std.color.mix((color, 30%), (white, 70%), space: rgb)
  // the lines: the word from the top of its letters to its baseline, the note a line of the text (1.5) under it, and
  // 0.3 of that line under the baseline of the last one
  set text(fill: fill, weight: "bold", bottom-edge: "baseline")
  align(center + horizon, rotate(angle, stack(dir: ttb,
    text(size: size, top-edge: "bounds", body),
    if note != none { v(line-spacing - 0.35 * size) },
    if note != none { text(size: 0.35 * size, top-edge: 1em, note) },
    v(0.3 * line-spacing))))
}

// the text of the nature: single spacing, justified, without indent, the space of a paragraph between its paragraphs
#let nature-text(body) = {
  set align(left)
  set par(leading: single-spacing - 1em, spacing: single-spacing - 1em + paragraph-skip, first-line-indent: 0pt,
    justify: true)
  body
}

// The nature of the work in a block of half the text block, from its middle to the right margin (14724, 5.2). NBR
// 14724 (5.1) does not except it from the size of the body. No norm gives the space around it, a decision of the
// package: after it, the space from a section to its text (2.3 ex and a line of the text, 29.88 pt from baseline to
// baseline in a body of 12); before it and between its paragraphs, the space of a paragraph.
/// Creates the block of the nature of the work: type of the work, aim, institution and area of concentration. The
/// block is set in single spacing, aligned from the middle of the text block to the right margin (NBR 14724:2024,
/// section 5.2).
///
/// The title page and the approval sheet already include this block. Use this function only in pages built by hand.
///
/// - body (content): Text of the nature of the work.
/// -> content
#let preamble(body) = align(right, block(width: 50%, above: line-spacing - 1em + paragraph-skip,
  below: heading-after.at(1) + line-spacing - 1em, nature-text(body)))

// the keys of a member of the board, in English or in Portuguese, to the fields
#let member-keys = (name: "name", nome: "name", title: "title", "titulação": "title", titulacao: "title",
  institution: "institution", "instituição": "institution", instituicao: "institution", role: "role", papel: "role")

// The signatures of `signature`, after a text whose lines are `line` apart: 1.5 by default; the approval sheet, in
// single spacing, gives a single line.
#let signatures(members, line: line-spacing) = {
  // the lines under the rule of one member
  let lines(member) = {
    if type(member) != dictionary { return member }
    let given = (:)
    for (key, value) in member {
      assert(key in member-keys, message: "signature: unknown field " + repr(key) + "; the fields are name, title, "
        + "institution and role (nome, titulação, instituição, papel)")
      given.insert(member-keys.at(key), value)
    }
    for key in ("name", "title", "institution") {
      assert(key in given, message: "signature: NBR 14724 (4.2.1.3) asks for the name, the title and the "
        + "institution of each member of the board; missing " + key)
    }
    [*#given.title #given.name*]
    if "role" in given [\ #given.role]
    [\ #given.institution]
  }
  block(above: line + paragraph-skip, below: 1pt + paragraph-skip, width: 100%, {
    set par(first-line-indent: 0pt, justify: false, leading: single-spacing - 1em)
    set align(center)
    for (i, member) in members.enumerate() {
      v(if i > 0 { 1pt + paragraph-skip } else { 0pt } + single-spacing + 0.7cm)
      block(width: 8cm, above: 0pt, below: 0pt, stack(dir: ttb, spacing: single-spacing - 1em,
        rect(width: 100%, height: 1pt, fill: black, stroke: none), par(lines(member))))
    }
  })
}

// No norm gives the form of the signature: a decision of the package. A rule of 8 cm and 1 pt, centred, 0.7 cm and
// a single line under what comes before it; under the rule, centred and in single spacing, the title and the name
// in bold, the role and the institution, a line each. Several signatures in one call stand 1 pt and the space of a
// paragraph further apart; after the text, a line of 1.5 and the space of a paragraph come before the first. The
// keys are accepted in Portuguese too (`titulação`, `nome`, `papel`, `instituição`).
/// Creates the signature lines of the members of the examining board. Each signature is a rule of 8 cm, centred, with
/// the academic title and the name in bold, the role and the institution under it. NBR 14724:2024 (section 4.2.1.3)
/// asks for the name, the academic title, the signature and the institution of each member on the approval sheet.
///
/// The function `approval-page` already creates the signatures. Use this function in pages built by hand. The
/// signatures of one call stand one under the other; to put them side by side, use a `grid` with one call in each
/// cell.
///
/// - ..members (dictionary, content): Members of the board, one in each argument. Each member is a dictionary with
///   the keys `name`, `title` and `institution` (required) and `role` (optional). It also takes content, with the text
///   that goes under the rule.
/// -> content
#let signature(..members) = {
  assert(members.named().len() == 0 and members.pos().len() > 0,
    message: "signature: takes one member of the board or more, each a dictionary (name, title, institution, "
      + "role) or content; got " + repr(members))
  signatures(members.pos())
}

