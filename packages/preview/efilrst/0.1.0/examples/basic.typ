#import "../src/lib.typ" as efilrst

#show ref: efilrst.show-rule


#efilrst.reflist(
  [My cool constraint A],<c:a>,
  [My also cool constraint B],<c:b>,
  [My non-refernceable constraint C],
  list-style: "C1)",
  ref-style: "C1",
  name: "Constraint"
)

See how my @c:a is better than @c:b.

