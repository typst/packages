#import "freeze_counters.typ": *
#import "animation.typ": *
#import "utils.typ"
#import "store.typ"



#let subslide(i, body, logical-slide: true) = {
  store.subslides.update(i)
  store.dynamics.update((pause: 1, steps: 1))
  store.pauses(i).update(1)


  context if store.settings.get().freeze-counter {
    for c in store.settings.get().frozen-counters.values().map(it => it.cover) {
      c.update(0)
    }
  }

  pdfpc-slide-markers(i)

  {
    set heading(outlined: i == 1)

    // applying updates to pause/meanwhile/reducer.
    show metadata: it => {
      if is-kind(it, "pause") {
        store.pauses(i).update(n => n + 1)
        store.dynamics.update(update-pause)
      } else if is-kind(it, "meanwhile") {
        store.pauses(i).update(1)
        store.dynamics.update(update-meanwhile)
      } else if is-kind(it, "reducer") {
        let values = it.value
        reconstruct-reducer(
          i,
          args: values.args,
          kwargs: values.kwargs,
          func: values.func,
          cover: values.cover,
        )
      } else {
        it
      }
    }
    // Force generation of `sequence`
    show text: it => it + []
    show block: it => it + []
    show box: it => it + []

    show sequence: reconstruct-sequence.with(i)

    body
  }

  v(0pt, weak: true)
  // freeze page number
  if i > 1 or not logical-slide {
    counter(page).update(x => x - 1)
  }

  context if store.settings.get().drafted {
    place(
      center + horizon,
      text(size: 3in, str(i), fill: black.transparentize(90%)),
    )
  }

  if i > 1 {
    pagebreak(weak: true)
  }
}

#let slide(body, steps: auto, logical-slide: true) = {
  show: it => (
    context {
      if store.settings.get().freeze-counter {
        show: apply-cover-counters.with(covering: store.settings.get().frozen-counters)
        it
      } else {
        it
      }
    }
  )

  // Put the first slide for steps data. 
  subslide(1, body, logical-slide: logical-slide)

  context if not store.settings.get().handout {
    let steps = if steps != auto {
      steps
    } else {
      store.dynamics.get().steps
    }
    // marks here because now we know the current number of steps.
    freeze-counter-marker(1, steps)
    pagebreak(weak: true)
    if not store.settings.get().handout {
      for i in range(2, steps + 1) {
        subslide(i, body, logical-slide: logical-slide)
        freeze-counter-marker(i, steps)
      }
    }
  }
}
