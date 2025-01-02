#let vw(
  body,
  kerning: 0.3em,
  leading: 0.5em,
  spacing: 1em,
  rotateChar: "[-ー\u{FF5E}\u{301C}\p{Open_Punctuation}\p{Close_Punctuation}]",
) = {
  set align(right)
  stack(
    dir: rtl,
    spacing: leading,
    ..for s in body.split(regex("[\n]")) {
      (
        stack(
          dir: ttb,
          spacing: spacing,
          ..for t in s.split(regex("[\p{Zs}]")) {
            (
              stack(
                dir: ttb,
                spacing: kerning,
                ..for l in t.clusters() {
                  (
                    if regex(rotateChar) in l {
                      set align(center)
                      rotate(90deg, l)
                    } else {
                      set align(center)
                      l
                    },
                  )
                },
              ),
            )
          },
        ),
      )
    },
  )
}

#let format-address(address) = {
  address.replace("-", "ー").replace("1", "一").replace("2", "二").replace("3", "三").replace("4", "四").replace("5", "五").replace("6", "六").replace("7", "七").replace("8", "八").replace("9", "九").replace("0", "〇").replace(" ", "\n")
}

/// Generate an address label for Japanese postcards
/// with the given information.
///
/// - last-name (string): The last name of the recipient, e.g., "岸田". 
/// - first-name (string): The first name of the recipient, e.g., "文雄".
/// - postal-code (string): The post code of the recipient, e.g., "1008981".
/// - address (string): The address of the recipient, e.g., "東京都千代田区永田町2-2-1 衆議院第1議員会館1222号室". Arabic numerals are automatically converted to kanji numerals.
/// - my-last-name (string): The last name of the sender, e.g., "岸田".
/// - my-first-name (string): The first name of the sender, e.g., "文雄".
/// - my-postal-code (string): The post code of the sender, e.g., "1008981".
/// - my-address (string): The address of the sender, e.g., "東京都千代田区永田町2-2-1 衆議院第1議員会館1222号室". Arabic numerals are automatically converted to kanji numerals.
/// - debug (boolean): Whether to show the debug image, e.g., true.
/// -> none
#let hagaki(last-name, first-name, postal-code, address, my-last-name, my-first-name, my-postal-code, my-address, debug: false) = {
  let background = none
  if debug {
    background = image("hagaki.png")
  }
  set page(width: 100mm, height: 148mm, margin: 0mm, background: background)
  // postCode

  set text(size: 16pt)
  for (i, c) in postal-code.clusters(
  ).filter(x => regex("[0-9]") in x).enumerate() {
    place(
      top + left,
      block(
        align(center + horizon)[#c],
        width: 6mm,
        height: 8mm,
      ),
      dx: i * 7mm + 44mm,
      dy: 12mm,
    )
  }

  // myPostCode

  set text(size: 10pt)
  for (i, c) in my-postal-code.clusters(
  ).filter(x => regex("[0-9]") in x).enumerate() {
    place(
      top + left,
      block(
        align(center + horizon)[#c],
        width: 4mm,
        height: 6.5mm,
      ),
      dx: i * 4.1mm + 5.7mm,
      dy: 122.5mm,
    )
  }

  // name

  set text(size: 30pt)
  place(
    center + bottom,
    block(
      vw(last-name + " " + first-name + " 様"),
    ),
    dy: -33mm,
  )

  // address

  set text(size: 13pt)
  place(
    top + right,
    block(
      vw(format-address(address)),
      width: 35mm,
      height: 90mm,
    ),
    dy: 30mm,
    dx: -10mm,
  )

  // myAddress

  place(
    left + top,
    block(
      align(center + horizon)[
        #set text(size: 10pt)
        #vw(format-address(my-address))
      ],
      width: 15mm,
      height: 60mm,
    ),
    dx: 15mm,
    dy: 60mm,
  )

  // myName

  place(
    left + top,
    block(
      align(center + bottom)[
        #set text(size: 16pt)
        #vw(my-last-name + " " + my-first-name)
      ],
      width: 10mm,
      height: 60mm,
    ),
    dx: 5mm,
    dy: 60mm,
  )
  pagebreak(weak: true)
}

/// Generate a batch of address labels for Japanese postcards 
/// with the given information from the CSV file.
///
/// - path (string): The path to the CSV file, e.g., "jyusyoroku.csv".
/// - lastNameColumn (integer): The column number for the last name, e.g., 0.
/// - firstNameColumn (integer): The column number for the first name, e.g., 1.
/// - postCodeColumn (integer): The column number for the post code, e.g., 2.
/// - addressColumn (integer): The column number for the address, e.g., 3.
/// - myLine (number): The line number for the sender, e.g., 1.
/// - debug (boolean): Whether to show the debug image, e.g., true.
/// -> none
#let hagaki-from-csv(
  path,
  last-name-col,
  first-name-col,
  postal-code-col,
  address-col,
  my-line: 1,
  debug: false,
) = {
  let lines = csv(path)
  for (i, line) in lines.slice(1).enumerate() {
    if i + 1 == my-line {
      continue
    }
    hagaki(
      line.at(last-name-col),
      line.at(first-name-col),
      line.at(postal-code-col),
      line.at(address-col),
      lines.at(my-line).at(last-name-col),
      lines.at(my-line).at(first-name-col),
      lines.at(my-line).at(postal-code-col),
      lines.at(my-line).at(address-col),
      debug: debug,
    )
  }
}
