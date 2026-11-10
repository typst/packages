/// Alert content with a color.
/// Unlike default alert, this function can
/// be used inside a context.
///
/// Example: `utils.alert[important]`
///
/// -> content
#import "context.typ": component-wrapper

#let render-alert(self: none, it) = [#metadata(it)<ambrosia-alert>]
#let alert(it) = component-wrapper(render-alert, it)

#let apply-alert-style(color: none, body) = context {
  if color == none {
    color = text.fill
  }
  show <ambrosia-alert>: it => {
    set text(fill: color)
    it.value
  }

  body
}
