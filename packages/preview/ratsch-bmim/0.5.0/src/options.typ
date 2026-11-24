#import "colors.typ": *
#import "data.typ": *
#import "check.typ": *

#let option-defaults = (
  theme: color-theme.cd26, // name of a theme in color-theme, or single colors
  lang: "de", // "de", "en"
  spell: i18n.de,
  show-solution: none, // none, "inline", "bottom"
  task-show: (..args) => {},
  task-show-points: false,
  task-wrap-counter: none,
  font: auto, // auto (= fonts.serif, slides: fonts.sans) or font name(s)
  fonts: (
    serif: "Source Serif 4", // body text
    sans: "Source Sans 3", // slides, abstract
    mono: "Source Code Pro", // code
    letter: "Bitstream Vera Sans", // letter, free font that looks like Arial
    logo: "Nimbus Sans", // text next to the LFUI logo
  ),
  size: 11pt,
  logo: auto, // none, auto, (left: // , right: //)
  institute: "iace", // key of institutes (data.typ) or (name: content, logo: content)
  titleblock: auto, // none, auto, function
  oneside: true
)

#let options = state("bmim-options", option-defaults)

// Validate the given options. This runs directly when calling option-set and
// not inside the state update, where errors are not reported reliably (e.g.
// slides and letter only showed a "did not converge" warning).
#let option-check(dict) = {
  let known = option-defaults.keys().filter(k => k != "spell")
  for (key, val) in dict {
    assert(key in known, message:
      "Unknown option '" + key + "', known options are [" +
      known.map(repr).join(", ") + "]"
    )
    if key == "theme" {
      if type(val) == str {
        assert-one-of("theme", val, color-theme.keys())
      } else {
        assert(type(val) == dictionary, message:
          "Option 'theme' must be the name of a theme or a dictionary " +
          "of colors, but was set to " + repr(val)
        )
        // all themes have the same keys
        for color-key in val.keys() {
          assert(color-key in option-defaults.theme, message:
            "Unknown theme color '" + color-key + "', known colors are [" +
            option-defaults.theme.keys().map(repr).join(", ") + "]"
          )
        }
      }
    } else if key == "fonts" {
      assert(type(val) == dictionary, message:
        "Option 'fonts' must be a dictionary of fonts, but was set to " +
        repr(val)
      )
      for font-key in val.keys() {
        assert(font-key in option-defaults.fonts, message:
          "Unknown font '" + font-key + "', known fonts are [" +
          option-defaults.fonts.keys().map(repr).join(", ") + "]"
        )
      }
    } else if key == "lang" {
      assert-one-of("lang", val, i18n.keys())
    } else if key == "show-solution" {
      assert-one-of("show-solution", val, (none, "inline", "bottom"))
    } else if key == "institute" {
      if type(val) == dictionary {
        for inst-key in val.keys() {
          assert(inst-key in ("name", "logo"), message:
            "Unknown key '" + inst-key + "' of option 'institute', known keys are ['name', 'logo']"
          )
        }
      } else {
        assert-one-of("institute", val, institutes.keys())
      }
    }
  }
}

#let option-set(dict) = {
  option-check(dict)
  options.update(o => {
    for (key, val) in dict {
      if key == "theme" {
        // a name selects a theme, a dictionary replaces single colors
        if type(val) == str { o.theme = color-theme.at(val) } else { o.theme += val }
      } else if key == "fonts" {
        // only the given fonts are replaced, the others keep their defaults
        o.fonts += val
      } else if key == "lang" {
        o.lang = val
        o.spell = i18n.at(val)
      } else {
        o.at(key) = val
      }
    }
    return o
  })
}

// Main text font: the `font` option, or the given role of `fonts` for auto.
#let main-font(opts, role: "serif") = if opts.font == auto {
  opts.fonts.at(role)
} else {
  opts.font
}
