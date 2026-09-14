// Maps to #link("https://github.com/morhetz/gruvbox-contrib/blob/150e9ca30fcd679400dc388c24930e5ec8c98a9f/color.table")[gruvbox-contrib color table], but contains no duplicate colors.
#let colors = (
  // -> dark.strong
  bright: (
    red: rgb("#FB4934"),
    green: rgb("#B8BB26"),
    yellow: rgb("#FABD2F"),
    blue: rgb("#83A598"),
    purple: rgb("#D3869B"),
    aqua: rgb("#8EC07C"),
    orange: rgb("#FE8019"),
  ),
  // -> muted
  neutral: (
    red: rgb("#CC241D"),
    green: rgb("#98971A"),
    yellow: rgb("#D79921"),
    blue: rgb("#458588"),
    purple: rgb("#B16286"),
    aqua: rgb("#689D6A"),
    orange: rgb("#D65D0E"),
  ),
  // -> light.strong
  faded: (
    red: rgb("#9D0006"),
    green: rgb("#79740E"),
    yellow: rgb("#B57614"),
    blue: rgb("#076678"),
    purple: rgb("#8F3F71"),
    aqua: rgb("#427B58"),
    orange: rgb("#AF3A03"),
  ),
  // INFO: Why are these not stored in an array?
  // 1) Typst has a longer syntax to index arrays (i.e. `at(i)` method).
  // 2) LSPs don't show the length of an array, it would be hard for the user to
  //    know the limits of a colorset.
  dark0-hard: rgb("#1d2021"),
  dark0: rgb("#282828"), // -> dark.medium.bg0
  dark0-soft: rgb("#32302f"),
  dark1: rgb("#3c3836"), // -> light.fg0
  dark2: rgb("#504945"),
  dark3: rgb("#665c54"),
  dark4: rgb("#7c6f64"),
  gray: rgb("#928374"),
  light4: rgb("#a89984"),
  light3: rgb("#bdae93"),
  light2: rgb("#d5c4a1"),
  light1: rgb("#ebdbb2"), // -> dark.fg0
  light0-soft: rgb("#f2e5bc"),
  light0: rgb("#fbf1c7"), // -> light.medium.bg0
  light0-hard: rgb("#f9f5d7"),
)
