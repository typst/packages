#import "../core.typ": *
#import "../deps.typ": octique-inline, showybox

/// Global result configuration to control visibility of proofs and solutions
/// Modified by `#set-result("noanswer")`
/// - "answer": Show proofs and solutions (default)
/// - "noanswer": Hide proofs and solutions
#let (get-result, set-result) = use-state("theorion-result", "answer")

/// Global QED symbol configuration
/// Modified by `#set-qed-symbol(sym.square.stroked)`
/// Default is `sym.square`
#let (get-qed-symbol, set-qed-symbol) = use-state(
  "theorion-qed-symbol",
  sym.square,
)

/// Code from: https://github.com/nleanba/typst-theoretic
/// Thanks for @nleanba
/// Internal state: stack of pending QED symbols for nested proofs.
/// Each entry is either a content/symbol to display, or `none` if already placed.
#let _theorion-qed-stack = state("theorion-qed-stack", ())

/// Internal helper: format a QED symbol right-aligned at the end of a line.
#let _fmt-qed-inline(qed-symbol) = {
  h(1fr)
  box()
  h(1fr)
  sym.wj
  box(math.equation(qed-symbol, block: false))
  linebreak()
}

/// Recursively append the QED symbol to the end of body content.
/// Handles block equations (places QED as equation number), list/enum items
/// (recurses into last item), and regular content (appends inline).
#let _append-qed(body, qed-symbol) = {
  // fmt-qed checks whether the QED has already been placed via #qedhere
  let fmt-qed() = context {
    let stack = _theorion-qed-stack.get()
    if stack.len() > 0 and stack.last() != none {
      _fmt-qed-inline(qed-symbol)
    }
  }

  let _body = body
  if _body.has("children") and _body.children.len() > 0 {
    let candidate = _body.children.last()
    // Skip trailing space/empty content
    if candidate == [ ] {
      _body = body.children.slice(0, -1).join()
      if _body.has("children") {
        candidate = _body.children.last()
      }
    }
    if (
      candidate.func() == math.equation
        and candidate.block
        and math.equation.numbering == none
    ) {
      // Block equation at end: use equation numbering slot for QED.
      // math.equation.numbering returns the current styled value (from set rules),
      // so this correctly skips when global equation numbering is active.
      _body = {
        _body.children.slice(0, -1).join()
        // Use ".." to capture and ignore the variadic equation-number arguments
        set math.equation(numbering: (..) => fmt-qed(), number-align: bottom)
        candidate
        counter(math.equation).update(i => i - 1)
      }
    } else if candidate.func() == list.item or candidate.func() == enum.item {
      // List/enum: recurse into last item
      _body = {
        _body.children.slice(0, -1).join()
        candidate.func()(_append-qed(candidate.body, qed-symbol))
      }
    } else {
      _body = {
        _body
        fmt-qed()
      }
    }
  } else {
    if (
      _body.func() == math.equation
        and _body.block
        and math.equation.numbering == none
    ) {
      // Same equation treatment as above (single-element body case)
      _body = {
        // Use ".." to capture and ignore the variadic equation-number arguments
        set math.equation(numbering: (..) => fmt-qed(), number-align: bottom)
        _body
        counter(math.equation).update(i => i - 1)
      }
    } else if _body.func() == list.item or _body.func() == enum.item {
      _body = _body.func()(_append-qed(_body.body, qed-symbol))
    } else {
      _body = {
        _body
        fmt-qed()
      }
    }
  }

  // Pop the QED stack entry when body finishes rendering
  _body
  _theorion-qed-stack.update(old => {
    if old.len() > 0 { old.slice(0, -1) } else { old }
  })
}

/// Place the QED symbol at this position manually.
/// Use inside proof environments when the QED should appear at a specific location
/// (e.g., inside a list item or before additional remarks) rather than at the end.
///
/// -> content
#let qedhere = context {
  let stack = _theorion-qed-stack.get()
  if stack.len() > 0 and stack.last() != none {
    let qed-symbol = stack.last()
    _fmt-qed-inline(qed-symbol)
  }
  _theorion-qed-stack.update(old => {
    if old.len() > 0 {
      (..old.slice(0, -1), none) // Mark as placed to prevent double placement
    } else {
      old
    }
  })
}

/// Environment QED symbol like proof or solution
///
/// - qed (none, auto, symbol, content): Symbol to use for end of environment. Default is none
/// - render-fn (function): Function to render the environment. Default is `body => [#emph(theorion-i18n(title)).#sym.space#body]`
/// - body (content): Content of the environment
/// -> content
#let environment-with-qed(
  qed: auto,
  render-fn: (inset: (top: .3em, bottom: .3em), title, body) => context {
    block(
      width: 100%,
      inset: inset,
      indent-repairer[#emph(theorion-i18n(title)).#sym.space#body],
    )
    indent-fakepar
  },
  title,
  body,
) = {
  let qed-symbol = if qed == auto { get-qed-symbol(here()) } else { qed }
  // Push qed-symbol onto the stack before the body renders, so #qedhere can read it
  let push-qed = _theorion-qed-stack.update(old => (..old, qed-symbol))
  if qed-symbol != none {
    render-fn(title)[#push-qed#_append-qed(body, qed-symbol)]
  } else {
    render-fn(title, body)
  }
}

/// Create a proof environment with italic title and QED symbol
/// Can be hidden using `#set-result("noanswer")`
/// Uses global QED symbol set by `#set-qed-symbol()`
///
/// - title (auto, str, dictionary): Title text or dictionary for i18n. Default is auto
/// - qed (none, auto, symbol, content): Symbol to use for end of proof. Default is from global setting
/// - body (content): Content of the proof
/// -> content
#let proof(
  title: auto,
  qed: auto,
  ..args,
  body,
) = context if get-result(here()) == "noanswer" { none } else {
  let default-title = theorion-i18n-map.at("proof")
  let actual-title = if args.pos().len() > 0 and title == auto {
    args.pos().first()
  } else {
    if title == auto { default-title } else { title }
  }
  environment-with-qed(qed: qed, actual-title, body)
}

/// Create a solution environment with italic title and optional QED symbol
/// Can be hidden using `#set-result("noanswer")`
/// Uses global QED symbol set by `#set-qed-symbol()`
///
/// - title (auto, str, dictionary): Title text or dictionary for i18n. Default is auto
/// - qed (none, auto, symbol, content): Symbol to use for end of solution. Default is none
/// - body (content): Content of the solution
/// -> content
#let solution(
  title: auto,
  qed: none,
  ..args,
  body,
) = context if get-result(here()) == "noanswer" { none } else {
  let default-title = theorion-i18n-map.at("solution")
  let actual-title = if args.pos().len() > 0 and title == auto {
    args.pos().first()
  } else {
    if title == auto { default-title } else { title }
  }
  environment-with-qed(qed: qed, actual-title, body)
}

/// Create a conclusion environment with italic title and optional QED symbol
/// Can be hidden using `#set-result("noanswer")`
/// Uses global QED symbol set by `#set-qed-symbol()`
///
/// - title (auto, str, dictionary): Title text or dictionary for i18n. Default is auto
/// - qed (none, auto, symbol, content): Symbol to use for end of conclusion. Default is none
/// - body (content): Content of the conclusion
/// -> content
#let conclusion(
  title: auto,
  qed: none,
  ..args,
  body,
) = context if get-result(here()) == "noanswer" { none } else {
  let default-title = theorion-i18n-map.at("conclusion")
  let actual-title = if args.pos().len() > 0 and title == auto {
    args.pos().first()
  } else {
    if title == auto { default-title } else { title }
  }
  environment-with-qed(qed: qed, actual-title, body)
}

/// Create an emphasized block with yellow styling and dashed border
///
/// - body (content): Content of the block
/// -> content
#let emph-block(body, breakable: false) = context {
  // Main rendering
  let rendered = showybox(
    frame: (
      dash: "dashed",
      border-color: yellow.darken(30%),
      body-color: yellow.lighten(90%),
    ),
    sep: (dash: "dashed"),
    breakable: breakable,
    indent-repairer(body),
  )
  if "html" in dictionary(std) {
    // HTML rendering
    if target() == "html" {
      html.elem(
        "div",
        attrs: (
          style: "background: #FFFDEB; border: .1em dashed #E3C000; border-radius: .4em; padding: .25em 1em; width: 100%; box-sizing: border-box; margin: .5em 0em;",
        ),
        body,
      )
    } else {
      rendered
    }
  } else {
    rendered
  }
}

/// Create a quote block with start border styling in gray
///
/// - body (content): Content to be quoted
/// -> content
#let quote-block(..args, body) = context {
  // HTML rendering
  if "html" in dictionary(std) and target() == "html" {
    html.elem(
      "div",
      attrs: (
        style: "border-inline-start: .25em solid #C8C8C8; padding: .1em 1em; width: 100%; box-sizing: border-box; margin-bottom: .5em; color: #646464;",
      ),
      body,
    )
  } else {
    // Main rendering
    block(
      stroke: language-aware-start(.25em + luma(200)),
      inset: language-aware-start(1em) + (y: .75em),
      ..args,
      text(
        luma(100),
        indent-repairer(body),
      ),
    )
  }
}

/// Create a note block with customizable styling and icon
/// Base template for tip-block, important-block, warning-block, and caution-block
///
/// - fill (color): Color of the border and icon. Default is `rgb("#0969DA")`
/// - title (str, dictionary): Title text or dictionary for i18n. Default is "Note"
/// - icon-name (str): Name of the icon to display from octicons set
/// - body (content): Content of the note
/// -> content
#let note-block(
  fill: rgb("#0969DA"),
  title: theorion-i18n-map.at("note"),
  icon-name: "info",
  ..args,
  body,
) = context {
  let title-i18n = theorion-i18n(title)
  // HTML rendering
  if "html" in dictionary(std) and target() == "html" {
    html.elem(
      "div",
      attrs: (
        style: "border-inline-start: .25em solid "
          + fill.to-hex()
          + "; padding: .1em 1em; width: 100%; box-sizing: border-box; margin-bottom: .5em;",
      ),
      {
        html.elem(
          "p",
          attrs: (
            style: "margin-top: .5em; font-weight: bold; color: "
              + fill.to-hex()
              + "; display: flex; align-items: center;",
          ),
          html.elem(
            "span",
            attrs: (
              style: "display: inline-flex; align-items: center; justify-content: center; width: 1em; height: 1em; vertical-align: middle; margin: 0em .5em 0em 0em;",
            ),
            html.frame(octique-inline(
              height: 1.2em,
              width: 1.2em,
              color: fill,
              baseline: .2em,
              icon-name,
            )),
          )
            + title-i18n,
        )
        body
      },
    )
  } else {
    // Main rendering
    block(
      stroke: language-aware-start(.25em + fill),
      inset: language-aware-start(1em) + (top: .5em, bottom: .75em),
      width: 100%,
      ..args,
      {
        block(sticky: true, text(
          fill: fill,
          weight: "semibold",
          octique-inline(
            height: 1.2em,
            width: 1.2em,
            color: fill,
            baseline: .2em,
            icon-name,
          )
            + h(.5em)
            + title-i18n,
        ))
        indent-repairer(body)
      },
    )
  }
}

/// Create a tip block with green styling and light bulb icon
/// Useful for helpful suggestions and tips
#let tip-block = note-block.with(
  fill: rgb("#1A7F37"),
  title: theorion-i18n-map.at("tip"),
  icon-name: "light-bulb",
)

/// Create an important block with purple styling and report icon
/// Useful for highlighting key information
#let important-block = note-block.with(
  fill: rgb("#8250DF"),
  title: theorion-i18n-map.at("important"),
  icon-name: "report",
)

/// Create a warning block with amber styling and alert icon
/// Useful for potential issues or warnings
#let warning-block = note-block.with(
  fill: rgb("#9A6700"),
  title: theorion-i18n-map.at("warning"),
  icon-name: "alert",
)

/// Create a caution block with red styling and stop icon
/// Useful for serious warnings or dangerous situations
#let caution-block = note-block.with(
  fill: rgb("#CF222E"),
  title: theorion-i18n-map.at("caution"),
  icon-name: "stop",
)

/// Create a remark environment
///
/// - title (str, dictionary): Title text or dictionary for i18n. Default is "Remark"
/// - body (content): Content of the remark
/// -> content
#let remark-block = note-block.with(
  fill: rgb("#118D8D"),
  title: theorion-i18n-map.at("remark"),
  icon-name: "comment",
)
