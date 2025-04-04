#set page(width: 10cm)

#import "../src/lib.typ" as efilrst

#show ref: efilrst.show-rule

#let constraint = efilrst.reflist.with(
  name: "Constraint", 
  list-style: "C1)", 
  ref-style: "C1")

#constraint(
  [My cool constraint A],<c:a>,
  [My also cool constraint B],<c:b>,
  [My non-refernceable constraint C],
)

See how my @c:a is better than @c:b but not as cool as @c:e.

#constraint(
  [We continue the list with D],<c:d>,
  [And then add constraint E],<c:e>,
)

#constraint(
  counter-name: "new-list",
  [This is a new list!],<c:f>,
)