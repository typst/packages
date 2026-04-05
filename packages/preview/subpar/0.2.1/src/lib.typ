#import "default.typ"

/// The default overrides to use for figures, these are used to pass arguments
/// through to the elements directly.
///
/// -> dictionary
#let figure-overrides = (
  caption: "caption",
  placement: "placement",
  scope: "scope",
  gap: "gap",
  outlined: "outlined",
)

/// The default overrides to use for figures, these are used to pass arguments
/// through to the elements directly.
///
/// -> dictionary
#let grid-overrides = (
  columns: "columns",
  rows: "rows",
  gutter: "gutter",
  column-gutter: "column-gutter",
  row-gutter: "row-gutter",
  fill: "fill",
  align: "align",
  stroke: "stroke",
  inset: "inset",
)

/// The counter used for sub figures. This is automatically counted within and
/// reset after for each super figure.
///
/// -> counter
#let sub-figure-counter = counter("__subpar:sub-figure-counter")

/// Creates a figure which may contain other figures, a #emph[super]figure.
///
/// This function makes no assumptions about the layout of its sub figures, it
/// simply applies the necessary show and set rules such that all figures within
/// its body get the appropriate numbering.
///
/// See @cmd:grid for a function which places its sub figures in a grid.
///
/// -> content
#let super(
  /// The image kind which should be used, this is mainly relevant for
  /// introspection and defaults to `image`.
  ///
  /// Must be one of:
  /// - `image`
  /// - `table`
  /// - `raw`
  ///
  /// -> str | function
  kind: image,

  /// This is the numbering used for this super figure.
  ///
  /// Signature: #lambda(int, ret: content)
  ///
  /// -> str | function
  numbering: "1",

  /// This is the numbering used for the sub figures.
  ///
  /// Signature: #lambda(int, ret: content)
  ///
  /// -> str | function
  numbering-sub: "(a)",

  /// This is the numbering used for _references_ to the sub figures. If
  /// this is a function, it receives both the super and sub figure numbering
  /// respectively.
  ///
  /// Signature: #lambda(int, int, ret: content)
  ///
  /// -> str | function
  numbering-sub-ref: "1a",

  /// The super figure's supplement.
  //
  /// -> content | auto
  supplement: auto,

  /// Whether the super figure's supplement should propagate down to its sub
  /// figures.
  //
  /// -> bool
  propagate-supplement: true,

  /// Whether the sub figures should appear in an outline of figures.
  ///
  /// -> bool
  outlined-sub: false,

  /// The label to attach to this super figure.
  ///
  /// -> label | none
  label: none,

  /// A show rule override for sub figures. Receives the sub figure.
  ///
  /// Signature: #lambda(content, ret: content)
  ///
  /// -> function | auto
  show-sub: auto,

  /// A show rule override for sub figure's captions. Receives the realized
  /// numbering and caption element. The numbering cna be used directly without
  /// any further formatting.
  ///
  /// Signature: #lambda(content, content, ret: content)
  ///
  /// -> function | auto
  show-sub-caption: auto,

  /// The names of named arguments to pass through to the figure directly.
  ///
  /// -> dictionary
  overrides: figure-overrides,

  /// Named arguments to pass to figure verbatim, these are selected using
  /// @cmd:super.overrides.
  ///
  /// -> any
  ..args,

  /// The figure body, this may contain other figures which will be numbered
  /// appropriately.
  body,
) = {
  import "util.typ"

  assert.eq(
    args.pos().len(), 0,
    message: "Unexpected positional args: `" + repr(args.pos()) + "`"
  )

  // These overrides allow use to only include those fields which were actually
  // set, not overriding them with their defaults.
  let (rest, overrides) = util.get-overrides(args.named(), overrides)

  assert.eq(rest.len(), 0, message: "Unexpected named args: `" + repr(rest) + "`")

  // Wrap numberings such that if thye are a pattern and contain only one symbol
  // we only pass the sub number, but otherwise both.
  numbering-sub = util.sparse-numbering(numbering-sub)
  numbering-sub-ref = util.sparse-numbering(numbering-sub-ref)

  let function-kinds = (
    image: "figure",
    table: "table",
    raw: "raw",
  )

  // If we use no propagation, then we fallback to the normal auto behavior,
  // which fixes #4.
  if propagate-supplement and supplement == auto {
    if repr(kind) in function-kinds {
      supplement = context util.i18n-supplement(function-kinds.at(repr(kind)))
    } else {
      panic("Cannot infer `supplement`, must be set")
    }
  }

  show-sub = util.auto-or-default(show-sub, it => it)
  show-sub-caption = util.auto-or-default(show-sub-caption, (num, it) => it)

  // We need the context for the figure caption rules and numbering retrieval.
  context {
    // Materialize the super figure number.
    let n-super = counter(figure.where(kind: kind)).get().first() + 1

    [#figure(
      kind: kind,
      numbering: n => std.numbering(numbering, n),
      supplement: supplement,
      ..overrides,
      {
        // TODO(tinger): It doesn't seem to work when suing show-set without a
        // kind, it doesn't not apply to all of the kinds, so we collect them
        // and apply each individually.
        show: util.apply-for-all(
          util.gather-kinds(body),
          kind => inner => {
            show figure.where(kind: kind): set figure(numbering: _ => std.numbering(
              numbering-sub-ref, n-super, sub-figure-counter.get().first() + 1
            ))
            inner
          },
        )

        set figure(supplement: supplement) if propagate-supplement
        set figure(outlined: outlined-sub, placement: none)

        // Set the rule default for figures to use this, then apply the user
        // rule on top. This allows the user to override it easily while keeping
        // the show-rule fallback behavior.
        show figure: show-sub
        show figure: it => {
          // Materialize the sub figure number.
          let n-sub = sub-figure-counter.get().first() + 1

          // Materialize the sub figure numbering with the given super and sub
          // numbers.
          let num = std.numbering(numbering-sub, n-super, n-sub)

          // Set the rule default for captions to use this, then apply the user
          // rule on top. Just like above.
          show figure.caption: it => {
            num
            [ ]
            it.body
          }
          show figure.caption: show-sub-caption.with(num)

          // Adjust the sub figure counter appropriately. This is done to allow
          // references to get the correct numbering within the figure.
          //
          // NOTE(tinger): I don't quite remember why this has to reset the
          // figure counter itself.
          sub-figure-counter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        // Reset the sub figure counter for the next super figure.
        sub-figure-counter.update(0)
        body
      },
    )#label]
  }
}

/// Provides a convenient wrapper around @cmd:super which puts sub figures in a
/// grid.
///
/// -> content
#let grid(
  /// The image kind which should be used, this is mainly relevant for
  /// introspection and defaults to `image`.
  ///
  /// -> str | function
  kind: image,

  /// This is the numbering used for this super figure.
  ///
  /// Signature: #lambda(int, ret: content)
  ///
  /// -> str | function
  numbering: "1",

  /// This is the numbering used for the sub figures.
  ///
  /// Signature: #lambda(int, ret: content)
  ///
  /// -> str | function
  numbering-sub: "(a)",

  /// This is the numbering used for _references_ to the sub figures. If
  /// this is a function, it receives both the super and sub figure numbering
  /// respectively.
  ///
  /// Signature: #lambda(int, int, ret: content)
  ///
  /// -> str | function
  numbering-sub-ref: "1a",

  /// The super figure's supplement.
  //
  /// -> content | auto
  supplement: auto,

  /// Whether the super figure's supplement should propagate down to its sub
  /// figures.
  //
  /// -> bool
  propagate-supplement: true,

  /// Whether the sub figures should appear in an outline of figures.
  ///
  /// -> bool
  outlined-sub: false,

  /// The label to attach to this super figure.
  ///
  /// -> label | none
  label: none,

  /// A show rule override for sub figures. Receives the sub figure.
  ///
  /// Signature: #lambda(content, ret: content)
  ///
  /// -> function | auto
  show-sub: auto,

  /// A show rule override for sub figure's captions. Receives the realized
  /// numbering and caption element. The numbering cna be used directly without
  /// any further formatting.
  ///
  /// Signature: #lambda(content, content, ret: content)
  ///
  /// -> function | auto
  show-sub-caption: auto,

  /// The names of named arguments to pass through to the figure directly.
  ///
  /// -> dictionary
  figure-overrides: figure-overrides,

  /// The names of named arguments to pass through to the grid directly.
  ///
  /// -> dictionary
  grid-overrides: grid-overrides,

  /// A template function which applies grid set rules. By default this applies
  /// a gutter of `1m`. These will be overriden by explicitly passing grid
  /// arguments, but will take precedence over the style chain, disabling them
  /// allows using the style chain.
  ///
  /// Signature: #lambda(content, ret: content)
  ///
  /// -> function | auto | none
  grid-styles: auto,

  /// Named arguments to pass to figure and grid verbatim, these are selected using
  /// @cmd:grid.figure-overrides and @cmd:grid.grid-overrides respectively.
  ///
  /// -> any
  ..args,
) = {
  import "util.typ"

  // As in `super` we want to skip those which aren't set.
  let (rest, figure-overrides) = util.get-overrides(args.named(), figure-overrides)

  // As in `super` we want to skip those which aren't set.
  let (rest, grid-overrides) = util.get-overrides(rest, grid-overrides)

  assert.eq(rest.len(), 0, message: "Unexpected named args: `" + repr(rest) + "`")

  // We apply the default rule here so to not override explicitly passed arguments
  grid-styles = util.none-or-default(grid-styles, it => it)
  grid-styles = util.auto-or-default(grid-styles, it => {
    set std.grid(gutter: 1em, align: bottom)
    it
  })

  let figures-raw = args.pos()
  let figures = ()

  // Turn figures followed by a label into a labeled figure.
  while figures-raw.len() != 0 {
    let item = figures-raw.remove(0)

    if type(item) == std.label {
      assert.eq(l, none, message: "`label` must follow a content argument")
    }

    if type(item) == content {
      if figures-raw.len() == 0 {
        figures.push(item)
        break
      }

      let next = figures-raw.first()

      if type(next) == std.label {
        let _ = figures-raw.remove(0)

        if item.func() in (
          std.grid.hline,
          std.grid.vline,
          std.grid.header,
          std.grid.footer,
        ) {
          panic(
            "`label` must not follow a `grid.cell` directly, place it inside the cell",
          )
        }

        figures.push([#item#next])
      } else {
        figures.push(item)
      }
    }
  }

  show: grid-styles

  super(
    kind: kind,
    numbering: numbering,
    numbering-sub: numbering-sub,
    numbering-sub-ref: numbering-sub-ref,

    supplement: supplement,
    propagate-supplement: propagate-supplement,
    outlined-sub: outlined-sub,
    label: label,

    show-sub: show-sub,
    show-sub-caption: show-sub-caption,

    ..figure-overrides,

    std.grid(
      ..grid-overrides,
      ..figures,
    ),
  )
}
