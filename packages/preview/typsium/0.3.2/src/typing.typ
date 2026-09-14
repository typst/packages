#import "@preview/elembic:1.1.1" as e: selector
#import "model/bond-element.typ": bond
#import "model/arrow-element.typ": reaction-arrow
#import "model/element-element.typ": element
#import "model/group-element.typ": group
#import "model/molecule-element.typ": molecule
#import "model/reaction-element.typ": reaction

#let fields = e.fields
#let elembic = e

/// Use this to modify how elements are displayed.
#let set-element(
  /// This will offset the charge symbol to the right so that it's not directly above the count. This may be more useful for ACS notation.
  /// ```example
  /// #ce("NH4-")
  /// >>> #v(0em)
  /// #show: set-element(spaced-charge: true)
  /// #ce("NH4-")
  /// ```
  /// -> bool
  spaced-charge: false,
  /// This will determine whether oxidation numbers will be shown using roman numerals or arabic numerals.
  /// ```example
  /// >>> #v(0.25em)
  /// #ce("H2^^1O^^-2")
  /// >>> #v(0em)
  /// #show: set-element(roman-oxidation: false)
  /// #ce("H2^^1O^^-2")
  /// ```
  /// -> bool
  roman-oxidation: true,
  /// This will determine whether charges will be shown using roman numerals or arabic numerals.
  /// ```example
  /// >>> #v(0.25em)
  /// #ce("Fe+3")
  /// >>> #v(0.25em)
  /// #show: set-element(roman-charge: true)
  /// #ce("Fe^3")
  /// ```
  /// -> bool
  roman-charge: false,
  /// Customise the appearance of the radical dot.
  /// ```example
  /// #ce("Br^.")
  /// >>> #v(0.25em)
  /// #show: set-element(radical-symbol: sym.dot)
  /// #ce("Br^.")
  /// ```
  /// -> content
  radical-symbol: sym.bullet,
  /// Customise the appearance of the minus symbol.
  /// ```example
  /// #ce("Cl-")
  /// >>> #v(0.25em)
  /// #show: set-element(negative-symbol: sym.minus.o)
  /// #ce("Cl-")
  /// ```
  /// -> content
  negative-symbol: math.minus,
  /// Customise the appearance of the plus symbol.
  /// ```example
  /// #ce("Na+")
  /// >>> #v(0.25em)
  /// #show: set-element(positive-symbol: sym.plus.o)
  /// #ce("Na+")
  /// ```
  /// -> content
  positive-symbol: math.plus,
  /// There are some edge cases where elements may be affecting layout. Turn this option off if you are having issues
  /// -> bool
  affect-layout: true,
) = e.set_.with(element)(
  affect-layout: affect-layout,
  roman-oxidation: roman-oxidation,
  spaced-charge: spaced-charge,
  roman-charge: roman-charge,
  radical-symbol: radical-symbol,
  negative-symbol: negative-symbol,
  positive-symbol: positive-symbol,
)

/// Use this to modify how groups are displayed in your document
///```example
/// #ce("(2{[Fe(CN)6]^4+}2-3)")
///
/// >>> #v(2em)
/// #show: set-group(
///   grow-brackets:true,
///   affect-layout:true,
/// )
///
/// #ce("(2{[Fe(CN)6]^4+}2-3)")
/// ```
/// -> show rule
#let set-group(
  /// Brackets will stay the same size by default. Enabling this option will pair Brackets and scale them to wrap around the inner content, dependent on bracket depth.
  grow-brackets: false,
  /// Counts and Charges will always stay at the same position by default, Enabling this option will move counts to the bottoms of brackets and move charges to the top of brackets, dependent on bracket depth. this will not look good inside a block paragraph because it affects the layout.
  affect-layout: false,
) = e.set_.with(group)(
  grow-brackets: grow-brackets,
  affect-layout: affect-layout,
)

/// Use this to permanently modify what gets drawn on top of all arrows. Don't use this if you are looking to add content on top of just one arrow. Use the squared brackets after the arrow instead. These will overwrite the show rule for the specific instance.
/// ```example
/// >>> #v(1em)
/// #show: set-arrow(
///   top:[Hello],
///   bottom:[World],
/// )
/// #ce("A + B -> C")
/// ```
/// -> show rule
#let set-arrow(
  top: none,
  bottom: none,
) = e.set_.with(reaction-arrow)(
  top: top,
  bottom: bottom,
)

/// Use this to modify the way bonds get drawn
/// ```example
/// >>> #v(1em)
/// #show: set-bond(
///   length: 2em
/// )
/// #ce("H2C==CH2")
/// ```
/// -> show rule
#let set-bond(
  /// Width of the bond
  length: 0.5em,
  /// Vertical spacing between each bond line
  spacing: 0.15em,
  /// stroke settings used to draw the normal bonds
/// ```example
/// >>> #v(1em)
/// #show: set-bond(
///   stroke: stroke(paint:red, thickness:1pt, cap:"round", dash:"dotted")
/// )
/// #ce("H2C==CH2")
/// ```
  stroke:(thickness: 0.5pt,),
  /// stroke settings used to draw the non covalent bonds
  non-covalent-stroke:(thickness: 0.5pt,dash: ("dot",),),
) = e.set_.with(bond)(
  length:length,
  spacing:spacing,
  stroke:stroke,
  non-covalent-stroke:non-covalent-stroke,
)

/// Use this to modify the way reactions get drawn
/// ```example
/// >>> #v(1em)
/// #show: set-reaction(
///   plus-spacing: box(fill:red, width:1em, height:1em),
///   arrow-spacing: h(2em),
/// )
/// #ce("A + B -> C")
/// ```
/// -> show rule
#let set-reaction(
  /// spacing applied in front of and behind + symbols
  plus-spacing: h(0.4em, weak: true),
  /// spacing applied in front of and behind of reaction arrows
  arrow-spacing: h(0.4em, weak: true),
  /// spacing applied between molecules
  molecule-spacing:sym.space.nobreak,
  /// spacing applied so that groups don't have big empty space after them
  group-spacing-correction: h(-0.4em),
) = e.set_.with(reaction)(
  plus-spacing: plus-spacing,
  arrow-spacing: arrow-spacing,
  molecule-spacing:molecule-spacing,
  group-spacing-correction: group-spacing-correction,
)

/// Use this to modify how molecules are displayed in your document
#let set-molecule(
  /// the content used for the spacing between the stochiometric number and the rest of the molecule
  /// -> content
  count-spacing: sym.space.nobreak,
  /// spacing applied in front of and behind of bonds
  bond-spacing: h(0.1em),
) = e.set_.with(molecule)(
  count-spacing: count-spacing,
  bond-spacing: bond-spacing,
)
