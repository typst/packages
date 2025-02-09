/// clashes with parameter name
#let _label = label

/// Function to run at beginning of theorem.
///
/// Default value of @theorem.fmt-prefix.
/// #example(```typ
/// #fmt-prefix([Theorem], [1.34], none)...
/// 
/// #fmt-prefix([Theorem], [1.34], [Pythagoras])...
/// ```)
/// -> content
#let fmt-prefix(
  /// -> content
  supplement,
  /// -> content | none
  number,
  /// -> content | none
  title,
) = {
  emph({
    supplement
    if number != none [ #number]
    if title != none {
      h(0.5em)
      [(#title)]
    }
    h(1em)
  })
}

/// Function to format the body
///
/// Default value of @theorem.fmt-body.
/// -> content
#let fmt-body(
  /// Theorem content.
  /// -> content
  body,
  /// // enables creating a link/reference to the solution.
  /// // -> location | none
  /// -> content
  solution,
) = {
  body
  if solution != none and solution != [] {
    footnote[#link(<_thm_solutions>)[Solution in Appendix]]
    // // This causes a document did not converge warning. why?
    // context {
    //     let sol = query(<_thm>).filter(m => m.value.body == solution)
    //     if sol.len() == 1 {
    //       footnote[#link(sol.first().location())[Solution in Appendix]]
    //     } else {
    //       footnote[#link(<_thm_solutions>)[Solution in Appendix (*??*)]]
    //     }
    // }
  }
}

/// -> state(boolean)
#let _needs_qed = state("_thm_needs_qed", false)

/// Place a QED mark and clear the `_thm_needs_qed` flag, so that the theorem environment itself won't place one.
///
/// See @proof.fmt-suffix.
/// // Pass this as @theorem.fmt-suffix for proof environments.
/// -> content
#let qed(
  /// -> content
  suffix: [#h(1fr)$square$],
  /// Whether to place suffix no matter the `_thm_needs_qed` flag.
  /// -> boolean
  force: true,
) = context {
  if force or _needs_qed.get() {
    _needs_qed.update(false)
    suffix
  }
}

/// Appends the suffix to the body, putting it inside any lists/enums and special casing block equations.
/// -> content
#let _append-qed(
  /// -> content
  body,
  /// -> function | none
  fmt-suffix,
) = {
  let _body = body
  if fmt-suffix != none {
    if body.has("children") {
      if body.children.last() == [ ] {
        _body = body.children.slice(0, -1).join()
      }
      let candidate = _body.children.last()
      if candidate.func() == math.equation and candidate.block and math.equation.numbering == none {
        _body = {
          _body.children.slice(0, -1).join()
          set math.equation(numbering: (..) => {fmt-suffix()}, number-align: bottom)
          candidate
          counter(math.equation).update((i) => {i - 1})
        }
      } else if candidate.func() == enum.item or candidate.func() == list.item {
        _body = {
          _body.children.slice(0, -1).join()
          candidate.func()(_append-qed(candidate.body,  fmt-suffix))
        }
      } else {
        _body = {
          _body
          fmt-suffix()
        }
      }
    } else {
      if _body.func() == math.equation and _body.block and math.equation.numbering == none {
        _body = {
          set math.equation(numbering: (..) => {fmt-suffix()}, number-align: bottom)
          _body
          counter(math.equation).update((i) => {i - 1})
        }
      } else if _body.func() == enum.item or _body.func() == list.item {
        _body = {
          _body.func()(_append-qed(_body.body,  fmt-suffix))
        }
      } else {
        _body = {
          _body
          fmt-suffix()
        }
      }
    }
  }
  return _body
}

/// Counts theorems.
///
/// In most cases, it is not neccesary to reset this manually, it will get updated accordingly if you pass an integer to @theorem.number.
/// -> counter
#let thm-counter = counter("_thm")

/// Theorem Environment
///
/// #example(```typ
/// >>> #thm-counter.update(0)
/// #set heading(numbering: none)
///
/// #theorem[If the headings are not numbered, theorem numbering starts at 1.]
///
/// = Heading
/// #theorem(title: "Pythagoras")[
///   Given a right-angled triangle, the length
///   of the hypothenuse squared is equal to the
///   sum of the squares of the remainig sides'
///   lengths.
/// ]
/// ```, scale-preview: 100%)
///
/// /* #example(```typ
/// >>> #thm-counter.update(0)
/// >>> #counter(heading).update(0)
/// #set heading(numbering: "1.1.")
///
/// #theorem[Theorem before first numbered heading is "0.\_".]
///
/// = Heading
/// #theorem(title: "Pythagoras")[
///   Given a right-angled triangle, the length
///   of the hypothenuse squared is equal to the
///   sum of the squares of the remainig sides'
///   lengths.
/// ]
///
/// == Subheading
/// #let corollary = theorem.with(
///   kind: "corollary",
///   supplement: "Corollary")
/// #corollary[#lorem(5)]
/// #corollary(number: none)[Skip number]
/// #corollary(number: "P")[Custom "number"]
/// #corollary[Resume numbering]
/// #corollary(number: 10)[Set number]
/// #corollary[Continue with set number]
///
/// = Heading
/// #theorem()[Restarted numbering.]
/// >>> #counter(heading).update((2,8))
/// ```, scale-preview: 100%) */
///
/// -> content
#let theorem(
  /// // Default: @fmt-prefix.
  /// -> function
  fmt-prefix: fmt-prefix,

  /// // Default: @fmt-body.
  /// -> function
  fmt-body: fmt-body,

  /// Will be called at the end of the theorem if `_thm_needs_qed` hasn't been cleared. (E.g. by @qed)
  /// -> function | none
  fmt-suffix: none,

  /// Arguments to pass to the ```typ #block[]``` containing the theorem.
  /// -> dict
  block-args: (:),

  /// Used for filtering e.g. when creating table of theorems.
  /// -> string
  kind: "theorem",
  
  /// What to label the environment.
  ///
  /// It is recommended to keep `kind` and `supplement` matching (except for "subtypes", e.g. one might have the kind of "Example" and "Counter-Example" both as ```typc "example"```)
  /// -> content
  supplement: "Theorem",

  ///- If ```typc auto```, will continue numbering from last numbered theorem.
  ///- If integer, it will contune the numbering of later theorems from the given number.
  ///- If content, it is shown as-is, with no side-effects.
  ///#example(```typ
  /// >>> // #thm-counter.update(0)
  /// >>> // #counter(heading).update(0)
  /// >>> // #set heading(numbering: "1.1.")
  /// #let corollary = theorem.with(
  ///   kind: "corollary",
  ///   supplement: "Corollary")
  ///
  /// #corollary[#lorem(2)]
  ///
  /// #corollary(number: none)[Skip number]
  /// #corollary[Resume numbering]
  ///
  /// #corollary(number: "X")[Custom "number"]
  /// #corollary[Resume numbering]
  ///
  /// #corollary(number: 10)[Set number]
  /// #corollary[Continue from set number]
  /// >>> // #counter(heading).update((2,8))
  /// ```, scale-preview: 100%)
  /// -> auto | none | integer | content
  number: auto,

  /// Title of the Theorem. Usually shown after the number.
  /// -> none | content
  title: none,

  /// Title of the Theorem to be used in outlines.
  /// ```typc auto``` to use the `title`.
  /// -> auto | content
  toctitle: auto,

  /// Label (for references)
  ///
  /// note: Simply putting a ```typ <label>``` after the ```typ #theorem[]``` does not work for referencing.
  /// -> label | string
  label: none,

  /// Theorem body
  /// -> content
  body,

  /// Optional Solution. Pass zero or one positional arguments here.
  ///
  /// #example(```typ
  /// #theorem[#lorem(5)][This will show up wherever `#theoretic.solutions()` is placed.]
  /// ```, scale-preview: 100%)
  ///
  /// See @solutions.
  /// -> content
  ..solution,
) = {
  // let number = number
  // if number == auto and label == none and title == none { number = none }
  
  context {
    if heading.numbering != none {
      let prev = query(selector(<_thm_marker>).before(here()))
      if prev.len() != 0 {
        let prev = prev.last()
        let h = counter(heading).get().first()
        if counter(heading).at(prev.location()).first() != h {
          thm-counter.update(0)
        }
      }
    }
  }
  [#metadata((none,))<_thm_marker>]
  if number == auto {
    thm-counter.step()
  }
  if type(number) == int {
    thm-counter.update(number)
  }
  block(width: 100%, ..block-args, {
     context {
      let thmnr = thm-counter.display("1")
      let number = number
      if number == auto or type(number) == int {
        if heading.numbering == none {
          number = thmnr
        } else {
          let h = counter(heading).get().first()
          let h_fmt = numbering(heading.numbering, h).trim(".", at: end)
          number = { h_fmt; "."; thmnr }
        }
      }
      let sol = none
      if solution.pos().len() == 1 {
        sol = solution.pos().first()
      } else if solution.pos().len() > 1 {
        panic("Illegal number of arguments. Only one solution allowed.")
      }
      let toctitle = if toctitle == auto { title } else { toctitle }
      [#metadata((body: body, solution: sol, toctitle: toctitle))<_thm>]
      let label = if type(label) == str { _label(label) } else { label }
      [#metadata((theorem-kind: kind, supplement: supplement, number: number, title: title))#label]
  
      fmt-prefix(supplement, number, title)
      h(0pt, weak: true)
      _needs_qed.update(true)

      let _body = _append-qed(body, fmt-suffix)
      
      fmt-body(_body, sol)
      // if fmt-suffix != none {
      //   fmt-suffix()
      // }
    }
  })
}

/// Re-state a theorem.
///
/// It will reuse the original kind, supplement, number, title, and body. It will _not_ re-emit the solution or label, and it will use `toctitle: none` to avoid duplicate toc entries.
///
/// It is currently not able to pick up any of the other configuration of the original theorem, therefore pass @restate.is if you modified e.g. any of the `fmt-`s.
/// #example(```typ
/// #let proposition = theorem.with(
///   kind: "proposition",
///   supplement: "Proposition",
///   fmt-body: (b, s) => { text(fill: red, {b;s}) }
/// )
/// #proposition(title: "Funky!", label: <funky>)[Blah _blah_ blah.]
/// Restated:
/// #restate("funky")
/// Restated with explicit kind:
/// #restate(<funky>, is: proposition)
/// ```, scale-preview: 100%);
/// -> content
#let restate(
  /// Label of the theorem to restate.
  /// -> label | string
  label,
  /// Theorem function to use.
  /// -> function
  is: theorem,
) = context {
  let label = label
  if type(label) == str { label = _label(label) }
  let original = query(label)
  if original.len() != 1 { panic("Cannot restate non-unique or non-existent label.") }
  original = original.first()
  let base = query(selector(metadata).before(original.location(), inclusive: false)).last().value
  if original.value.number != none {
    is(base.body, kind: original.value.theorem-kind, supplement: link(label, original.value.supplement), number: link(label, original.value.number), title: original.value.title, toctitle: none)
  } else {
    is(base.body, kind: original.value.theorem-kind, supplement: link(label, original.value.supplement), number: none, title: original.value.title, toctitle: none)
  }
}

/// Function to run at beginning of proof.
///
/// Default value of @proof.fmt-prefix.
/// #example(```typ
/// #proof-fmt-prefix([Proof], none, none)...
/// 
/// #proof-fmt-prefix([Proof], none, [@pythagoras])...
/// ```)
/// -> content
#let proof-fmt-prefix(
  /// -> content
  supplement,
  /// -> content | none
  number,
  /// -> content | none
  title,
) = {
  emph({
    supplement
    if number != none [ #number]
    if title != none [ of #title]
    [.]
    h(1em)
  })
}

/// This is just @theorem with different defaults.
/// #example(```typ
/// #proof[#lorem(5)]
/// #proof(title: [@pythagoras[!]])[#lorem(6)]
/// ```, scale-preview: 100%)
/// -> content
#let proof(
  /// #[]
  /// -> content
  kind: "proof",
  /// #[]
  /// -> content
  supplement: "Proof",
  /// #[]
  /// -> string
  number: none,
  /// #[]
  /// -> function
  fmt-prefix: proof-fmt-prefix,
  /// #[]
  /// -> function
  fmt-suffix: qed.with(force: false),
  /// Same as for @theorem.
  /// -> arguments
  ..args,
) = {theorem(kind: kind, supplement: supplement, number: number, fmt-prefix: fmt-prefix, fmt-suffix: fmt-suffix, ..args)}

/// Show-rule-function to be able to ```typ @``` labelled theorems.
///
/// Use via \````typ #show ref: show-ref```\` at the beginning of your document.
///
/// #example(```typ
/// >>> // #thm-counter.update(0)
/// >>> // #set heading(numbering: "1.1.")
/// #show ref: theoretic.show-ref
/// #theorem(label: <fact>, supplement: "Fact")[#lorem(2)]
/// #theorem(label: <pythagoras>, title: "Pythagoras")[#lorem(2)]
/// #theorem(label: <zl>, title: "Only Named", number: none)[#lorem(2)]
/// #theorem(label: <y>, number: "Y")[#lorem(2)]
/// #theorem(label: "5", number: none)[#lorem(2)]
/// 
/// As a consequence of @fact and @pythagoras[!!]...
/// ```, scale-preview: 100%)
/// 
/// The reference can be controlled via the supplement passed:
/// #{
///   set text(size: 0.8em)
///   pad(x: -1cm, table(
///   columns: (1fr, auto, auto, auto, auto),
///   // columns: (1fr, 1fr, 1fr, 1fr, 1fr),
///   align: left,
///   [], [Both], [Without Title], [Without Number], [Neither],
///   [```typ @ref``` (Full)], [@pythagoras], [@fact / @y], [@zl], [@5],
///   [```typ @ref[-]``` (Compact)], [@pythagoras[-]], [@fact[-] / @y[-]], [@zl[-]], [@5[-]],
///   [```typ @ref[--]``` (Number)], [@pythagoras[--]], [@fact[--] / @y[--]], [@zl[--]], [@5[--]],
///   [```typ @ref[!]``` (Inverted)], [@pythagoras[!]], [@fact[!] / @y[!]], [@zl[!]], [@5[!]],
///   [```typ @ref[!!]``` (Compact Inverted)], [@pythagoras[!!]], [@fact[!!] / @y[!!]], [@zl[!!]], [@5[!!]],
///   [```typ @ref[!!!]``` (Name)], [@pythagoras[!!!]], [@fact[!!!] / @y[!!!]], [@zl[!!!]], [@5[!!!]],
///   [```typ @ref[?]``` (Kind)], [@pythagoras[?]], [@fact[?] / @y[?]], [@zl[?]], [@5[?]],
///   [```typ @ref[Custom]``` (Custom Supplement)], [@pythagoras[Custom]],[@fact[Custom] / @y[Custom]], [@zl[Custom]], [@5[Custom]],
/// ))
/// }
///
/// Note: the fact that references and links in this document are underlined in gray is achieved with a separate ```typ @show link: it => underline(..)``` rule, and not because of this function.
#let show-ref(
  /// -> ref
  it,
) = {
  let el = it.element
  if el != none and el.func() == metadata and type(el.value) == dictionary and el.value.at("theorem-kind", default: none) != none {
    let val = el.value
    if it.supplement == [?] {
      link(it.target, [#val.supplement])
    }
    // else if it.supplement == [-] {
    //   if val.number != none {
    //     link(it.target, [#val.supplement #val.number])
    //   } else if val.title != none {
    //     link(it.target, [#val.supplement (#val.title)])
    //   } else {
    //     link(it.target, [#val.supplement])
    //   }
    // } else if it.supplement == [--] {
    //   if val.number != none {
    //     link(it.target, [#val.number])
    //   } else if val.title != none {
    //     link(it.target, [(#val.title)])
    //   } else {
    //     link(it.target, [*??*])
    //   }
    // } else if it.supplement == [!] {
    //   if val.title != none {
    //     link(it.target, [#val.title])
    //   } else if val.title != none {
    //     link(it.target, [(#val.title)])
    //   } else {
    //     link(it.target, [*??*])
    //   }
    // } else if it.supplement == [!!] {
    //   link(it.target, [#val.title (#val.number)])
    // } else if it.supplement == [!!!] {
    //   link(it.target, [#val.title (#val.supplement #val.number)])
    // } else if it.supplement == auto {
    //   if val.number != none {
    //     link(it.target, [#val.number])
    //   } else if val.title != none {
    //     link(it.target, [(#val.title)])
    //   } else {
    //     link(it.target, [*??*])
    //   }
    // } else {
    //   link(it.target, [#it.supplement #val.number (#val.title)])
    // }

    else if val.title != none {
      if val.number != none {
        if it.supplement == [-] {
          link(it.target, [#val.supplement #val.number])
        } else if it.supplement == [--] {
          link(it.target, [#val.number])
        } else if it.supplement == [!!!] {
          link(it.target, [#val.title])
        } else if it.supplement == [!!] {
          link(it.target, [#val.title (#val.number)])
        } else if it.supplement == [!] {
          link(it.target, [#val.title (#val.supplement #val.number)])
        } else if it.supplement == auto {
          link(it.target, [#val.supplement #val.number (#val.title)])
        } else {
          link(it.target, [#it.supplement #val.number (#val.title)])
        }
      } else {
        if it.supplement == [-] or it.supplement == auto {
          link(it.target, [#val.supplement (#val.title)])
        } else if it.supplement == [--] {
          link(it.target, [(#val.title)])
        } else if it.supplement == [!!!] or it.supplement == [!!] {
          link(it.target, [#val.title])
        } else if it.supplement == [!] {
          link(it.target, [#val.title (#val.supplement)])
        } else {
          link(it.target, [#it.supplement (#val.title)])
        }
      }
    } else if val.number != none {
      if it.supplement == [-] or it.supplement == [!] or it.supplement == [!!] or it.supplement == [!!!] or  it.supplement == auto {
        link(it.target, [#val.supplement #val.number])
      } else if it.supplement == [--] {
        if val.number != none {
          link(it.target, [#val.number])
        } else {
          link(it.target, [*??*])
        }
      } else {
        link(it.target, [#it.supplement #val.number])
      }
    } else {
      if it.supplement == [-] or it.supplement == [--] or it.supplement == [!] or it.supplement == [!!] or it.supplement == [!!!] or  it.supplement == auto {
        link(it.target, [#val.supplement])
      } else {
        link(it.target, [#it.supplement #val.number])
      }
    }
  } else {
    // Other references as usual.
    it
  }
}

/// List all solutions, if any.
///
/// See @_thm_solutions for how it looks.
/// Currently not customizable, working on it.
/// -> content
#let solutions(
  /// Title/heading to use.
  /// -> content
  title: "Solutions"
) = context {
  let sols = query(<_thm>).filter(m => m.value.solution != none and m.value.solution != [])
  if sols.len() > 0 {
    [#heading(level: 1, title)<_thm_solutions>]
    for sol in sols {
      let val = query(selector(metadata).after(sol.location(), inclusive: false)).first().value
      let target = if val.number != none {
        if val.title != none {
          [#val.supplement #val.number (#val.title)]
        } else {
          [#val.supplement #val.number]
        }
      } else {
        if val.title != none {
          [#val.supplement (#val.title)]
        } else {
          [#val.supplement]
        }
      }
      theorem(kind: "solution", supplement: "Solution", title: link(sol.location(), target), number: none, fmt-prefix: proof-fmt-prefix, sol.value.solution)
    }
  } else {
    [#metadata("No solutions. Should not link here.")<_thm_solutions>]
  }
}

/// internal helper
/// -> string
#let _to-string(
  /// -> content
  content
) = {
  if content == none { "" }
  else if type(content) == str { content}
  else if content.has("text") { content.text }
  else if content.has("children") { content.children.map(_to-string).join("") }
  else if content.has("child") { _to-string(content.child) }
  else if content.has("body") { _to-string(content.body) }
  else if content == [] { "" }
  else if content == [ ] { " " }
  else if content.func() == ref { "_ref_" }
  else {
    let offending = content
    ""
  }
} 

/// Create an outline that includes named theorems.
///
/// Can be styled with show rules for ```typc outline.entry()```.
/// See the source code of this manual for an example.
///
/// #example(```typ
///  #heading(outlined: false, level: 3)[
///    Contents
///  ]
///  #toc(depth: 1)
///  ```, scale-preview: 100%)
/// -> content
#let toc(
  /// Maximum depth of headings to conisder
  /// -> integer
  depth: 2,
  /// list of @theorem.kind#[]s to ignore.
  /// #example(```typ
  ///  #heading(outlined: false, level: 3)[
  ///    Table of Examples
  ///  ]
  ///  #toc(
  ///    depth: 0,
  ///    exclude: ("proof", "solution", "theorem")
  ///  )
  ///  ```, scale-preview: 100%)
  /// -> list (string)
  exclude: ("proof", "solution"),
  /// Fake level to use for theorems.
  /// Set this to some level greater than the depth if to avoid conflict in your show rules for `outline.entry`. 
  /// -> integer
  level: 4,
  /// Fill for outline entries
  /// -> content
  fill: repeat[.],
  /// Whether to sort the entries alphabetically.
  /// Only resepcted if `depth` is 0.
  /// #example(```typ
  ///  #theorem(title: "Z")[Blah blah.]
  ///  #theorem(title: "A")[Blah blah.]
  ///  #heading(outlined: false, level: 3)[
  ///    Sorted Table of Theorems
  ///  ]
  ///  #toc(
  ///    depth: 0,
  ///    sort: true,
  ///  )
  ///  ```, scale-preview: 100%)
  /// -> bool
  sort: false
) = context {
  let thms = query(selector(<_thm>).or(heading))
  if depth == 0 and sort {
    thms = array(thms).filter(thm => { thm.func() != heading and thm.value.toctitle != none }).sorted(key: (thm) => { _to-string(thm.value.toctitle) })
    let len = thms.len()
  }
  for thm in thms {
    let pn = thm.location().page-numbering()
    let p = if pn != none {
      numbering(pn, ..counter(page).at(thm.location()))
    } else {
      numbering("1", ..counter(page).at(thm.location()))
    }
    if thm.func() == heading {
      let level = thm.level
      if level > depth or thm.outlined == false { continue }
      let number = none
      if thm.numbering != none {
        number = numbering(thm.numbering, ..counter(heading).at(thm.location()))
      }
      outline.entry(level, thm, [#number #thm.body], fill, p)
      linebreak()
    } else {
      let base = query(selector(metadata).after(thm.location(), inclusive: false)).first().value
      if base == () or base.theorem-kind in exclude { continue }
      if thm.value.toctitle != none {
        outline.entry(level, thm, [#base.supplement #base.number (#thm.value.toctitle)], fill, p)
        linebreak()
      }
    }
  }
}
