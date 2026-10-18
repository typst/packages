/// Numera provides composable numbering functions for figures and equations.
///
/// A Numera numbering function accepts `(ref: false, ..nums)`: `ref` is
/// `false` while rendering an element and `true` while rendering a reference.

#let equate-sub-numbering-state = state("equate/sub-numbering", false)

#let counting-symbols = "1aAiIαΑ一壹あいアイא가ㄱ*١۱१১ক①⓵"
#let non-counting = "[^" + counting-symbols + "]"
#let pattern = regex("^" + non-counting + "*(.*?)" + non-counting + "*$")

/// Removes non-counting symbols from the beginning and end of a numbering
/// pattern.
///
/// #test(`numera.trim-numbering("(1.a)") == "1.a"`)
///
/// -> str
#let trim-numbering(
  /// The numbering pattern to trim.
  /// -> str
  s,
) = s.match(pattern).captures.at(0)

#let counting-pattern = regex("[" + counting-symbols + "]")

/// Returns the number of counting symbols in a numbering pattern.
///
/// #test(`numera.count-counting-symbols("1.a") == 2`)
///
/// -> int
#let count-counting-symbols(
  /// The numbering pattern to inspect.
  /// -> str
  s,
) = s.matches(counting-pattern).len()

/// Produces a numbering pattern/function that trims numbering patterns if `(ref: true)` is passed.
///
/// -> none | str | function
#let patch-numbering(
  /// The numbering pattern or function to adapt, or `none`.
  /// -> none | str | function
  the-numbering,
  /// Whether the result will render a reference.
  /// -> bool
  ref: false,
) = {
  if the-numbering == none {
    none
  } else if type(the-numbering) == str {
    if ref {
      trim-numbering(the-numbering)
    } else {
      the-numbering
    }
  } else {
    the-numbering.with(ref: ref)
  }
}

/// Produces a numbering that trims numbering patterns if `(ref: true)` is passed.
///
/// -> content
#let my-numbering(
  /// The numbering pattern or function to render.
  /// -> str | function
  the-numbering,
  /// Whether the result will render a reference.
  /// -> bool
  ref: false,
  /// The counter components passed to the numbering.
  /// -> int
  ..nums,
) = {
  numbering(patch-numbering(the-numbering, ref: ref), ..nums)
}

/// Gets the active numbering pattern or function for an element at `here()`.
///
/// -> none | str | function
#let get-numbering(
  /// The element function or selector whose numbering should be read.
  /// -> function | selector
  target,
  /// Whether the result will render a reference.
  /// -> bool
  ref: false,
) = {
  patch-numbering(
    query(selector(target).before(here()))
      .last(default: (numbering: none))
      .numbering,
    ref: ref,
  )
}

/// Displays numbering for `target` with truncated counter to `max-level`.
///
/// -> none | content
#let display-numbering(
  /// The element function or selector whose counter should be displayed.
  /// -> function | selector
  target,
  /// The maximum number of counter components to display.
  /// -> int
  max-level,
  /// Whether the result will render a reference.
  /// -> bool
  ref: false,
) = {
  let the-numbering = get-numbering(target, ref: ref)
  if the-numbering == none or max-level == 0 {
    return none
  }
  counter(target).display((..nums) => my-numbering(
    the-numbering,
    ..nums.pos().slice(0, calc.min(max-level, nums.pos().len())),
    ref: ref,
  ))
}

/// Selects figures of kind `image`, `table`, or `raw`, excluding subfigures.
///
/// -> selector
#let normal-figure = (
  figure
    .where(kind: image)
    .or(figure.where(kind: table))
    .or(figure.where(kind: raw))
)

/// Returns the counter of the `normal-figure` containing this `figure.where(kind: "subfigure")` or `none` when applied to the location of a `normal-figure`.
///
/// -> none | array
#let outer-figure-counter-value() = (
  if (
    query(selector(figure).before(here())).last().kind == "subfigure"
  ) {
    query(selector(normal-figure).before(here())).last().counter.get()
  } else {
    none
  }
)

/// Returns a numbering function that joins the heading counter, truncated to
/// `max-level`, and the element numbering with `separator`.
/// Use `heading-format: "reference"` to omit heading punctuation from both
/// captions and references (the default). `"display"` preserves existing behavior:
/// heading punctuation appears on elements and is trimmed in references.
/// Put the joining punctuation in `separator`, not in the element pattern;
/// for example, use `"1"` rather than `".1"`.
///
/// -> function
#let heading-dependent(
  /// The maximum number of heading counter components to include.
  /// -> int
  max-level,
  /// The numbering pattern or function for the element's own counter.
  /// -> str | function
  the-numbering,
  /// Text inserted between the heading and element numberings.
  /// -> str
  separator: ".",
  /// The heading format: `"display"` follows the element/reference context;
  /// `"reference"` always uses the heading's reference numbering. For function
  /// numberings, this passes `ref: true`; string patterns lose outer punctuation.
  /// -> str
  heading-format: "reference",
) = {
  assert(
    heading-format in ("display", "reference"),
    message: "`heading-format` must be \"display\" or \"reference\"",
  )
  (ref: false, ..nums) => {
    let the-heading = display-numbering(
      heading,
      max-level,
      ref: ref or heading-format == "reference",
    )
    if the-heading != none {
      the-heading += separator
    }
    (
      the-heading + my-numbering(the-numbering, ref: ref, ..nums)
    )
  }
}

/// Returns a numbering function that uses the first numbering for non-`ref` numberings and the second numbering for `ref` numberings.
///
/// -> function
#let ref-dependent(
  /// The numbering pattern or function used on the numbered element.
  /// -> str | function
  inline-numbering,
  /// The numbering pattern or function used in references.
  /// -> str | function
  ref-numbering,
) = {
  (
    ref: false,
    ..nums,
  ) => {
    if ref {
      my-numbering(ref-numbering, ref: ref, ..nums)
    } else {
      my-numbering(inline-numbering, ref: ref, ..nums)
    }
  }
}

/// Returns a numbering function that uses the first numbering for `figure.where(kind: "subfigure")` and, if provided, the second numbering for `normal-figure`. Use `figure-numbering: auto` to use the same numbering for `normal-figure`. Does NOT add the parent figure number for subfigures!
///
/// -> function
#let subfigure-dependent(
  /// The numbering pattern or function used for subfigures.
  /// -> str | function
  subfigure-numbering,
  /// The normal-figure numbering, `auto` to reuse `subfigure-numbering`, or
  /// `none` when the returned function is used only for subfigures.
  /// -> auto | none | str | function
  figure-numbering: none,
) = {
  (
    ref: false,
    ..nums,
  ) => {
    if outer-figure-counter-value() == none {
      // figure
      assert(
        figure-numbering != none,
        message: "`subfigure-dependent` used for `normal-figure` numbering, either filter with `.where(kind: \"subfigure\")` or provide `figure-numbering` argument to `subfigure-dependent`",
      )
      my-numbering(
        if figure-numbering == auto { subfigure-numbering } else {
          figure-numbering
        },
        ref: ref,
        ..nums,
      )
    } else {
      // subfigure
      my-numbering(subfigure-numbering, ref: ref, ..nums)
    }
  }
}

/// Returns a numbering function that uses the first numbering for `figure.where(kind: "subfigure")` and, if provided, the second numbering for `normal-figure`. Use `figure-numbering: auto` to use the same numbering for `normal-figure`. ADDS the parent figure number for subfigures!
///
/// -> function
#let subfigure-counter-dependent(
  /// The numbering pattern or function used for subfigures.
  /// -> str | function
  subfigure-numbering,
  /// The normal-figure numbering, `auto` to reuse `subfigure-numbering`, or
  /// `none` when the returned function is used only for subfigures.
  /// -> auto | none | str | function
  figure-numbering: none,
) = {
  (
    ref: false,
    ..nums,
  ) => {
    let outer-figure-counter = outer-figure-counter-value()
    if outer-figure-counter == none {
      // figure
      assert(
        figure-numbering != none,
        message: "`subfigure-counter-dependent` used for `normal-figure` numbering, either filter with `.where(kind: \"subfigure\")` or provide `figure-numbering` argument to `subfigure-counter-dependent`",
      )
      my-numbering(
        if figure-numbering == auto { subfigure-numbering } else {
          figure-numbering
        },
        ref: ref,
        ..nums,
      )
    } else {
      // subfigure
      my-numbering(
        subfigure-numbering,
        ref: ref,
        ..outer-figure-counter,
        ..nums,
      )
    }
  }
}

/// Returns a numbering function that concatenates other Numera numbering
/// functions.
///
/// -> function
#let concat(
  /// The numbering functions to concatenate.
  /// -> function
  ..numberings,
) = {
  (
    ref: false,
    ..nums,
  ) => {
    numberings.pos().map(numbering-fn => numbering-fn(ref: ref, ..nums)).join()
  }
}

/// Returns a numbering function that produces the provided string for non-`ref` uses and an empty string otherwise.
///
/// #test(
///   `numera.non-ref("(")(ref: false) == "("`,
///   `numera.non-ref("(")(ref: true) == ""`,
/// )
///
/// -> function
#let non-ref(
  /// The text to emit on the numbered element.
  /// -> str
  string,
) = {
  (
    ref: false,
    ..nums,
  ) => {
    if ref {
      ""
    } else {
      string
    }
  }
}

/// Returns a numbering function that produces the provided string for `ref` uses and an empty string otherwise.
///
/// #test(
///   `numera.ref-only("(")(ref: false) == ""`,
///   `numera.ref-only("(")(ref: true) == "("`,
/// )
///
/// -> function
#let ref-only(
  /// The text to emit in references.
  /// -> str
  string,
) = {
  (
    ref: false,
    ..nums,
  ) => {
    if ref {
      string
    } else {
      ""
    }
  }
}

#let link-ref(it, counter, render) = {
  let here = here()
  let location = it.element.location()
  assert(
    here != location,
    message: "cannot reference an element from its own location",
  )
  let rendered = counter.display(render, at: location)
  let result = if it.element.supplement in ([], none) {
    rendered
  } else {
    [#it.element.supplement~#rendered]
  }
  link(location, result)
}

/// Resets the equation and figure counters at the specified heading level.
/// Level 0 means not resetting at all. Resets the subfigure counter for each
/// normal figure and renders references with `ref: true`.
/// Subfigures keep their configured supplement; they do not automatically
/// inherit the parent figure's supplement. Set an explicit supplement for
/// `kind: "subfigure"` with
/// `show figure.where(kind: "subfigure"): set figure(supplement: [Figure])`.
/// Use `none` to omit it.
///
/// -> function
#let numera(
  /// The heading level at which counters reset, or `0` for no resets.
  /// -> int
  level: 0,
) = it => {
  show heading: it => {
    if it.level <= level {
      counter(math.equation).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
    }
    it
  }

  show normal-figure: outer => {
    counter(figure.where(kind: "subfigure")).update(0)

    outer
  }

  // imitates default show rule but passes (ref: true) to numbering
  show ref: it => {
    if it.element == none or it.element.func() != math.equation { return it }
    link-ref(it, counter(math.equation), patch-numbering(
      it.element.numbering,
      ref: true,
    ))
  }

  // imitates default show rule but passes (ref: true) to numbering
  show ref: it => {
    if it.element == none or it.element.func() != figure { return it }
    if it.element.kind not in (image, table, raw, "subfigure") { return it }
    link-ref(it, it.element.counter, patch-numbering(
      it.element.numbering,
      ref: true,
    ))
  }

  // equate compatibility for (ref: true) and correct location context
  // TODO upstream the display(at: ) as that should already fix quite a bit.
  // or rather try refactoring upstream so the numbering function can retrieve this value.
  show ref: it => {
    if it.element == none or it.element.func() != figure { return it }
    if it.element.kind != math.equation { return it }
    if it.element.body == none or it.element.body.func() != metadata {
      return it
    }
    let nums = if equate-sub-numbering-state.at(it.element.location()) {
      it.element.body.value
    } else {
      (
        it.element.body.value.first()
          + it.element.body.value.slice(1).sum(default: 1)
          - 1,
      )
    }
    assert(
      it.element.numbering != none,
      message: "cannot reference equation without numbering.",
    )
    link-ref(it, it.element.counter, (..) => numbering(
      patch-numbering(it.element.numbering, ref: true),
      ..nums,
    ))
  }

  it
}
