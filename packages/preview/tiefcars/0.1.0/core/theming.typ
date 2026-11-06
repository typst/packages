#let tng-theme-dark = (
  accent: (
    a-0: color.rgb("cc99ff"),
    a-1: color.rgb("ffaa90"),
    a-2: color.rgb("ffbbaa"),
    a-3: color.rgb("ff8866"),
    a-4: color.rgb("8899ff"),
    a-5: color.rgb("cc5599"),
    a-6: color.rgb("ffaa00"),
    a-7: color.rgb("f5f6fa"),
    a-8: color.rgb("666688"),
    a-9: color.rgb("99ccff"),
  ),
  red: color.rgb("cc4444"),
  green: color.rgb("999933"),
  heading: color.rgb("ffaa00"),
  bg: luma(5%),
  fg: white,
  elem-fg: black,
)

#let nemesis-blue-theme-dark = (
  accent: (
    a-0: color.rgb("2233ff"),
    a-1: color.rgb("2266ff"),
    a-2: color.rgb("6699ff"),
    a-3: color.rgb("88bbff"),
    a-4: color.rgb("9966cc"),
    a-5: color.rgb("9966cc"),
    a-6: color.rgb("9966cc"),
    a-7: color.rgb("9966cc"),
    a-8: color.rgb("9966cc"),
    a-9: color.rgb("9966cc"),
  ),
  red: color.rgb("cc2233"),
  green: color.rgb("99cc33"),
  heading: color.rgb("2233ff"),
  bg: luma(5%),
  fg: white,
  elem-fg: black,
)

#let apply-theme(theme) = {
  let selected-theme = if theme == "tng" {
    tng-theme-dark
  } else if theme == "nemesis-blue" {
    nemesis-blue-theme-dark
  } else {
    assert(true, "Selected theme '" + theme + "' is not available.")
  }

  state("theme-state").update(selected-theme)
}
