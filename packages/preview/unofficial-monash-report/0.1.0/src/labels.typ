// Package-owned wording. Native figure/table/equation supplements remain settable.
#let default-labels = (
  question: "Question", marks: "marks", mark: "mark", tutor: "Tutor",
  author: "Author", student-id: "Student ID", contribution: "Contribution",
  supervisor: "Supervisor", date: "Date", word-count: "Word count",
  abstract: "Abstract", keywords: "Keywords", contents: "Contents", proof: "Proof",
  listing: "Listing", theorem: "Theorem", lemma: "Lemma", proposition: "Proposition",
  corollary: "Corollary", definition: "Definition", example: "Example", remark: "Remark",
)
#let resolve-labels(labels) = {
  if type(labels) != dictionary { panic("`labels` must be a dictionary") }
  for (key, value) in labels {
    if key not in default-labels { panic("unknown label `labels." + key + "`") }
    if type(value) not in (str, content) {
      panic("`labels." + key + "` must be str or content")
    }
  }
  default-labels + labels
}
// Suppress punctuation and spacing together with an empty label.
#let labelled(label, value, separator: [: ]) = {
  if label != "" and label != [] { [#label#separator#value] } else { value }
}
