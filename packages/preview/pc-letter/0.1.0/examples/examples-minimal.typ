#import "@preview/pc-letter:0.1.0"

#let letter = pc-letter.init(
  author: (
      name: "Hercule Poirot",
      address: (
        "56B Whitehaven Mansions",
        "London EC2Y 5HN"
      ),
      phone: "020 7123 4567",
      email: "hercule.poirot@example.org"
  ),
)

#show: letter.letter-style

#(letter.address-field)[
  Mrs Ariadne Oliver\
  23 Benthall Street\
  London W2 1NB
]


Dear Madame Oliver,

#lorem(55)

#lorem(23)

#(letter.valediction)(
)[Yours very truly,]
