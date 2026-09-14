// style.typ
// This file defines the style and colors used in the Deckz package.
// It includes the background color, border style, and suit colors.

/// The background color for the card rendering area.
/// It represents the color of the "paper" or "canvas" where the cards are displayed.
/// Currently set to a light aqua color.
/// 
/// -> color
#let bg-color = aqua.lighten(90%)

/// The color used for the back of the cards.
/// It is a light blue color, defined using a hex code.
#let back-color = color.rgb("#4796a4")

/// The border style for the card rendering area.
/// It defines the appearance of the border around the card area.
/// Currently set to a gray color mixed with aqua, darkened by 50% and with a width of 1pt.
/// 
/// -> color + length
#let border-style = gray.mix(aqua).darken(50%) + 1pt

/// Variant suits colors dictionary, defined with the suit name as key and the color as value.
/// The colors are used to render the suit symbols on the cards.
/// 
/// Current colors are:
/// - Hearts: red mixed with purple (20%)
/// - Spades: black mixed with green (10%)
/// - Diamonds: red mixed with orange (90%)
/// - Clubs: blue mixed with black (10%)
/// 
/// -> dict
/* // DEPRECATED
#let suits-colors-variant = (
  "heart": red.mix((purple, 20%)), 
  "spade": black.mix((green, 10%)),
  "diamond": red.mix((yellow, 70%)),
  "club": blue.mix((black, 10%)),
)
*/