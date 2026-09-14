#import "@preview/pc-letter:0.4.0"

#let letter = pc-letter.init(
  author: (
      name: "The Rev. J. Brown",
      address: (
        "St Mary's Catholic Church",
        "Kembleford, Glos."
      ),
  ),
)

#show: letter.letter-style

#(letter.address-field)[
  The Countess of Montague\
  Montague House\
  Kembleford\
  Gloucestershire
]


Dear Lady Montague,

#lorem(37)

#(letter.valediction)(
  signature: image("example-signature.svg"), // Use an image to insert a signature
  name: "Father Brown" // Change the name displayed below the signature
)[Yours sincerely,]
