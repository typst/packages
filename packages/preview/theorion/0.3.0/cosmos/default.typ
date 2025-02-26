#import "../core.typ": *
#import "../deps.typ": showybox, octique-inline

/// Global result configuration to control visibility of proofs and solutions
/// Modified by `#set-result("noanswer")`
/// - "answer": Show proofs and solutions (default)
/// - "noanswer": Hide proofs and solutions
#let (get-result, set-result) = use-state("theorion-result", "answer")

/// Global QED symbol configuration
/// Modified by `#set-qed-symbol(sym.square.stroked)`
/// Default is `sym.square`
#let (get-qed-symbol, set-qed-symbol) = use-state("theorion-qed-symbol", sym.square)

/// Create an example environment with italic title
///
/// - title (string|dict): Title text or dictionary for i18n. Default is "Example"
/// - body (content): Content of the example
/// -> content
#let example(
  title: theorion-i18n-map.at("example"),
  body,
) = [#emph(theorion-i18n(title)).#sym.space#body]


/// Create a problem environment with italic title
///
/// - title (string|dict): Title text or dictionary for i18n. Default is "Problem"
/// - body (content): Content of the problem
/// -> content
#let problem(
  title: theorion-i18n-map.at("problem"),
  body,
) = [#emph(theorion-i18n(title)).#sym.space#body]

/// Create a solution environment with italic title
/// Can be hidden using #set-result("noanswer")
///
/// - title (string|dict): Title text or dictionary for i18n. Default is "Solution"
/// - body (content): Content of the solution
/// -> content
#let solution(
  title: theorion-i18n-map.at("solution"),
  body,
) = context if get-result(here()) == "noanswer" { none } else [#emph(theorion-i18n(title)).#sym.space#body]

/// Create a conclusion environment with italic title
///
/// - title (string|dict): Title text or dictionary for i18n. Default is "Conclusion"
/// - body (content): Content of the conclusion
/// -> content
#let conclusion(
  title: theorion-i18n-map.at("conclusion"),
  body,
) = [#emph(theorion-i18n(title)).#sym.space#body]

/// Create an exercise environment with italic title
///
/// - title (string|dict): Title text or dictionary for i18n. Default is "Exercise"
/// - body (content): Content of the exercise
/// -> content
#let exercise(
  title: theorion-i18n-map.at("exercise"),
  body,
) = [#emph(theorion-i18n(title)).#sym.space#body]

/// Create a proof environment with italic title and QED symbol
/// Can be hidden using #set-result("noanswer")
/// Uses global QED symbol set by #set-qed-symbol()
///
/// - title (string|dict): Title text or dictionary for i18n. Default is "Proof"
/// - qed (symbol): Symbol to use for end of proof. Default is from global setting
/// - body (content): Content of the proof
/// -> content
#let proof(
  title: theorion-i18n-map.at("proof"),
  qed: auto,
  body,
) = context if get-result(here()) == "noanswer" { none } else {
  let qed-symbol = if qed == auto { get-qed-symbol(here()) } else { qed }
  [#emph(theorion-i18n(title)).#sym.space#body#box(width: 0em)#h(1fr)#sym.wj#sym.space.nobreak$#qed-symbol$]
}

/// Create an emphasized box with yellow styling and dashed border
///
/// - body (content): Content of the box
/// -> content
#let emph-box(body) = {
  showybox(
    frame: (
      dash: "dashed",
      border-color: yellow.darken(30%),
      body-color: yellow.lighten(90%),
    ),
    sep: (dash: "dashed"),
    breakable: true,
    body,
  )
}

/// Create a quote box with left border styling in gray
///
/// - body (content): Content to be quoted
/// -> content
#let quote-box(body) = block(
  stroke: (left: .25em + luma(200)),
  inset: (left: 1em, y: .75em),
  text(luma(100), body),
)

/// Create a note box with customizable styling and icon
/// Base template for tip-box, important-box, warning-box, and caution-box
///
/// - fill (color): Color of the border and icon. Default is `rgb("#0969DA")`
/// - title (string|dict): Title text or dictionary for i18n. Default is "Note"
/// - icon-name (string): Name of the icon to display from octicons set
/// - body (content): Content of the note
/// -> content
#let note-box(
  fill: rgb("#0969DA"),
  title: theorion-i18n-map.at("note"),
  icon-name: "info",
  body,
) = block(
  stroke: (left: .25em + fill),
  inset: (left: 1em, top: .5em, bottom: .75em),
  {
    let title-i18n = theorion-i18n(title)
    stack(
      spacing: 1.5em,
      text(
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
      ),
      body,
    )
  },
)

/// Create a tip box with green styling and light bulb icon
/// Useful for helpful suggestions and tips
#let tip-box = note-box.with(
  fill: rgb("#1A7F37"),
  title: theorion-i18n-map.at("tip"),
  icon-name: "light-bulb",
)

/// Create an important box with purple styling and report icon
/// Useful for highlighting key information
#let important-box = note-box.with(
  fill: rgb("#8250DF"),
  title: theorion-i18n-map.at("important"),
  icon-name: "report",
)

/// Create a warning box with amber styling and alert icon
/// Useful for potential issues or warnings
#let warning-box = note-box.with(
  fill: rgb("#9A6700"),
  title: theorion-i18n-map.at("warning"),
  icon-name: "alert",
)

/// Create a caution box with red styling and stop icon
/// Useful for serious warnings or dangerous situations
#let caution-box = note-box.with(
  fill: rgb("#CF222E"),
  title: theorion-i18n-map.at("caution"),
  icon-name: "stop",
)

/// Create a remark environment
///
/// - title (string|dict): Title text or dictionary for i18n. Default is "Remark"
/// - body (content): Content of the remark
/// -> content
#let remark = note-box.with(
  fill: rgb("#118D8D"),
  title: theorion-i18n-map.at("remark"),
  icon-name: "comment",
)