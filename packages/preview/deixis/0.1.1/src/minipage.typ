#import "core.typ": *

/// Creates an isolated, self-contained layout environment for notes.
///
/// A minipage acts as a sub-document. Any notes declared inside it (like margin notes or footnotes)
/// are strictly bound to its physical boundaries, and its note counters operate independently of the
/// main document flow. This is essential for creating complex layouts like infoboxes, sidebars, or
/// custom chapter summaries without breaking global note numbering.
///
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-footnote[This is a page footnote.]
/// #deixis-block(inset: 5pt, fill: gray.lighten(90%))[
///   Inside a `#deixis-block`, notes have its own counter system and layout behaviors.
///   #deixis-footnote[This is a block-level footnote.]
/// ]
/// ```
///
/// ````experiment
/// You can nest `#deixis-block`, infinitely, but it will be hyper fragile.
///
/// ```example
/// //| sandbox-mode: "page"
/// #deixis-block(inset: 5pt, fill: red.lighten(90%))[
///   #deixis-footnote[Level 1.]
///   #deixis-block(inset: 5pt, fill: orange.lighten(90%))[
///     #deixis-footnote[Level 2.]
///     #deixis-block(inset: 5pt, fill: yellow.lighten(90%))[
///       #deixis-footnote[Level 3.]
///       #deixis-block(inset: 5pt, fill: green.lighten(90%))[
///         You are wandering into the unknown#deixis-footnote[Level 4.].
///       ]
///     ]
///   ]
/// ]
/// ```
/// ````
///
/// - id (auto, str): A unique identifier for this layout context. If `auto`, the engine generates one automatically.
/// - thread (none, str): Allows multiple separate minipages to share the same continuous note counter. Pass a matching string to link them into the same "thread".
/// - sync-counters-with (auto, int, label, str): Synchronize internal counters with another `#deixis-block` or the global document counters rather than starting from 1.
/// - width (auto, length, relative): See #link("https://typst.app/docs/reference/layout/block/#parameters-width")[`std.block.width`].
/// - height (auto, length, relative): See #link("https://typst.app/docs/reference/layout/block/#parameters-height")[`std.block.height`].
/// - breakable (auto, bool): See #link("https://typst.app/docs/reference/layout/block/#parameters-breakable")[`std.block.breakable`].
/// - fill (auto, color, none): See #link("https://typst.app/docs/reference/layout/block/#parameters-fill")[`std.block.fill`].
/// - stroke (auto, stroke, none): See #link("https://typst.app/docs/reference/layout/block/#parameters-stroke")[`std.block.stroke`].
/// - radius (auto, length, dictionary): See #link("https://typst.app/docs/reference/layout/block/#parameters-radius")[`std.block.radius`].
/// - inset (auto, length, dictionary): See #link("https://typst.app/docs/reference/layout/block/#parameters-inset")[`std.block.inset`].
/// - outset (auto, length, dictionary): See #link("https://typst.app/docs/reference/layout/block/#parameters-outset")[`std.block.outset`].
/// - spacing (auto, length): See #link("https://typst.app/docs/reference/layout/block/#parameters-spacing")[`std.block.spacing`].
/// - above (auto, length): See #link("https://typst.app/docs/reference/layout/block/#parameters-above")[`std.block.above`].
/// - below (auto, length): See #link("https://typst.app/docs/reference/layout/block/#parameters-below")[`std.block.below`].
/// - clip (auto, bool): See #link("https://typst.app/docs/reference/layout/block/#parameters-clip")[`std.block.clip`].
/// - sticky (auto, bool): See #link("https://typst.app/docs/reference/layout/block/#parameters-sticky")[`std.block.sticky`].
/// - ..args (arguments): Accepts at most 1 positional argument: `[body]`, the content of the minipage.
///
/// -> content
#let deixis-block(
  /// A unique identifier for this layout context. If `auto`, the engine generates one automatically.
  /// -> auto | str
  id: auto,
  /// Allows multiple separate minipages to share the same continuous note counter. Pass a matching string to link them into the same "thread".
  ///
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-block(thread: "green", inset: 5pt, fill: green.lighten(90%))[
  ///   #deixis-footnote[This block belongs to the `"green"` thread.]
  /// ]
  ///
  /// #deixis-block(inset: 5pt, fill: red.lighten(90%))[
  ///   #deixis-footnote[This block does not, hence, its notes count from 1.]
  /// ]
  ///
  /// #deixis-block(thread: "green", inset: 5pt, fill: green.lighten(90%))[
  ///   #deixis-footnote[This block also belongs to the `"green"` thread.]
  /// ]
  /// ```
  ///
  /// ````tip
  /// `thread` cannot be used to sync counters with the `"page"`.
  /// For that purpose, use @deixis-block.sync-counters-with.
  /// ```experiment
  /// `thread` and `sync-counters-with` can be used together, at your own risk.
  /// ```
  /// ````
  ///
  /// -> none | str
  thread: none,
  /// Synchronize internal counters with another `#deixis-block` or the global document counters rather than starting from 1.
  /// - Accepts `int` for going up in the stack level, and `"page"` for the document global.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-block(sync-counters-with: "page", inset: 5pt, fill: red.lighten(90%))[
  ///   #deixis-footnote[This block shares its counters with the document.]
  /// ]
  ///
  /// #deixis-block(sync-counters-with: -1, inset: 5pt, fill: orange.lighten(90%))[
  ///   #deixis-footnote[Same for this block.]
  /// ]
  /// ```
  /// - Also accepts `label` or `str` for targetting another `#deixis-block`.
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-block(id: <blue-block>, inset: 5pt, fill: blue.lighten(90%))[
  ///   #deixis-footnote[This block is given an `id: <blue-block>`.]
  /// ]
  ///
  /// #deixis-block(sync-counters-with: <blue-block>, inset: 5pt, fill: teal.lighten(90%))[
  ///   #deixis-footnote[This block shares its counters with `<blue-block>`.]
  /// ]
  /// ```
  ///
  /// ```tip
  /// To sync counters of multiple blocks, it is more convenient to use @deixis-block.thread.
  /// ```
  ///
  /// -> auto | int | label | str
  sync-counters-with: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-width")[`std.block.width`].
  /// -> auto | length | relative
  width: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-height")[`std.block.height`].
  /// -> auto | length | relative
  height: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-breakable")[`std.block.breakable`].
  /// -> auto | bool
  breakable: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-fill")[`std.block.fill`].
  /// -> auto | color | none
  fill: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-stroke")[`std.block.stroke`].
  /// -> auto | stroke | none
  stroke: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-radius")[`std.block.radius`].
  /// -> auto | length | dictionary
  radius: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-inset")[`std.block.inset`].
  ///
  /// ```info
  /// The left and right inset of a `#deixis-block` is where block-level @deixis-margin-note-body are rendered.
  /// ```
  ///
  /// -> auto | length | dictionary
  inset: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-outset")[`std.block.outset`].
  /// -> auto | length | dictionary
  outset: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-spacing")[`std.block.spacing`].
  /// -> auto | length
  spacing: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-above")[`std.block.above`].
  /// -> auto | length
  above: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-below")[`std.block.below`].
  /// -> auto | length
  below: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-clip")[`std.block.clip`].
  /// -> auto | bool
  clip: auto,
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-sticky")[`std.block.sticky`].
  /// -> auto | bool
  sticky: auto,
  /// Accepts at most 1 positional argument: `[body]`, the content of the minipage.
  /// See #link("https://typst.app/docs/reference/layout/block/#parameters-body")[`std.block.body`].
  /// -> arguments
  ..args,
) = {
  if args.named().len() > 0 {
    panic("deixis: Unknown named argument(s) " + repr(args.named().keys()) + " passed to #deixis-block.")
  }
  if args.pos().len() > 1 {
    panic("deixis: #deixis-block accepts at most 1 positional argument (the body).")
  }

  context _deixis-check-setup-state()
  std.counter("deixis-block-inst").step()

  context {
    let body = args.pos().at(0, default: [])

    let c-val = std.counter("deixis-block-inst").get().first()
    let inst-id = if id != auto { str(id) } else { str(c-val) }
    let sys = deixis-system.get()

    let actual-render-id = if thread != none { "thread-" + thread } else { inst-id }
    let actual-count-id = if sync-counters-with != auto {
      _deixis-resolve-target(sys, sync-counters-with).count-id
    } else if (
      thread != none
    ) { "thread-" + thread } else { actual-render-id }

    let m-inset = deixis-utils.get-margins(if inset != auto { inset } else { 0pt })
    let l-space = deixis-utils.resolve-len(m-inset.left)
    let r-space = deixis-utils.resolve-len(m-inset.right)

    let safe-block-args = (:)
    if width != auto { safe-block-args.insert("width", width) }
    if height != auto { safe-block-args.insert("height", height) }
    if breakable != auto { safe-block-args.insert("breakable", breakable) }
    if fill != auto { safe-block-args.insert("fill", fill) }
    if stroke != auto { safe-block-args.insert("stroke", stroke) }
    if radius != auto { safe-block-args.insert("radius", radius) }
    if outset != auto { safe-block-args.insert("outset", outset) }
    if spacing != auto { safe-block-args.insert("spacing", spacing) }
    if above != auto { safe-block-args.insert("above", above) }
    if below != auto { safe-block-args.insert("below", below) }
    if clip != auto { safe-block-args.insert("clip", clip) }
    if sticky != auto { safe-block-args.insert("sticky", sticky) }

    block(inset: m-inset, ..safe-block-args, {
      deixis-system.update(sys => {
        sys.stack.push((
          inst-id: inst-id,
          render-id: actual-render-id,
          count-id: actual-count-id,
          left-space: l-space,
          right-space: r-space,
        ))
        if id != auto { sys.blocks.insert(str(id), sys.stack.last()) }
        return sys
      })

      block(width: 100%, height: 0pt, above: 0pt, below: 0pt, {
        box(width: 0pt, height: 0pt)[#metadata((
          id: inst-id,
          render-id: actual-render-id,
          thread: thread,
          l-space: l-space,
          r-space: r-space,
        ))<deixis-block-start>]
        place(top + right, box(width: 0pt, height: 0pt)[#metadata((id: inst-id))<deixis-block-right>])
      })

      body

      context {
        let block-fn-data = query(<deixis-footnote>)
          .filter(x => x.value.inst-id == inst-id and x.value.target-id == actual-render-id)
          .map(x => x.value)
        if block-fn-data.len() > 0 {
          if height != auto {
            colbreak()
            v(1e-10fr)
          }

          deixis-group-layout(block-fn-data)
        }
      }

      block(width: 100%, height: 0pt, above: 0pt, below: 0pt)[#box(width: 0pt, height: 0pt)[#metadata((
        id: inst-id,
        render-id: actual-render-id,
        thread: thread,
      ))<deixis-block-end>]]
      deixis-system.update(sys => {
        let popped = sys.stack.pop()
        return sys
      })
    })
  }
}

/// Creates an isolated layout environment for notes, utilizing `margin` instead of `inset`/`outset`.
///
/// This is just a convenience wrapper around `#deixis-block`.
/// It forward calls to `#deixis-block` with `inset: margin` and `outset: 0pt` by default.
///
/// See `#deixis-block` for details about parameters.
///
/// - id (auto, str): A unique identifier for this layout context. If `auto`, the engine generates one automatically.
/// - thread (none, str): Allows multiple separate minipages to share the same continuous note counter. Pass a matching string to link them into the same "thread".
/// - sync-counters-with (auto, int, label, str): Synchronize internal counters with another `#deixis-block` or the global document counters rather than starting from 1.
/// - width (auto, length, relative): See #link("https://typst.app/docs/reference/layout/block/#parameters-width")[`std.block.width`].
/// - height (auto, length, relative): See #link("https://typst.app/docs/reference/layout/block/#parameters-height")[`std.block.height`].
/// - breakable (auto, bool): See #link("https://typst.app/docs/reference/layout/block/#parameters-breakable")[`std.block.breakable`].
/// - fill (auto, color, none): See #link("https://typst.app/docs/reference/layout/block/#parameters-fill")[`std.block.fill`].
/// - stroke (auto, stroke, none): See #link("https://typst.app/docs/reference/layout/block/#parameters-stroke")[`std.block.stroke`].
/// - radius (auto, length, dictionary): See #link("https://typst.app/docs/reference/layout/block/#parameters-radius")[`std.block.radius`].
/// - margin (auto, length, dictionary): See ```ref #deixis-block.inset```.
/// - spacing (auto, length): See #link("https://typst.app/docs/reference/layout/block/#parameters-spacing")[`std.block.spacing`].
/// - above (auto, length): See #link("https://typst.app/docs/reference/layout/block/#parameters-above")[`std.block.above`].
/// - below (auto, length): See #link("https://typst.app/docs/reference/layout/block/#parameters-below")[`std.block.below`].
/// - clip (auto, bool): See #link("https://typst.app/docs/reference/layout/block/#parameters-clip")[`std.block.clip`].
/// - sticky (auto, bool): See #link("https://typst.app/docs/reference/layout/block/#parameters-sticky")[`std.block.sticky`].
/// - ..args (arguments): Accepts at most 1 positional argument: `[body]`, the content of the minipage.
///
/// -> content
#let deixis-minipage(
  id: auto,
  thread: none,
  sync-counters-with: auto,
  width: auto,
  height: auto,
  breakable: auto,
  fill: auto,
  stroke: auto,
  radius: auto,
  /// External margin pushing the block outward from surrounding content.
  /// -> auto | length | dictionary
  margin: auto,
  spacing: auto,
  above: auto,
  below: auto,
  clip: auto,
  sticky: auto,
  ..args,
) = {
  deixis-block(
    id: id,
    thread: thread,
    sync-counters-with: sync-counters-with,
    width: width,
    height: height,
    breakable: breakable,
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: margin,
    outset: 0pt,
    spacing: spacing,
    above: above,
    below: below,
    clip: clip,
    sticky: sticky,
    ..args,
  )
}
