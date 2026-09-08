// src/layout/page.typ
// Rendering columns and pages

#import "../renderer/renderer.typ": render-char-token

/// Renders a single column of tokens as a top-to-bottom vertical stack.
///
/// - tokens (array): Array of token dictionaries for this column.
/// - config (dictionary): Layout configuration.
/// -> content: A vertical stack of rendered character boxes.
#let render-column(tokens, config) = {
  if tokens.len() == 0 {
    return box(width: config.sizing.char-box, height: config.sizing.char-box)
  }

  let rendered = tokens.map(token => render-char-token(token, config))

  stack(
    dir: ttb,
    spacing: 0pt,
    ..rendered,
  )
}

/// Renders a single page worth of columns arranged RTL.
///
/// - cols (array): Array of column token arrays for this page.
/// - gap (length): Horizontal gap between columns.
/// - config (dictionary): The layout configuration.
/// -> content: RTL-arranged vertical columns.
#let render-page(cols, gap, config) = {
  if config.layout.hooks.len() > 0 {
    return config.layout.hooks.last()(cols, config.font, gap, config)
  }
  let rendered = cols.map(col => render-column(col, config))
  align(right + top, stack(
    dir: rtl,
    spacing: gap,
    ..rendered,
  ))
}
