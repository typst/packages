// synkit — A toolkit to draw syntax trees
// Version 0.1.0

#import "syntax.typ": garden, tree
#import "movement.typ": blank, move
#import "eg.typ": eg, eg-rules
#import "gloss.typ": gloss

/// Draw a syntax tree from bracket notation.
/// Optional arguments include spacing, arrows, annotations, color,
/// numbering, and font controls; see the package manual for the full list.
///
/// ```typ
/// #tree("[CP [C' [C did] [TP [DP she] [T' [T e] [VP [V leave]]]]]]")
/// ```
#let tree = tree

/// Draw multiple syntax trees in a single canvas with cross-tree equivalence lines.
///
/// Each positional argument is a spec dict with the tree-specific keys supported
/// by `garden()` (`input`, `direction`, `spread`, `drop`, `content-size`,
/// `node-size`, `triangle`, `terminal-branch`, `bottom`).
/// Node anchors are suffixed with tree index: `"np1-1"` = first NP in tree 1.
///
/// ```typ
/// #garden(
///   (input: "[S [NP the cat] [VP [V sat]]]", direction: "down"),
///   (input: "[S [NP 猫が] [VP [V 座った]]]", direction: "up"),
///   equivalence: (("np1-1", "np1-2"),),
///   gap: 2.0,
/// )
/// ```
#let garden = garden

/// Draw inline movement notation with subscripted bracket labels and
/// rectangular arrows below the text. Optional arguments include `arrows`,
/// `delinks`, `scale`, `content-size`, `line-width`, and `protect`.
///
/// ```typ
/// #move(
///   "[CP Who do you think [(CP)[TP<who>saw Mary]]]",
///   arrows: ((from: "who2", to: "who1", dash: "solid", color: black),),
/// )
/// ```
#let move = move

/// Render a blank underline representing an empty position.
/// Use `width` to adjust its length.
///
/// ```typ
/// The word #blank(width: 3em) means "house".
/// ```
#let blank = blank

/// Numbered linguistic example with automatic (1), (2)... numbering.
/// Wrap content directly for a single example, or use list syntax for
/// automatically lettered sub-examples. Use `labels` to make individual
/// sub-examples referenceable.
/// Apply `#show: eg-rules` to enable reference formatting.
/// Optional arguments include `caption`, `title`, and `labels`.
///
/// ```typ
/// #eg(labels: (<s-plain>, <s-move>))[
///   - Who do you think saw Mary?
///   - #move(
///       "[CP Who do you think [(CP)[TP<who>saw Mary]]]",
///       arrows: ((from: "who2", to: "who1", dash: "solid", color: black),),
///     )
/// ] <eg-wh>
/// ```
#let eg = eg

/// Show rules for linguistic examples.
///
/// Apply this to enable proper reference formatting for eg().
/// References render as (1), (1a), (1b), etc.
///
/// Usage: `#show: eg-rules`
#let eg-rules = eg-rules

/// Create an interlinear glossed example with automatic numbering.
/// Shares the same (1), (2)... sequence as eg().
/// Apply `#show: eg-rules` to enable reference formatting.
/// Optional arguments include `per`, `labels`, `caption`, `spacing`,
/// `title`, and `escape`.
///
/// ```typ
/// #gloss()[
///   - eu gosto de maçã
///   - I like.1prs.sg.pres of apple
///   - 'I like apples'
/// ]
/// ```
#let gloss = gloss
