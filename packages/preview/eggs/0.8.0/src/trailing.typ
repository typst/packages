/// Insert content as non-breaking, right-aligned,
/// and showing on the next line if it does not fit.
///
/// - body (content): The contents to show.
/// *Required*
///
/// - gap (length): Minimum space between the main line and the trailing content
/// *Default*: 1.5em
///
/// -> content
#let trailing(body, gap: 1.5em) = {
  box()
  h(1fr)
  sym.wj
  box({h(gap); body})
}
