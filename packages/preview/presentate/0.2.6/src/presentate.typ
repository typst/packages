#import "freeze-counters.typ": freeze-states-mark, start-location
#import "utils.typ"
#import "indices.typ"
#import "animation.typ": pdfpc-slide-markers
#import "store.typ": states

#let subslide(i, body, preamble: it => it, logical-slide: true) = {
  show: preamble

  // set states to originals.
  states.update(s => {
    let (info, ..x) = s
    info.subslide = i
    (info,)
  })

  // Touying x Polylux's originals

  {
    set heading(outlined: i == 1, bookmarked: i == 1)

    body
  }
  v(0pt)


  // freeze page number, tricks from minideck.
  if i > 1 or not logical-slide {
    counter(page).update(x => x - 1)
  }

  pdfpc-slide-markers(i)

  context if states.get().at(0).drafted {
    place(
      center + horizon,
      text(size: 3in, str(i), fill: black.transparentize(90%)),
    )
  }

  pagebreak(weak: true)
}

/// Presentate slide function 
/// -> content 
#let slide(
  /// the content on the slide 
  /// -> content 
  body,
  /// Total number of subslides needed. `auto` means detecting automatically. 
  /// -> auto | int 
  steps: auto,
  /// function that wraps only the content. 
  /// -> function 
  body-fn: it => it,
  /// function that wraps the whole slide. 
  /// -> function 
  preamble: it => it,
  /// whether this should be counted as a logical slide. This effects page numbering as non-logical slide will have a skipped page number. 
  /// -> bool
  logical-slide: true,
) = {
  // Save the location, idea from Touying.
  context start-location.update(here())
  states.update(s => {
    let (info, ..x) = s
    if not info.logical-slide {
      info.add-page-index += 1
    }
    info.logical-slide = logical-slide

    (info, ..x)
  })

  let subslide = subslide.with(preamble: preamble, logical-slide: logical-slide)
  body = body-fn(body)

  // Put the first subslide to get the data for the following subslides.
  subslide(1, body)

  context {
    let steps = steps
    let s = states.get()
    let (info, ..x) = s
    if steps == auto {
      (steps,) = indices.resolve(s)
    }
    if not info.handout {
      // Polylux's originals
      for i in range(2, steps + 1) {
        freeze-states-mark()
        subslide(i, body)
      }
    }
  }
  // magic ???
  start-location.update(none)
}
