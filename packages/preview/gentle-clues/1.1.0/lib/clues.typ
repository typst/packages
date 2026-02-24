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
/// ```typ
/// #show: gentle-clues.with(
///   headless: true,  // never show any headers
///   breakable: false, // default breaking behavior
///   content-inset: 2em, // default content-inset
///   stroke-width: 6pt, // default left stroke-width
/// )
/// ```
/// )<gentle-clues-example>
///
/// - breakable (boolean): sets if clues break across pages.
/// - headless (boolean): if all clues should be shown without a header
/// - header-inset (length): sets the default header-inset for all clues.
/// - width (auto, length): sets the default width for all clues.
/// - stroke-width (length): sets the default stroke width of the left colored stroke for all clues.
/// - border-radius (length): sets the default border radius for all clues.
/// - border-width (length): sets the default border width for all clues.
/// - content-inset (length): sets the default content inset of the body for all clues.
/// - show-task-counter (boolean): enable or disable task counter for all tasks.
/// - title-font (auto, string): font for the title
/// - title-weight-delta (auto, int): weight offset of the title
///
/// -> content
#let gentle-clues(
  breakable: false,
  headless: false,
  header-inset: 0.5em,
  width: auto,
  stroke-width: 2pt,
  border-radius: 2pt,
  border-width: 0.5pt,
  content-inset: 1em,
  show-task-counter: false,
  title-font: auto,
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
/// This function can be used to create custom clues. You can pass all of this parameters to the predefined clues as well to overwrite the default settings.
///
/// *Example:*
/// #example(`clue(title:"Test", width: 6cm)[Some important content]`)
/// #figure(``)<clue-api>
///
/// - content (content): Content inside the body.
/// - title (string, none): The title for the
/// - icon (none, image, symbol): The icon to show in front of the title.
/// - accent-color (color, gradient, pattern):
/// - border-color (color, gradient, pattern):
/// - header-color (color, gradient, pattern):
/// - body-color (none, color, gradient, pattern):
/// - width (auto, length):
/// - radius (auto, length):
/// - border-width (auto, length):
/// - content-inset (auto, length):
/// - header-inset (auto, length):
/// - breakable (auto, boolean):
/// - title-font (auto, string):
/// - title-weight-delta (auto, int):
///
/// -> content
#let clue(
  content,
  title: "",
  icon: none,
  accent-color: navy,
  border-color: auto,
  header-color: auto,
  body-color: none,
  width: auto,
  radius: auto,
  border-width: auto,
  content-inset: auto,
  header-inset: auto,
  title-font: auto,
  title-weight-delta: auto,
  breakable: auto,
) = {
  // check color types
  assert(type(accent-color) in (color, gradient, pattern), message: "expected color, gradient or pattern found " + type(accent-color));

  if (header-color != auto) {
    assert(type(header-color) in (color, gradient, pattern), message: "expected color, gradient or pattern found " + type(header-color));
  }
  if (border-color != auto) {
    assert(type(border-color) in (color, gradient, pattern), message: "expected color, gradient or pattern, found " + type(border-color));
  }
  if (body-color != none) {
    assert(type(body-color) in (color, gradient, pattern), message: "expected color, gradient or pattern, found " + type(body-color));
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
    let _stroke-width = if-auto-then(auto, __gc_stroke_width.get())
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
              #if icon == none { _title-content } else {
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
      #if __gc_clues_headless.get() == false and title != none { header-block }
      #content-block(content)
    ] // wrapper block end
  }
}
