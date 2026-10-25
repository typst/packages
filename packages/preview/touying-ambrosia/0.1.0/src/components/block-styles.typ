// Container geometry and treatments. Colors are resolved from the current palette.
#let block-styles = (
  plain: (header: "plain", background: "surface", border: "neutral", shadow: auto),
  framed: (header: "joined", background: "tinted", border: "neutral", shadow: auto),
  poster: (header: "detached", background: "alternate", border: "none", shadow: false),
  outlined: (header: "ruled", background: "none", border: "accent", shadow: false),
  stripe: (header: "plain", background: "alternate", border: "stripe", shadow: false),
  tabbed: (header: "tabbed", background: "tinted", border: "accent", shadow: false),
)

#let block-style-names = block-styles.keys()
#let get-block-style(name) = {
  assert(name in block-styles, message: "Block style '" + str(name) + "' is not supported. Choose: " + block-style-names.join(", ") + ".")
  block-styles.at(name)
}
