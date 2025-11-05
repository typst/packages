/*
  File: private.typ
  Author: neuralpain
  Date Modified: 2025-04-20

  Description: Private functions shared by
  multiple modules, not accessible to the end
  user.
*/

#import "pigments.typ": *
#import "text-contrast.typ": get-contrast-color

#let pgmt-page-list-heading = [#link("https://typst.app/universe/package/pigmentpedia","pigmentpedia") by #link("https://github.com/neuralpain","neuralpain")]
#let pgmt-page-text-size = 16pt

// color viewbox settings
#let colorbox = (radius: 100%, width: 100%, height: 1em)
#let colorbox-block-properties = (inset: 1em, radius: 10pt, width: 100%, spacing: 8mm)


#let pgmt-logo-svg = "../assets/logo/pigmentpedia-logo.svg"
#let pgmt-icon-svg = "../assets/logo/pigmentpedia-icon.svg"

#let pgmt-logo(color) = {
  let icon = read(pgmt-logo-svg)
  icon.replace("#df4d4d", color.to-hex()).replace("#f5bb00", color.to-hex())
}

#let pgmt-icon(color) = {
  let icon = read(pgmt-icon-svg)
  icon.replace("#df4d4d", color.to-hex()).replace("#f5bb00", color.to-hex())
}

#let pgmt-icon-error(color: none) = {
  let icon = read(pgmt-icon-svg)
  if color != none { icon = icon.replace("#df4d4d", color.to-hex()).replace("#f5bb00", color.to-hex()) }
  icon.replace("fill-opacity:1;", "fill-opacity:0;")
}

// page setup for Pigmentpedia view
#let pigmentpage = (
  paper: "a4",
  margin: (x: 1cm, top: 3cm, bottom: 2cm),
  foreground: none,
  background: none,
  header: align(center, text(11pt, pad(y: 3mm, pgmt-page-list-heading))),
  footer: text(
    11pt,
    [#h(1fr) Pigment Page #context counter(page).display("1") #h(1fr)],
  ),
)

#let group-divider-line = (
  stroke: (thickness: 1pt, paint: gradient.linear(..color.map.rainbow)),
  length: 100%,
)

/// Page setup for Pigmentpedia
///
/// - body (content): Pigmentpedia pages data
/// - bg (color): Page background color. Default is white.
/// -> content
#let pgmt-page-setup(body, bg: white) = {
  set page(
    ..pigmentpage,
    fill: bg,
    header: align(center)[
      #if bg == white {
        image(pgmt-logo-svg, height: 5mm)
        v(4mm)
      } else {
        image(bytes(pgmt-logo(get-contrast-color(bg))), height: 5mm)
      }
    ],
  )
  counter(page).update(1)
  set text(size: pgmt-page-text-size, get-contrast-color(bg), font: "Libertinus Serif")
  set grid(gutter: 2em)
  body
}

// Name conversions for the top-level pigment groups
#let pgmt-group-name-fmt = (
  "aqua": "Aqua",
  "black": "Black",
  "blue": "Blue",
  "c": "Pantone C",
  "cang": "cang",
  "catppuccin": "Catppuccin",
  "cg-vol-1": "CG Vol 1",
  "cg-vol-2": "CG Vol 2",
  "classic": "RAL Classic",
  "cp": "Pantone CP",
  "crayola": "Crayola",
  "css": "CSS",
  "design": "RAL Design",
  "dic": "DIC",
  "effect": "RAL Effect",
  "en": "en",
  "fluorescent": "Fluorescent",
  "frappe": "Frappe",
  "gold-silver": "Gold-Silver",
  "gray": "Gray",
  "green": "Green",
  "grey": "Grey",
  "grey-white": "Grey-White",
  "hei": "hei",
  "hexachrome": "Hexachrome",
  "hks": "HKS",
  "hong": "hong",
  "huang": "huang",
  "huibai": "huibai",
  "iscc-nbs": "ISCC-NBS",
  "jinyin": "jinyin",
  "jp": "jp",
  "lan": "lan",
  "latte": "Latte",
  "lu": "lu",
  "macchiato": "Macchiato",
  "metallic": "Metallic",
  "mocha": "Mocha",
  "ncs": "NCS",
  "nippon": "Nippon",
  "nippon-paint": "Nippon Paint",
  "nord": "Nord",
  "pantone": "Pantone",
  "pastel": "Pastel",
  "pinyin": "pinyin",
  "pms": "PMS",
  "process": "Process",
  "ral": "RAL",
  "ral-classic": "RAL Classic",
  "red": "Red",
  "romaji": "romaji",
  "shui": "shui",
  "skintone": "SkinTone",
  "standard": "Standard",
  "tc-china": "TC China",
  "tc-france": "TC France",
  "tc-japan": "TC Japan",
  "u": "Pantone U",
  "up": "Pantone UP",
  "xgc": "Pantone XGC",
  "yellow": "Yellow",
  "zh": "zh",
  "zhongguo": "Zhongguo",
  "水": "水",
  "灰白": "灰白",
  "红": "红",
  "绿": "绿",
  "苍": "苍",
  "蓝": "蓝",
  "金银": "金银",
  "黄": "黄",
  "黑": "黑",
)

/// Show the name of the scope selected to search from.
///
/// The search starts off in the top-level pigmentpedia and
/// then traverses through the sub-dictionaries to find the
/// correct names of the groups.
///
/// - scope (dictionary): The pigment group to reference.
/// - depth (dictionary): The group level being referenced.
/// - l (str): Text to place on the left side of the
///   pigment group name.
/// - r (str): Text to place on the right side of the
///   pigment group name.
/// - bg (color): Page background color. Default is white.
/// -> content
#let get-pgmt-group-name(scope, depth: pigmentpedia, l: none, r: none, bg: white) = {
  for (a, b) in depth {
    if a == "output" { continue }
    if b == scope {
      [#l #pigment(get-contrast-color(bg))[
          #for (x, y) in pgmt-group-name-fmt {
            if x == a { strong(y) }
          }
        ] #r]
    } else if type(b) == dictionary {
      get-pgmt-group-name(scope, depth: b, l: l, r: r, bg: bg)
    }
  }
}

/// Capitalize the first letter in a word.
///
/// - word (str): The word to capitalize.
/// -> str
#let cap-first-letter(word) = {
  let _word = upper(word.at(0))
  for i in range(word.len()) {
    if i > 0 { _word += word.at(i) }
  }

  _word
}

/// Capitalize the first letter of each word.
///
/// - char_str (str): The string to process.
/// -> str
#let convert-caps-each-word(char_str) = {
  char_str = char_str.split("-")

  let cnv-str = ""
  for word in char_str {
    cnv-str += cap-first-letter(word) + " "
  }

  cnv-str.trim()
}

/// Format the output of the pigment names for the results pages.
///
/// - name (str): The name of the pigment or pigment group.
/// - caps (str, none): The type of capitalization.
/// - hyphen (bool, none): Whether or not the name of the pigment should contain hyphens.
/// -> str
#let format-pigment-name(name, caps, hyphen) = {
  if hyphen != none {
    if caps == "all" {
      name = upper(name)
    } else if caps == "each" {
      name = convert-caps-each-word(name)
    }

    if hyphen {
      name = name.replace(" ", "-")
    } else if not hyphen {
      name = name.replace("-", " ")
    }
  }

  return name.trim("_")
}

/*
  Error messages for Pigmentpedia
*/

#let error-head(color: none) = {
  image(bytes(pgmt-icon-error(color: color)), height: 50mm)
  text(pgmt-page-text-size, if color == none { red } else { color })[
    `Error!` \ \
  ]
}

#let pgmt-error = (
  key-not-str: {
    align(center + horizon)[
      #error-head()
      #text(pgmt-page-text-size, red)[
        `Search must be a string.`

        `Other data types are not accepted.`
      ]
    ]
  },
  not-a-color: {
    align(center + horizon)[
      #error-head()
      #text(pgmt-page-text-size, red)[
        `Item is not a color.`

        `Use 'view-pigments()'` \
        `for pigment groups.`

        `Use 'rgb("#000000")'` \
        `to enter HEX codes.`
      ]
    ]
  },
  bg-not-a-color: {
    align(center + horizon)[
      #error-head()
      #text(pgmt-page-text-size, red)[
        `'bg' is not a color.`

        `Use 'rgb("#000000")'` \
        `to enter HEX codes.`

        `Use 'view-pigments()' to` \
        `view individual pigments.`
      ]
    ]
  },
  scope-is-color: {
    set page(fill: white)
    align(center + horizon)[
      #error-head()
      #text(pgmt-page-text-size, red)[
        `'scope' cannot be a color.`

        `Please select a` \
        `pigment group for 'scope'.`
      ]
    ]
  },
  not-a-pgmt-group: {
    set page(fill: white)
    align(center + horizon)[
      #error-head()
      #text(pgmt-page-text-size, red)[
        `The selected item` \
        `is not a pigment group.`

        `Use 'view-pigments()' to` \
        `view individual pigments.`
      ]
    ]
  },
)
