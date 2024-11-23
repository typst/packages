// Imports
#import "../90-Document/91-Doc-Info.typ": *
#import "textbox.typ": *

// ================================================================
//  Supervisor Feedback
// ================================================================
// Reviewer 1
#let supervisor1 = textbox.with(
  name-supervisor1,
  color: red,
  radius: 2pt,
  width: auto,
)

// Reviewer 2
#let supervisor2 = textbox.with(
  name-supervisor2,
  color: orange,
  radius: 2pt,
  width: auto
)

// ================================================================
//  Reviewer Feedback
// ================================================================
// Reviewer 1
#let reviewer = textbox.with(
//  "Reviewer 1",
  //color: green,
  radius: 2pt,
  width: auto,
)


// Source needed
// ================================================================
#let source = text(fill: red)[\u{2190} \[Source needed!\]]