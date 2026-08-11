/// Typesets the content, then adds negative space
/// of the length of this content.
/// Used to add a judge to the left of a text.
///
/// - j (content): The content to typeset
///
///   *Required*
///
/// -> content
#let judge(
  j
) = [#context(h(-measure(j).width))#j]
