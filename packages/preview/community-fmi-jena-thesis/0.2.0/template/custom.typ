// =====================================================================================
//  custom.typ: your own changes to the template
// =====================================================================================
//
// This file is the place for your own changes to how your thesis looks. It belongs to
// your project, not to the template, so you can change it freely. Your changes stay
// when you update to a newer version of the template.
//
// Nothing in here is required. Out of the box, the examples below are switched off.
//
// -------------------------------------------------------------------------------------
//  How to switch on an example
// -------------------------------------------------------------------------------------
//
// Lines starting with `//` are comments: Typst ignores them. To switch on an example,
// delete the `//` at the start of its line(s). To switch it off again, put the `//`
// back. Then look at the preview to see the effect.
//
// -------------------------------------------------------------------------------------
//  The two kinds of changes
// -------------------------------------------------------------------------------------
//
// 1. Your own functions (`#let ...`), in the part "Part 1" below.
//
//    A function you define here with the same name as one of the template, such as
//    `todo` or `blockquote`, replaces the template's version. This works because
//    main.typ loads this file after the template.
//
//    You can also add completely new functions and use them in main.typ, e.g.
//    `#let note(body) = ...` and then `#note[Some text]` in main.typ.
//
// 2. Rules (`set` and `show`), in "Part 2" below.
//
//    Rules change how existing things look: all links, all headings, all tables, ...
//    - A `set` rule changes a setting, e.g. `set text(size: 11pt)`.
//    - A `show` rule changes how something is displayed, e.g.
//      `show link: underline` underlines every link.
//
//    Put rules inside `custom-rules` (between the `{` and `body`). main.typ applies them
//    with `#show: custom-rules`. They affect everything you write in main.typ after
//    that line, i.e. your chapters. They do not affect the cover page, the abstract,
//    the preface or the appendix, which you pass to the template as parameters.
//
//    Your rules win over the template's rules, so you can use them to override the
//    template's look.
//
// -------------------------------------------------------------------------------------
//  Learn more
// -------------------------------------------------------------------------------------
//
// - Set and show rules: https://typst.app/docs/reference/styling/
// - Everything you can style (text, link, heading, ...):
//   https://typst.app/docs/reference/model/ and https://typst.app/docs/reference/text/
// - Colors you can use: https://typst.app/docs/reference/visualize/color/
//
// If something goes wrong, the preview shows an error message with the line number.
// Undo your last change (put the `//` back) and try again.

// =====================================================================================
//  Part 1: your own functions
// =====================================================================================

// Example: a more visible `todo`, in red and bold.
// #let todo(it) = text(fill: red, weight: "bold")[TODO: #it]

// Example: hide all todos (e.g. for the final version).
// #let todo(it) = none

// Example: a new function for side notes. Use it in main.typ as `#note[Your text]`.
// #let note(body) = block(
//   fill: luma(240),
//   inset: 8pt,
//   radius: 4pt,
//   width: 100%,
//   [*Note:* #body],
// )

// =====================================================================================
//  Part 2: your own rules
// =====================================================================================

#let custom-rules(body) = {
  // Put your rules below this line. -------------------------------------------------

  // Example: show links in blue.
  // show link: set text(fill: blue)

  // Example: underline links.
  // show link: underline

  // Example: a smaller font size (the template uses 12pt; the examination office asks
  // for at least 11pt).
  // set text(size: 11pt)

  // Example: number headings as "1.1" instead of "1.1.".
  // set heading(numbering: "1.1")

  // Example: make a word bold wherever it appears.
  // show "Typst": strong

  // Put your rules above this line. -------------------------------------------------
  body
}
