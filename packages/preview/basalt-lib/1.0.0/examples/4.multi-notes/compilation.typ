#import "vault.typ": *
#show: vault.new-note.with(
  name: "compilation",
)

= A Compilation

#for path in (
  "note1.typ",
  "note2.typ",
) {
  pagebreak(weak: true)
  // as-branch includes the notes with root=false.
  // Also, links between notes will be resolved as
  // in-document links when possible!
  as-branch(include path)
}
