#import "../src/lib.typ" as reflist

#show ref: reflist.show-rule


#reflist.reflist(
  [My cool constraint A],<c:a>,
  [My also cool constraint B],<c:b>,
  [My non-refernceable constraint C],
  list-style: "C1)",
  ref-style: "C1",
  name: "Constraint"
)

See how my @c:a is better than @c:b.

