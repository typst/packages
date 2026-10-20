// =======================================================================
//
// Git repository:
//      https://github.com/neruthes/typstpkg-vtzone
//
//
// Copyright (c) 2026 Neruthes.
// Published with the MIT license.
//
// =======================================================================







#let fix-cjk-punct-vertical(doc) = {
  let movepunctloc(it) = box(stroke: 0.0pt + gray, {
    place(center + horizon, dx: 0.20em, dy: -0.4em, it)
    hide(text(fill: red.transparentize(10%), it))
  })
  show regex("[，。、]"): movepunctloc
  show regex("[「」【】『』❲❳［］“”《》]"): it => {
    // Define sets for opening and closing punctuation
    let openers = "「【『❲［“《".clusters()
    let is-opener = it.text in openers
    box({
      let that = rotate(-90deg, reflow: true, it)
      // Set offsets based on whether it opens or closes the phrase
      let (dx, dy) = if is-opener {
        (-0.1em, -0.5em)
      } else {
        (0.1em, 0.4em)
      }

      place(horizon + center, dx: dx, dy: dy, box(fill: none, that))
      hide(it)
    })
  }
  doc
}













#let vtzone(
  doc,
  x-scale: 100%,
  max-height: auto,
  horizontal: rtl,
  row-gutter: 0.37em,
  col-gutter: 0.5em,
  custom-parbreak: none,
  initial-skip: 0mm,
  inner-alignment: center,
  debug: false,
) = context {
  /*
    NOTES:
        - Ender: Ender characters are not allowed to start a column.
        - Leader: Leader characters are not allowed to end a column.
        - Overhang: We allow up to 1 ender character to overhang at the end of the column.
        - Underhang: When the current column already has an overhang character committed, and the upcoming character is also an ender, we should migrate both characters (and retrospectively all previous enders and the last non-ender character) to the next column.
  */
  let actual-max-h = if max-height == auto { 100mm } else { max-height }
  let row-gutter-pt = measure(v(row-gutter)).height

  let get-atoms(it, wrapper: x => x) = {
    if it == [] or it == [ ] { return () }
    let func = it.func()
    if func == linebreak or func == parbreak { return (func,) }
    if it.has("text") {
      let fields = it.fields()
      let txt = fields.remove("text")
      let text-wrapper = child => wrapper(text(..fields, child))
      return txt.clusters().map(c => box(text-wrapper(c)))
    }
    if it.has("children") {
      return it.children.map(c => get-atoms(c, wrapper: wrapper)).flatten()
    }
    let container-wrapper = child => {
      if it.has("styles") and it.has("child") { return wrapper(it.func()(child, it.styles)) }
      let fields = it.fields()
      let clean-fields = (:)
      let forbidden = ("body", "child", "children", "styles", "text")
      for (k, v) in fields { if k not in forbidden { clean-fields.insert(k, v) } }
      wrapper(it.func()(..clean-fields, child))
    }
    if it.has("body") { return get-atoms(it.body, wrapper: container-wrapper) }
    if it.has("child") { return get-atoms(it.child, wrapper: container-wrapper) }
    return (box(wrapper(it)),)
  }

  let atoms = get-atoms(doc)
  let enders = regex("^[.,;:!?，。；：！？、」』）〉】”]$")
  let leaders = regex("^[「『（〈【“]$")

  let get-txt(atom) = {
    if type(atom) == symbol { return str(atom) }
    if type(atom) == content {
      if atom.has("text") { return atom.text }
      if atom.has("body") { return get-txt(atom.body) }
      if atom.has("child") { return get-txt(atom.child) }
    }
    ""
  }

  // Helper to colorize atoms for debug mode
  let mark-debug(atom) = {
    if not debug or type(atom) != content { return atom }
    text(fill: red, atom)
  }

  let output-flow = ()
  if initial-skip > 0mm { output-flow.push(box(h(initial-skip))) }
  let current-col = ()
  let i = 0

  let calc-h(atom_list) = {
    if atom_list.len() == 0 { return 0pt }
    let h_sum = atom_list.map(a => measure(a).height).sum()
    let g_sum = (atom_list.len() - 1) * row-gutter-pt
    h_sum + g_sum
  }

  while i < atoms.len() {
    let atom = atoms.at(i)

    if atom == linebreak or atom == parbreak {
      if current-col.len() > 0 {
        output-flow.push(box(stack(dir: ttb, spacing: row-gutter, ..current-col)))
        output-flow.push(h(col-gutter, weak: false))
        if custom-parbreak != none { output-flow.push(custom-parbreak) }
      }
      current-col = ()
      i += 1
      continue
    }

    let atom-h = measure(atom).height
    let current-h = calc-h(current-col)
    let gap = if current-col.len() > 0 { row-gutter-pt } else { 0pt }

    if current-h + gap + atom-h > actual-max-h {
      let txt = get-txt(atom)
      let next-is-ender = if i + 1 < atoms.len() { get-txt(atoms.at(i + 1)).match(enders) != none } else { false }

      // Overhang check
      if txt.match(enders) != none and not next-is-ender {
        current-col.push(atom)
        i += 1
      } else {
        // Rollback (Underhang / Kinsoku)
        if txt.match(enders) != none {
          while current-col.len() > 0 {
            let last = current-col.pop()
            atoms.insert(i, mark-debug(last)) // Colorize if debugging
            if get-txt(last).match(enders) == none { break }
          }
          // The current atom that caused the overflow should also be marked
          atoms.at(i) = mark-debug(atoms.at(i))
        } else {
          // Leader check
          while current-col.len() > 0 and get-txt(current-col.last()).match(leaders) != none {
            let pulled = current-col.pop()
            atoms.insert(i, mark-debug(pulled))
          }
        }
      }

      if current-col.len() > 0 {
        output-flow.push(box(stack(dir: ttb, spacing: row-gutter, ..current-col)))
        output-flow.push(h(col-gutter, weak: false))
        current-col = ()
      }
    } else {
      current-col.push(atom)
      i += 1
    }
  }

  if current-col.len() > 0 {
    output-flow.push(box(stack(dir: ttb, spacing: row-gutter, ..current-col)))
  }

  {
    set text(dir: horizontal)
    set par(leading: 0pt, spacing: 0pt)
    output-flow
      .map(it => {
        box(baseline: 100%, height: max-height, box(scale(x: x-scale, reflow: true, align(inner-alignment, it))))
      })
      .join()
  }
}
