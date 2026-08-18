#import "configs.typ": *
#import "@preview/ratchet:0.0.3": figure-number

#let add-countblock(cb, name, info, color, counter-name: none, depth: none) = {
  if depth != none and not (depth in (1, 2, 3)) {
    panic("add-countblock: depth must be none, 1, 2, or 3")
  }
  if counter-name == none { counter-name = name }
  cb.insert(name, (info, color, counter-name, depth))
  return cb
}

#let set-countblock-depth(cb, name, depth, detach: false) = {
  if not (name in cb) { panic("set-countblock-depth: block not registered") }
  if not (depth in (1, 2, 3)) { panic("set-countblock-depth: depth must be 1, 2, or 3") }

  let item = cb.at(name)
  let counter-name = item.at(2)
  if detach {
    cb.insert(name, (item.at(0), item.at(1), name, depth))
  } else {
    for (block-name, block) in cb.pairs() {
      if block-name != "cb-counter-depth" and block.at(2) == counter-name {
        cb.insert(block-name, (block.at(0), block.at(1), counter-name, depth))
      }
    }
  }
  cb
}

#let countblock-counter-names(cb) = {
  let names = ()
  for (name, item) in cb.pairs() {
    if name != "cb-counter-depth" {
      let counter-name = item.at(2)
      if not names.contains(counter-name) { names.push(counter-name) }
    }
  }
  names
}

#let countblock-figure-groups(cb, default-depth: 2, outline: "1.1", color: none) = {
  let depths = (:)
  for (name, item) in cb.pairs() {
    if name != "cb-counter-depth" {
      let counter-name = item.at(2)
      let depth = item.at(3, default: none)
      let depth = if depth == none { default-depth } else { depth }
      if counter-name in depths and depths.at(counter-name) != depth {
        panic("countblock: blocks sharing counter-name `" + counter-name + "` must use the same depth")
      }
      depths.insert(counter-name, depth)
    }
  }

  let groups = ()
  for (counter-name, depth) in depths.pairs() {
    groups.push((
      kinds: (counter-name,),
      depth: depth,
      outline: outline,
      color: color,
    ))
  }
  groups
}

#let countblock(name, cb, cb-counter-depth: none, subname: "", count: true, lab: none, body) = {
  if not (name in cb) { panic("countblock: block not registered") }
  let item = cb.at(name)
  let (info, color, counter-name) = (item.at(0), item.at(1), item.at(2))

  let title = [#info]
  if count { title += [ #figure-number(counter-name)] }
  if subname != "" { title += [ #subname] }

  let rendered = block(
    fill: color.transparentize(70%),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    stroke: (left: (thickness: 4pt, paint: color)),
    breakable: true,
    [
      #set text(font: font.countblock)
      #set align(left)
      #v(-0.5em)#h(-0.5em)
      #box(fill: color.transparentize(60%), inset: 6pt, outset: -2pt, radius: 3pt)[#h(0.3em)#strong(title)#h(0.3em)]
      #h(0.75em)

      #v(-0.3em)
      #body
    ],
  )

  // Keep a native figure as a zero-size anchor so Ratchet and `@ref` can use
  // Typst's figure counter, while leaving the visible block in normal flow.
  // A figure containing the whole block cannot break across pages.
  let elem = if count {
    figure(
      [],
      caption: none,
      kind: counter-name,
      supplement: info,
      outlined: false,
    )
  } else {
    figure(
      [],
      caption: none,
      kind: counter-name,
      supplement: info,
      numbering: none,
      outlined: false,
    )
  }

  let anchor = [
    #elem
    #if lab != none { label(lab) }
  ]

  [
    #place(anchor)
    #rendered
  ]
}

#let definition = countblock.with("def", cb)
#let theorem = countblock.with("thm", cb)
#let proposition = countblock.with("prop", cb)
#let lemma = countblock.with("lem", cb)
#let corollary = countblock.with("cor", cb)
#let remark = countblock.with("rmk", cb)
#let claim = countblock.with("clm", cb)
#let exercise = countblock.with("ex", cb)
#let problem = countblock.with("prob", cb)
#let example = countblock.with("eg", cb)
#let note = countblock.with("note", cb, count: false)
#let caution = countblock.with("cau", cb, count: false)

// Kept as no-op compatibility shims for documents written for Scripst 1.1.1.
// Ratchet now installs and resets countblock counters from the registry passed to scripst.
#let reg-countblock(counter-name, cb-counter-depth: none, body) = body
#let reg-default-countblock(cb-counter-depth: none, body) = body
