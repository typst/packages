// ===========================================================================
//  socialyst — 30-second smoke test
//
//    typst compile examples/quickstart.typ examples/quickstart.pdf \
//          --root . --font-path /path/to/fontawesome/otfs
// ===========================================================================

#import "/lib.typ": *

#set page(width: 16cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= socialyst #text(size: 0.7em, fill: luma(90))[v0.1.0]

#tweetbox(
  author: "Maxime", handle: [maxime], date: [23 Aug],
  published: true, likes: 128, liked: true,
  thread: (
    (author: "Léa", handle: [lea.m], time: [4m],
      likes: 24, liked: true, body: [Clear — $A C = 13$.]),
    (author: "Yanis", handle: [yanis], time: [12m],
      likes: 6, body: [And if a side is missing?]),
  ),
)[In a right triangle, $A C^2 = A B^2 + B C^2$.]

#v(0.55em)
#facebookbox(
  author: "Collège El-Biar", date: [21 Aug], time: [18:40],
  published: true, liked: true, likes: 64, shares: 3,
  thread: (
    (author: "Samir", body: [Page 42 as well?], likes: 8, liked: true, time: [1 h]),
    (author: "Inès", body: [Yes — bring a set square.], likes: 3, time: [45 min]),
  ),
)[Homework is on page 42.]
