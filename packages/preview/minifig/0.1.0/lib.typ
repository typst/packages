/// Show rule function
///
/// Put `#show: minifig` at the top of your document and it should work fine
#let minifig(doc) = {
  set figure(kind: figure, supplement: [Figure])
  doc
}

/// Equivalent to the `figure` command with less arguments
///
/// - caption: The caption for the whole figure
/// - cols: Number of columns to split the subfigure up into
/// - subfigs: All the subfigures to display. Use @sfigure for these
#let subfigures(caption: none, cols: auto, ..subfigs) = {
  figure(caption: caption, {
    subfigs = subfigs.pos()
    cols = if cols == auto { subfigs.len() } else { cols }
    counter("sfig").update(1)
    grid(columns: (1fr,) * cols, align: center + bottom, gutter: 1em, ..subfigs)
  })
}

/// A singular subfigure
///
/// This uses some custom numbering so make sure to use this for your subfigures
#let sfigure = figure.with(
  kind: "subfig", supplement: [Figure],
  numbering: (..pos) => {
    counter("sfig").step()
    counter(figure.where(kind: figure)).display()
    [.]
    counter("sfig").display()
  }
)
