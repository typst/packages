


#let __rawfuncmap = (
  text: text,
  par: par,
  box: box,
  block: block,
  grid: grid,
  table: table,
  list: list,
  enum: enum,
  terms: terms,
  heading: heading,
  quote: quote,
  raw: raw,
  place: place,
  equation: math.equation,
  image: image,
  figure: figure,
  ref: ref,
  outline: outline,
)

#let capture(
  saving-text: true,
  saving-par: true,
  saving-box: true,
  saving-block: true,
  saving-grid: true,
  saving-table: true,
  saving-list: true,
  saving-enum: true,
  saving-terms: true,
  saving-heading: true,
  saving-quote: true,
  saving-raw: true,
  saving-place: true,
  saving-equation: true,
  saving-image: true,
  saving-figure: true,
  saving-ref: true,
  saving-outline: true,
  use-absolute-em: true,
  doc,
) = context {
  let moment = (:)

  let resolved-text-size = if use-absolute-em {
    measure(box(width: text.size, height: 0pt)).width
  } else {
    text.size
  }

  // ========================================================================
  // BEGIN GENERATED CAPTURE BLOCK
  // ========================================================================

  if saving-text {
    moment.text = (
      size: resolved-text-size,
      font: __rawfuncmap.text.font,
      fill: __rawfuncmap.text.fill,
      stroke: __rawfuncmap.text.stroke,
      tracking: __rawfuncmap.text.tracking,
      spacing: __rawfuncmap.text.spacing,
      style: __rawfuncmap.text.style,
      weight: __rawfuncmap.text.weight,
      stretch: __rawfuncmap.text.stretch,
      top-edge: __rawfuncmap.text.top-edge,
      bottom-edge: __rawfuncmap.text.bottom-edge,
      lang: __rawfuncmap.text.lang,
      region: __rawfuncmap.text.region,
      dir: __rawfuncmap.text.dir,
      hyphenate: __rawfuncmap.text.hyphenate,
      ligatures: __rawfuncmap.text.ligatures,
      number-type: __rawfuncmap.text.number-type,
      number-width: __rawfuncmap.text.number-width,
      slashed-zero: __rawfuncmap.text.slashed-zero,
      fractions: __rawfuncmap.text.fractions,
      features: __rawfuncmap.text.features,
      fallback: __rawfuncmap.text.fallback,
      overhang: __rawfuncmap.text.overhang,
      kerning: __rawfuncmap.text.kerning,
      alternates: __rawfuncmap.text.alternates,
      stylistic-set: __rawfuncmap.text.stylistic-set,
      script: __rawfuncmap.text.script,
    )
  }

  if saving-par {
    moment.par = (
      leading: __rawfuncmap.par.leading,
      spacing: __rawfuncmap.par.spacing,
      justify: __rawfuncmap.par.justify,
      linebreaks: __rawfuncmap.par.linebreaks,
      first-line-indent: __rawfuncmap.par.first-line-indent,
      hanging-indent: __rawfuncmap.par.hanging-indent,
    )
  }

  if saving-box {
    moment.box = (
      width: __rawfuncmap.box.width,
      height: __rawfuncmap.box.height,
      baseline: __rawfuncmap.box.baseline,
    )
  }

  if saving-block {
    moment.block = (
      width: __rawfuncmap.block.width,
      height: __rawfuncmap.block.height,
      breakable: __rawfuncmap.block.breakable,
      above: __rawfuncmap.block.above,
      below: __rawfuncmap.block.below,
    )
  }

  if saving-grid {
    moment.grid = (
      columns: __rawfuncmap.grid.columns,
      rows: __rawfuncmap.grid.rows,
      column-gutter: __rawfuncmap.grid.column-gutter,
      row-gutter: __rawfuncmap.grid.row-gutter,
      align: __rawfuncmap.grid.align,
    )
  }

  if saving-table {
    moment.table = (
      columns: __rawfuncmap.table.columns,
      rows: __rawfuncmap.table.rows,
      column-gutter: __rawfuncmap.table.column-gutter,
      row-gutter: __rawfuncmap.table.row-gutter,
      align: __rawfuncmap.table.align,
    )
  }

  if saving-list {
    moment.list = (
      indent: __rawfuncmap.list.indent,
      body-indent: __rawfuncmap.list.body-indent,
      spacing: __rawfuncmap.list.spacing,
      marker: __rawfuncmap.list.marker,
      tight: __rawfuncmap.list.tight,
    )
  }

  if saving-enum {
    moment.enum = (
      indent: __rawfuncmap.enum.indent,
      body-indent: __rawfuncmap.enum.body-indent,
      spacing: __rawfuncmap.enum.spacing,
      numbering: __rawfuncmap.enum.numbering,
      start: __rawfuncmap.enum.start,
      full: __rawfuncmap.enum.full,
      reversed: __rawfuncmap.enum.reversed,
      tight: __rawfuncmap.enum.tight,
    )
  }

  if saving-terms {
    moment.terms = (
      indent: __rawfuncmap.terms.indent,
      spacing: __rawfuncmap.terms.spacing,
      hanging-indent: __rawfuncmap.terms.hanging-indent,
      tight: __rawfuncmap.terms.tight,
    )
  }

  if saving-heading {
    moment.heading = (
      level: __rawfuncmap.heading.level,
      depth: __rawfuncmap.heading.depth,
      offset: __rawfuncmap.heading.offset,
      numbering: __rawfuncmap.heading.numbering,
      supplement: __rawfuncmap.heading.supplement,
      outlined: __rawfuncmap.heading.outlined,
      bookmarked: __rawfuncmap.heading.bookmarked,
      hanging-indent: __rawfuncmap.heading.hanging-indent,
    )
  }

  if saving-quote {
    moment.quote = (
      block: __rawfuncmap.quote.block,
      quotes: __rawfuncmap.quote.quotes,
      attribution: __rawfuncmap.quote.attribution,
    )
  }

  if saving-raw {
    moment.raw = (
      lang: __rawfuncmap.raw.lang,
      align: __rawfuncmap.raw.align,
      block: __rawfuncmap.raw.block,
      theme: __rawfuncmap.raw.theme,
    )
  }

  if saving-place {
    moment.place = (
      dx: __rawfuncmap.place.dx,
      dy: __rawfuncmap.place.dy,
    )
  }

  if saving-equation {
    moment.equation = (
      block: __rawfuncmap.equation.block,
      numbering: __rawfuncmap.equation.numbering,
      number-align: __rawfuncmap.equation.number-align,
      supplement: __rawfuncmap.equation.supplement,
      alt: __rawfuncmap.equation.alt,
    )
  }

  if saving-image {
    moment.image = (
      width: __rawfuncmap.image.width,
      height: __rawfuncmap.image.height,
      alt: __rawfuncmap.image.alt,
    )
  }

  if saving-figure {
    moment.figure = (
      placement: __rawfuncmap.figure.placement,
      scope: __rawfuncmap.figure.scope,
      kind: __rawfuncmap.figure.kind,
      supplement: __rawfuncmap.figure.supplement,
      numbering: __rawfuncmap.figure.numbering,
      gap: __rawfuncmap.figure.gap,
      outlined: __rawfuncmap.figure.outlined,
    )
  }

  if saving-ref {
    moment.ref = (
      supplement: __rawfuncmap.ref.supplement,
      form: __rawfuncmap.ref.form,
    )
  }

  if saving-outline {
    moment.outline = (
      title: __rawfuncmap.outline.title,
      depth: __rawfuncmap.outline.depth,
      indent: __rawfuncmap.outline.indent,
    )
  }

  // ========================================================================
  // END GENERATED CAPTURE BLOCK
  // ========================================================================

  // ========================================================================
  // BEGIN GENERATED APPLY BLOCK
  // ========================================================================

  let apply(body) = {
    let setters = ()
    if saving-text {
      setters.push(it => {
        set text(
          size: moment.text.size,
          font: moment.text.font,
          fill: moment.text.fill,
          stroke: moment.text.stroke,
          tracking: moment.text.tracking,
          spacing: moment.text.spacing,
          style: moment.text.style,
          weight: moment.text.weight,
          stretch: moment.text.stretch,
          top-edge: moment.text.top-edge,
          bottom-edge: moment.text.bottom-edge,
          lang: moment.text.lang,
          region: moment.text.region,
          dir: moment.text.dir,
          hyphenate: moment.text.hyphenate,
          ligatures: moment.text.ligatures,
          number-type: moment.text.number-type,
          number-width: moment.text.number-width,
          slashed-zero: moment.text.slashed-zero,
          fractions: moment.text.fractions,
          features: moment.text.features,
          fallback: moment.text.fallback,
          overhang: moment.text.overhang,
          kerning: moment.text.kerning,
          alternates: moment.text.alternates,
          stylistic-set: moment.text.stylistic-set,
          script: moment.text.script,
        )
        it
      })
    }
    if saving-par {
      setters.push(it => {
        set par(
          leading: moment.par.leading,
          spacing: moment.par.spacing,
          justify: moment.par.justify,
          linebreaks: moment.par.linebreaks,
          first-line-indent: moment.par.first-line-indent,
          hanging-indent: moment.par.hanging-indent,
        )
        it
      })
    }
    if saving-box {
      setters.push(it => {
        set box(
          width: moment.box.width,
          height: moment.box.height,
          baseline: moment.box.baseline,
        )
        it
      })
    }
    if saving-block {
      setters.push(it => {
        set block(
          width: moment.block.width,
          height: moment.block.height,
          breakable: moment.block.breakable,
          above: moment.block.above,
          below: moment.block.below,
        )
        it
      })
    }
    if saving-grid {
      setters.push(it => {
        set grid(
          columns: moment.grid.columns,
          rows: moment.grid.rows,
          column-gutter: moment.grid.column-gutter,
          row-gutter: moment.grid.row-gutter,
          align: moment.grid.align,
        )
        it
      })
    }
    if saving-table {
      setters.push(it => {
        set table(
          columns: moment.table.columns,
          rows: moment.table.rows,
          column-gutter: moment.table.column-gutter,
          row-gutter: moment.table.row-gutter,
          align: moment.table.align,
        )
        it
      })
    }
    if saving-list {
      setters.push(it => {
        set list(
          indent: moment.list.indent,
          body-indent: moment.list.body-indent,
          spacing: moment.list.spacing,
          marker: moment.list.marker,
          tight: moment.list.tight,
        )
        it
      })
    }
    if saving-enum {
      setters.push(it => {
        set enum(
          indent: moment.enum.indent,
          body-indent: moment.enum.body-indent,
          spacing: moment.enum.spacing,
          numbering: moment.enum.numbering,
          start: moment.enum.start,
          full: moment.enum.full,
          reversed: moment.enum.reversed,
          tight: moment.enum.tight,
        )
        it
      })
    }
    if saving-terms {
      setters.push(it => {
        set terms(
          indent: moment.terms.indent,
          spacing: moment.terms.spacing,
          hanging-indent: moment.terms.hanging-indent,
          tight: moment.terms.tight,
        )
        it
      })
    }
    if saving-heading {
      setters.push(it => {
        set heading(
          level: moment.heading.level,
          depth: moment.heading.depth,
          offset: moment.heading.offset,
          numbering: moment.heading.numbering,
          supplement: moment.heading.supplement,
          outlined: moment.heading.outlined,
          bookmarked: moment.heading.bookmarked,
          hanging-indent: moment.heading.hanging-indent,
        )
        it
      })
    }
    if saving-quote {
      setters.push(it => {
        set quote(
          block: moment.quote.block,
          quotes: moment.quote.quotes,
          attribution: moment.quote.attribution,
        )
        it
      })
    }
    if saving-raw {
      setters.push(it => {
        set raw(
          lang: moment.raw.lang,
          align: moment.raw.align,
          block: moment.raw.block,
          theme: moment.raw.theme,
        )
        it
      })
    }
    // note: set place is mostly a no-op; kept for completeness
    if saving-place {
      setters.push(it => {
        set place(
          dx: moment.place.dx,
          dy: moment.place.dy,
        )
        it
      })
    }
    if saving-equation {
      setters.push(it => {
        set math.equation(
          block: moment.equation.block,
          numbering: moment.equation.numbering,
          number-align: moment.equation.number-align,
          supplement: moment.equation.supplement,
          alt: moment.equation.alt,
        )
        it
      })
    }
    if saving-image {
      setters.push(it => {
        set image(
          width: moment.image.width,
          height: moment.image.height,
          alt: moment.image.alt,
        )
        it
      })
    }
    if saving-figure {
      setters.push(it => {
        set figure(
          placement: moment.figure.placement,
          scope: moment.figure.scope,
          kind: moment.figure.kind,
          supplement: moment.figure.supplement,
          numbering: moment.figure.numbering,
          gap: moment.figure.gap,
          outlined: moment.figure.outlined,
        )
        it
      })
    }
    if saving-ref {
      setters.push(it => {
        set ref(
          supplement: moment.ref.supplement,
          form: moment.ref.form,
        )
        it
      })
    }
    if saving-outline {
      setters.push(it => {
        set outline(
          title: moment.outline.title,
          depth: moment.outline.depth,
          indent: moment.outline.indent,
        )
        it
      })
    }

    show: it => setters.fold(it, (acc, f) => f(acc))
    body
  }

  // ========================================================================
  // END GENERATED APPLY BLOCK
  // ========================================================================

  let macroApply(content) = {
    // I know little about label and recursion. Expect bugs with complex nesting!
    let marker = <setsuna-macro-applied>
    let guarded(it) = if it.has("setsuna-macro-applied") { it } else {
      [
        #apply(it)
        <setsuna-macro-applied>
      ]
    }
    show text: guarded
    show par: guarded
    show box: guarded
    show block: guarded
    show grid: guarded
    show table: guarded
    show list: guarded
    show enum: guarded
    show terms: guarded
    show heading: guarded
    show quote: guarded
    show raw: guarded
    show place: guarded
    show math.equation: guarded
    show image: guarded
    show figure: guarded
    show ref: guarded
    show outline: guarded
    // No more?
    [
      #apply(content)
      <setsuna-macro-applied>
    ]
  }

  doc(macroApply)
}

