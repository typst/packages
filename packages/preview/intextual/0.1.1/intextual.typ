#let current-left-bounds = state("current-left-bounds", 0pt)
#let current-right-bounds = state("current-right-bounds", 0pt)

/// Place text flushed right inside a block math.equation context.
///
/// - body (content): content to flush right
/// - dx (length): Extra offset towards the right (default: 0em)
/// - overlap (bool): If `overlap` is `false`, creates vertical space according to `above`
///   and `below`.
/// - above (length): If `overlap == true`, how much vertical space to give above the text.
/// - below (length): If `overlap == true`, how much vertical space to give below the text
/// -> content
#let flushr(body, dx: 0em, overlap: true, above: 0.4em, below: 0em) = context {
  let x-pos = here().position().x
  let left-margin = current-left-bounds.get()
  let right-margin = current-right-bounds.get()
  let width = right-margin - left-margin

  // assumes page margin is consistent
  let distance-from-right = right-margin - x-pos

  if overlap {
    place(right + horizon, dx: distance-from-right + dx, body)
  } else {
    let (width, height) = measure(body, width: width)
    $
      #place(right + top, dx: distance-from-right + dx, dy: above, body) \
      #v(height + above + below) \
    $
  }
}

/// Place text flushed left inside a block math.equation context.
///
/// - body (content): content to flush left
/// - dx (length): Extra offset towards the right (default: 0em)
/// - overlap (bool): If `overlap` is `false`, creates vertical space according to `above`
///   and `below`.
/// - above (length): If `overlap == true`, how much vertical space to give above the text.
/// - below (length): If `overlap == true`, how much vertical space to give below the text
/// -> content
#let flushl(body, dx: 0em, overlap: true, above: 0.4em, below: 0em) = context {
  let x-pos = here().position().x
  let left-margin = current-left-bounds.get()
  let right-margin = current-right-bounds.get()
  let width = right-margin - left-margin

  // assumes page margin is consistent
  let distance-from-left = x-pos - left-margin

  if overlap {
    place(left + horizon, dx: -distance-from-left + dx, body)
  } else {
    let (width, height) = measure(body, width: width)
    $
      #place(left + top, dx: -distance-from-left + dx, dy: above, body) \
      #v(height + above + below) \
    $
  }
}

/// Place horizontally centered text inside a block math.equation context.
///
/// Useful for when you want to annotate an equation with centered text but there are
/// already & alignments in the equation that will un-center normally placed text.
///
/// - body (content): content to flush left
/// - dx (length): Extra offset towards the right (default: 0em)
/// - overlap (bool): If `overlap` is `false`, creates vertical space according to `above`
///   and `below`. Defaults to true since no overlap is wanted
/// - above (length): If `overlap == true`, how much vertical space to give above the text.
/// - below (length): If `overlap == true`, how much vertical space to give below the text
/// -> content
#let centertext(body, dx: 0em, overlap: false, above: 0em, below: 0em) = context {
  let x-pos = here().position().x
  let left-margin = current-left-bounds.get()
  let right-margin = current-right-bounds.get()
  let width = right-margin - left-margin

  // assumes page margin is consistent
  let distance-from-center = x-pos - (left-margin + right-margin) / 2

  if overlap {
    place(center + horizon, dx: -distance-from-center + dx, body)
  } else {
    let (width, height) = measure(body, width: width)
    $
      #place(center + top, dx: -distance-from-center + dx, dy: above, body) \
      #v(height + above + below) \
    $
  }
}

/// Flushed-left text to display in the middle of an equation
///
/// - body (content): Text to display
/// - above (length): Extra space above the text (default: 1em)
/// - below (length): Extra space below the text (default: 1em)
///
/// -> content
#let intertext(body, above: 0.4em, below: 0em) = {
  flushl(body, overlap: false, above: above, below: below)
}


/// Tag a particular line of a multi-line block equation and automatically generate a label
/// for referencing.
///
/// Unlike LaTeX's \tag, it doesn't automatically wrap with parentheses.
///
/// If `label-str` is not given, it automatically creates a label for referencing, based on the
/// `label-prefix` and `body`. Only alphanumberic characters, period, hyphen and underscore are
/// kept in the label name. Whitespaces are replaced by hyphens. Set `label-str: none` to not
/// create a label.
///
/// When referencing the equation tag, the `supplement` denotes how to refer to the equation.
///
/// Use the `eqref` method to reference an equation by its tag. If multiple tags with the same
/// label exist, it will automatically link to the most recent occurence of the label.
///
/// It is also possible to use the built-in `ref` or `@` syntax to reference equations, but only
/// if this label is unique in the document.
///
/// -> context
#let tag(
  /// Text to display in the tag.
  /// -> str | content
  body: none,
  /// Supplementary text when referencing the equation.
  /// -> str | content
  supplement: "Equation",
  /// Whether to display the tag on the right. If `false`, flushes left instead.
  /// -> bool
  right: true,
  /// Extra rightwards offset to apply to the tag position.
  /// -> length
  dx: 0em,
  /// Prefix to use for autogenerated labels. Only applicable if `label-str` is `auto`.
  /// -> str
  label-prefix: "eq",
  /// Label string to use for referencing the equation.
  ///
  /// If `auto`, generates labels based on the body text. Only alphanumberic characters, period,
  /// hyphen and underscores are kept in the label name. Whitespaces are replaced by hyphens.
  ///
  /// Set to `none` to not create a referencable label. If you just want flushed text without
  /// references, use the `flushl` and `flushr` methods instead.
  /// -> auto | str | none
  label-str: auto,
  /// A label and body (content | str) can be provided in optional args.
  /// -> args
  ..args
) = {
  let fn = if right {flushr} else {flushl}

  for arg in args.pos() {
    if type(arg) == content or type(arg) == str {
      body = arg
    } else if type(arg)== label {
      label-str = str(arg)
    }
  }

  if label-str == auto {
    label-str = label-prefix + "-" + {
      if body.at("text", default: none) != none {
        body.text.replace(regex("[^0-9A-Za-z.\-_]"), "").replace(regex("\\\\w+"), " ")
      } else {
        repr(body).replace(regex("[^0-9A-Za-z.\-_]"), "").replace(regex("\\\\w+"), " ")
      }
    }
  }

  if label-str != none {
    fn([#figure(body, kind: "intertext-eq-tag", supplement: supplement) #label(label-str)], dx: dx)
  } else {
    // No reference needed
    fn(body, dx: dx)
  }
}

/// Similar to LaTeX's `\eqref`, creates a link to an equation created by `tag`.
///
/// - label-str (str | label | int): The label (or label name string) to reference. If the referenced equation has a label of the form `<eq-N>` for some integer N, e.g., if it was tagged with `#tag[(N)]` then just passing the integer N would also work.
/// - args (content): Pass a `content` body to modify the displayed reference text.
/// -> content
#let eqref(
  /// The label string to reference.
  /// -> str | label
  label-str,
  /// Pass a content body to modify the displayed reference text.
  /// -> args
  ..args
) = context {
  let label-str = if type(label-str) == str {
    label-str
  } else if type(label-str) == label {
    str(label-str)
  } else if type(label-str) == int {
    "eq-" + str(label-str)
  }
  let q = query(selector(label(label-str)).before(here()))
  assert(q.len() != 0, message: "Label does not exist: " + label-str)
  let fig = q.last()

  let body = [#fig.supplement #fig.body]
  for arg in args.pos() {
    if type(arg) == content or type(arg) == str {
      body = arg
    }
  }
  link(fig.location(), body)
}

#let intertext-rule = it => {
  show math.equation.where(block: true): it => {
    // return it // uncomment to test if layout is being alteered by pre-eqn-width-ruler

    let (above-old, below-old) = (block.above, block.below)
    // Setting block.below to 0 should make the line not take up any vertical space.
    set block(above: 0em)
    [#line(length: 100%, stroke: 0pt)<pre-eqn-width-ruler>]

    context {
      let ruler = query(selector(<pre-eqn-width-ruler>).before(here())).last()
      place(
        // layout creates a block container, so we don't want it to take up extra space.
        layout(parent => {
          let left = ruler.location().position().x
          let ruler-width = measure(ruler, height: parent.height, width: parent.width).width
          let right = left + ruler-width
          current-left-bounds.update( _ => left)
          current-right-bounds.update(_ => right)
        })
      )
    }
    set block(above: above-old, below: below-old)
    it
  }

  show ref.where(supplement: auto): it => {
    if it.element != none and it.element.func() == figure and {
      it.element.kind == "intertext-eq-tag" and it.element.body != none
    } {
      let body = if it.element.body.at("text", default: none) != none {
        [#it.element.supplement #it.element.body.text]
      } else if it.element.body.at("supplement", default: none) != none {
        it.element.body.supplement
      } else {
        it.element.body
      }

      return link(it.element.location(), body)
    }

    it
  }

  it
}