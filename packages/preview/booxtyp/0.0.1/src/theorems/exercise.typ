#import "new-plain-template.typ": new-plain-template
#import "../counters.typ": exercise-counter

#let exercise = new-plain-template(
  "Exercise",
  title-prefix: emoji.hand.write,
  template-counter: exercise-counter,
)
