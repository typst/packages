= 0017. Letter Combinations of a Phone Number

Given a string containing digits from `2-9` inclusive, return all possible letter combinations that the number could represent. Return the answer in *any order*.

A mapping of digits to letters (just like on the telephone buttons) is given below. Note that 1 does not map to any letters.

#let phone-keypad() = {
  // Phone keypad data: (digit, letters)
  let keys = (
    ("1", ""),
    ("2", "abc"),
    ("3", "def"),
    ("4", "ghi"),
    ("5", "jkl"),
    ("6", "mno"),
    ("7", "pqrs"),
    ("8", "tuv"),
    ("9", "wxyz"),
    ("*", "+"),
    ("0", " "),
    ("#", ""),
  )

  let key-width = 70pt
  let key-height = 45pt
  let gap = 8pt

  let draw-key(digit, letters) = {
    box(
      width: key-width,
      height: key-height,
      {
        // Outer bezel (dark rim)
        place(
          center + horizon,
          box(
            width: key-width - 4pt,
            height: key-height - 4pt,
            radius: 50%,
            fill: gradient.radial(
              rgb("#5a5a5a"),
              rgb("#3a3a3a"),
              center: (30%, 30%),
            ),
            stroke: 1pt + rgb("#2a2a2a"),
          ),
        )
        // Inner button (glossy)
        place(
          center + horizon,
          box(
            width: key-width - 12pt,
            height: key-height - 10pt,
            radius: 50%,
            fill: gradient.linear(
              rgb("#e8e8f0"),
              rgb("#c8c8d8"),
              rgb("#a8a8c0"),
              angle: 90deg,
            ),
            stroke: 0.5pt + rgb("#888"),
            {
              set align(center + horizon)
              // Digit
              text(size: 18pt, weight: "regular", fill: rgb("#333"))[#digit]
              // Letters
              if letters != "" and letters != " " and letters != "+" {
                text(size: 10pt, fill: rgb("#555"), style: "italic")[ #letters]
              } else if letters == "+" {
                text(size: 10pt, fill: rgb("#555"), baseline: -2pt)[#super[+]]
              } else if letters == " " {
                h(2pt)
                text(size: 10pt, fill: rgb("#555"))[─]
              }
            },
          ),
        )
      },
    )
  }

  // Build 4x3 grid
  box(
    fill: gradient.linear(
      rgb("#7a7a7a"),
      rgb("#5a5a5a"),
      rgb("#4a4a4a"),
      angle: 90deg,
    ),
    inset: 15pt,
    radius: 8pt,
    {
      set align(center)
      grid(
        columns: 3,
        column-gutter: gap,
        row-gutter: gap,
        ..keys.map(k => draw-key(k.at(0), k.at(1)))
      )
    },
  )
}

#align(center)[#phone-keypad()]
