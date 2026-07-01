/// Creates an inference rule.
///
/// You can render a rule created with this function using the `prooftree`
/// function.
#let rule(
  /// The label of the rule, displayed on the left of the horizontal bar.
  label: none,
  /// The name of the rule, displayed on the right of the horizontal bar.
  name: none,
  /// The conclusion of the rule.
  conclusion,
  /// The premises of the rule. Might be other rules constructed with this
  /// function, or some content.
  ..premises
) = {
  assert(
    label == none or type(label) in (str, content, symbol),
    message: "the label of a rule must be some content",
  )
  assert(
    name == none or type(name) in (str, content, symbol),
    message: "the name of a rule must be some content",
  )
  assert(
    type(conclusion) in (str, content, symbol),
    message: "the conclusion of a rule must be some content (it cannot be another rule)",
  )
  for premise in premises.pos() {
    assert(
      type(premise) in (str, content, symbol)
        or (
          type(premise) == dictionary
            and "name" in premise
            and "conclusion" in premise
            and "premises" in premise
        ),
      message: "a premise must be some content or another rule",
    )
  }
  assert.eq(
    premises.named().len(),
    0,
    message: "unexpected named arguments to `rule`",
  )
  (
    label: label,
    name: name,
    conclusion: conclusion,
    premises: premises.pos()
  )
}

/// Lays out a proof tree.
#let prooftree(
  /// The rule to lay out.
  ///
  /// Such a rule can be constructed using the `rule` function.
  rule,
  /// The minimum amount of space between two premises.
  min-premise-spacing: 15pt,
  /// The amount to extend the horizontal bar beyond the content. Also
  /// determines how far from the bar labels and names are displayed.
  title-inset: 2pt,
  /// The stroke to use for the horizontal bars.
  stroke: stroke(0.4pt),
  /// The space between the bottom of the bar and the conclusion, and between
  /// the top of the bar and the premises.
  ///
  /// Note that, in this case, "the bar" refers to the bounding box of the
  /// horizontal line and the rule name (if any).
  vertical-spacing: 0pt,
  /// The minimum height of the box containing the horizontal bar.
  ///
  /// The height of this box is normally determined by the height of the rule
  /// name because it is the biggest element of the box. This setting lets you
  /// set a minimum height. The default is 0.8em, is higher than a single line
  /// of content, meaning all parts of the tree will align properly by default,
  /// even if some rules have no name (unless a rule is higher than a single
  /// line).
  min-bar-height: 0.8em,
  /// The orientation of the proof tree.
  ///
  /// If set to ttb, the conclusion will be at the top, and the premises will
  /// be at the bottom. Defaults to btt, the conclusion being at the bottom
  /// and the premises at the top.
  dir: btt,
) = {
  /// Lays out some content.
  ///
  /// This function simply wraps the passed content in the usual
  /// `(content: .., left-blank: .., right-blank: ..)` dictionary.
  let layout-content(content) = {
    // We wrap the content in a box with fixed dimensions so that fractional units
    // don't come back to haunt us later.
    let dimensions = measure(content)
    (
      content: box(
        // stroke: yellow + 0.3pt, // DEBUG
        ..dimensions,
        content,
      ),
      left-blank: 0pt,
      right-blank: 0pt,
    )
  }


  /// Lays out multiple premises, spacing them properly.
  let layout-premises(
    /// Each laid out premise.
    ///
    /// Must be an array of ditionaries with `content`, `left-blank` and
    /// `right-blank` attributes.
    premises,
    /// The minimum amount between each premise.
    min-spacing,
    /// If the laid out premises have an inner width smaller than this, their
    /// spacing will be increased in order to reach this inner width.
    optimal-inner-width,
  ) = {
    let arity = premises.len()

    if arity == 0 {
      return layout-content(none)
    }

    if arity == 1 {
      return premises.at(0)
    }

    let left-blank = premises.at(0).left-blank
    let right-blank = premises.at(-1).right-blank

    let initial-content = stack(
      dir: ltr,
      spacing: min-spacing,
      ..premises.map(premise => premise.content),
    )
    let initial-inner-width = measure(initial-content).width - left-blank - right-blank

    if initial-inner-width >= optimal-inner-width {
      return (
        content: box(initial-content),
        left-blank: left-blank,
        right-blank: right-blank,
      )
    }

    // Conclusion is wider than the premises: they need to be spaced out.
    let remaining-space = optimal-inner-width - initial-inner-width
    let final-content = stack(
      dir: ltr,
      spacing: min-spacing + remaining-space / (arity + 1),
      ..premises.map(premise => premise.content),
    )

    (
      content: box(final-content),
      left-blank: left-blank,
      right-blank: right-blank,
    )
  }


  /// Lays out multiple premises that are all leaves, spacing them properly, and
  /// optionally creating multiple lines if there is not enough available
  /// horizontal space.
  let layout-leaf-premises(
    /// Each laid out premise.
    ///
    /// Must be an array of content-like (meaning `content`, `string`, etc.).
    premises,
    /// The minimum amount between each premise.
    min-spacing,
    /// If the laid out premises have an inner width smaller than this, their
    /// spacing will be increased in order to reach this inner width.
    optimal-inner-width,
    /// The available width for the returned content.
    ///
    /// `none` is interpreted as infinite available width.
    ///
    /// Ideally, the width of the returned content should be bounded by this
    /// value, although no guarantee is made.
    available-width,
  ) = {
    // By default, typeset like a regular tree.

    let default = layout-premises(
      premises.map(layout-content),
      min-spacing,
      optimal-inner-width,
    )

    if available-width == none or measure(default.content).width <= available-width {
      return default
    }

    // If there is not enough horizontal space, use multiple lines.

    let line-builder = stack.with(
      dir: ltr,
      spacing: min-spacing,
    )

    let lines = ((), )
    for premise in premises {
      let augmented-line = lines.last() + (premise, )
      if available-width == none or measure(line-builder(..augmented-line)).width <= available-width {
        lines.last() = augmented-line
      } else {
        lines.push((premise, ))
      }
    }

    layout-content({
      set align(center)
      stack(
        dir: ttb,
        spacing: 0.7em,
        ..lines
          .filter(line => line.len() != 0)
          .map(line => line-builder(..line)),
      )
    })
  }


  /// Lays out the horizontal bar of a rule.
  let layout-bar(
    /// The stroke to use for the bar.
    stroke,
    /// The length of the bar, without taking hangs into account.
    length,
    /// How much to extend the bar to the left and to the right.
    hang,
    /// The label of the rule, displayed on the left of the bar.
    ///
    /// If this is `none`, no label is displayed.
    label,
    /// The name of the rule, displayed on the right of the bar.
    ///
    /// If this is `none`, no name is displayed.
    name,
    /// The space to leave between the label and the bar, and between the bar
    /// and the name.
    margin,
    /// The minimum height of the content to return.
    min-height,
  ) = {
    let bar = line(
      start: (0pt, 0pt),
      length: length + 2 * hang,
      stroke: stroke,
    )

    let (width: label-width, height: label-height) = measure(label)
    let (width: name-width, height: name-height) = measure(name)

    let content = {
      show: box.with(
        // stroke: green + 0.3pt, // DEBUG
        height: calc.max(label-height, name-height, min-height),
      )

      set align(horizon)

      let bake(body) = if body == none {
        none
      } else {
        move(dy: -0.15em, box(body, ..measure(body)))
      }

      let parts = (
        bake(label),
        bar,
        bake(name),
      ).filter(p => p != none)

      stack(
        dir: ltr,
        spacing: margin,
        ..parts,
      )
    }

    (
      content: content,
      left-blank:
        if label == none {
          hang
        } else {
          hang + margin + label-width
        },
      right-blank:
        if name == none {
          hang
        } else {
          hang + margin + name-width
        },
    )
  }


  /// Lays out the application of a rule.
  let layout-rule(
    /// The laid out premises.
    ///
    /// This must be a dictionary with `content`, `left-blank`
    /// and `right-blank` attributes.
    premises,
    /// The conclusion, displayed below the bar.
    conclusion,
    /// The stroke of the bar.
    bar-stroke,
    /// The amount by which to extend the bar on each side.
    bar-hang,
    /// The label of the rule, displayed on the left of the bar.
    ///
    /// If this is `none`, no label is displayed.
    label,
    /// The name of the rule, displayed on the right of the bar.
    ///
    /// If this is `none`, no name is displayed.
    name,
    /// The space to leave between the label and the bar, and between the bar
    /// and the name.
    bar-margin,
    /// The spacing above and below the bar.
    vertical-spacing,
    /// The minimum height of the bar element.
    min-bar-height,
  ) = {
    // Fix the dimensions of the conclusion and name to prevent problems with
    // fractional units later.
    conclusion = box(conclusion, ..measure(conclusion))

    let premises-inner-width = measure(premises.content).width - premises.left-blank - premises.right-blank
    let conclusion-width = measure(conclusion).width

    let bar-length = calc.max(premises-inner-width, conclusion-width)

    let bar = layout-bar(bar-stroke, bar-length, bar-hang, label, name, bar-margin, min-bar-height)

    let left-start
    let right-start

    let premises-left-offset
    let conclusion-left-offset

    if premises-inner-width > conclusion-width {
      left-start = calc.max(premises.left-blank, bar.left-blank)
      right-start = calc.max(premises.right-blank, bar.right-blank)
      premises-left-offset = left-start - premises.left-blank
      conclusion-left-offset = left-start + (premises-inner-width - conclusion-width) / 2
    } else {
      let premises-left-hang = premises.left-blank - (bar-length - premises-inner-width) / 2
      let premises-right-hang = premises.right-blank - (bar-length - premises-inner-width) / 2
      left-start = calc.max(premises-left-hang, bar.left-blank)
      right-start = calc.max(premises-right-hang, bar.right-blank)
      premises-left-offset = left-start + (bar-length - premises-inner-width) / 2 - premises.left-blank
      conclusion-left-offset = left-start
    }
    let bar-left-offset = left-start - bar.left-blank

    let content = {
      // show: box.with(stroke: yellow + 0.3pt) // DEBUG

      let stack-dir = dir.inv()
      let align-y = dir.start()

      set align(align-y + left)

      stack(
        dir: stack-dir,
        spacing: vertical-spacing,
        h(premises-left-offset) + premises.content,
        h(bar-left-offset) + bar.content,
        h(conclusion-left-offset) + conclusion,
      )
    }

    (
      content: box(content),
      left-blank: left-start + (bar-length - conclusion-width) / 2,
      right-blank: right-start + (bar-length - conclusion-width) / 2,
    )
  }


  /// Lays out an entire proof tree.
  ///
  /// All lengths passed to this function must be resolved.
  let layout-tree(
    /// The rule containing the tree to lay out.
    rule,
    /// The available width for the tree.
    ///
    /// `none` is interpreted as infinite available width.
    ///
    /// Ideally, the width of the returned tree should be bounded by this value,
    /// although no guarantee is made.
    available-width,
    /// The minimum amount between each premise.
    min-premise-spacing,
    /// The stroke of the bar.
    bar-stroke,
    /// The amount by which to extend the bar on each side.
    bar-hang,
    /// The space to leave between the label and the bar, and between the bar
    /// and the name.
    bar-margin,
    /// The margin above and below the bar.
    vertical-spacing,
    /// The minimum height of the bar element.
    min-bar-height,
  ) = {
    if type(rule) != dictionary {
      return layout-content(rule)
    }

    // A small branch is a tree whose premises (if any) are all leaves. The
    // premises of such a tree can be typeset in multiple lines in case there is
    // not enough horizontal space.
    let is-small-branch = rule.premises.all(premise => type(premise) != dictionary)
    let premises = if is-small-branch {
      let width-available-to-premises = none
      if available-width != none {
        width-available-to-premises = available-width - bar-hang * 2
        if rule.name != none {
          width-available-to-premises -= bar-margin + measure(rule.name).width
        }
        if rule.label != none {
          width-available-to-premises -= bar-margin + measure(rule.label).width
        }
        // This fixes some rounding issues in auto sized containers.
        width-available-to-premises += 0.00000001pt
      }
      layout-leaf-premises(
        rule.premises,
        min-premise-spacing,
        measure(rule.conclusion).width,
        width-available-to-premises,
      )
    } else {
      layout-premises(
        rule.premises.map(premise => layout-tree(
          premise,
          none,
          min-premise-spacing,
          bar-stroke,
          bar-hang,
          bar-margin,
          vertical-spacing,
          min-bar-height,
        )),
        min-premise-spacing,
        measure(rule.conclusion).width,
      )
    }

    layout-rule(
      premises,
      rule.conclusion,
      bar-stroke,
      bar-hang,
      rule.label,
      rule.name,
      bar-margin,
      vertical-spacing,
      min-bar-height,
    )
  }


  layout(available => {
    let tree = layout-tree(
      rule,
      available.width,
      min-premise-spacing.to-absolute(),
      stroke,
      title-inset.to-absolute(),
      title-inset.to-absolute(),
      vertical-spacing.to-absolute(),
      min-bar-height.to-absolute(),
    ).content

    block(
      // stroke : black + 0.3pt, // DEBUG
      ..measure(tree),
      breakable: false,
      tree,
    )
  })
}
