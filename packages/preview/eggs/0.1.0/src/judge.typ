/// Typesets the content, then adds negative space
/// of the length of this content.
/// Used to add a judge to the left of a text. -> content
#let judge(
  /// The content to typeset. -> content
  j
) = [#context(h(-measure(j).width))#j]
