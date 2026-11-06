// src/view/format.typ

#import "../logic/convert.typ": * 
#import "canvas.typ": *
#import "placement.typ": *
#import "../logic/random.typ": prepare-rng, attach-rng-if-from-outside, call-rng-function, suiji


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
    width: 1.7em, 
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
    align(center)[#card-data.rank-symbol#card-data.suit-symbol]
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
      box(width: 0.8em, align(center, card-data.rank-symbol))
    )
    align(center + horizon)[
      #text(size: 1.4em, card-data.suit-symbol)
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
      text(card-data.suit-color,
        render-card-content(format, card-data)
      )
    )
  }
}

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
  /// The amount of "randomness" in the placement and rotation of the card. Default value is #value(none) or #value(0.), which corresponds to no variations.
  /// A value of #value(1.) corresponds to a "standard" amount of noise, according to DECKZ style. Higher values might produce crazy results, handle with care. 
  /// -> float | none
  noise: none,
  /// The random number generator to use for the noise. If not provided or set to default value #value(auto), a new random number generator will be created. Otherwise, you can pass an existing random number generator to use.
  /// -> rng | auto
  rng: auto,
) = {
  let (rng-from-outside, rng) = prepare-rng(rng: rng, seed: card)
  
  // Handle noise generation manually to maintain RNG state
  let result-content = render-card(format, card)
  
  if noise != none and noise > 0 {
    // Generate random values for noise and update RNG state
    let (new-rng, (shift-x, shift-y, shift-rot)) = suiji.uniform-f(rng, low: -1/2, high: 1/2, size: 3)
    rng = new-rng  // Update RNG state
    
    // Apply noise transformation manually (avoiding context constraint)
    result-content = box(move(
      dx: shift-x * noise * 1em,  // Use approximate sizing since we can't measure here
      dy: shift-y * noise * 1em,
      rotate(
        shift-rot * noise * 90deg,
        origin: center + horizon,
        reflow: false,
        result-content
      )
    ))
  }
  
  return attach-rng-if-from-outside(rng-from-outside, rng, result-content)
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
/// This is a wrapper around the @cmd:deckz:render function with the format set to "inline". Every additional argument passed to this function will be forwarded to the @cmd:deckz:render function.
/// 
/// -> content
#let inline(
  /// The code of the card you want to represent. 
  /// -> string
  card,
  /// Additional arguments to pass to the rendering function @cmd:deckz:render.
  /// -> any
  ..args,
) = render(format: "inline", card, ..args)


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
/// This is a wrapper around the @cmd:deckz:render function with the format set to "mini". Every additional argument passed to this function will be forwarded to the @cmd:deckz:render function.
/// 
/// -> content
#let mini(
  /// The code of the card you want to represent.
  /// -> string
  card,
  /// Additional arguments to pass to the rendering function @cmd:deckz:render.
  /// -> any
  ..args,
) = render(format: "mini", card, ..args)

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
/// This is a wrapper around the @cmd:deckz:render function with the format set to "small". Every additional argument passed to this function will be forwarded to the @cmd:deckz:render function.
/// 
/// -> content
#let small(
  /// The code of the card you want to represent. 
  /// -> string
  card,
  /// Additional arguments to pass to the rendering function @cmd:deckz:render.
  /// -> any
  ..args,
) = render(format: "small", card, ..args)

/// Renders a card with the "*medium*" format: a full, structured card layout with two corner summaries and realistic suit placement.
/// The medium format is usually the default format for card rendering in DECKZ.
/// 
/// ```side-by-side
/// #deckz.medium("QD")
/// #deckz.medium("AH")
/// #deckz.medium("7C")
/// ```
/// 
/// This is a wrapper around the @cmd:deckz:render function with the format set to "medium". Every additional argument passed to this function will be forwarded to the @cmd:deckz:render function.
/// 
/// -> content
#let medium(
  /// The code of the card you want to represent. 
  /// -> string
  card,
  /// Additional arguments to pass to the rendering function @cmd:deckz:render.
  /// -> any
  ..args,
) = render(format: "medium", card)


/// Renders a card with the "*large*" format, emphasizing the card's details: all four corners are used to display the rank and suit, with a large central representation.
/// Like other formats, the large format is responsive to text size; corner summaries are scaled accordingly to the current text size.
/// 
/// ```side-by-side
/// #deckz.large("JD")
/// #deckz.large("9C")
/// ```
/// 
/// This is a wrapper around the @cmd:deckz:render function with the format set to "large". Every additional argument passed to this function will be forwarded to the @cmd:deckz:render function.
/// 
/// -> content
#let large(
  /// The code of the card you want to represent. 
  /// -> string
  card,
  /// Additional arguments to pass to the rendering function @cmd:deckz:render.
  /// -> any
  ..args,
) = render(format: "large", card, ..args)

/// Renders a card with the "*square*" format, i.e. with a frame layout with 1:1 ratio. 
/// This may be useful for grid layouts or for situations where the cards are often rotated in many directions, because the corner summaries are placed diagonally.
/// 
/// ```side-by-side
/// #deckz.square("5C")
/// #deckz.square("JH")
/// ```
/// 
/// This is a wrapper around the @cmd:deckz:render function with the format set to "square". Every additional argument passed to this function will be forwarded to the @cmd:deckz:render function.
/// 
/// -> content
#let square(
  /// The code of the card you want to represent. 
  /// -> string
  card,
  /// Additional arguments to pass to the rendering function @cmd:deckz:render.
  /// -> any
  ..args,
) = render(format: "square", card, ..args)

