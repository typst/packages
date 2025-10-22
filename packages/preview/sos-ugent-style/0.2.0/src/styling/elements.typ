#import "../i18n.typ"
#import "colors.typ": ugent-blue
#import "/utils/lib.typ" as utils

#let ugent-caption-format-supplement(it) = {
  // Check if the caption is valid.
  if type(it) != content or it.func() != figure.caption {
    panic("`ugent-caption` must be provided with a `figure.caption`!")
  }

  // Follow Typst behaviour to not display the supplement when 1 of them is none
  // Remark that if numbering != none, it will still be part of the outline!!
  if it.supplement != none and it.numbering != none {
    set text(fill: ugent-blue)
    smallcaps[
      *#it.supplement #context it.counter.display(it.numbering)*
    ]
  }
}
#let ugent-caption-stroke-supplement = (
  right: (paint: ugent-blue, thickness: 1.5pt),
  rest: none
)
#let ugent-caption-separator-gap = 0.64em

// Formatting function for a UGent figure captions.
#let ugent-caption(it, align: "left") = {
  let supplement = ugent-caption-format-supplement(it)

  let col-sizing = if align == "left" {
    // TODO: The column size of the label varies between figures, depending on the label.
    // For example, compare: 'table 1' (small column) and 'Listing 100' (large column)
    // (6em, 1fr) could be used to have globally consistent column sizes
    // for the caption label
    (auto, 1fr)
  } else if align == "center" {
    // And (6em, auto) to still keep the complete caption centered for
    // small caption texts
    2
  } else { panic("Wrong align argument provided to `ugent-caption`") }

  grid(
    columns: col-sizing,
    gutter: 0pt,
    rows: 1,
    if supplement != none {
      grid.cell(
        inset: (y: 0.32em, right: ugent-caption-separator-gap),
        stroke: ugent-caption-stroke-supplement,
        std.align(top+right, supplement),
      )
    },
    grid.cell(
      inset: (y: 0.32em, left: ugent-caption-separator-gap),
      stroke: none,
      std.align(left, it.body),
    ),
  )
}
#let ugent-caption-inline(it) = {
  let supplement = ugent-caption-format-supplement(it)
  if supplement != none {
    box(
      ugent-caption-format-supplement(it),
      inset: (right: ugent-caption-separator-gap),
      outset: (y: 0.3em),
      stroke: ugent-caption-stroke-supplement,
    )
    h(ugent-caption-separator-gap)
  }
  it.body
}

// Limits the numbering to 3 levels
// Use as wrapper: `set heading(numbering: ugent-heading-numbering.with("1.1.1"))`
#let ugent-heading-numbering(
  numbering,
  cut-off: 3,
  ..n,
) = {
  assert(type(numbering) != int, message: "Did you forget the numbering argument?")
  if numbering != none and n.pos().len() <= cut-off {
    std.numbering(numbering, ..n)
  }
}

// Style the numbers ONLY when displaying the heading. (not in references, outline, ...)
#let ugent-heading-style-numbering(
  numbering,
  ..n,
  prefix: none,
  postfix: " ",
  big: false, // TODO: refactor away to use general show-set rule on level == 1.
) = {
  assert(type(numbering) != int, message: "Did you forget the numbering argument?")
  let num = if numbering != none { std.numbering(numbering, ..n) }
  if num != none {
    if big {
      set text(size: 80pt, font: "Bookman Old Style", weight: "thin", fill: luma(50%))
      num + [.]
      linebreak() // size of this linebreak is determined by the fontsize of the par
    } else {
      prefix
      num
      postfix
    }
  }
}

// Destroy the heading element, return inline-content
// Needed, because underline does not handle numbers very well
#let ugent-heading-title-text(it,
  underlined: false,
  // 2nd option to set heading fontsize. 1st option: `show heading: set text(size: )`
  // The advantage here is that the previous fontsize is still accessible.
  // This way, em units are still relative to the surrounding (= previous) text.
  // Disadvantage: as a user, you cannot override the heading font-size anymore :(
  size: none,
  // Options used in sections
  prefix: none,
  postfix: " ",
  big-chap-num: false,
  underline-all: false,
) = {
  // Check if the heading is valid.
  if type(it) != content or it.func() != heading {
    panic("`ugent-heading-title-text` must be provided with a `heading`!")
  }

  let big = big-chap-num and it.level == 1
  let num = ugent-heading-style-numbering(
    prefix : prefix,
    postfix: postfix,
    big: big,
    it.numbering,
    ..counter(heading).at(it.location()),
  )
  if big {
    // TODO: remove this incidental complexity. Only needed to place the linebreak()
    // from the big number BEFORE setting the fontsize. Better approach: set
    // absolute linebreak spacing (probably need a parbreak for that, or a block).
    num
    num = none
  }
  set text(size: size) if size != none // Use size only if given
  if underlined {
    if not underline-all { num }
    underline(evade: true, offset: 4pt,
      if underline-all { num } + smallcaps(it.body)
    )
  } else {
    num + smallcaps(it.body)
  }
}

// Formatting function for a UGent heading
// Applied as `show: ugent-heading-rules`, see design rationale.
#let ugent-heading-rules(
  // The prefix to place before the number
  prefix: none,
  // The postfix to place after the number
  postfix: " ",
  // Whether first level heading should have a big number.
  big-chap-num: false,
  // Whether to underline both the number and the title.
  underline-all: false,
  body
) = {
  // Make sure the heading is NOT a paragraph (see Typst block vs paragraph)
  // TODO: it seems this indeed not a paragraph (since a general
  // `#set par(first-line-indent: (amount: 60pt, all: true))` doesn't affect this.
  // But, our next `set par()` DOES (luckily) affect the inline content...!
  // TODO: How is this possible?!

  // Disable justification locally, set line spacing for titles with multiple lines
  // TODO: when using this, the heading is automatically cast into a paragraph.
  // Luckily, we don't actually need it for now, since the text (see ugent-doc) has
  // the exact same properties. See https://github.com/typst/typst/issues/6416
  //show heading: set par(leading: 1em, justify: false)
  // Set the text to be bold, and blue
  show heading: set text(weight: "extrabold", fill: ugent-blue)

  // Below/above spacing is loosely based on @polleflietScorenMetJe2023[pg. 299]
  let heading-block = block.with(breakable: false, sticky: true)
  let title = ugent-heading-title-text.with(
    prefix: prefix, postfix: postfix,
    big-chap-num: big-chap-num, underline-all: underline-all,
  )

  // *show-function rules*
  // In order of last application - the default rule thus first
  // Destructive show-function rules
  show heading: it => heading-block(
    // TODO (not yet possible): Make the title always a block, even if inline with a paragraph
    // Goal: correct semantics + when there is a linebreak after the heading, then the
    // paragraph should reset... (see https://forum.typst.app/t/how-to-use-inline-headings/1067)
    // Almost normal text size for level 4+ .
    title(size: text.size + 1pt, it),
    below: 1em,
  )
  /* This by default gives a block heading, leading to a heading on a single line.
   * To get the heading inline with the paragraph, wrap it in `#box[]`. When all
   * paragraphs except the first are indented, add a `#block(below: 0pt)` just before.
   * This resets the paragraph counter. (why `below: 0pt`? block(spacing) is
   * inherited from paragraph (and overrules it for above and below paragraphs);
   * Take only one-side to correctly emulate this block doesn't exist)
   */
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    heading-block(
      title(size: 23pt, underlined: true, it), // TODO: ugent-panno: 30pt
      // TODO: deprecate `size` argument of `title` by specifying below/above either
      // in absolute units, or relative to the title textsize (instead of
      // the body text size like now).
      below: 1.6em,
    )
  }
  show heading.where(level: 2): it => heading-block(
    // TODO: when the immediate neighbour above is a heading level 1, the distance should be larger
    // https://github.com/typst/typst/issues/1699
    // TODO: solution? https://forum.typst.app/t/how-to-conditionally-set-heading-block-parameters/2080/3
    title(size: 19pt, underlined: true, it), // TODO: ugent-panno: 22pt
    below: 1.5em, above: 2em,
  )
  show heading.where(level: 3): it => heading-block(
    // TODO: same when immediate heading above is level 2
    title(size: 15pt, it), // TODO: ugent-panno: 18pt
    below: 1.3em, above: 1.8em,
  )
  // Could use `set text(size: 14pt)`,
  // but use destructive method to prevent default rule from applying too
  // TODO: this special casing of level 99 is probably not needed anymore due
  // to better architecture. Investigate usages, adapt & remove.
  show heading.where(level:99): it => heading-block(title(size: 12pt, it)) // TODO: ugent-panno: 14pt

  // All non-destructive show-function rules are AFTER the destructive rules.
  // There should probably NO non-destructive show-function rules, since these
  // cannot be deactivated. Probably a good thing that smallcaps doesn't work...
  // Edit: Maybe show rules can be deactivated? See: https://forum.typst.app/t/2792/2
  // TODO: for an unkown reason, when doing smallcaps here, the number size changes
  //show heading: smallcaps

  body
}

#let ugent-show-outlines(body) = {
  // Default `#outline()`
  show outline.where(
    target: selector(heading)
  ): set outline(title: i18n.table_of_contents, depth: 3)
  show outline.where(target: selector(heading)): out => {
    // TODO: cannot yet easily be overridden :(
    show outline.entry.where(level: 1): set outline.entry(fill: none)
    // convoluted override:
    // `show outline.entry.where(level: 1): entry => { set block(above: 1.3em); entry }`
    show outline.entry.where(level: 1): set block(above: 1.5em)
    show outline.entry.where(level: 1): strong

    // Create the 'normal' part and the 'appendix' part
    outline(..out.fields(), target: selector(heading).before(<ugent-section-appendix>))
    show outline.entry: entry => {
      let el = entry.element
      let num = ugent-heading-style-numbering(
        prefix: i18n.ref-Annex + [ ],
        postfix: ":",
        el.numbering,
        ..counter(heading).at(el.location()),
      )
      if num != none {
        link(
          el.location(),
          entry.indented(num, entry.inner()),
        )
      }
    }
    show outline.entry.where(level: 1): strong // Needed twice, previous show-function is destructive
    outline(target: selector(heading).after(<ugent-section-appendix>), title: none, indent: 2em)
  }

  show outline.where(
    target: figure.where(kind: table)
  ): set outline(title: i18n.list_tables)

  show outline.where(
    target: figure.where(kind: image)
  ): set outline(title: i18n.list_figures)

  show outline.where(
    target: figure.where(kind: raw)
  ): set outline(title: i18n.list_listings)

  // MATH FORMULAS
  // A lot of different combinations can used to display specific math formulas
  // Most of these are specified by Theorion (see /utils/util.typ)
  // TODO: Specify a correct default title for the most common combinations.
  show selector.or(
    outline.where(target: utils.all-math-figures),
    outline.where(target: figure.where(kind: math.equation)),
  ): set outline(title: i18n.list_equations)

  body
}

// The UGent variant of `#glossary` from @preview/glossy
// This only prints the glossary, glossary-entries are specified with init-glossary
#let ugent-glossary(..args) = {
  // Late import, prevent dependency when not needed
  import "glossary.typ": glossy-theme-ugent
  // TODO: When https://github.com/typst/typst/issues/147 is fixed, just
  // write a show rule for it
  // In the glossary, justified text looks better (my opinion). Remove if not generally applicable
  set par(
    justify: true,
    linebreaks: "optimized",
  )
  utils.glossy().glossary(
    title: i18n.list_abbrev,
    theme: glossy-theme-ugent,
    sort: true,
    ignore-case: true,
    ..args,
  )
}

// Show rule to display the bibliography stylised for UGent.
// Follows same rationale as ugent-heading-rules.
#let ugent-bibliography-theme(body) = {
  // Style the bibliography heading
  set bibliography(title: i18n.reference_list)
  // included in ToC, see faculty engineering & architecture and @polleflietScorenMetJe2023[pg. 130]
  show bibliography: set heading(numbering: none, outlined: true)
  show bibliography: set par(spacing: 1.2em) // Keep 'normal' paragraph spacing
  show bibliography: bib => {
    show: ugent-heading-rules // Destructive
    show heading: h => {
      assert(h.level == 1, message: "The bibliography should be a toplevel ugent-heading.")
      h
    }
    bib
  }
  body
}
