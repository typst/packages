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

#let _desc(c) = markdown(c).replace(regex(" *\n *"), "\n").replace(regex("\n{3,}"), "\n\n").replace(regex(" {2,}"), " ").trim()

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

/// A division's number: its numbers from the question down, joined by dots
/// ("2.1" for 2 (a)); `none` for an unnumbered one.
#let division_number(address) = {
  if address.len() == 0 or address.any(n => n == none) { return none }
  address
    .map(n => if type(n) == int { str(n + 1) } else if type(n) == str { n } else { _desc(n) })
    .join(".")
}

/// The rubrics of an exam's divisions, from their records (see `RECORD`),
/// as data. Pure.
#let rubric_data(records) = records.map(r => (
  number: division_number(r.address),
  title: _desc(r.heading.title),
  points: r.points,
  rubric: rubric_entries(r.nodes),
))

/// Each division's rubric recorded (see `RECORD`), and the exam's rubrics
/// as `metadata` labelled `<examy-rubric>`: `(exam, questions)`, `exam`
/// counted from 1 and `questions` each division with a rubric, in order
/// (see `rubric_data`). Emitted at the end of an exam with rubrics, whatever
/// `show-rubrics` says, all in one place, so that it costs the same however
/// many divisions there are. `divisions`: those that may have a rubric, in
/// order, each `(id, address, field, info)` (see `rubric_info`).
#let rubric_export(divisions) = context {
  let exam = _exam_number(here())
  let bounds = exam_bounds()
  let records = ()
  for d in divisions {
    let nodes = division_rubric(d.id, d.field, bounds).nodes
    if nodes.len() == 0 { continue }
    records.push((exam: exam, address: d.address, heading: d.info.heading, points: d.info.points, nodes: nodes))
  }
  for r in records [#metadata(r)#RECORD]
  [#metadata((exam: exam, questions: rubric_data(records)))<examy-rubric>]
}
