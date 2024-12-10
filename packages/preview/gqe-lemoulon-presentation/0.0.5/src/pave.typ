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



/// Speaker notes are a way to add additional information to your slides that is not visible to the audience. This can be useful for providing additional context or reminders to yourself.
///
/// == Example
///
/// #example(```typ
/// #speaker-note[This is a speaker note]
/// ```)
///
/// - self (none): The current context.
///
/// - mode (string): The mode of the markup text, either `typ` or `md`. Default is `typ`.
///
/// - setting (function): A function that takes the note as input and returns a processed note.
///
/// - note (content): The content of the speaker note.
///
/// -> content
#let pave(title, content) = {
  touying-fn-wrapper(intern-gros-pave, title: title, content)
}

