// These are the Resumania styling functions.
//
// Generally, these are meant to be kind of used like Typst's built-in `show`
// functions. In essence, there are a bunch of `state` variables in this module
// that "style" (format) various parts of the resume. They can be overridden if
// desired and completely customized, as well as putting together a whole style
// to be shipped as one easily-applied piece.
// 
// See the default style as an example for writing custom styles.
//
// Here is a usage example:
// ```typst
// #let wacky-style = new-style-from-default((
//   // Set the name to always display this instead of the configured name
//   name: (value) => {"Whackamole"},
//   // Set the section text to be much larger, but keep the rest of the default
//   // style
//   section: (value) => {
//     [
//       #set text(size: 20pt)
//       #(default-style.section)(value)
//     ]
//   },
//   // Change elements to have a red outline and white infill
//   element: (value) => {
//     text(size: 12pt, stroke: 0.2mm + red, fill: white, value)
//   },
// ))
//
// #current-style.update(wacky-style)
// ```
// -----------------------------------------------------------------------------

#import "debug.typ": debug-block

// The coefficient to multiply the text size by to get block spacing for resume
// elements. This is used for keeping the element headers closer to their
// respective bodies for visual signaling to readers that they are together.
#let text-size-to-block-spacing-coeff = 1/1.25

// The default style. This should also be used as an example/template for
// writing custom styles.
//
// Styles consist of keys that define the type of resume part they style and a
// corresponding "show function", which should accept the value that needs to be
// styled and return styled content. The value given to styling functions can be
// assumed to already be some content or something that is directly-convertible
// to content such as via `[#value]`.
#let default-style = (
  // Styles the name of the resume-owner
  name: (value) => { align(center, text(weight: "bold", size: 12pt, value)) },
  // Styles element titles within sections
  element: emph,
  // Styles section titles
  section: strong,
  // Styles timeframes
  timeframe: emph,
  // Styles locations
  location: text,
  // Styles a whole header of an element. Note that this styles on top of the
  // element, timeframe, and location styles.
  header: (value) => {
    context debug-block(
      value,
      spacing: text.size*text-size-to-block-spacing-coeff,
      sticky: true,
    )
  },
  // Styles the whole body of an element.
  body: (value) => {
    context debug-block(
      value,
      spacing: text.size*text-size-to-block-spacing-coeff,
      inset: (left: text.size/5),
    )
  },
)

// Create a new style using the default style as a basis for missing style
// parameters.
//
// The only parameter `style` is a dictionary formatted just like a full style
// (see `default-style` for an example), except it may be a *partial* style. The
// returned value will be a full style dictionary.
#let new-style-from-default(style) = {
  let new-style = default-style

  for (key, value) in style {
    new-style.insert(key, value)
  }

  return new-style
}

// The global style state, which may be updated freely so long as the new value
// contains all style parameters. It is encouraged to use
// `new-style-from-default` for this purpose to fill any missing parameters
// automatically.
#let current-style = state("resumania:style:current-style", default-style)

// Reset the current style to the default style.
#let reset-style-to-default() = {
  current-style.update(default-style)
}


// The below functions are convenience for accessing the elements in the style
// since it can be cumbersome to do so manually.
// -----------------------------------------------------------------------------

#let name(value) = {
  return context (current-style.get().name)(value)
}

#let element(value) = {
  return context (current-style.get().element)(value)
}

#let section(value) = {
  return context (current-style.get().section)(value)
}

#let timeframe(value) = {
  return context (current-style.get().timeframe)(value)
}

#let location(value) = {
  return context (current-style.get().location)(value)
}

#let header(value) = {
  return context (current-style.get().header)(value)
}

#let body(value) = {
  return context (current-style.get().body)(value)
}
