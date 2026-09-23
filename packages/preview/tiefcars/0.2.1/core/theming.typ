#let tng-accent = (
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
)

#let nemesis-blue-accent = (
  a-0: color.rgb("6699ff"),
  a-1: color.rgb("2266ff"),
  a-2: color.rgb("52526a"),
  a-3: color.rgb("88bbff"),
  a-4: color.rgb("9966cc"),
  a-5: color.rgb("ffcc99"),
  a-6: color.rgb("ebf0ff"),
  a-7: color.rgb("6699ff"),
  a-8: color.rgb("88bbff"),
  a-9: color.rgb("2266ff"),
)

#let tng-theme-dark = (
  accent: tng-accent,
  red: color.rgb("cc4444"),
  green: color.rgb("999933"),
  heading: color.rgb("ffaa00"),
  bg: luma(5%),
  fg: white,
  elem-fg: black,
)

#let tng-theme-light = (
  accent: tng-accent,
  red: color.rgb("cc4444"),
  green: color.rgb("999933"),
  heading: color.rgb("dd8800"),
  bg: white,
  fg: black,
  elem-fg: black,
)

#let nemesis-blue-theme-dark = (
  accent: nemesis-blue-accent,
  red: color.rgb("cc2233"),
  green: color.rgb("99cc33"),
  heading: color.rgb("2233ff"),
  bg: luma(5%),
  fg: white,
  elem-fg: black,
)

#let theme-presets = (
  "tng": tng-theme-dark,
  "tng-l": tng-theme-light,
  "nemesis-blue": nemesis-blue-theme-dark,
)

#let theme-aliases = (
  "tng-light": "tng-l",
)

#let preset-for(name) = {
  let lookup = theme-aliases.at(name, default: name)
  let preset = theme-presets.at(lookup, default: none)
  assert(
    preset != none,
    message: "Selected theme '" + name + "' is not available.",
  )
  preset
}

#let merge-theme(base, overrides) = {
  let merged = base
  for (key, value) in overrides {
    if key != "extends" and key != "base" {
      let base-value = base.at(key, default: none)
      if type(base-value) == dictionary and type(value) == dictionary {
        merged = merged.insert(key, merge-theme(base-value, value))
      } else {
        merged = merged.insert(key, value)
      }
    }
  }
  merged
}

#let ensure-theme-complete(theme) = {
  let required-keys = (
    "accent",
    "red",
    "green",
    "heading",
    "bg",
    "fg",
    "elem-fg",
  )
  for key in required-keys {
    assert(
      theme.at(key, default: none) != none,
      message: "Theme is missing required key '" + key + "'.",
    )
  }

  let accent = theme.accent
  assert(
    type(accent) == dictionary,
    message: "Theme accent must be a dictionary.",
  )
  for i in range(10) {
    let accent-key = "a-" + str(i)
    assert(
      accent.at(accent-key, default: none) != none,
      message: "Theme accent is missing '" + accent-key + "'.",
    )
  }
  theme
}

#let resolve-theme(theme) = {
  if type(theme) == dictionary {
    let extends = theme.at("extends", default: none)
    let base-key = theme.at("base", default: none)
    let base = if extends != none {
      resolve-theme(extends)
    } else if base-key != none {
      resolve-theme(base-key)
    } else {
      none
    }
    let resolved = if base != none { merge-theme(base, theme) } else { theme }
    ensure-theme-complete(resolved)
  } else if type(theme) == str {
    ensure-theme-complete(preset-for(theme))
  } else {
    assert(
      false,
      message: "Selected theme '" + str(theme) + "' is not available.",
    )
  }
}

#let apply-theme(theme) = {
  let selected-theme = resolve-theme(theme)
  state("theme-state").update(selected-theme)
}
