// gentle-clues

// Helper
#let if-auto-then(val,ret) = {
  if (val == auto){
    ret
  } else {
    val
  }
}

// Global states
#let __gc_clues_breakable = state("breakable", false)
#let __gc_clues_headless = state("headless", false)
#let __gc_clue_width = state("clue-width", auto)
#let __gc_header_inset = state("header-inset", 0.5em)
#let __gc_content_inset = state("content-inset", 1em)
#let __gc_border_radius = state("border-radius", 2pt)
#let __gc_border_width = state("border-width", 0.5pt)
#let __gc_stroke_width = state("stroke-width", 2pt)
#let __gc_title_font = state("title-font", auto)
#let __gc_title_weight_delta = state("title-weight-delta", 200)


/// Config the default settings for all clues globally.
///
/// *Example:*
/// Change the default settings for all clues.
/// #figure(
/// ```example
/// #show: gentle-clues.with(
///   headless: true,
///   stroke-width: 6pt,
///   width: 5.5cm,
/// )
/// #clue[With changed default settings.]
/// ```,
/// supplement: "Example"
/// )<gentle-clues-example>
///
/// -> content
#let gentle-clues(
  /// defines if clues break across pages by default.
  /// -> boolean
  breakable: false,
  /// defines if clues should be shown without a header by default.
  /// -> boolean
  headless: false,
  /// defines the default header-inset for all clues.
  /// -> length
  header-inset: 0.5em,
  /// defines the default width for all clues.
  /// -> auto | length
  width: auto,
  /// defines the default stroke width of the left colored stroke for all clues.
  /// -> length
  stroke-width: 2pt,
  /// defines the default border radius for all clues.
  /// -> length
  border-radius: 2pt,
  /// defines the default border width for all clues.
  /// -> length
  border-width: 0.5pt,
  /// defines the default content inset of the body for all clues.
  /// -> length
  content-inset: 1em,
  /// defines the default font for the title
  /// -> auto | string
  title-font: auto,
  /// defines the default weight offset for the title
  /// -> int
  title-weight-delta: 200,
  body
) = {

  // Update breakability
  __gc_clues_breakable.update(breakable);

  // Update clues width
  __gc_clue_width.update(width);

  // Update headless state
  __gc_clues_headless.update(headless);

  // Update header inset
  __gc_header_inset.update(header-inset);

  // Update border radius
  __gc_border_radius.update(border-radius);

  // Update border width
  __gc_border_width.update(border-width);

  // Update stroke width
  __gc_stroke_width.update(stroke-width);

  // Update content inset
  __gc_content_inset.update(content-inset);

  // Update title font
  __gc_title_font.update(title-font);

  // Update title weight delta
  __gc_title_weight_delta.update(title-weight-delta);

  body

  }

/// Basic gentle-clue (clue) template function.
///
/// This function can be used to create custom clues. You can pass all of this parameters to the predefined clues (@predefined) as well to overwrite the default settings.
/// If an argument is `auto` it will fallback to the value which is specified in @gentle-clues
///
/// *Example:*
/// ```example
/// #clue(title:"Test")[Some important content.]
/// ```
/// #figure(``, supplement: "Section")<clue-api>
///
///
/// -> content
#let clue(
  /// Content inside the body.
  /// -> content
  content,
  /// The title of the clue. If `none` the header is ommited.
  /// ```example
  /// #clue(title:"My title")[Some important content.]
  /// ```
  ///
  /// -> string | none
  title: none,
  /// The icon to show in front of the title.
  /// ```example
  /// #clue(title:"with icon", icon: emoji.ticket)[Some important content.]
  /// ```
  ///
  /// -> none | image | symbol
  icon: none,

  /// The accent color defines the color of the stroke on the left side.
  /// If border-color and header-color are set to auto those get derived from the accent color.
  /// ```example
  /// #clue(title:"red accent", accent-color: red)[Some important content.]
  /// ```
  ///
  /// -> color | gradient | tiling
  accent-color: navy,
  /// The background color of the header.
  /// ```example
  /// #clue(title:"green header", header-color: green.lighten(50%))[Some important content.]
  /// ```
  ///
  /// -> auto | color | gradient | tiling
  header-color: auto,
  /// The color of the small border on the bottom and right side.
  /// if in headless mode also for the top border.
  /// ```example
  /// #clue(title: "blue borders", border-color: blue)[Some important content.]
  /// ```
  ///
  /// -> auto | color | gradient | tiling
  border-color: auto,
  /// The background color of the body
  /// ```example
  /// #clue(title:"pink body", body-color: fuchsia.lighten(50%))[Some important content.]
  /// ```
  ///
  /// -> none | color | gradient | tiling
  body-color: none,

  /// The total width of the clue.
  /// ```example
  /// #clue(title:"4 cm wide", width: 4cm)[Some small content.]
  /// ```
  ///
  /// -> auto | length
  width: auto,
  /// The border radius on the right side.
  /// ```example
  /// #clue(title:"rounded", radius: 10pt)[Some important content.]
  /// ```
  ///
  /// -> auto | length
  radius: auto,
  /// Defines the width of the border.
  /// ```example
  /// #clue(title:"thick", border-width: 5pt, border-color: orange)[Some important content.]
  /// ```
  ///
  /// -> auto | length
  border-width: auto,
  /// Defines the width of the stroke on the left side.
  /// ```example
  /// #clue(title:"big", stroke-width: 5pt,)[Some important content.]
  /// ```
  ///
  /// -> auto | length
  stroke-width: auto,

  /// The inset for the content body.
  /// ```example
  /// #clue(title:"squeeze", content-inset: 1pt)[Some important content.]
  /// ```
  ///
  /// -> auto | length
  content-inset: auto,
  /// Defines the inset for the header
  /// ```example
  /// #clue(title:"tight", header-inset: 1pt)[Some important content.]
  /// ```
  ///
  /// -> auto | length
  header-inset: auto,
  /// The font which is used for the title.
  /// ```example
  /// #clue(title:"styled", title-font:"New Computer Modern" )[Some important content.]
  /// ```
  ///
  /// -> auto | string
  title-font: auto,
  /// The weight delta which is used for the title. Output depends on the used font.
  /// ```example
  /// #clue(title:"fat", title-weight-delta: 500)[Some important content.]
  /// ```
  ///
  /// -> auto  | int
  title-weight-delta: auto,

  /// Defines if the clue is breakable. If `auto` it falls back to the default settings. See @gentle-clues
  /// -> auto | boolean
  breakable: auto,
  /// Defines if clues should be shown without a header. If `auto` it falls back to the default settings. See @gentle-clues
  /// ```example
  /// #clue(title:"fat", headless: true)[Some important content.]
  /// ```
  ///
  /// -> boolean
  headless: auto,
) = {
  // check color types
  assert(type(accent-color) in (color, gradient, tiling), message: "expected color, gradient or tiling found " + str(type(accent-color)));

  if (header-color != auto) {
    assert(type(header-color) in (color, gradient, tiling), message: "expected color, gradient or tiling found " + str(type(header-color)));
  }
  if (border-color != auto) {
    assert(type(border-color) in (color, gradient, tiling), message: "expected color, gradient or tiling, found " + str(type(border-color)));
  }
  if (body-color != none) {
    assert(type(body-color) in (color, gradient, tiling), message: "expected color, gradient or tiling, found " + str(type(body-color)));
  }

  context {
    // Set default color:
    let _stroke-color = accent-color;
    let _header-color = if-auto-then(header-color, accent-color)
    let _border-color = if-auto-then(border-color, accent-color)

    // setting bg and stroke color from color argument
    if (type(accent-color) == color) {
      _header-color = if-auto-then(header-color, accent-color.lighten(85%));
      _border-color = if-auto-then(border-color, accent-color.lighten(70%));
    }

    let _border-width = if-auto-then(border-width, __gc_border_width.get());
    let _border-radius = if-auto-then(radius, __gc_border_radius.get())
    let _stroke-width = if-auto-then(stroke-width, __gc_stroke_width.get())
    let _title-weight-delta = if-auto-then(title-weight-delta, __gc_title_weight_delta.get())
    let _title-font = if-auto-then(title-font, if-auto-then(__gc_title_font.get(), text.font))
    let _clip-content = true
    let _title-content = strong(delta: _title-weight-delta, text(font: _title-font, title))

    // Header Part
    let header-block = block(
            sticky: true,
            below: 0pt,
            fill: _header-color,
            width: 100%,
            radius: (top-right: _border-radius),
            inset: if-auto-then(header-inset, __gc_header_inset.get()),
            stroke: (right: _border-width + _header-color )
          )[
            #if icon == none { _title-content  } else {
                grid(
                  columns: (auto, auto),
                  align: (horizon, left + horizon),
                  gutter: 1em,
                  box(height: 1em)[ #icon ],
                  _title-content
                )
              }
          ]

    // Content-Box
    let content-block(content) = block(
      breakable: if-auto-then(breakable, __gc_clues_breakable.get()),
      width: 100%,
      fill: body-color,
      inset: if-auto-then(content-inset, __gc_content_inset.get()),
      radius: (
        top-left: 0pt,
        bottom-left: 0pt,
        top-right: if (title != none){0pt} else {_border-radius},
        rest: _border-radius
      ),
      above: 0pt,
    )[#content]

    // Wrapper-Block
    return block(
      breakable: if-auto-then(breakable, __gc_clues_breakable.get()),
      width: if-auto-then(width, __gc_clue_width.get()),
      inset: (left: 1pt),
      radius: (right: _border-radius, left: 0pt),
      stroke: (
        left: (thickness: _stroke-width, paint: _stroke-color, cap: "butt"),
        top: if (title != none){_border-width + _header-color} else {_border-width + _border-color},
        rest: _border-width + _border-color,
      ),
      clip: _clip-content,
    )[
      #set align(start)
      #if if-auto-then(headless, __gc_clues_headless.get())  == false and title != none { header-block }
      #content-block(content)
    ] // wrapper block end
  }
}
