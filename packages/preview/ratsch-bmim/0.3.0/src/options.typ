#import "colors.typ": *
#import "data.typ": *

#let options = state("bmim-options", (
  theme: color-theme.blue,
  lang: "de", // "de", "en"
  spell: i18n.de,
  logo-with-text: false,
  show-solution: none, // none, "inline", "bottom"
  task-show: (..args) => {},
  task-show-points: true,
  task-wrap-counter: none,
  font: ("New Computer Modern",),
  size: 12pt,
  logo: auto, // none, auto, (left: // , right: //)
))

#let option-set(dict) = {
  options.update(o => {
    for (key, val) in dict {
      if key not in o {
        let known = o.keys().filter(k => k != "spell")
        panic(
          "Unknown option: " + key +
          ". Known options: " + known.join(", ")
        )
      }
      if key == "lang" {
        o.lang = val
        o.spell = i18n.at(val)
      } else {
        o.at(key) = val
      }
      if key == "show-solution" {
        let recognized = (none, "inline", "bottom")
        assert( val in recognized, message:
          "Option 'show-solution' must be one of ["+
          recognized.map(repr).join(", ") +
          "], but was set to " + repr(val)
        )
      }
    }
    return o
  })
}
