#let record-answer(body) = context {
  // Read the current enum numbers, exposed by itemize
  let nums = state("__enum-parent-number__", ()).get()

  // Read the current numbering pattern (of function), exposed by itemize
  let numbering-pattern = state("__enum-numbering__", (numbering: "1.1.1.1.1.")).get().numbering

  // Generate the numbering label
  let label = numbering(numbering-pattern, ..nums)

  // Add the answer body to the answers list in state
  state("__answers-list__").update(a => {
    a.push((label: label, answer: body))
    a
  })

  // Display inline answers
  let inline-answers-formatter = state("___inline-answers___", none).get()
  if inline-answers-formatter != none {
    inline-answers-formatter(body)
  }
}
