#import "@preview/ftn77-thesis:0.2.0": style as default

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
  accent: navy, // default accent is navy (engineer blue in default style actually)
  body-size: 11pt,
)

#let main(body, ..sink) = {
  show: default.main.with(accent: navy)

  body
}

#let appendices = default.appendices.with(accent: navy)

// ... see default style module
