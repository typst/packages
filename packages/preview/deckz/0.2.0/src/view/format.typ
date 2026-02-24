#import "../model/convert.typ": * 
#import "canvas.typ": *
#import "placement.typ": *

// Dictionary of formats' parameters
// this is used to make code more modular and reusable
#let format-parameters = (
  default: (
    width: auto, // Width must be provided! 
    height: auto, // Height must be provided!
    inset: 2pt + 3%, 
    outset: 0pt,
    radius: 2pt + 5%,
    stroke: border-style,
    fill: bg-color,
  ),
  inline: (
    width: 1.5em, 
    height: 0.8em,
    inset: 0pt, 
    outset: 0.13em,
    radius: 0.5em,
    stroke: none,
  ),
  mini: (
    width: 1.5em, 
    height: 2.1em,
  ),
  small: (
    width: 2.5em, 
    height: 3.5em,
  ),
  medium: (
    width: 6.5em, 
    height: 9.1em,
  ),
  large: (
    width: 10em, 
    height: 14em,
  ),
  square: (
    width: 10em, 
    height: 10em,
  ),
)

#{
  // When the module is imported, this should be executed
  for (format, params) in format-parameters.pairs() {
    if format != "default" {
      // For every parameter
      for key in format-parameters.default.keys() {
        if key not in params {
          format-parameters.at(format).insert(key, format-parameters.default.at(key))
        }
      }
    }
  }
  // This guarantees that every format has all the parameters to be displayed.
  // TODO for future releases: load configs from file.
}

// Show a rectangle with the card style and a custom content
#let render-card-frame(format, body) = box(
  ..format-parameters.at(format),
  body
)

#let render-card-content(format, card-data) = {
  if format == "inline" {
    align(center)[#get-rank-symbol(card-data.rank)#suits.at(card-data.suit)]
  } 
  else if format == "mini" {
    align(center,
      cetz.canvas(
        draw-stack-rank-and-suit(card-data)
      )
    )
  } 
  else if format == "small" {
    two-corners(
      box(width: 0.8em, align(center, get-rank-symbol(card-data.rank)))
    )
    align(center + horizon)[
      #text(size: 1.4em, suits.at(card-data.suit))
    ]
  } 
  else if format == "medium" {
    two-corners(
      cetz.canvas(
        draw-stack-rank-and-suit(card-data)
      )
    )
    text(2em,
      align(center + horizon,
        draw-central-rank-canvas(card-data)
      )
    )
  } 
  else if format == "large" {
    four-corners(
      cetz.canvas(
        draw-stack-rank-and-suit(card-data)
      )
    )
    text(3em,
      align(center + horizon,
        draw-central-rank-canvas(card-data)
      )
    )
  }
  else if format == "square" {
    four-corners-diagonal(
      cetz.canvas(
        draw-stack-rank-and-suit(card-data)
      )
    )
    text(2.5em,
      align(center + horizon,
        draw-central-rank-canvas(card-data)
      )
    )
  } else {
    render-card-medium(card)
  }
}

#let render-card(format, card) = {
  let card-data = extract-card-data(card)
  if card-data.suit == none or card-data.rank == none {
    import "back.typ": back
    back(format: format)
  } else {
    render-card-frame(format,
      text(card-data.color,
        render-card-content(format, card-data)
      )
    )
  }
}
#import "@preview/suiji:0.4.0" as suiji // Random numbers library

/// Render function to view cards in different formats.
/// This function allows you to specify the format of the card to be rendered.
/// Available formats include: inline, mini, small, medium, large, and square.
/// 
/// ```side-by-side
/// #deckz.render("10S")
/// #deckz.render(format: "large", "8C")
/// #deckz.render(format: "mini", "KH")
/// ```
/// 
/// -> content
#let render(
  /// The code of the card you want to represent. -> string
  card, 
  /// The selected format of the card. Available formats are: #choices("inline", "mini", "small", "medium", "large", "square").
  /// -> string
  format: "medium", 
  /// The amount of "randomness" in the placement and rotation of the card. Default value is #value(none) or #value(0.), which corresponds to no variations. A value of #value(1.) corresponds to a "standard" amount of noise, according to Deckz style. Higher values might produce crazy results, handle with care. -> float | none
  noise: none,
) = {
  if noise == none or noise <= 0 {
    // No Noise
    return render-card(format, card)
  } else {
    // Ok noise
    let seed = int(noise * 1e9) + 42
    let rng = suiji.gen-rng-f(seed)
    let (rng, (shift-x, shift-y, shift-rot)) = suiji.uniform-f(rng, low: -1/2, high: 1/2, size: 3)
    move(
      dx: shift-x * noise * 0.5em,
      dy: shift-y * noise * 0.5em,
      rotate(
        shift-rot * noise * 15deg,
        origin: center + horizon,
        { // Translated and rotated content
          render-card(format, card)
        }
      )
    )
  }
}


/// Renders a card with the "*inline*" format.
/// The card is displayed in a compact style: text size is coherent with the surrounding text, and the card is rendered as a simple text representation of its rank and suit.
/// 
/// ```side-by-side
/// #lorem(10)
/// #deckz.inline("AS"), #deckz.inline("3S")
/// #lorem(10)
/// #deckz.inline("KH").
/// ```
/// 
/// -> content
#let inline(
  /// The code of the card you want to represent. -> string
  card,
) = render(format: "inline", card)


/// Renders a card with the "*mini*" format.
/// The card is displayed in a very compact style, suitable for dense layouts. The frame size is responsive to text, and it contains a small representation of the card's rank and suit.
/// 
/// ```side-by-side
/// #deckz.mini("JC")
/// #deckz.mini("AH")
/// #deckz.mini("5S")
/// #deckz.mini("9D")
/// #deckz.mini("4H")
/// #deckz.mini("3C")
/// #deckz.mini("2D")
/// #deckz.mini("KS")
/// ```
/// 
/// -> content
#let mini(
  /// The code of the card you want to represent. -> string
  card,
) = render(format: "mini", card)

/// Renders a card with the "*small*" format.
/// The card is displayed in a concise style, balancing readability and space: the card's rank is shown symmetrically in two corners, with the suit displayed in the center.
/// 
/// ```side-by-side
/// #deckz.small("3S")
/// #deckz.small("6H")
/// #deckz.small("QS")
/// #deckz.small("5D")
/// #deckz.small("AC")
/// #deckz.small("4S")
/// ```
/// 
/// -> content
#let small(
  /// The code of the card you want to represent. -> string
  card,
) = render(format: "small", card)

/// Renders a card with the "*medium*" format: a full, structured card layout with two corner summaries and realistic suit placement.
/// The medium format is usually the default format for card rendering in DECKZ.
/// 
/// ```side-by-side
/// #deckz.medium("QD")
/// #deckz.medium("AH")
/// #deckz.medium("7C")
/// ```
/// 
/// -> content
#let medium(
  /// The code of the card you want to represent. -> string
  card,
) = render(format: "medium", card)


/// Renders a card with the "*large*" format, emphasizing the card's details: all four corners are used to display the rank and suit, with a large central representation.
/// Like other formats, the large format is responsive to text size; corner summaries are scaled accordingly to the current text size.
/// 
/// ```side-by-side
/// #deckz.large("JD")
/// #deckz.large("9C")
/// ```
/// 
/// -> content
#let large(
  /// The code of the card you want to represent. -> string
  card,
) = render(format: "large", card)

/// Renders a card with the "*square*" format, i.e. with a frame layout with 1:1 ratio. 
/// This may be useful for grid layouts or for situations where the cards are often rotated in many directions, because the corner summaries are placed diagonally.
/// 
/// ```side-by-side
/// #deckz.square("5C")
/// #deckz.square("JH")
/// ```
/// 
/// -> content
#let square(
  /// The code of the card you want to represent. -> string
  card,
) = render(format: "square", card)

