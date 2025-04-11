#import "util-textbox.typ": *


// Review Comment - Supervisor 1
// --------------------------------------------------------
#let supervisor1 = textbox.with(
  "Supervisor 1",
  color: red,
  radius: 2pt,
  width: auto,
)


// Review Comment - Supervisor 2
// --------------------------------------------------------
#let supervisor2 = textbox.with(
  "Supervisor 2",
  color: orange,
  radius: 2pt,
  width: auto
)



// Review Comment - Reviewer 1
// --------------------------------------------------------
#let reviewer1 = textbox.with(
  "Reviewer 1",
  color: green,
  radius: 2pt,
  width: auto,
)

// Review Comment - Reviewer 2
// --------------------------------------------------------
#let reviewer2 = textbox.with(
  "Reviewer 2",
  color: purple,
  radius: 2pt,
  width: auto,
)

// Review Comment - Reviewer 3
// --------------------------------------------------------
#let reviewer3 = textbox.with(
  "Reviewer 3",
  color: lime,
  radius: 2pt,
  width: auto,
)

// Review Comment - Reviewer 4
// --------------------------------------------------------
#let reviewer4 = textbox.with(
  "Reviewer 4",
  color: fuchsia,
  radius: 2pt,
  width: auto,
)



// Source requested
// --------------------------------------------------------
#let source = text(fill: red)[\u{2190} \[Source requested!\]]