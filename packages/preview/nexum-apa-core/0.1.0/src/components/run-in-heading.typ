// Explicit APA run-in heading helper for levels 4 and 5.
// Pass the paragraph as content so the heading and its paragraph stay together.
#let apa-run-in-heading(title, body, level: 4) = {
  assert(level == 4 or level == 5, message: "Run-in heading level must be 4 or 5.")
  if level == 4 [
    #set par(first-line-indent: 0.5in)
    #strong[#title.] #h(0.25em) #body
  ] else [
    #set par(first-line-indent: 0.5in)
    #strong[#emph[#title.]] #h(0.25em) #body
  ]
}
