// Body-matter helpers: theorem-like environments, appendix, CRediT
// statement, biographies and booktabs rules.
#import "globals.typ": *
#import "utils.typ": *

// Tables -------------------------------------------------------------------

/// Booktabs rules (`\toprule`, `\midrule`, `\bottomrule`) for use in `table`.
/// Their label lets `show-booktabs` find them.
#let toprule = [#table.hline(stroke: heavy-rule-width)<cas-toprule>]
#let midrule = [#table.hline(stroke: light-rule-width)<cas-midrule>]
#let bottomrule = [#table.hline(stroke: heavy-rule-width)<cas-bottomrule>]

/// Space above and below each rule (\abovetopsep and \belowbottomsep are 0).
#let booktabs-rules = (
  cas-toprule: (above: 0pt, below: below-rule-sep, width: heavy-rule-width),
  cas-midrule: (
    above: above-rule-sep,
    below: below-rule-sep,
    width: light-rule-width,
  ),
  cas-bottomrule: (above: above-rule-sep, below: 0pt, width: heavy-rule-width),
)

#let rule-kind(child) = {
  let label = child.at("label", default: none)
  if label != none and str(label) in booktabs-rules { str(label) }
}

/// Leave the space of booktabs around its rules: a table line takes no
/// room, so the rows next to a rule get extra inset. Applied by `article`.
#let show-booktabs(it) = {
  let fields = it.fields()
  let children = fields.remove("children")
  // A label stays with the original table.
  let _ = fields.remove("label", default: none)
  let is-group(c) = c.func() in (table.header, table.footer)
  let flat = children.map(c => if is-group(c) { c.children } else { c })
  flat = flat.flatten()
  if flat.all(c => rule-kind(c) == none) { return it }

  // Find the row boundary of each rule by placing the cells as Typst does:
  // a line without `y` goes below the last automatically placed cell.
  let columns = fields.at("columns", default: auto)
  let n = if type(columns) == int { columns } else if type(columns) == array {
    columns.len()
  } else { 1 }
  let taken = (:) // grid slots filled by row-spanning cells
  let next = 0 // slot of the next automatically placed cell
  let pad-top = (:) // row -> extra inset
  let pad-bottom = (:)
  for c in flat {
    let kind = rule-kind(c)
    if kind != none {
      let y = calc.div-euclid(next + n - 1, n)
      let rule = booktabs-rules.at(kind)
      pad-top.insert(str(y), rule.below + rule.width / 2)
      if y > 0 { pad-bottom.insert(str(y - 1), rule.above + rule.width / 2) }
    } else if c.func() not in (table.hline, table.vline) {
      let cell = c.func() == table.cell
      let colspan = if cell { calc.min(c.at("colspan", default: 1), n) } else { 1 }
      let rowspan = if cell { c.at("rowspan", default: 1) } else { 1 }
      let placed = cell and (c.at("x", default: auto), c.at("y", default: auto)) != (auto, auto)
      if not placed {
        let fits(i) = (
          calc.rem(i, n) + colspan <= n
            and range(colspan).all(k => str(i + k) not in taken)
        )
        let i = next
        while not fits(i) { i += 1 }
        for dy in range(rowspan) {
          for dx in range(colspan) { taken.insert(str(i + dy * n + dx), true) }
        }
        next = i + colspan
      }
    }
  }

  let base = fields.at("inset", default: 0pt)
  let side(inset, key, axis) = if type(inset) == dictionary {
    inset.at(key, default: inset.at(axis, default: inset.at(
      "rest",
      default: 0pt,
    )))
  } else { inset }
  fields.insert("inset", (x, y) => {
    let inset = if type(base) == function { base(x, y) } else if (
      type(base) == array
    ) { base.at(calc.rem(x, base.len())) } else { base }
    (
      left: side(inset, "left", "x"),
      right: side(inset, "right", "x"),
      top: side(inset, "top", "y") + pad-top.at(str(y), default: 0pt),
      bottom: side(inset, "bottom", "y") + pad-bottom.at(str(y), default: 0pt),
    )
  })

  // Rebuild the table with unlabelled rules, which this rule leaves alone.
  let unlabel(c) = if rule-kind(c) != none {
    let f = c.fields()
    let _ = f.remove("label", default: none)
    table.hline(..f)
  } else if is-group(c) {
    let f = c.fields()
    let kids = f.remove("children")
    c.func()(..f, ..kids.map(unlabel))
  } else { c }
  table(..fields, ..children.map(unlabel))
}

// Theorems -----------------------------------------------------------------

#let thm-kind-prefix = "cas-thm:"

/// Define a numbered theorem-like environment (`\newtheorem`): bold heading
/// "Theorem 1." followed by an italic body. Environments sharing a `counter`
/// are numbered together (`\newtheorem{lemma}[theorem]{Lemma}`).
///
/// ```typ
/// #let theorem = new-theorem("theorem", [Theorem])
/// #let lemma = new-theorem("lemma", [Lemma], counter: "theorem")
/// #theorem(title: [Fermat])[No three positive integers ...] <thm:fermat>
/// ```
/// - name (str): identifier of the environment.
/// - supplement (content): heading word, also used by references.
/// - counter (str, none): name of the environment whose counter is shared.
/// - italic (bool): set the body in italics.
/// -> function
#let new-theorem(name, supplement, counter: none, italic: true) = {
  let kind = thm-kind-prefix + if counter == none { name } else { counter }
  (title: none, body) => figure(
    kind: kind,
    supplement: supplement,
    numbering: "1",
    outlined: false,
    caption: title,
    if italic { emph(body) } else { body },
  )
}

/// Like `new-theorem`, with an upright body (`\newdefinition`).
#let new-definition(name, supplement, counter: none) = new-theorem(
  name,
  supplement,
  counter: counter,
  italic: false,
)

/// Define an unnumbered proof-like environment (`\newproof`): heading in
/// small capitals, upright body.
#let new-proof(name, supplement) = (title: none, body) => block(
  width: 100%,
  breakable: true,
  above: 10pt,
  below: 10pt,
  {
    set par(first-line-indent: (amount: par-indent, all: false))
    [#smallcaps[#supplement#if title != none [ (#title)].] #body]
  },
)

/// End-of-proof square pushed to the right margin (`\qed`).
#let qed = [#h(1fr)$square$]

/// Render theorem figures created by `new-theorem`; applied by `article`.
#let show-theorem(it) = {
  if type(it.kind) != str or not it.kind.starts-with(thm-kind-prefix) {
    return it
  }
  let title = if it.caption != none { it.caption.body }
  block(width: 100%, breakable: true, above: 10pt, below: 10pt, {
    set align(left)
    set par(first-line-indent: (amount: par-indent, all: false))
    let number = context it.counter.display(it.numbering)
    [#strong[#it.supplement #number#if title != none [ (#title)].] #it.body]
  })
}

// Appendix -----------------------------------------------------------------

/// Start the appendices (`\appendix`): sections are numbered A, B, ...
/// Use as `#show: appendix`.
#let appendix(body) = {
  set heading(
    numbering: (..n) => if n.pos().len() <= 3 { numbering("A.1", ..n) },
    supplement: [Appendix],
  )
  counter(heading).update(0)
  body
}

// CRediT authorship statement ----------------------------------------------

/// Print the CRediT authorship contribution statement from the `credit`
/// entries of the authors (`\printcredits`).
#let print-credits(
  title: [CRediT authorship contribution statement],
) = context {
  let info = cas-info.get()
  let credited = info.authors.filter(a => a.at("credit", default: none) != none)
  if credited.len() > 0 {
    heading(numbering: none, outlined: false, title)
    if info.blind { v(10mm) } else {
      credited.map(a => [*#full-name(a):* #a.credit]).join(". ") + [.]
    }
  }
}

// Biographies --------------------------------------------------------------

/// An author biography (`\bio ... \endbio`), with an optional photo that is
/// set 25.5mm wide to the left of the text. Hidden for double-blind review.
///
/// ```typ
/// #bio[Biography without photo.]
/// #bio(image("photo.jpg"))[Biography with photo.]
/// ```
#let bio(..args) = context {
  let pos = args.pos()
  assert(pos.len() in (1, 2), message: "bio takes an optional photo and a body")
  let body = pos.last()
  let photo = if pos.len() == 2 { pos.first() }
  assert(
    type(photo) != str,
    message: "pass the photo as `image(\"...\")`, not as a path string",
  )
  if not cas-info.get().blind {
    // \casbiographyfont
    with-size((8pt, 10pt), {
      set par(first-line-indent: 0pt)
      if photo == none {
        block(above: 6.4pt, below: 6.4pt, body)
      } else {
        block(above: 20.7pt, below: 20.7pt, grid(
          columns: (25.5mm, 1fr),
          column-gutter: 5pt,
          {
            set image(width: 25.5mm)
            photo
          },
          body,
        ))
      }
    })
  }
}
