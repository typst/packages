/* TODO: Interesting from Dherse: info.typ, with 'info'boxes */

// see Dherse
#let text_emoji(content, ..args) = text.with(
  font: "tabler-icons",
  fallback: false,
  weight: "regular",
  size: 16pt,
  ..args,
)(content)

// example usage
//#let lightbulb = text_emoji(fill: earth-yellow, size: font-size - 2.7pt)[\u{ea51}]

// flex-caption and ofigure have the same purpose, allowing different text
// in the outline compared to the actual figure. It's just a matter of taste
// on what to use. (TODO: should we encourage/remove 1 in favor of the other?)

/// Short figure caption in outline
///
/// Also usable in heading and other outline things.
/// When using positional arguments:
/// flex-caption([Long figure caption], [Short outline title])
// https://github.com/typst/typst/issues/1295
#let flex-caption(
  long: none, short: none, ..args,
) = {
  assert(args.named().len() == 0,
         message: "Got unexpected named arguments: " + repr(args.named().keys()))
  assert(args.pos().len() + int(long != none) + int(short != none) == 2,
         message: "Expected exactly two arguments (either named long/short or "
                  + "positional), but got " + str(int(long!=none) + int(short!=none))
                  + " named and " + str(args.pos().len()) + " positional.")
  // If positional arguments are used, assign correctly to long/short
  if short == none {
    if long == none { short = args.at(1) } else { short = args.at(0) }
  }
  if long  == none { long  = args.at(0) }
  context if state("in-outline", false).get() { short } else { long }
}

/// outline-figure
/// A figure with a different outline caption and a normal caption.
/// Typically, you should use a short, descriptive outline caption.
/// We used to override the default `figure`, but this wasn't a good idea
// TODO: Alternative: use #show figure.caption: <function to parse body.>
// <If content => caption. If array/dict => input for flex-caption>
// Not yet possible: https://github.com/typst/typst/issues/1295 and related
#let ofigure(outline: none, caption: none, ..kwargs) = {
  figure(caption: if outline == none {
      caption
    } else {
      flex-caption(short: outline, long: caption)
    },
    ..kwargs
  )
}

// Math figure selection
// A lot of different combinations can used to display specific math formulas
// Most of these are specified by Theorion

#let figure-selector(kinds) = {
  assert.ne(kinds.len(), 0,
            message: "The array 'kinds' needs to be at least of length 1.")
  selector.or(
    ..kinds.map(k => figure.where(kind: k))
  )
}
// See Theorion
#let all-math-figure-kinds = (math.equation, "theorem", "lemma", "corollary", "axiom", "postulate", "definition", "proposition")
#let all-math-figures = figure-selector(all-math-figure-kinds)

// Sorting outline?: https://github.com/typst/typst/discussions/3431
/// Select an array of targets & group them in this order
/// The default is changed to ALL math figures
#let outline-group-by(
  title: auto,
  /// Can be array
  /// Example: ("theorem", "definition").map(k => figure.where(kind: k))
  target: all-math-figure-kinds.map(k => figure.where(kind: k)),
  // Pass through
  depth: none,
  indent: auto,
) = {
  let targets = target // Decouple API from clear internal variable names
  if type(targets) == array {
    // TODO: problem is that the indent is now not uniform...
    for (i, target_i) in targets.enumerate() {
      if i == 0 {
          // A hack to determine the title based on the set rule for the
          // complete target XorYorZ - this might be excessive...
          // `show outline.where(target: XorYorZ): set outline(title: ...)`
          show outline.where(
            target: selector.or(..targets)
          ): out => {
            let fields = out.fields()
            // Fallback to automatic title set for first selector X
            let title = fields.remove("title")
            outline(
              ..fields,
              ..if title != auto { (title: title) },
              target: target_i,
            )
          }
          outline(
            // if auto, let the set rule determine 'title'
            ..if title != auto { (title: title) },
            target: selector.or(..targets), // complete XorYorZ target
            depth: depth, indent: indent,
          )
      } else {
          outline(target: target_i, title: none, depth: depth, indent: indent)
      }
    }
  } else {
    outline(title: title, target: targets, depth: depth, indent: indent)
  }
}
