#import "@preview/pc-letter:0.1.0"

#let letter = pc-letter.init(
  author: (
      // Change this to your own address
      name: "Sherlock Holmes",
      address: ("221B Baker Street", "London NW1 6XE"),
      phone: "020 7123 4567",
      email: "sherlock@example.org"
  ),
  // Remove to automatically insert today's date
  date: datetime(day: 25, month: 5, year: 2025),
  style: (
    // Adjust to reflect your language and region
    locale: (lang: "en", region: "GB"),
    // If intending to print, change this to "print"
    medium: "digital",
  ),
)

#show: letter.letter-style

// Remove if you don't want the falzmarken in the left margin
#(letter.falzmarken)()

#(letter.address-field)[
  // Enter the recipient's address here
  Dr John H. Watson\
  c/o The Porch House\
  1 Digbeth Street\
  Stow-on-the-Wold\
  Cheltenham GL54 1BN
]

// Remove this if you don't need to quote a reference number
#(letter.reference-field)[XY/1928/ABC/28]


Dear Watson,

= Corrections to some recent notes in the case-book

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in sapien sed orci sodales mollis eget vel elit. Sed ultricies risus in neque eleifend, malesuada lacinia ipsum iaculis. Pellentesque enim purus, sagittis congue dolor ut, ullamcorper rutrum quam. Praesent suscipit orci at mauris finibus malesuada.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin gravida pharetra lacus, non laoreet nunc ornare eu.

In sit amet mi eleifend, viverra tortor ut, ultricies nunc. Etiam mollis neque ac erat placerat, id pharetra nisi tempus. Etiam nisi ipsum, bibendum in nisi eu, euismod finibus libero.

== Subheading

Ut metus turpis, varius sed risus ut, tempus mattis odio. Ut a sodales mauris. Vivamus tincidunt purus ex, pellentesque dignissim neque dignissim sed.

Aliquam sem nibh, eleifend facilisis nunc at, elementum eleifend lacus. Vivamus nec justo est. Nam tincidunt felis eget posuere auctor. Vivamus erat purus, elementum eget lobortis eget, rutrum eu felis. Aliquam ex nulla, auctor fermentum enim sed, cursus hendrerit mauris.

Cras ac tortor ut odio accumsan mattis. Proin nec vestibulum nulla. Suspendisse pulvinar ultricies rutrum. Praesent bibendum finibus orci.


#(letter.valediction)(
  signature: image("signature.svg", height: 3em)
)[Yours sincerely,]


// Remove if you don't intend to send copies to anyone
#(letter.cc-field)(
  "DI Greg Lestrade",
  "Mrs Hudson",
)

// Remove if you don't have any attachments
#(letter.enclosed-field)(
  "Map of crime scene",
  "Original notes on Ormsted",
)
