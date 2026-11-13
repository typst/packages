/// The rubrics as data: every exam with rubrics leaves them in the document,
/// invisible, as `metadata` labelled `<examy-rubric>`, one per exam, for the
/// command line to read out as JSON:
///
///   typst eval --in exam.typ --pretty 'query(<examy-rubric>).first().value'
///
/// Text is Markdown: `**bold**`, `*italic*`, bullet lists, and math in LaTeX
/// between `$` (inline) or `$$` (display).

#import "prelude.typ": *
#import "rubric.typ": RECORD, _exam_number, division_rubric, exam_bounds
#import "points.typ": PAGES, _document_index

#let SPACE = [ ].func()

/// Unicode a Typst equation is made of, as LaTeX. Commands end in a space so
/// that a following letter does not join them.
#let _LATEX = (
  "−": "-", "≤": "\\le ", "≥": "\\ge ", "≠": "\\neq ", "≈": "\\approx ",
  "∈": "\\in ", "∉": "\\notin ", "⊆": "\\subseteq ", "⊂": "\\subset ",
  "∪": "\\cup ", "∩": "\\cap ", "∅": "\\emptyset ", "→": "\\to ",
  "⇒": "\\Rightarrow ", "⇔": "\\Leftrightarrow ", "↦": "\\mapsto ",
  "∀": "\\forall ", "∃": "\\exists ", "¬": "\\neg ", "∧": "\\wedge ", "∨": "\\vee ",
  "∞": "\\infty ", "·": "\\cdot ", "⋅": "\\cdot ", "×": "\\times ", "÷": "\\div ",
  "±": "\\pm ", "…": "\\ldots ", "⋯": "\\cdots ", "∫": "\\int ", "∑": "\\sum ",
  "∏": "\\prod ", "∂": "\\partial ", "∇": "\\nabla ", "′": "'",
  "ℝ": "\\mathbb{R}", "ℤ": "\\mathbb{Z}", "ℕ": "\\mathbb{N}", "ℚ": "\\mathbb{Q}", "ℂ": "\\mathbb{C}",
  "α": "\\alpha ", "β": "\\beta ", "γ": "\\gamma ", "δ": "\\delta ", "ε": "\\varepsilon ",
  "θ": "\\theta ", "λ": "\\lambda ", "μ": "\\mu ", "π": "\\pi ", "σ": "\\sigma ",
  "φ": "\\varphi ", "ω": "\\omega ", "Δ": "\\Delta ", "Σ": "\\Sigma ", "Ω": "\\Omega ",
  "∖": "\\setminus ", "∣": "\\mid ", "⊈": "\\not\\subseteq ",
  "{": "\\{", "}": "\\}",
)
#let _OPS = ("sin", "cos", "tan", "log", "ln", "exp", "lim", "max", "min", "sup", "inf", "det", "gcd")

/// A Typst equation's body as LaTeX. Covers what rubrics are made of:
/// letters and numbers, the symbols in `_LATEX`, quoted text, fractions,
/// roots, sub- and superscripts, primes, and operators such as `sin`;
/// anything else is read through for what it holds.
#let latex(c) = {
  if c == none { return "" }
  if type(c) == str { return c.clusters().map(ch => _LATEX.at(ch, default: ch)).join() }
  if type(c) != content { return str(c) }
  let f = c.func()
  // Letters and operators are `symbol`s; digits and quoted strings `text`.
  if f != math.op and c.has("text") {
    let t = c.text
    if f == text and t.match(regex("\\p{L}")) != none { return "\\text{" + t + "}" }
    return latex(t)
  }
  if f == SPACE { return " " }
  if f == math.equation { return latex(c.body) }
  if f == math.frac { return "\\frac{" + latex(c.num) + "}{" + latex(c.denom) + "}" }
  if f == math.root {
    let i = c.at("index", default: none)
    return "\\sqrt" + if i != none { "[" + latex(i) + "]" } else { "" } + "{" + latex(c.radicand) + "}"
  }
  if f == math.primes { return "'" * c.count }
  if f == math.op {
    let t = c.text
    if type(t) == content { t = t.at("text", default: "") }
    return if t in _OPS { "\\" + t + " " } else { "\\operatorname{" + t + "}" }
  }
  if f == math.attach {
    let out = latex(c.base)
    for k in ("tr", "t") {
      if c.has(k) {
        let v = c.at(k)
        out += if v.func() == math.primes { latex(v) } else { "^{" + latex(v) + "}" }
      }
    }
    for k in ("br", "b") { if c.has(k) { out += "_{" + latex(c.at(k)) + "}" } }
    return out
  }
  if c.has("children") { return c.children.map(latex).join(default: "") }
  if c.has("body") { return latex(c.body) }
  if c.has("child") { return latex(c.child) }
  ""
}

/// Content as Markdown: `**bold**`, `*italic*`, lists, and math as `$..$`
/// (inline) or `$$..$$` (display), in LaTeX.
#let markdown(c) = {
  if c == none { return "" }
  if type(c) == str { return c }
  if type(c) != content { return str(c) }
  let f = c.func()
  if f == text { return c.text }
  if f == SPACE { return " " }
  if f == linebreak { return "\n" }
  if f == parbreak { return "\n\n" }
  if f == smartquote { return if c.double { "\"" } else { "'" } }
  if f == strong { return "**" + markdown(c.body) + "**" }
  if f == emph { return "*" + markdown(c.body) + "*" }
  if f == raw { return "`" + c.text + "`" }
  if f == list.item { return "\n* " + markdown(c.body).trim() }
  if f == enum.item { return "\n1. " + markdown(c.body).trim() }
  if f == math.equation {
    let d = if c.block { "$$" } else { "$" }
    return d + latex(c.body).trim() + d
  }
  // Escapes, shorthands (`--`), and `sym` are `symbol`s.
  if c.has("text") and type(c.text) == str { return c.text }
  if c.has("children") { return c.children.map(markdown).join(default: "") }
  if c.has("body") { return markdown(c.body) }
  if c.has("child") { return markdown(c.child) }
  ""
}

/// The no-break spaces Typst writes for a `~` (and its narrow form), which
/// the exported text has as plain ASCII spaces.
#let NBSP = regex("[\u{a0}\u{202f}]")

#let _desc(c) = markdown(c).replace(NBSP, " ").replace(regex(" *\n *"), "\n").replace(regex("\n{3,}"), "\n\n").replace(regex(" {2,}"), " ").trim()

/// A rubric's nodes (see `rubric_tree`) as data, nested as they are:
///   (type: "item", points, description, annotation)
///   (type: "group", title, note, annotation, items)
///   (type: "note", text)
/// with their text as Markdown (`none`: not given). Pure.
#let rubric_entries(nodes) = nodes.map(n => if n.kind == "item" {
  (type: "item", points: n.points, description: _desc(n.body), annotation: if n.annotation != none { _desc(n.annotation) })
} else if n.kind == "group" {
  (
    type: "group",
    title: _desc(n.title),
    note: if n.note != none { _desc(n.note) },
    annotation: if n.annotation != none { _desc(n.annotation) },
    items: rubric_entries(n.children),
  )
} else {
  (type: "note", text: _desc(n.body))
})

/// Content as a name in the exported data (a `display-name`): as `markdown`
/// writes it, its spaces plain ASCII ones, whatever spaces Typst gave it (a
/// label's thin space, a `~`'s no-break space), so that it reads, and
/// compares, as it is typed.
#let display_name(c) = markdown(c).replace(regex("[\u{a0}\u{2000}-\u{200a}\u{202f}\u{205f}\u{3000}]"), " ")

/// What the data an exam exports (its rubrics, and its regions) says of a
/// division, from its row of point data `r` (see `compute_points_data`): its
/// `address`, its `path` (not its numbers, which two divisions may share,
/// or not have), its label as text (`display-name`, not `label`, which in
/// Typst is a `<label>`), its `level`, and its own `points` and
/// `bonus-points`, as given, not its parts' (`none`: not given; practice
/// points are neither). Pure.
#let division_row(r) = (
  address: r.path,
  display-name: display_name(r.label),
  level: r.level,
  points: if r.intent == none { r.given },
  bonus-points: if r.intent == "bonus" { r.given },
)

/// The rubrics of an exam's divisions, each `(row, nodes)`, its row of point
/// data and its rubric's nodes (see `rubric_tree`), as data. Pure.
#let rubric_data(divisions) = divisions.map(d => (..division_row(d.row), rubric: rubric_entries(d.nodes)))

/// The name of a file the exam that ends at `here()` attaches, `base` +
/// `ext`: the first exam of a document attaches it as named; another, with
/// its number among the document's exams (`examy-rubric-2.json`), so
/// that each attaches a file of its own. `base` is a path from the root,
/// `/examy-rubric`, as the PDF names a file by its path from the root, and
/// one from examy's own files would be named `src/examy-rubric.json`.
/// Needs context.
#let attached_name(base, ext) = {
  let doc = _document_index(here())
  let n = query(selector(PAGES).before(here())).filter(m => m.value.doc == doc).len()
  if n <= 1 { base + ext } else { base + "-" + str(n) + ext }
}

/// Each division's rubric recorded (see `RECORD`), and the exam's rubrics
/// as `metadata` labelled `<examy-rubric>`:
///
///   (format: "examy-rubric", exam-name, rubrics)
///
/// `exam-name` the exam's name, `name`, as text; and `rubrics` each
/// division with a rubric, in order (see `rubric_data`). Emitted at the end
/// of an exam with rubrics, whatever `show-rubrics` says, all in one place,
/// so that it costs the same however many divisions there are.
/// `divisions`: those that may have a rubric, in order, each `(id, address,
/// field, info, row)` (see `rubric_info`, and `compute_points_data` for
/// `row`). With `attach`, also attached to the PDF as `examy-rubric.json`
/// (see `config`'s `embed-metadata`).
#let rubric_export(divisions, name, attach: false) = context {
  let exam = _exam_number(here())
  let bounds = exam_bounds()
  let records = ()
  let rubrics = ()
  for d in divisions {
    let nodes = division_rubric(d.id, d.field, bounds).nodes
    if nodes.len() == 0 { continue }
    records.push((exam: exam, address: d.address, heading: d.info.heading, points: d.info.points, nodes: nodes))
    rubrics.push((row: d.row, nodes: nodes))
  }
  for r in records [#metadata(r)#RECORD]
  let data = (format: "examy-rubric", exam-name: name, rubrics: rubric_data(rubrics))
  [#metadata(data)<examy-rubric>]
  if attach and target() == "paged" {
    pdf.attach(
      attached_name("/examy-rubric", ".json"),
      bytes(json.encode(data)),
      mime-type: "application/json",
      description: "The exam's rubrics",
    )
  }
}
