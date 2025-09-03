#import "@preview/touying:0.5.3": *
#import "@preview/showybox:2.0.3": showybox

#let intern-gros-pave(self: none, title: none, content) = {
  set text(size: 0.9em)
 showybox(
  frame: (
    border-color: self.colors.primary.darken(50%),
    title-color: self.colors.primary.lighten(75%),
    body-color: self.colors.primary.lighten(90%),
    radius: 8pt,
  ),
  title-style: (
    color: self.colors.neutral-darkest,
    weight: "bold",
    align: left
  ),
  shadow: (
    offset: 3pt,
  ),
  title: title,
  content
)
}



/// Display boxes using your touying config-colors settings.
///
/// ```
/// #pave("Scientific projects and hardware")[
/// - High throughput
/// - Metaproteomics
/// - Instrument improvements
/// ]
/// ```
///
/// -> content
#let pave(title, content) = {
  touying-fn-wrapper(intern-gros-pave, title: title, content)
}

