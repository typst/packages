/// A box for displaying TODOs.
///
/// It is used in different places to layout warning boxes.
/// Usually, you don't use it directly but may pass it to other functions that use it,
/// so you can customize its appearance.
///
/// *Example*
/// ```typst
/// #let todo-box = todo-box.with(stroke: none)
/// #let todo = todo.with(todo-box: todo-box)
/// #let task = task.with(todo-box: todo-box)
/// ```
///
/// -> content
#let todo-box(
  /// The text that is displayed at the beginning of the box. -> content
  todo-prefix: [TODO],
  /// The styling of the `todo-prefix`. -> function
  todo-style: t => text(red)[*#t*],
  /// The styling of the box's contents. -> function
  text-style: t => t,
  /// The stroke of the box. -> stroke
  stroke: red,
  /// The `inset` value of the box. -> relative | dictionary
  inset: (x: 0.2em),
  /// The `outset` value of the box. -> relative | dictionary
  outset: (y: 0.3em),
  /// The `radius` value of the box. -> relative | dictionary
  radius: 0.3em,
  /// Arbitrary content that is passed into the box.
  ///
  /// You can only pass _positional_ arguments.
  ///
  /// -> arguments
  ..content,
) = {
  assert(content.named().len() == 0, message: "Invalid named argument")
  let content = content.pos()
  box(
    inset: inset,
    outset: outset,
    stroke: stroke,
    radius: radius,
    {
      todo-style(todo-prefix)
      for content in content.map(text-style) {
        h(0.3em)
        content
      }
    },
  )
}

/// Mark a part of your document as unfinished.
///
/// This displays an inline warning box and signals to the context.
///
/// -> content
#let todo(
  /// The layout of the box.
  ///
  /// Set this using the provided `todo-box` function.
  ///
  /// *Example*
  /// ```typst
  /// #todo(todo-box: todo-box.with(stroke: none))[Custom box.]
  /// ```
  /// -> function
  todo-box: todo-box,
  /// Arbitrary content that is passed into the box.
  ///
  /// You can only pass _positional_ arguments.
  ///
  /// -> arguments
  ..comments,
) = {
  counter("sheetstorm-todo").step()
  counter("sheetstorm-global-todo").step()
  todo-box(..comments)
}
