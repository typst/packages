#import "themes/themes.typ"
#import "paper.typ": papers

// Counter for pauses and for automatic tracking of subslide number.
// First value: number of subslides so far referenced in current slide.
// Second value: number of pauses so far in current slide.
// Both values are kept in one state so that an update function can update the
// number of subslides based on the number of pauses, without requiring a
// context. This avoids problems with layout convergence.
#let _subslide-count = state("__minideck-subslide-count", (0, 0))

// Current subslide being generated for current slide
#let _subslide-step = state("__minideck-subslide-step", 0)

// Return a state update for `_subslide_count` ensuring that the subslide count
// (first counter value) is at least `n`.
#let update-subslide-count(n) = _subslide-count.update(((x, y)) => (calc.max(n, x), y))

// Return a state update for `_subslide_count` to increment the pause index
// (first value) and to ensure that the subslide count is at least equal to the
// new pause index.
#let update-by-pause() = _subslide-count.update(((x, y)) => (calc.max(x, y+2), y+1))

// If `handout` is `auto`, infer its value from command-line input
#let _is-handout(handout) = {
  if handout == auto {
    sys.inputs.at("handout", default: none) == "true"
  } else {
    handout
  }
}

// Format `it` as content of a (sub)slide
#let _subslide-content(it) = {
  pagebreak(weak: true)
  it
}

// Show one subslide of the slide.
// The subslide counter starts at 0 for every subslide, so that its
// value can be used in the subslide to compare with `_subslide-step`.
#let _subslide(n, it) = {
  _subslide-count.update((1,0))
  _subslide-step.update(n)
  _subslide-content({
    // Revert page increment unless it's the first subslide for this slide
    if n > 0 { counter(page).update(x => calc.max(0, x - 1))  }
    it
  })
}

// Hide content if current subslide step is smaller than pause index.
#let _pause(updater, hider, it) = {
  let pause-index = _subslide-count.get().at(1)
  if _subslide-step.get() < pause-index{ hider(it) } else { it } 
}

// Increase pause counter and hide content if current `_subslide-step` is
// smaller. Use this function as `#show: pause` or `#show: pause.with(...)`.
// `updater` is a callback that returns a state update for `_subslide-count` to
// increment the pause index (second counter value) and to ensure that the
// subslide count (first counter value) is at least the pause index plus 1. This
// callback is normally `update-by-pause`.
// `hider` is the callback used to hide `it` when appropriate.
// If `handout` is `true`, dynamic features are disabled: all slide content is
// shown in a single subslide. If `auto`, the value is taken as `true` if
// `--input handout=true` is passed on the command line, `false` otherwise.
// If `opaque` is true, the result will already have `context` invoked, otherwise
// the caller is responsible for invoking `context` in a suitable scope.
#let pause(handout: auto, opaque: true, updater: update-by-pause, hider: hide, it) = {
  if _is-handout(handout) {
    return it
  }
  update-by-pause()
  if opaque {
    context _pause(updater, hider, it)
  } else {
    // return non-opaque content: caller must ensure context is available
    _pause(updater, hider, it)
  }
}

// Hide `it` on all given subslide indices and/or starting at `from`.
// Subslide indices start at 1.
#let _process-impl(updater, hider, indices, from, it) = {
  // Convert zero-based subslide step to 1-based user-facing subslide index
  let j = _subslide-step.get() + 1
  let from-array = if from == none { () } else { (from,) }
  if updater != none {
    updater(calc.max(..indices, ..from-array))
  }
  let visible = (from != none and j >= from) or j in indices
  if visible { it } else { hider(it) }
}

// Hide `it` on all given subslide indices and/or starting at `from`.
// Subslide indices start at 1.
// This is used by `uncover` (hider=hide) and `only` (hider=`it=>none`).
// `updater` is a callback that takes a number `n` and returns a state update
// for `_subslide-count` to ensure that the first counter value is at least `n`.
// This callback is normally `update-subslide-count`, but CeTZ needs one that
// returns a CeTZ element.
// `hider` is the callback used to hide `it` when appropriate.
// If `handout` is `true`, dynamic features are disabled: all slide content is
// shown in a single subslide. If `auto`, the value is taken as `true` if
// `--input handout=true` is passed on the command line, `false` otherwise.
// If `opaque` is true, the result will already have `context` invoked, otherwise
// the caller is responsible for invoking `context` in a suitable scope.
#let _process(handout, opaque, updater, hider, indices, from, it) = {
  if _is-handout(handout) {
    return it
  }
  if opaque {
    context _process-impl(updater, hider, indices, from, it)
  } else {
    // return non-opaque content: caller must ensure context is available
    _process-impl(updater, hider, indices, from, it)
  }
}

// Uncover `it` on all given subslide indices and/or from given index.
// Subslide indices start at 1.
// See `_process` for the other parameters.
#let uncover(from: none,
             handout: auto,
             opaque: true,
             updater: update-subslide-count,
             hider: hide,
             ..indices, it) = _process(handout, opaque, updater, hider, indices.pos(), from, it)

// Include `it` on all given subslide indices and/or from given index.
// Subslide indices start at 1.
// See `_process` for the other parameters.
#let only(from: none,
          handout: auto,
          opaque: true,
          updater: update-subslide-count,
          hider: it => none,
          ..indices, it) = _process(handout, opaque, updater, hider, indices.pos(), from, it)

// Generate subslides with number of steps given explicitly
#let _slide-explicit(steps, it) = {
  for i in range(0, steps) {
    _subslide(i, it)
  }
}

// Generate subslides with number of steps derived from the subslide counter.
// This requires an up-to-date subslide counter (see `slide`).
#let _slide-auto(it) = {
  // Each slide is shown at least once
  _subslide(0, it)
  // After showing slide once, _subslide-count holds the number of subslides
  context for i in range(1, _subslide-count.get().first()) {
    _subslide(i, it)
  }
}

// Make a new slide made of `steps` subslides. If steps is auto, the number of
// subslides is determined automatically by updating a state (this requires that
// `uncover` and `only` are configured with a valid updater callback, and that
// they are called from a place where the update can be inserted).
#let slide(handout: auto, steps: auto, it) = {
  if _is-handout(handout) {
    return _subslide-content(it)
  }
  if steps == auto {
    _slide-auto(it)
  } else {
    _slide-explicit(steps, it)
  }
}

// Calculate paper size from all parameters
#let paper-size(paper, landscape, width, height) = {
  let size = papers.at(paper)
  let (w, h) = (size.width*1mm, size.height*1mm)
  if landscape and w < h {
    (w, h) = (h, w)
  }
  (
    width: if width == none { w } else { width },
    height: if height == none { h } else { height },
  )
}

// Return a dictionary of functions that implement the given configuration
// settings. For example use `(slide, uncover) = config(handout: true)` to
// define `slide` and `uncover` functions that work in handout mode. 
//
// Named parameters:
//
// - paper: a string for one of the paper size names recognized by page.paper
//   or one of the shorthands "16:9" or "4:3". Default: "4:3".
// - landscape: use the paper size in landscape orientation. Default: `true`
// - width: page width as an absolute length, takes precedence over `paper`
// - height: page height as an absolute length, takes precedence over `paper`
// - handout: when `true`, dynamic features are disabled: all slide content is
//   shown in a single subslide. When set to `auto`, the value used is `true` if
//   `--input handout=true` is passed on the command line, `false` otherwise.
// - theme: the theme to use, the default being `themes.simple`
// - cetz: if the CeTZ module is passed here, the returned dictionary will
//   include `cetz-uncover` and `cetz-only`, which are versions of `uncover`
//   and `only` configured to use cetz methods for hiding and state update.
// - fletcher: if the fletcher module is passed here, the returned dictionary
//   will include `fletcher-uncover` and `fletcher-only`, which are versions
//   of `uncover` and `only` that use `fletcher.hide` for hiding and that
//   disable state update (so the number of slide steps must be given to `slide`
//   explicitly).
//
// Functions configured for CeTZ and fletcher return non-opaque content, so the
// caller is responsible for invoking `context` in a suitable scope, typically
// as in `#context cetz.canvas({...})`.
#let config(
  paper: "4:3",
  landscape: true,
  width: none,
  height: none,
  handout: auto,
  theme: themes.simple,
  cetz: none,
  fletcher: none,
) = {
  let slide = slide.with(handout: handout) 
  let page-size = paper-size(paper, landscape, width, height)
  let theme-funcs = theme(slide, page-size: page-size)
  (
    pause: pause.with(handout: handout),
    uncover: uncover.with(handout: handout),
    only: only.with(handout: handout),
    ..theme-funcs,
  )
  if cetz != none {
    let cetz-update(n) = cetz.draw.content((), update-subslide-count(n))
    (
      cetz-uncover: uncover.with(
        handout: handout,
        opaque: false,
        updater: cetz-update,
        hider: it => cetz.draw.hide(it, bounds: true),
      ),
      cetz-only: only.with(
        handout: handout,
        opaque: false,
        updater: cetz-update,
      ),
    )
  }
  if fletcher != none {
    (
      fletcher-uncover: uncover.with(
        handout: handout,
        opaque: false,
        updater: none,
        hider: it => fletcher.hide(it, bounds: true),
      ),
      fletcher-only: only.with(
        handout: handout,
        opaque: false,
        updater: none,
      ),
    )
  }
}
