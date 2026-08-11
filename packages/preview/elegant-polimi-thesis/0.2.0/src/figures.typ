#import "utils.typ": _localization, bluepoli

/// It displays the caption of subfigures. Use "(a)" that will be colored based on `colored-headings` parameter.
/// -> content
#let _subfigure-caption(
  /// Whether to apply bluepoli on captions
  /// -> bool
  colored-caption: true,
  /// Parent figure of this subfigure
  /// -> figure
  parent: none,
  it,
) = context {
  align(
    center,
    block({
      set align(left)
      text(
        fill: if (colored-caption) { bluepoli } else { black },
        it.counter.display("(a)"),
      )
      [ ]
      it.body
    }),
  )
}

/// Style-figures handles (optional heading-dependent) numbering of figures and subfigures.
/// Can modify the caption of all figures.
/// -> none
#let _style-figures(
  /// Whether to apply bluepoli on captions (#text(fill: rgb("#5f859f"), "Figure 1")).
  /// -> bool
  colored-caption: true,
  /// Heading level to account for in the numbering.
  /// -> int
  heading-levels: 0,
  body,
) = context {
  show figure.caption: it => context {
    if (it.kind != "lists" and it.kind != "_blank-toc") {
      text(
        fill: if (colored-caption) { bluepoli } else { black },
        {
          it.supplement
          " "
          it.counter.display(it.numbering)
          it.separator
        },
      )
      it.body
    } else {
      it
    }
  }
  // Numbering patterns for figures and subfigures.
  let fig-numbering = "1." * heading-levels + "1" // e.g. "1.1"
  let subfig-numbering = "1." * heading-levels + "1a" // e.g. "1.1a"

  // Set default supplement for subfigures.
  show figure.where(kind: "subfigure"): set figure(
    supplement: _localization.at(text.lang).figure,
  )

  // removed styling function because the one used is the template global one

  show heading: outer => {
    if outer.level <= heading-levels {
      // reset figure counter.
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
    }
    outer
  }

  set figure(numbering: (..nums) => {
    // TODO: check if we need to provide more context (i.e. using `at` instead
    // of `get`)?
    //
    // ref: https://github.com/typst/typst/issues/3930
    let heading-nums = counter(heading).get()
    if heading-nums.len() > heading-levels {
      // truncate if needed.
      heading-nums = heading-nums.slice(0, heading-levels)
    } else if heading-nums.len() < heading-levels {
      // zero pad if needed.
      for i in range(heading-nums.len(), heading-levels) {
        heading-nums.push(0)
      }
    }
    std.numbering(fig-numbering, ..heading-nums, ..nums)
  })

  show figure.where(kind: image): outer => {
    // reset subfigure counter
    counter(figure.where(kind: "subfigure")).update(0)

    // use nesting level of figure to infer numbering of subfigures.
    set figure(numbering: (..nums) => {
      let heading-nums = counter(heading).at(outer.location())
      if heading-nums.len() > heading-levels {
        // truncate if needed.
        heading-nums = heading-nums.slice(0, heading-levels)
      } else if heading-nums.len() < heading-levels {
        // zero pad if needed.
        for i in range(heading-nums.len(), heading-levels) {
          heading-nums.push(0)
        }
      }
      let outer-nums = counter(figure.where(kind: image)).at(outer.location())
      std.numbering(subfig-numbering, ..heading-nums, ..outer-nums, ..nums)
    })

    show figure.where(kind: "subfigure"): inner => {
      show figure.caption: _subfigure-caption.with(colored-caption: colored-caption, parent: outer)
      inner
    }
    outer
  }

  body
}
