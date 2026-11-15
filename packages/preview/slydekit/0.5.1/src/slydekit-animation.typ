#import "slydekit-defaults.typ": *

#let split-at-pause(body) = {
  // If body is not a sequence of elements, there are no pauses
  if body.func() != [].func() {
    return (body,)
  }

  let chunks = ()
  let current-chunk = ()

  for child in body.children {
    if child.has("label") and child.label == <sk-pause> {
      chunks.push(current-chunk.join())
      current-chunk = ()
    } else {
      current-chunk.push(child)
    }
  }

  chunks.push(current-chunk.join())

  // Always return at least one chunk, even if body ends up empty, so callers spreading chunks.len() values into calc.max(..) never receive a zero-length array
  if chunks.len() == 0 {
    chunks.push([])
  }

  return chunks
}

// Splits body into parallel tracks at <sk-meanwhile> boundaries, mirroring split-at-pause exactly. Each track is then split-at-pause'd on its own by the caller (slide()), and all tracks advance on the same subslide clock, which reproduces Touying's #meanwhile: content after #meanwhile gets its own local pause chain instead of being appended to the one before it.
#let split-at-meanwhile(body) = {
  if body.func() != [].func() {
    return (body,)
  }

  let tracks = ()
  let current-track = ()

  for child in body.children {
    current-track.push(child)
    if child.has("label") and child.label == <sk-meanwhile> {
      tracks.push(current-track.join())
      current-track = ()
    }
  }

  // Always push the trailing track, even if it's empty, so this always returns at least one track (a body with zero children, or a #meanwhile right at the end, would otherwise yield an empty array, and calc.max(..tracks.map(t => t.len())) in slide() requires at least one value)
  tracks.push(if current-track.len() > 0 { current-track.join() } else { [] })

  return tracks
}

// Recursive traversal of the AST (Abstract Syntax Tree) to determine the maximum step requested by uncover/only
#let analyze-max-step(body) = {
  let rec(it) = {
    if type(it) == content {
      let current-max = 1

      // If the element is our animation metadata
      if it.has("label") and it.label == <sk-reveal> and it.has("value") {
        let val = it.value
        let upper = if val.int-or-range.len() > 0 {
          calc.max(..val.int-or-range)
        } else if val.to != none {
          val.to
        } else { val.from }
        current-max = calc.max(current-max, upper)
      }

      // Recursive inspection of the element's fields
      for (key, val) in it.fields() {
        current-max = calc.max(current-max, rec(val))
      }
      return current-max

    } else if type(it) == array {
      let current-max = 1
      for item in it {
        current-max = calc.max(current-max, rec(item))
      }
      return current-max

    } else if type(it) == dictionary {
      let current-max = 1
      for (key, val) in it {
        current-max = calc.max(current-max, rec(val))
      }
      return current-max

    } else {
      return 1
    }
  }

  rec(body)
}

#let reveal-visible(
  step,
  int-or-range,
  from,
  to,
) = {
  if int-or-range.len() > 0 {
    step in int-or-range
  } else {
    step >= from and (to == none or step <= to)
  }
}

#let _reveal(..args) = {
  let pos = args.pos()
  let body = pos.last()
  let int-or-range = pos.slice(0, -1)
  let from = args.named().at("from", default: 1)
  let to = args.named().at("to", default: none)
  let hide-color = args.named().at("hide-color", default: none)
  let reserved = args.named().at("reserved", default: true)
  let hide-fn = args.named().at("hide-fn", default: none)

  // Dynamic rendering of the element according to the current step
  let anim-content = context {
    let step = sk-states.subslide-step.get().first()
    let visible = reveal-visible(step, int-or-range, from, to)

    if visible {
      body
    } else if hide-fn != none {
      // Allows a third-party package to provide its own masking
      hide-fn(body)
    } else if reserved {
      if hide-color != none {
        text(fill: hide-color, body)
      } else {
        hide(body)
      }
    } else {
      none
    }
  }

  // Metadata for the animation, to be used by the reveal() function
  [#metadata((
    int-or-range: int-or-range,
    from: from,
    to: to,
  ))<sk-reveal>#anim-content]
}

// #let pause = <sk-pause>
// #let meanwhile = <sk-meanwhile>
//
// pause/meanwhile are wrapped in metadata(none) rather than used as bare labels: a bare label reference (e.g. #let pause = <sk-pause>) attaches to the preceding content element instead of becoming its own node in the sequence. That silently breaks split-at-pause/split-at-meanwhile whenever the preceding element sits inside a style wrapper (see style-body-with-pauses in slydekit-slide.typ), and silently drops a second #pause placed right after a first one, since a single element can only carry one label. Wrapping in metadata(none) makes each #pause/#meanwhile its own standalone node, exactly like <sk-slide-parser-boundary> and anim-label already do.
#let pause = [#metadata(none)<sk-pause>]
#let meanwhile = [#metadata(none)<sk-meanwhile>]
#let uncover = _reveal
#let only = _reveal.with(reserved: false)

// split-at-pause/split-at-meanwhile only ever look at the direct children of a sequence, so a <sk-pause>/<sk-meanwhile> hidden behind a layout wrapper - a #set scope (`#[#set align(center) a #pause b]`) or `#align(..)[a #pause b]` - is invisible to them and never animates. Naively splitting such a wrapper's content and re-instantiating the wrapper once per chunk would "fix" the visibility, but multiplies a block-level wrapper (e.g. #set align(center)) into one independent block per chunk, which is a different, worse bug (each chunk ends up on its own line). resolve-nested-pauses instead rewrites the pauses/meanwhiles into an uncover(from: ..) chain applied *inside* the wrapper, which is only ever instantiated once.
//
// Splits body into tracks at <sk-meanwhile>, each track into chunks at <sk-pause>, and flattens the result into a sequence of uncover(from: ..) calls, one per chunk, restarting the index at each new track - exactly mirroring how slide() renders tracks/chunks. `resolve` is applied to each chunk to recurse into further nested wrappers; taking it as a parameter (rather than calling resolve-nested-pauses by name) avoids a forward reference between the two functions below.
#let _tracks-to-uncover-chain(body, resolve) = {
  split-at-meanwhile(body).map(split-at-pause).map(chunks => {
    chunks.enumerate().map(((idx, chunk)) => uncover(from: idx + 1, resolve(chunk))).join()
  }).join()
}

// Single-body layout containers whose every field except `body` is named, so they round-trip as `func()(..other-fields, new-body)` - `body` dropped from the field dict and re-supplied positionally (passing it by name errors: `block(body: ..)` is rejected). Multi-child layout elements (grid, stack, table...) whose children can't be reconstructed this way, and inline markup elements (emph, strong, link...) where a #pause makes no sense, are deliberately left out.
#let _pause-container-funcs = (block, box, pad)

// #set scopes, and a handful of layout containers, are descended into and rebuilt so a <sk-pause>/<sk-meanwhile> buried inside one still animates. A #set scope is rebuilt via its own func()(body, styles); align and columns have a positional-only leading field and are rebuilt by hand; the _pause-container-funcs are rebuilt generically from their field dict. Any other function call still can't be reconstructed from body.fields() alone (a field that isn't actually positional would be misassigned), so a pause buried in anything else stays invisible to the splitter.
#let resolve-nested-pauses(body) = {
  if type(body) != content {
    return body
  }

  // Structural markers we must never rebuild, since is-slide-marker/heading detection in slide-parser relies on their exact identity.
  if body.func() == metadata or body.func() == heading {
    return body
  }

  if body.func() == [].func() {
    return body.children.map(resolve-nested-pauses).join()
  }

  let is-style = body.has("child") and body.has("styles")
  let is-container = body.func() in _pause-container-funcs and body.has("body")
  let is-align = body.func() == align
  let is-columns = body.func() == columns and body.has("body")

  let wrapped = if is-style {
    body.child
  } else if is-align or is-columns or is-container {
    body.body
  } else {
    none
  }

  if wrapped == none {
    return body
  }

  let tracks = split-at-meanwhile(wrapped).map(split-at-pause)
  let new-body = if tracks.len() <= 1 and tracks.first().len() <= 1 {
    resolve-nested-pauses(wrapped)
  } else {
    _tracks-to-uncover-chain(wrapped, resolve-nested-pauses)
  }

  if is-style {
    body.func()(new-body, body.styles)
  } else if is-align {
    align(body.alignment, new-body)
  } else if is-columns {
    let fields = body.fields()
    let count = fields.remove("count", default: 2)
    let _ = fields.remove("body", default: none)
    columns(count, ..fields, new-body)
  } else {
    let fields = body.fields()
    let _ = fields.remove("body", default: none)
    body.func()(..fields, new-body)
  }
}

// Rebuilds body as an equivalent uncover(from: ..) chain (see _tracks-to-uncover-chain), resolving any further nested wrapper along the way. Used by style-body-with-pauses (slydekit-slide.typ) to fold a style wrapper's pauses/meanwhiles into that single wrapper instance instead of splitting it into several.
#let pauses-to-uncover-chain(body) = _tracks-to-uncover-chain(body, resolve-nested-pauses)

// label, so nothing can land on it and overwrite it.
#let anim-label(lbl, step: 1) = context {
  let current = sk-states.subslide-step.get().first()
  if current == step {
    [#metadata(none)#lbl]
  }
}


// Reproduces the visibility logic of reveal(), but allows a third-party package (Fletcher, CeTZ...) to provide its own masking via the hide-fn argument. This is useful for packages that use their own visibility logic and own context, which are not compatible with uncover/only.
#let draw-reveal(..args, hide-fn: none, body) = {
  let step = sk-states.subslide-step.get().first()
  let int-or-range = args.pos()
  let from = args.named().at("from", default: 1)
  let to = args.named().at("to", default: none)

  let visible = reveal-visible(step, int-or-range, from, to)

  if visible {
    body
  } else {
    if hide-fn != none {
      hide-fn(body)
    }
  }
}

// Reveals a sequence of already-separated elements, one per step: element i becomes visible from step `start + i` onwards and stays. `item-by-item` builds on this after pulling the .item children out of a list/enum/terms.
#let one-by-one(start: 1, hide-color: none, hide-fn: none, ..children) = {
  for (idx, child) in children.pos().enumerate() {
    uncover(from: start + idx, hide-color: hide-color, hide-fn: hide-fn, child)
  }
}

// Reveals each element of a list, enumeration, or terms on its own step. On the model of Polylux's item-by-item: we never reconstruct list(..)/enum(..)/terms(..), we simply filter the direct children of body that are list.item/enum.item/terms.item and reveal them one by one via one-by-one. Typst then visually groups these adjacent items, regardless of whether they are each wrapped in an uncover.
#let item-by-item(start: 1, hide-color: none, hide-fn: none, body) = {
  let is-item(it) = type(it) == content and it.func() in (
    list.item, enum.item, terms.item
  )
  let children = if type(body) == content and body.has("children") {
    body.children
  } else {
    body
  }
  one-by-one(start: start, hide-color: hide-color, hide-fn: hide-fn, ..children.filter(is-item))
}

// Adapts a descriptor (integer = single step, dictionary (beginning: n) = open from n) to a call to only, the only vocabulary that alternatives needs
#let _only-for(descriptor, body) = {
  if type(descriptor) == dictionary {
    only(from: descriptor.beginning, body)
  } else {
    only(descriptor, body)
  }
}

// Displays different content per step, reserving the space of the largest among them. On the model of Polylux's alternatives-match/alternatives: each option is revealed by a separate only(..) call, so each declares its own <sk-reveal> metadata, without manual declaration of the number of steps.
#let alternatives-match(subslides-contents) = {
  let pairs = if type(subslides-contents) == dictionary {
    subslides-contents.pairs()
  } else {
    subslides-contents
  }

  context {
    for (descriptor, content) in pairs {
      _only-for(descriptor, content)
    }
  }
}

#let alternatives(start: 1, repeat-last: false, ..options) = {
  let contents = options.pos()
  let n = contents.len()

  if n == 0 { return none }

  let subslides = range(start, start + n)
  let descriptors = subslides.enumerate().map(((i, s)) => {
    if repeat-last and i == n - 1 { (beginning: s) } else { s }
  })

  [
    #metadata((int-or-range: (), from: start, to: start + n - 1))<sk-reveal>
    #alternatives-match(descriptors.zip(contents))
  ]
}

// Parallel track: local split by <sk-pause>, counted independently of the main flow, but synchronized on the same subslide clock. Replaces the use of #meanwhile from Touying: instead of a marker inserted in the flow, we wrap each parallel branch in track(..).
#let track(body) = {
  let chunks = split-at-pause(body)
  let n = chunks.len()

  let anim-content = context {
    let step = sk-states.subslide-step.get().first()
    let idx = calc.min(calc.max(step, 1), n)
    chunks.slice(0, idx).join()
  }

  [#metadata((int-or-range: (), from: 1, to: n))<sk-reveal>#anim-content]
}

// Code animation integration
#let raw-renderer(highlight-color: luma(90%), ..args) = (active, body) => {
  set raw(..args)
  show raw.line: it => if it.number in active {
    highlight(fill: highlight-color, it)
  } else {
    it
  }
  body
}

#let codly-renderer(codly-fn, highlight-color: luma(90%), ..args) = (active, body) => {
  codly-fn(highlights: active.map(l => (line: l, fill: highlight-color), ..args))
  body
  codly-fn()
}

#let zebraw-renderer(zebraw-fn, highlight-color: rgb("e0f5f2"), ..args) = (active, body) => {
  zebraw-fn(
    highlight-lines: active.map(l => (l, highlight-color)),
    ..args,
    body,
  )
}

// Helper function required to process the body when zebraw-renderer is used. This is required because, starting with zebraw 0.6.x, zebraw no longer lets Typst simply compose raw.line. It retrieves it.lines, processes the lines itself with process-lines, then reconstructs the block with grids.
#let process-raw-body(body, hidden) = {
  if type(body) == content {
    if body.func() == raw {
      let lines = body.text.split("\n")
      let filtered-text = lines.enumerate().map(((idx, line)) => {
        if (idx + 1) in hidden { "" } else { line }
      }).join("\n")
      return raw(filtered-text, lang: body.lang, block: body.block)
    } else if body.has("children") {
      return body.children.map(c => process-raw-body(c, hidden)).join()
    }
  }
  return body
}

#let code-reveal(
  highlight-lines: (:),
  hide-lines: (:),
  renderer: raw-renderer(),
  body,
) = {
  let step-value(v) = if type(v) == array { calc.max(..v) } else { v }
  let max-step = calc.max(
    1,
    ..highlight-lines.values().map(step-value),
    ..hide-lines.values().map(step-value),
  )
  [#metadata((int-or-range: (), from: 1, to: max-step))<sk-reveal>]

  context {
    let step = sk-states.subslide-step.get().first()

    let active = highlight-lines.pairs()
      .filter(((_, v)) => if type(v) == array { step in v } else { step == v })
      .map(((k, _)) => int(k))

    let hidden = hide-lines.pairs()
      .filter(((_, v)) => if type(v) == array { step not in v } else { step < v })
      .map(((k, _)) => int(k))

    show raw.line: it => if it.number in hidden { std.hide(it) } else { it }

    // Process the body to hide lines that are not active, so that the renderer receives a body with only the visible lines. This is necessary for the zebraw-renderer, which need to know the line numbers of the visible lines to apply highlighting correctly.
    let new-body = process-raw-body(body, hidden)

    renderer(active, new-body)
  }
}

// Reusable animations
// An animated block written once as an ordinary value (with #pause, #meanwhile, #uncover, #only, ...) can be rendered wherever it is needed via render-animation, either in full or one window of steps at a time. The main use case is splitting an animation across *several* slides: it can be paused, other slides shown, and then resumed exactly where it left off. Every window re-shows the earlier steps in their fully-revealed state and animates only the steps inside its window.

// Total number of animation steps in `body`, computed exactly like slide() computes its own `total`.
#let animation-length(body) = {
  body = resolve-nested-pauses(body)
  if body == none { body = [] }
  let tracks = split-at-meanwhile(body).map(split-at-pause)
  let max-track-length = calc.max(..tracks.map(t => t.len()))
  calc.max(max-track-length, analyze-max-step(body))
}

// Turns the same `int-or-range` / `from` / `to` selector `_reveal` accepts into an inclusive `(start, end)` window of global animation steps, clamped to `1..length`. A render window is contiguous by nature (you cannot resume steps 2 and 4 while skipping 3 on one slide), so an `int-or-range` list is taken as its span `min..max`.
//   (no selector)          from: 1, to: none  -> (1, length)   whole animation
//   3                      -> (3, 3)                            a single step
//   2, 4                   -> (2, 4)                            span of the list
//   from: 3                -> (3, length)                       step 3 to the end
//   from: 2, to: 4         -> (2, 4)
//   to: 2                  -> (1, 2)
#let reveal-window(int-or-range, from, to, length) = {
  let clamp(n) = calc.min(calc.max(n, 1), length)
  let (lo, hi) = if int-or-range.len() > 0 {
    (calc.min(..int-or-range), calc.max(..int-or-range))
  } else {
    (from, if to == none { length } else { to })
  }
  (clamp(lo), clamp(calc.max(hi, lo)))
}

// Renders a reusable animation, in full or one window at a time. Takes the same selector as `#uncover` / `#only`: positional step numbers (`int-or-range`) plus named `from:` / `to:`, with `body` as the last positional argument. No selector at all renders the whole animation (behaves like dropping `body` inline).
//
// The enclosing slide() gets exactly `end - start + 1` sub-steps, whatever absolute steps `body`'s own uncover/only calls happen to mention: the <sk-reveal> marker is emitted outside the `context` below, and slide()'s analyze-max-step does not recurse through `context` nodes, so the body's own eager markers stay invisible to it.
//
// Inside the context, this slide's *local* sub-step is mapped onto the global animation clock by temporarily setting the shared `subslide-step` counter, so every uncover/only/#pause in `body`, and any package that reads the counter, resolves against the right global step with no per-call rewriting. Steps before `start` are simply already visible (`uncover(from: k)` with `k < start` is shown), so earlier windows reappear fully revealed and static.
#let render-animation(..args) = {
  let pos = args.pos()
  let body = pos.last()
  let int-or-range = pos.slice(0, -1)
  let from = args.named().at("from", default: 1)
  let to = args.named().at("to", default: none)

  let length = animation-length(body)
  let (start, end) = reveal-window(int-or-range, from, to, length)
  let window = end - start + 1

  // Generate the metadata for the animation window.
  [#metadata((int-or-range: (), from: 1, to: window))<sk-reveal>]

  context {
    let here = sk-states.subslide-step.get().first()
    // Clamp so a slide that carries more sub-steps than this window (extra top-level #pause around the call, handout mode, an explicit `steps:` on the slide) never runs off either end of the animation.
    let local = calc.min(calc.max(here, 1), window)
    let global = calc.min(calc.max(start - 1 + local, 1), length)

    sk-states.subslide-step.update(global)
    pauses-to-uncover-chain(body)
    // Restore the local clock for anything else living on this slide.
    sk-states.subslide-step.update(here)
  }
}