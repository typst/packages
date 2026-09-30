#import "colors.typ": *
#import "data.typ": *

#let options = state("bmim-options", (
  theme: color-theme.cd26,
  lang: "de", // "de", "en"
  spell: i18n.de,
  logo-with-text: true,
  show-solution: none, // none, "inline", "bottom"
  task-show: (..args) => {},
  task-show-points: false,
  task-wrap-counter: none,
  font: ("Source Serif 4",),
  size: 11pt,
  logo: auto, // none, auto, (left: // , right: //)
  titleblock: auto, // none, auto, function
  oneside: true
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
