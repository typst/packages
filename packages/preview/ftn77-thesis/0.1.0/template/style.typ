#import "@local/ftn77-thesis:0.1.0": style as default

// Override your styles here. You can start from default style or scratch.
// The base style is applied to all content besides forms and cover, main is applied
// only to pages with chapters, form and form-heading define uni form styling
// and cover is only for its page. Form and cover page default styles are adaptive
// (just set absolute font size) and may work sufficiently on different page sizes.

// Any style here is optional (as all defaults are included by the below line)
// including the whole file. You may use the default styling by not passing any style
// to the `thesis` function.
#import default: *

#let cover = default.cover.with(margin: 1.5cm)

#let base = default.base.with(
  accent: blue, // uses blue from ftn site defined by default.blue, which is the default accent
  body-size: 11pt,
)

#let main(body) = {
  show: default.main.with(accent: blue)

  // additional styling starting from default main style, if changed also change the appendices style to reflect it

  body
}

#let appendices = default.appendices.with(accent: blue)

// #let appendices = main

// ... see default style module
