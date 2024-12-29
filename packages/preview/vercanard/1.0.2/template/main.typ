#import "@preview/vercanard:1.0.2": *
#show: resume.with(
  name: "Your name",
  title: "What you are looking for",
  accent-color: rgb("f3bc54"),
  margin: 2.6cm,
  aside: [
    = Contact

    // lists in the aside are right aligned

    - #link("mailto:example@example.org")
    - +33 6 66 66 66 66
    - 10 Downing Street, London

    = Languages

    - French : native
    - English : C1
    - German : B2

    = Hobbies

    - Writing documents in Typst
  ]
)

= Experience

#for i in range(3) {
  entry(lorem(2 + i), lorem(6 - i), "2022-2023")
}

= Personal projects

#for i in range(2) {
  entry(lorem(2 + i), lorem(6 - i), "2022-2023")
}

= Education

#for i in range(2) {
  entry(lorem(2 + i), lorem(6 - i), "2022-2023")
}
