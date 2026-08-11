/** base package functionality */

#let _qeds = state("_thm_qed_stack", ())

/// Place the QED mark last pushed to `state("_thm_qed_stack")` here.
///
/// Will be automatically called by theorems to place their suffix.
/// You should only need to call this in the rare situation that theoretic cannot place the qed in the correct position automatically.
/// (If this occurs, please let me know on GitHub or Typst Forum so I can try to fix it.)
///
/// #example(scale-preview: 90%, ```typ
/// #proof[
///   I want the QED on this line already.#qed()
///
///   There will be no QED on this line, even though this is still in the proof.
/// ]
/// ```)
///
/// -> content
#let qed(
  /// Optional.
  ///
  /// If provided, will ignore the `state("_thm_qed_stack")` and just place the given symbol here. Us this if you want to call it outside of a @proof or other theorem with suffix.
  ///
  /// #example(scale-preview: 90%, ```typ
  /// This is not inside a proof environment.#qed($triangle$)
  /// ```)
  /// -> content
  symbol,
) = { }
#let qed(..args) = {
  if args.pos().len() == 1 and args.named().len() == 0 {
    h(1fr)
    box()
    h(1fr)
    sym.wj
    box(args.pos().first())
    linebreak()
  } else if args.pos().len() == 0 and args.named().len() == 0 {
    context {
      let qeds = _qeds.get()
      if qeds.len() > 0 and qeds.last() != none {
        h(1fr)
        box()
        h(1fr)
        sym.wj
        box(qeds.last())
        linebreak()
      }
      _qeds.update(old => {
        if old.len() > 0 {
          let _ = old.pop()
          old.push(none)
        }
        return old
      })
    }
  } else {
    panic("unexpected arguments for qed()")
  }
}

/// Use this to place a QED in the (next) block equation.
/// Can be called either as with `#show: ` or simply by wrapping the block equation.
///
/// #example(scale-preview: 90%, ```typ
/// #import theoretic: qed-in-equation
/// #proof[
///   #show: qed-in-equation
///   $ x = y $
///   QED is above this line!
/// ]
/// #proof[
///   #qed-in-equation($ x = y $)
///   QED is above this line!
/// ]
/// ```)
#let qed-in-equation(rest) = {
  set math.equation(numbering: (..) => qed(), number-align: bottom)
  rest
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
    if _body.has("children") {
      let candidate = _body.children.last()
      if candidate == [ ] {
        _body = body.children.slice(0, -1).join()
        if _body.has("children") {
          candidate = _body.children.last()
        } // TODO: else ?
      }
      if candidate.func() == math.equation and candidate.block and math.equation.numbering == none {
        _body = {
          _body.children.slice(0, -1).join()
          set math.equation(numbering: (..) => { fmt-suffix() }, number-align: bottom)
          candidate
          counter(math.equation).update(i => { i - 1 })
        }
      } else if candidate.func() == enum.item or candidate.func() == list.item {
        _body = {
          _body.children.slice(0, -1).join()
          candidate.func()(_append-qed(candidate.body, fmt-suffix))
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
          set math.equation(numbering: (..) => { fmt-suffix() }, number-align: bottom)
          _body
          counter(math.equation).update(i => { i - 1 })
        }
      } else if _body.func() == enum.item or _body.func() == list.item {
        _body = {
          _body.func()(_append-qed(_body.body, fmt-suffix))
        }
      } else {
        _body = {
          _body
          fmt-suffix()
        }
      }
    }
  }
  return {
    _body
    _qeds.update(old => {
      if old.len() > 0 {
        old.pop()
      }
      return old
    })
  }
}

/// Counts theorems.
///
/// In most cases, it is not necessary to reset this manually, it will get updated accordingly if you pass an integer to @theorem.number.
/// -> counter
#let thm-counter = counter("_thm")

/// The default options per variant. "proof" is same as the last one ("remark"). Unknown variants inherit from the first one ("definition").
/// -> dictionary
#let _defaults = (
  definition: (
    head-font: (style: "normal", weight: "bold"),
    title-font: (weight: "regular"),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true),
    head-punct: [.],
    head-sep: h(0.5em),
    link: none,
  ),
  plain: (
    head-font: (style: "normal", weight: "bold"),
    title-font: (weight: "regular"),
    body-font: (style: "italic", weight: "regular"),
    block-args: (width: 100%, breakable: true),
    head-punct: [.],
    head-sep: h(0.5em),
    link: none,
  ),
  important: (
    head-font: (style: "normal", weight: "bold"),
    title-font: (weight: "regular"),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true, outset: 4pt, stroke: 0.5pt),
    head-punct: [.],
    head-sep: h(0.5em),
    link: none,
  ),
  remark: (
    head-font: (style: "italic", weight: "regular"),
    title-font: (:),
    body-font: (style: "normal", weight: "regular"),
    block-args: (width: 100%, breakable: true),
    head-punct: [.],
    head-sep: h(0.5em),
    link: none,
  ),
)

/// Used to fill the @show-theorem `it.options` with default values.
///
/// If you create your own `show-theorem` function, you should make sure to use this or something similar to handle unset options.
///
/// This function is intended for use _only_ when creating your own style, have a look at the columns style as to how this can be used.
///
/// Note: the output here depends on the chosen `variant`. Variants `plain`, `definition`, `remark` correspond to the respective amsthm styles if combined with the default @show-theorem.
/// Variant `important` is like `definition`, but with an added border.
#let fill-options(
  /// -> dictionary
  options,
  /// -> str
  variant: "plain",
  /// A dictionary containing the default values for each variant. If the variant passed is `proof`, it will fill using the last entry in this dictionary, otherwise if the variant passed is not a key of the dictionary, it will use the first one.
  /// -> dictionary
  _defaults: _defaults,
) = {
  let default = if variant in _defaults { variant } else { _defaults.keys().first() }
  if variant == "proof" { default = _defaults.keys().last() }

  for (key, value) in _defaults.at(default) {
    if type(value) == dictionary {
      options.insert(key, (:..value, ..options.at(key, default: (:))))
    } else {
      options.insert(key, options.at(key, default: value))
    }
  }

  return options
}

/// Default "show" function for theorems. Note that in your versions of this, you cannot use `it` to generate the default options, but you can fall back to `theoretic.show.theorem(it)`.
///
/// For your own style, make sure to always handle the "link" option, which will be set by @restate and @solutions and contains a link target for the supplement (to link to the original location).
#let show-theorem(
  /// A dictionary with keys:
  /// ```
  /// - supplement: content
  /// - number: content | none
  /// - title: content | none
  /// - body: content
  /// - variant: str
  /// - options: dictionary
  /// ```
  ///
  /// Note that the suffix (QED) is already added to the body at this point.
  ///
  /// Also, note that the variant is already used when filling the options dictionary with defaults.
  /// For the expected keys of `options`, see @theorem.options
  /// -> dictionary
  it,
) = {
  it.options = fill-options(it.options, variant: it.variant)
  block(
    ..it.options.block-args,
    {
      text(
        ..it.options.head-font,
        {
          if it.options.link != none {
            link(
              it.options.link,
              {
                it.supplement
                if it.number != none [ #it.number]
              },
            )
          } else {
            it.supplement
            if it.number != none [ #it.number]
          }
          if it.title != none {
            if it.variant == "proof" {
              text(..it.options.title-font)[ of #it.title]
            } else {
              text(..it.options.title-font)[ (#it.title)]
            }
          }
          it.options.head-punct
        },
      )
      it.options.head-sep
      text(..it.options.body-font, it.body)
    },
  )
}

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
///   of the hypotenuse squared is equal to the
///   sum of the squares of the remaining sides'
///   lengths.
/// ]
/// ```, scale-preview: 90%)
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
///   of the hypotenuse squared is equal to the
///   sum of the squares of the remaining sides'
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
/// ```, scale-preview: 90%) */
///
/// -> content
#let theorem(
  /// This function is used to show the actual theorem.
  /// I recommend looking at the code and documentation for the default @show-theorem to see how this would look.
  /// -> function
  show-theorem: show-theorem,
  /// Additional options that are passed to `show-theorem`.
  ///
  /// The default `show-theorem` handles the following keys:
  /// ```
  /// - head-font: dict     // options for the head text
  /// - title-font: dict    // title is placed inside the head
  /// - body-font: dict     // options for the body text
  /// - block-args: dict    // options for the block
  /// - head-punct: content // placed at the end of the head
  /// - head-sep: content   // placed after the head
  /// - link: none | (link target) // The target the head should link to.
  /// ```
  ///
  /// If you are using a custom `show-theorem`, you can also add other fields here.
  ///
  /// This will be filled with defaults depending on the `variant`.
  /// -> dictionary
  options: (:),
  /// This controls the defaults for `options`. It is also passed to `show-theorem`.
  /// -> str
  variant: "plain",
  /// Will be placed at the end of the theorem or where @qed is called.
  /// #example(```typ
  /// #theorem(suffix: sym.suit.spade)[...]
  /// #proof(
  ///   suffix: $limits(script(square))^arrow.zigzag$,
  /// )[Proof by contradiction!]
  /// ```, scale-preview: 90%)
  /// -> none | content
  suffix: none,
  /// Used for filtering e.g. when creating table of theorems.
  /// -> string
  kind: "theorem",
  /// What to label the environment.
  ///
  /// It is recommended to keep `kind` and `supplement` matching (except for "subtypes", e.g. one might have the kind of "Example" and "Counter-Example" both as ```typc "example"```)
  /// -> content
  supplement: "Theorem",
  ///- If ```typc auto```, will continue numbering from last numbered theorem.
  ///- If #type("integer"), it will continue the numbering of later theorems from the given number.
  ///- If #type("content"), it is shown as-is, with no side-effects.
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
  /// ```, scale-preview: 90%)
  /// -> auto | none | integer | content
  number: auto,
  /// Title of the Theorem. Usually shown in parentheses after the number.
  ///
  /// _This can also be passed as apositional argument._
  /// -> none | content
  title: none,
  /// Title of the Theorem to be used in outlines.
  ///
  /// - ```typc auto``` to use the `title`.
  /// - ```typc none``` to hide it from the outlines.
  ///
  /// If you pass an array, in _sorted_ outlines (@toc.sort) it will be split into multiple entries.
  /// All but the first one are marked as secondary.
  ///
  /// #example(scale-preview: 90%, ```typ
  /// #theorem(
  ///   title: [A to Z],
  ///   toctitle: ([AAAAA], [ZZZZZZ])
  /// )[
  ///   Compare how this appears in different outlines!
  /// ]
  /// ```)
  /// -> auto | none | content | array
  toctitle: auto,
  /// Label (for references)
  ///
  /// _This can also be passed as a positional argument. In that case it must be a `label` and not a `string`._
  ///
  /// NB: Simply putting a ```typ <label>``` after the ```typ #theorem[]``` does not work for referencing.
  /// -> none | label | string
  label: none,
  /// #parbreak()
  /// Optional Solution.  See also @solutions.
  ///
  /// #example(```typ
  /// #theorem(solution: [This will show up wherever `#theoretic.solutions()` is placed.])[#lorem(5)]
  /// ```, scale-preview: 90%)
  /// -> none | content
  solution: none,
  /// The last positional argument given is used as the theorem body.
  ///
  /// Other positional arguments are used for the title and label, depending on their type.
  /// #example(```typ
  /// // Any of these work:
  /// #theorem(<positional>)[Positional][#lorem(4)]
  /// #theorem(label: <named>, title: [Named])[#lorem(4)]
  /// #theorem([Mixed], label: <mixed>)[#lorem(4)]
  /// ```, scale-preview: 90%)
  /// -> arguments
  ..unnamed-and-body,
) = {
  // let number = number
  // if number == auto and label == none and title == none { number = none }

  let body = unnamed-and-body.pos().last()

  let title = if title != none {
    title
  } else if unnamed-and-body.pos().len() > 1 {
    unnamed-and-body.pos().find(p => type(p) == content or type(p) == str)
  } else {
    none
  }

  let label = if label != none {
    if type(label) == std.label {
      label
    } else {
      std.label(label)
    }
  } else if unnamed-and-body.pos().len() > 1 {
    unnamed-and-body.pos().find(p => type(p) == std.label)
  } else {
    none
  }

  let toctitle = if toctitle == auto { title } else { toctitle }

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
  _qeds.update(old => {
    old.push(suffix)
    return old
  })
  context {
    let thmnr = thm-counter.display("1")
    let number = number
    if number == auto or type(number) == int {
      if heading.numbering == none {
        number = thmnr
      } else {
        let h = counter(heading).get().first()
        let h_fmt = numbering(heading.numbering, h)
        if type(h_fmt) == str {
          h_fmt = h_fmt.trim(".", at: end)
        }
        number = {
          h_fmt
          "."
          thmnr
        }
      }
    }
    [#metadata((body: body, solution: solution, toctitle: toctitle))<_thm>]
    [#metadata((
        show-theorem: show-theorem,
        options: options,
        variant: variant,
        suffix: suffix,
        theorem-kind: kind,
        supplement: supplement,
        number: number,
        title: title,
      ))#label]

    show-theorem((
      supplement: supplement,
      number: number,
      title: title,
      body: _append-qed(body, qed),
      variant: variant,
      options: options,
    ))
  }
}

/// This is simply @theorem with different options.
/// -> function
#let proof = (
  // needs to be on next line because otherwise it fails to handle the currying.
  theorem.with(
    variant: "proof",
    suffix: sym.qed,
    supplement: "Proof",
    kind: "proof",
    number: none,
  )
)

/// Re-state a theorem.
///
/// It will reuse the original kind, supplement, number, title, body, and styling.
/// It will _not_ re-emit the solution or label, and it will use `toctitle: none` to avoid duplicate toc entries.
///
/// #example(```typ
/// #let proposition = theorem.with(
///   kind: "proposition",
///   supplement: "Proposition",
///   options: (
///     head-font: (fill: blue),
///   )
/// )
/// #proposition(<funky>)[Funky!][Blah _blah_ blah.]
/// Restated:
/// #restate("funky")
/// Restated with added customizations:
/// #restate(<funky>, options: (body-font: (fill: red)))
/// ```, scale-preview: 90%);
/// -> content
#let restate(
  /// Label of the theorem to restate.
  /// -> label | string
  label,
  /// Override arguments for the theorem function.
  ///
  /// (I don’t recommend changing anything here except possibly `show-theorem` and `options`.)
  ..args,
) = context {
  let label = label
  if type(label) == str { label = std.label(label) }
  let original = query(label)
  if original.len() != 1 { panic("Cannot restate non-unique or non-existent label.") }
  original = original.first()
  let base = query(selector(metadata).before(original.location(), inclusive: false)).last().value
  original = original.value
  let options = (..original.options, ..args.named().at("options", default: (:)), link: label)
  theorem(
    show-theorem: original.show-theorem,
    suffix: original.suffix,
    kind: original.theorem-kind,
    variant: original.variant,
    supplement: original.supplement,
    number: original.number,
    title: original.title,
    base.body,
    toctitle: none,
    ..args, // spread before options in case args.options is set
    options: options,
  )
}

/// Show-rule-function to be able to ```typ @``` labelled theorems.
///
/// Use via \````typ #show ref: show-ref```\` at the beginning of your document.
///
/// #example(```typ
/// >>> // #thm-counter.update(0)
/// >>> // #set heading(numbering: "1.1.")
/// #show ref: theoretic.show-ref
/// #theorem(label: <fact>, supplement: "Fact")[#lorem(2)]
/// #theorem(<pythagoras>, "Pythagoras")[#lorem(2)]
/// #theorem(label: <zl>, title: "Only Named", number: none)[#lorem(2)]
/// #theorem(label: <y>, number: "Y")[#lorem(2)]
/// #theorem(label: "5", number: none)[#lorem(2)]
///
/// As a consequence of @fact and @pythagoras[!!]...
/// ```, scale-preview: 90%)
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
  if (
    el != none
      and el.func() == metadata
      and type(el.value) == dictionary
      and el.value.at("theorem-kind", default: none) != none
  ) {
    let val = el.value
    if it.supplement == [?] {
      link(it.target, [#val.supplement])
    } // else if it.supplement == [-] {
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
      if (
        it.supplement == [-]
          or it.supplement == [!]
          or it.supplement == [!!]
          or it.supplement == [!!!]
          or it.supplement == auto
      ) {
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
      if (
        it.supplement == [-]
          or it.supplement == [--]
          or it.supplement == [!]
          or it.supplement == [!!]
          or it.supplement == [!!!]
          or it.supplement == auto
      ) {
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
/// Should not be used more than once in a document, as this might break links.
///
/// See @_thm_solutions for how it looks.
/// -> content
#let solutions(
  /// Title/heading to use.
  /// -> content
  title: "Solutions",
  /// Which theorem function to use for the solutions.
  /// -> function
  theorem-function: theorem,
  /// Supplement to use for the solution theorems. Change this e.g. for localization.
  /// -> content
  supplement: "Solution",
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
      theorem-function(
        kind: "solution",
        supplement: supplement,
        number: none,
        link(sol.location(), target),
        sol.value.solution,
      )
    }
  } else {
    [#metadata("No solutions. Should not link here.")<_thm_solutions>]
  }
}

/// internal helper
/// -> string
#let _to-string(
  /// -> content
  content,
) = {
  if content == none {
    ""
  } else if type(content) == str {
    content
  } else if type(content) == array {
    content.map(_to-string).join(", ")
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    if content.children.len() == 0 {
      ""
    } else {
      content.children.map(_to-string).join("")
    }
  } else if content.has("child") {
    _to-string(content.child)
  } else if content.has("body") {
    _to-string(_to-string(content.body))
  } else if content == [] {
    ""
  } else if content == [ ] {
    " "
  } else if content.func() == ref {
    "_ref_"
  } else {
    let offending = content
    ""
  }
}

/// Create a toc entry.
///
/// Pass this to @toc using `.with(..)` to customize the `fmt-` parameters used.
///
/// This is used because since Typst 0.13, it is no longer possible to call outline.entry outside of an actual ourline element, and one "cannot outline metadata".
///
/// This manual uses
/// //#example(scale-preview: 90%,
/// #block(radius: 3pt, stroke: .5pt + luma(200), inset: 5pt, width: 100%, {
/// set text(size: 0.9em)
/// ```typc
/// set par(justify: false)
/// let indents = (0pt, 15pt, 37pt)
/// let hang-indents = (15pt, 22pt, 54pt)
/// let text-styles = ((weight: 700), (size: 10pt), (size: 9pt, weight: 500), (size: 9pt, fill: luma(20%)), )
/// theoretic.toc(toc-entry: theoretic.toc-entry.with(
///   indent: (level) => { indents.at(level - 1) },
///   hanging-indent: (level) => { hang-indents.at(level - 1) },
///   fmt-prefix: (prefix, level, _s) => {
///     set text(..text-styles.at(level - 1), number-width: "tabular")
///     prefix
///     h(4pt)
///   },
///   fmt-body: (body, level, _s) => {
///     set text(..text-styles.at(level - 1))
///     body
///   },
///   fmt-fill: (level, _s) => {
///     if level == 2 {
///       set text(..text-styles.at(2))
///       box(width: 1fr, align(right, repeat(gap: 9pt, justify: false, [.])))
///     }
///   },
///   fmt-page: (page, level, _s) => {
///     set text(..text-styles.at(level - 1), number-width: "tabular")
///     box(width: 18pt, align(right, [#page]))
///   },
///   above: (level) => {
///     if level == 1 {
///       auto // paragraph spacing
///     } else {
///       7pt
///     }
///   },
///   below: auto,
/// ))
/// ```})
#let toc-entry(
  /// -> int
  level,
  /// -> location
  target,
  /// -> content | none
  prefix,
  /// -> content
  body,
  /// -> content
  page,
  /// This is `true` for entries where the toc-title is an array, the entry was split and this is _not_ the first one (in order specified).
  /// -> boolean
  secondary: false,
  /// How much to indent each entry.
  ///
  /// - If #type("relative length"), it will be multiplied with level - 1.
  /// - If #type("function"), will be called with the level as argument.
  /// -> relative length | function
  indent: 1em,
  /// How much more to indent subsequent lines (in addition th @toc-entry.indent).
  ///
  /// If the prefix is shorter than this, this will lead to a gap between prefix and body;
  /// If the prefix is longer, the body will start immediately after the prefix.
  ///
  /// // In both cases subsequent lines of the body are indented by the given amount _plus_ the indent
  ///
  /// - If #type("function"), will be called with the level as argument.
  /// - If ```typc auto```, will use the width of the prefix
  ///
  /// #example(scale-preview: 90%, ```typ
  /// >>> #show link: it => { show underline: ul => { ul.body }; it }
  /// >>> #context[
  /// #let example-entry = theoretic.toc-entry.with(1, here(), [Section 1.], lorem(6), [0])
  /// #let example-entry-2 = theoretic.toc-entry.with(2, here(), [Section 1.1.], lorem(6), [0])
  ///
  /// // aligned with end of prefix
  /// #example-entry(hanging-indent: auto)
  /// #example-entry-2(hanging-indent: auto)
  ///
  /// #example-entry(hanging-indent: 1em)
  /// #example-entry-2(hanging-indent: 1em)
  /// #example-entry(hanging-indent: 80pt)
  /// #example-entry-2(hanging-indent: 80pt)
  /// >>> ]
  /// ```)
  /// -> relative length | function | auto
  hanging-indent: auto,
  /// If #type("function"), will be called with the level as argument.
  /// -> relative length | function
  above: 0.7em,
  /// If #type("function"), will be called with the level as argument.
  /// -> relative length | function
  below: 0.7em,
  /// -> function
  fmt-prefix: (prefix, level, secondary) => if prefix != none {
    prefix
    h(0.5em, weak: false)
  },
  /// -> function
  fmt-body: (body, level, secondary) => if secondary [(#body) ] else [#body ],
  /// -> function
  fmt-fill: (level, secondary) => box(width: 1fr, repeat[.~]),
  /// -> function
  fmt-page: (page, level, secondary) => page,
) = {
  let indent = if type(indent) == function { indent(level) } else { indent * (level - 1) }
  let prefix = fmt-prefix(prefix, level, secondary)
  let width = measure(prefix).width

  let hanging-indent = if hanging-indent == auto {
    width
  } else if type(hanging-indent) == function {
    measure(h(hanging-indent(level))).width
  } else {
    measure(h(hanging-indent)).width
  }
  if width <= hanging-indent { width = hanging-indent }
  let above = if type(above) == function { above(level) } else { above }
  let below = if type(below) == function { below(level) } else { below }
  block(
    width: 100%,
    above: above,
    below: below,
    inset: (left: indent),
    {
      link(
        target,
        {
          h(hanging-indent)
          box(
            width: 1fr,
            {
              box(
                width: width,
                {
                  h(-hanging-indent)
                  prefix
                },
              )
              h(-hanging-indent)
              fmt-body(body, level, secondary)
              fmt-fill(level, secondary)
            },
          )
          fmt-page(page, level, secondary)
        },
      )
    },
  )
}

/// Helper function to adapt actual outlines to look the same as those made with @toc.
/// This is useful if you want to have e.g. a list of figures and a list of definitions and want them to share their style.
///
/// Note: For typst versions <= 0.12, this function is a bit "hacky" and might not always work.
/// (It deconstructs the `outline.entry` based on heuristics.)
///
/// #example(scale-preview: 90%, ```typ
/// #import theoretic: show-entry-as, toc-entry
///
/// #outline(target: figure, title: [Typst Default])
///
/// #show outline.entry: show-entry-as(toc-entry.with(hanging-indent: 60pt, /*...*/))
/// >>> #show link: it => { show underline: ul => { ul.body }; it }
/// #outline(target: figure, title: [Using `theoretic.toc-entry`])
///
/// #figure(
///   caption: [Example Figure],
///   block(height: 2em, width: 100%, fill: gradient.linear(..color.map.viridis))
/// )
/// ```)
#let show-entry-as(
  /// Customize @toc-entry used.
  ///
  /// Expects a function taking five positional arguments (level, target, prefix, body, page).
  /// -> function
  toc-entry,
) = {
  entry => context {
    if sys.version >= version(0, 13, 0) {
      toc-entry(
        entry.level,
        entry.element.location(),
        entry.prefix(),
        entry.body(),
        entry.page(),
      )
    } else {
      if entry.body.has("children") {
        let index = array(entry.body.children).position(s => regex("\d|^[A-z]$") in _to-string(s))
        if entry.body.children.len() > index + 1 and regex("^:\s*$") in _to-string(entry.body.children.at(index + 1)) {
          index = index + 1
        }
        let prefix = if index != none { entry.body.children.slice(0, index + 1).join() } else { none }
        let body = if index != none { entry.body.children.slice(index + 1).join() } else { entry.body }
        toc-entry(
          entry.level,
          entry.element.location(),
          prefix,
          body,
          entry.page,
        )
      } else {
        toc-entry(
          entry.level,
          entry.element.location(),
          none,
          entry.body,
          entry.page,
        )
      }
      v(-1em)
    }
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
///  ```, scale-preview: 90%)
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
  /// -> array (string)
  exclude: ("proof", "solution"),
  /// Fake level to use for theorems. If `auto`, it will use `depth + 1`.
  /// -> integer | auto
  level: auto,
  /// Customize @toc-entry used.
  ///
  /// Expects a function taking five positional arguments (level, target, prefix, body, page).
  /// -> function
  toc-entry: toc-entry,
  /// Whether to sort the entries alphabetically.
  ///
  /// Only respected if `depth` is 0.
  ///
  /// If true, this will also split entries where `toctitle` is an array into separate entries.
  ///
  /// #example(```typ
  ///  #theorem("Z")[Blah blah.]
  ///  #theorem("A")[Blah blah.]
  ///  #heading(outlined: false, level: 3)[
  ///    Sorted Table of Theorems
  ///  ]
  ///  #set text(size: 9pt)
  ///  #toc(
  ///    depth: 0,
  ///    sort: true,
  ///    toc-entry: toc-entry.with(hanging-indent: 60pt),
  ///  )
  ///  ```, scale-preview: 90%)
  /// -> bool
  sort: false,
) = context {
  let level = if level == auto { depth + 1 } else { level }
  let thms = query(selector(<_thm>).or(heading))
  if depth == 0 and sort {
    thms = array(thms)
      .filter(thm => {
        thm.func() != heading and thm.value.toctitle != none
      })
      .map(thm => {
        if type(thm.value.toctitle) == array {
          let x = thm.value.toctitle.map(title => {
            (loc: thm.location(), value: (toctitle: title, secondary: true))
          })
          x.at(0).value.secondary = false
          x
        } else { (loc: thm.location(), value: (toctitle: thm.value.toctitle)) }
      })
      .flatten()
      .sorted(
        key: thm => {
          _to-string(thm.value.toctitle)
        },
      )
    let len = thms.len()
  }
  for thm in thms {
    let loc = if type(thm) == dictionary { thm.loc } else { thm.location() }
    let pn = loc.page-numbering()
    let p = if pn != none {
      numbering(pn, ..counter(page).at(loc))
    } else {
      numbering("1", ..counter(page).at(loc))
    }
    if type(thm) != dictionary and thm.func() == heading {
      let level = thm.level
      if level > depth or thm.outlined == false { continue }
      let number = none
      if thm.numbering != none {
        number = numbering(thm.numbering, ..counter(heading).at(loc))
      }
      // outline.entry(level, thm, [#number #thm.body], fill, p)
      // linebreak()
      toc-entry(level, loc, number, thm.body, p)
      // outline.entry(level, thm)
    } else {
      let base = query(selector(metadata).after(loc, inclusive: false)).first().value
      if base == () or base.theorem-kind in exclude { continue }
      if type(thm.value.toctitle) == array {
        toc-entry(level, loc, [#base.supplement #base.number], thm.value.toctitle.join(" / "), p)
      } else if thm.value.toctitle != none {
        toc-entry(
          level,
          loc,
          [#base.supplement #base.number],
          thm.value.toctitle,
          p,
          secondary: thm.value.at("secondary", default: false),
        )
      }
    }
  }
}
