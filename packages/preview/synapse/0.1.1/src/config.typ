#let _modes = (
  "composition": "composition",
  "paper": "paper",
  "electronic": "electronic",
)

#let _config = state(
  "config",
  (
    mode: "composition",
    intro-style: text.with(style: "italic", fill: rgb("#bd4702")),
    syn-style: text.with(weight: "bold", fill: rgb("#3b91d8")),
  ),
)

#let _style-of(style-name) = _config.get().at(style-name)
#let _writing-mode() = _config.get().mode
#let _is-mode(mode) = {
  if mode not in _modes {
    panic("Invalid mode: " + mode + ". Valid modes are: " + repr(_modes.keys()))
  }
  _writing-mode() == _modes.at(mode)
}
