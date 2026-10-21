#import "utils.typ"
#import "object-case.typ": case, class-of, provide-object
#import "process.typ": _process, get-total-steps
#import "class.typ"
#import "pdfpc.typ"

#let indicate-case(s, name) = {
  let (ctx, ..) = s
  ctx
    .cases
    .at(name, default: ())
    .at(ctx.subslide - 1, default: (
      if ctx.is-shown { ("base",) } else { ("hidden",) }
    ))
}

// raw tag function
#let _tag(s, name, body, hidden: auto, ..defined-cases) = {
  // ensure the name is a string
  name = str(name)
  // get current cases
  let (ctx, ..) = s
  let current-cases = indicate-case(s, name)
  // resolve the hidden case
  if hidden == auto and class-of(body) != "object" {
    hidden = ctx.defined-cases.remove("hidden")
  }

  provide-object(
    body,
    ..ctx.defined-cases,
    ..defined-cases,
    hidden: hidden,
  )(..current-cases)
}

/// Tags content for animation control.
///
/// This function allows you to mark content that can be modified or revealed
/// step by step during a presentation.
///
///
/// ```
/// #slide(s => ([
///   #let tag = tag.with(s)
///   #tag("hello")[Hello World!]
///   #s.push(apply("hello", text.with(fill: red)))
/// ], s))
/// ```
/// -> any
#let tag(
  /// The slide animation sequence provided by `slide()`.
  /// -> array
  s,
  /// A unique identifier for the tagged content.
  /// -> str
  name,
  /// The content to tag. If a callback is provided,
  /// it will receive a non-hidden variant of `tag`, allowing nested elements to
  /// be tagged without automatically inheriting the hidden case.
  /// -> any | function
  body,
  /// The case to use when content is hidden.
  /// -> case | function | auto
  hidden: auto,
  /// Additional cases defined for this tag.
  /// -> arguments
  ..defined-cases,
) = {
  if type(body) == function {
    // nested tag will apply without hidden by default
    body = body(_tag.with(s, hidden: "base"))
  }
  _tag(s, name, body, hidden: hidden, ..defined-cases)
}

/// The `pause` function.
/// Show the content after the current number of calls in `s`.
/// Must be used with `#s.push(1)` for step forward, or
/// `#s.push(-1)` for stepping backward.
///
/// ```
/// #slide(s => ([
///   This is visible immediately.
///   #pause(s)[This appears after pushing a step.]
///   #s.push(1)
/// ], s))
/// ```
/// -> any
#let pause(
  /// The slide animation sequence provided by `slide()`.
  /// -> array
  s,
  /// The content to show or hide.
  /// -> any
  body,
  /// The case to use when content is hidden.
  /// -> function | case | auto
  hidden: auto,
) = {
  let (ctx, ..actions) = s
  let current-step = get-total-steps(actions)
  let hidden-case = if hidden == auto { ctx.defined-cases.hidden } else { hidden }
  let obj = provide-object(body, hidden: hidden-case)

  if ctx.subslide > current-step {
    obj("base")
  } else {
    obj("hidden")
  }
}

#let subslide(ctx, func) = {
  let (body, (ctx, ..)) = func((ctx,))
  let i = ctx.subslide

  {
    set heading(outlined: i == 1, bookmarked: i == 1)

    body

    if i > 1 {
      counter(page).update(n => n - 1)
    }
    pdfpc.pdfpc-slide-markers(ctx)
  }

  v(0pt)
  pagebreak(weak: true)
}

#let superhide(body) = {
  show enum: hide
  show list: hide
  hide(body)
}

// The `cases` should be
// (
//   name-1: (..array of cases,),
//   name-2: (..array of cases,),
// )
#let default-options = (
  handout: false,
  handout-index: auto,
  cases: (:),
  subslide: 1,
  step: 1,
  total-steps: 1,
  defined-cases: (hidden: case(superhide)),
  is-shown: false,
  debug: false,
)

/// The main slide function.
///
/// Creates an animated slide where content can be revealed or modified step by step.
/// The function takes a slide context `s` and returns content. Use `s.push()` to add actions
/// that control the animation sequence.
///
/// ```
/// #slide(s => ([
///   #let tag = tag.with(s)
///   #tag("hello")[Hello from Sanor!]
///   #s.push(apply("hello"))
/// ], s))
/// ```
#let slide(
  /// The configuration option dictionary.
  /// -> dictionary
  options: (:),
  /// The body function. Must returns an array of `body` and modified sequence `s`.
  /// Usually written as `s => ([..], s)`.
  /// -> function
  func,
  /// The default case applied to the hidden element.
  /// -> case
  hidden: auto,
  /// Whether to show the tagged elements by default.
  /// -> bool
  is-shown: false,
  /// Reusable named cases for applying on the tagged elements.
  /// Must be in the form `name: case`
  /// -> dictionary
  defined-cases: (:),
) = {
  let base-ctx = utils.merge-dicts(base: default-options, options)
  let ctx = utils.merge-dicts(
    base: base-ctx,
    options
      + (
        is-shown: is-shown,
        start: start,
        defined-cases: defined-cases
          + (
            hidden: if hidden == auto { case(superhide) } else { hidden },
          ),
      ),
  )

  let (_, (_, ..actions)) = func((ctx,))

  let steps = get-total-steps(actions)
  ctx = _process(ctx, actions)

  if steps == 0 { steps += 1 }

  if ctx.handout {
    ctx.subslide = if ctx.handout-index == auto { steps } else { ctx.handout-index }

    return subslide(ctx, func)
  } else {
    for i in range(steps) {
      ctx.subslide = i + 1
      subslide(ctx, func)
    }
  }
}

/// A function for creating a slide, with an animation-context-included `tag` function.
///
/// Unlike the slide function, the animation context is already included in the `tag` callback.
/// The rules for displaying the components must be specified in the `controls` argument instead.
///
/// -> content
#let scene(
  /// A configuration option defined to control the behavior of the slide.
  /// -> dictionary
  options: (:),
  /// A function that receives a `tag` function and returns content
  /// -> function
  func,
  /// Default modifier for tagged components in its hidden state.
  /// -> auto | case | function
  hidden: auto,
  /// Whether to shown the tagged components by default when the component is not called by the control rules.
  /// -> bool
  is-shown: false,
  /// A dictionary whose key is a name and value is a case to modify the tagged components.
  /// -> dictionary
  defined-cases: (:),
  /// An array of rules that will be applied for each step of the animation
  /// -> array
  controls: (),
) = slide(
  s => (func(tag.with(s)), s + controls),
  options: options,
  hidden: hidden,
  is-shown: is-shown,
  defined-cases: defined-cases,
)

/// Sets global options for slides.
///
/// This function allows you to configure default options for all slides,
/// such as enabling handout mode or defining default cases.
///
/// ```
/// #let (slide,) = set-option(handout: true)
/// ```
#let set-option(
  /// Handout mode
  /// -> bool
  handout: false,
  /// Index of the subslide used for handout slides. `auto` means
  /// using the last subslide.
  /// -> auto | int
  handout-index: auto,
  /// Named options to set globally for slides.
  /// -> dictionary
  ..new-options,
) = {
  let options = utils.merge-dicts(
    base: default-options,
    (handout: handout, handout-index: handout-index),
  )

  return (
    slide: slide.with(options: options, ..new-options),
    scene: slide.with(options: options, ..new-options),
  )
}
