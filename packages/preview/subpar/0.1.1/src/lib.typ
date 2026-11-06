#import "util.typ" as _util
#import "_pkg.typ"
#import "default.typ"

#let _numbering = numbering
#let _label = label
#let _grid = grid

/// The counter used for sub figures.
#let sub-figure-counter = counter("__subpar:sub-figure-counter")

/// Creates a figure which may contain other figures, a #emph[super]figure. For
/// the meaning of parameters take a look at the regular figure documentation.
///
/// See @@grid() for a function which places its sub figures in a grid.
///
/// - kind (str, function): The image kind which should be used, this is mainly
///   relevant for introspection and defaults to `image`. This cannot be
///   automatically resovled like for normal figures and must be set.
/// - numbering (str, function): This is the numbering used for this super
///   figure.
/// - numbering-sub (str, function): This is the numbering used for the sub
///   figures.
/// - numbering-sub-ref (str, function): This is the numbering used for
///   _references_ to the sub figures. If this is a function, it receives both
///   the super and sub figure numbering respectively.
/// - supplement (content, function, auto, none): The supplement used for this
///   super figure _and_ the sub figures when referenced.
/// - propagate-supplement (bool): Whether the super figure's supplement should
///   propagate down to its sub figures.
/// - caption (content): The caption of this super figure.
/// - placement (alignment, auto, none): The float placement of this super
///   figure.
/// - gap (length): The gap between this super figure's caption and body.
/// - outlined (bool): Whether this super figure should appear in an outline of
///   figures.
/// - outlined-sub (bool): Whether the sub figures should appear in an outline
///   of figures.
/// - label (label, none): The label to attach to this super figure.
/// - show-sub (function, auto): A show rule override for sub figures. Recevies
///   the sub figure.
/// - show-sub-caption (function, auto): A show rule override for sub figure's
///   captions. Receives the realized numbering and caption element.
/// -> content
#let super(
  kind: image,

  numbering: "1",
  numbering-sub: "(a)",
  numbering-sub-ref: "1a",

  supplement: auto,
  propagate-supplement: true,
  caption: none,
  placement: none,
  gap: 0.65em,
  outlined: true,
  outlined-sub: false,
  label: none,

  show-sub: auto,
  show-sub-caption: auto,

  body,
) = {
  _pkg.t4t.assert.any-type(str, function, kind)

  let assert-numbering = _pkg.t4t.assert.any-type.with(str, function)
  assert-numbering(numbering)
  assert-numbering(numbering-sub)
  assert-numbering(numbering-sub-ref)

  // adjust numberings to receive either both or the sub number
  numbering-sub = _util.sparse-numbering(numbering-sub)
  numbering-sub-ref = _util.sparse-numbering(numbering-sub-ref)

  _pkg.t4t.assert.any-type(str, content, function, type(auto), type(none), supplement)
  _pkg.t4t.assert.any-type(bool, propagate-supplement)
  _pkg.t4t.assert.any-type(str, content, type(none), caption)
  _pkg.t4t.assert.any(top, bottom, auto, none, placement)
  _pkg.t4t.assert.any-type(length, gap)
  _pkg.t4t.assert.any-type(bool, outlined)
  _pkg.t4t.assert.any-type(bool, outlined-sub)
  _pkg.t4t.assert.any-type(_label, type(none), label)

  _pkg.t4t.assert.any-type(function, type(auto), show-sub)
  _pkg.t4t.assert.any-type(function, type(auto), show-sub-caption)

  let function-kinds = (
    image: "figure",
    table: "table",
    raw: "raw",
  )

  // NOTE: if we use no propagation, then we can fallback to the normal auto behavior, fixing #4.
  if propagate-supplement and supplement == auto {
    if repr(kind) in function-kinds {
      supplement = context _util.i18n-kind(function-kinds.at(repr(kind)))
    } else {
      panic("Cannot infer `supplement`, must be set.")
    }
  }

  show-sub = _pkg.t4t.def.if-auto(it => it, show-sub)
  show-sub-caption = _pkg.t4t.def.if-auto((num, it) => it, show-sub-caption)

  context {
    let n-super = counter(figure.where(kind: kind)).get().first() + 1

    [#figure(
      kind: kind,
      numbering: n => _numbering(numbering, n),
      supplement: supplement,
      caption: caption,
      placement: placement,
      gap: gap,
      outlined: outlined,
      {
        // TODO: simply setting it for all doesn't seem to work
        show: _util.apply-for-all(
          _util.gather-kinds(body),
          kind => inner => {
            show figure.where(kind: kind): set figure(numbering: _ => _numbering(
              numbering-sub-ref, n-super, sub-figure-counter.get().first() + 1
            ))
            inner
          },
        )

        set figure(supplement: supplement) if propagate-supplement
        set figure(outlined: outlined-sub, placement: none)

        show figure: show-sub
        show figure: it => {
          let n-sub = sub-figure-counter.get().first() + 1
          let num = _numbering(numbering-sub, n-super, n-sub)
          show figure.caption: it => {
            num
            [ ]
            it.body
          }
          show figure.caption: show-sub-caption.with(num)

          sub-figure-counter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        sub-figure-counter.update(0)
        body
      },
    )#label]
  }
}

/// Provides a convenient wrapper around @@super() which puts sub figures in a
/// grid.
///
/// - columns (auto, int, relative, fraction, array): Corresponds to the grid's
///   `columns` parameter.
/// - rows (auto, int, relative, fraction, array): Corresponds to the grid's
///   `rows` parameter.
/// - gutter (auto, int, relative, fraction, array): Corresponds to the grid's
///   `gutter` parameter.
/// - column-gutter (auto, int, relative, fraction, array): Corresponds to the
///   grid's `column-gutter` parameter.
/// - row-gutter (auto, int, relative, fraction, array): Corresponds to the
///   grid's `row-gutter` parameter.
/// - align (auto, array, alignment, function): Corresponds to the grid's
///   `align` parameter.
/// - inset (relative, array, dictionary, function): Corresponds to the grid's
///   `inset` parameter.
/// - kind (str, function): Corressponds to the super figure's `kind`.
/// - numbering (str, function): Corressponds to the super figure's
///   `numbering`.
/// - numbering-sub (str, function): Corressponds to the super figure's
///   `numbering-sub`.
/// - numbering-sub-ref (str, function): Corressponds to the super figure's
///   `numbering-sub-ref`.
/// - supplement (content, function, auto, none): Corressponds to the super
///   figure's `supplement`.
/// - propagate-supplement (bool): Corressponds to the super figure's
///   `propagate-supplement`.
/// - caption (content): Corressponds to the super figure's `caption`.
/// - placement (alignment, auto, none): Corressponds to the super figure's
///   `placement`.
/// - gap (length): Corressponds to the super figure's `gap`.
/// - outlined (bool): Corressponds to the super figure's `outlined`.
/// - outlined-sub (bool): Corressponds to the super figure's `outlined-sub`.
/// - label (label, none): Corressponds to the super figure's `label`.
/// - show-sub (function): Corressponds to the super figure's `show-sub`.
/// - show-sub-caption (function): Corressponds to the super figure's
///   `show-sub-caption`.
/// -> content
#let grid(
  columns: auto,
  rows: auto,
  gutter: 1em,
  column-gutter: auto,
  row-gutter: auto,
  align: bottom,
  inset: (:),

  kind: image,

  numbering: "1",
  numbering-sub: "(a)",
  numbering-sub-ref: "1a",

  supplement: auto,
  propagate-supplement: true,
  caption: none,
  placement: none,
  gap: 0.65em,
  outlined: true,
  outlined-sub: false,
  label: none,

  show-sub: auto,
  show-sub-caption: auto,
  ..args,
) = {
  let assert-arg = _pkg.t4t.assert.any-type.with(type(auto), int, length, relative, fraction, array)
  assert-arg(columns)
  assert-arg(rows)
  assert-arg(gutter)
  assert-arg(column-gutter)
  assert-arg(row-gutter)

  _pkg.t4t.assert.any-type(type(auto), array, alignment, function, align)
  _pkg.t4t.assert.any-type(length, relative, array, dictionary, function, inset)

  if args.named().len() != 0 {
    panic("Unexpectd arguments: `" + repr(args.named()) + "`")
  }

  let figures = args.pos()

  // NOTE: the mere existence of an argument seems to change how grid behaves, so we discard any that are auto ourselves
  let grid-args = (
    columns: columns,
    rows: rows,
    align: align,
    inset: inset,
  )

  if gutter != auto {
    grid-args.gutter = gutter
  }
  if column-gutter != auto {
    grid-args.column-gutter = column-gutter
  }
  if row-gutter != auto {
    grid-args.row-gutter = row-gutter
  }

  super(
    kind: kind,
    numbering: numbering,
    numbering-sub: numbering-sub,
    numbering-sub-ref: numbering-sub-ref,

    supplement: supplement,
    propagate-supplement: propagate-supplement,
    caption: caption,
    placement: placement,
    gap: gap,
    outlined: outlined,
    outlined-sub: outlined-sub,
    label: label,

    show-sub: show-sub,
    show-sub-caption: show-sub-caption,

    _grid(
      .._util.stitch-pairs(figures).map(((f, l)) => [#f#l]),
      ..grid-args,
    ),
  )
}
