/**
== Horizontal Rule Command

:horizontalrule:

Adds a horizontal rule, visual separators used to distinguish subtle changes
of subject in extensive texts.
**/
#let horizontalrule(
  symbol: [#sym.ast.op #sym.ast.op #sym.ast.op], /// <- content
    /// Decoration in the middle of the horizontal rule — defaults to 3 asterisks. |
  spacing: 1em, /// <- length
    /// Vertical space before and after the horizontal rule. |
  line-size: 15%,
) = {
  v(spacing, weak: true)
  
  align(
    center,
    block(width: 100%)[
      #box(
        height: 1em,
        align(
          center + horizon,
          line(length: line-size)
        )
      )
      #box(height: 1em, symbol)
      #box(
        height: 1em,
        align(
          center + horizon,
          line(length: line-size)
        )
      )
    ]
  )
  
  v(spacing, weak: true)
}

/// The `#horizontalrule` command is also available as the smaller `#hr` alias.
#let hr = horizontalrule