#let enheading(body) = [
  #metadata(body)<enheading>
]

// Add an enheading
// If the body is not none
#let addif_enheading(body) = {
  if body != none {
    enheading(body)
  }
}