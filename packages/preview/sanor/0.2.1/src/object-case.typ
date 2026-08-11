#import "class.typ": class, class-of, is-class
#import "utils.typ" as utils: strfmt

#let Case(stylers, wrappers, active: false) = class(
  "modifier",
  stylers: stylers,
  wrappers: wrappers,
  active: active,
)


#let Object(func, cases: (:)) = class(
  "object",
  func: func,
  cases: cases,
)

/// case definition
///
/// Creates a case that can modify content with stylers and wrappers.
/// Stylers are named arguments that modify properties, wrappers are functions
/// that transform the content.
///
/// - ..modifiers (any): Named stylers and positional wrapper functions.
/// -> case
///
/// #example ```typst
/// #let red-text = case(fill: red)
/// #let bold-text = case(text.with(weight: "bold"))
/// ```
#let case(..modifiers) = {
  let stylers = modifiers.named()
  let wrappers = modifiers.pos()

  assert(
    wrappers.all(m => type(m) == function),
    message: "Positional arguments must be functions.",
  )

  Case(stylers, wrappers)
}

#let combine-case(..cases) = {
  let stylers = (:)
  let wrappers = ()
  for case in cases.pos() {
    stylers = utils.merge-dicts(base: stylers, case.stylers)
    wrappers += case.wrappers
  }

  Case(stylers, wrappers)
}

#let make-case(maybe-case) = {
  if class-of(maybe-case) in (str, "modifier") {
    return maybe-case
  }
  if class-of(maybe-case) == dictionary {
    return case(..maybe-case)
  }
  if class-of(maybe-case) == function {
    return case(maybe-case)
  }

  return case(it => maybe-case)
}

#let resolve-case(maybe-case, defined: (:)) = {
  let case = make-case(maybe-case)
  if type(case) == str {
    return defined.at(maybe-case, default: case)
  }
  if class-of(case) == "modifier" {
    return case
  }

  panic(strfmt("Unsupported case `{}`", maybe-case))
}

/// `defined-cases` means  *named* cases.
#let _object(func, hidden: case(hide), defined-cases) = {
  // define the hidden and base cases
  // defined-cases.hidden = resolve-case(hidden, defined: defined-cases)
  hidden = make-case(hidden)
  if class-of(hidden) == str {
    defined-cases.hidden = resolve-case(hidden, defined: defined-cases)
  } else {
    defined-cases.hidden = hidden
  }

  defined-cases.base = Case((:), (it => it,))

  Object(
    func,
    cases: defined-cases,
  )
}

#let _call-object(obj, case, debug: false) = {
  if debug { return obj }
  utils.pipe((obj.func)(..case.stylers), ..case.wrappers)
}

#let _make-object(obj) = (..cases, debug: false) => {
  let cases = cases.pos().map(c => resolve-case(c, defined: obj.cases))
  let current-case = combine-case(..cases)
  _call-object(obj, current-case, debug: debug)
}

/// Creates an object with different states.
///
/// This function creates a reusable object that can be displayed in different
/// states defined by cases. The object can be called with different case names
/// to apply various modifications.
///
/// - func (function): The base function to create the object.
/// - hidden (case): The case to use when the object is hidden.
/// - ..defined-cases (cases): Named cases defining different states.
/// -> function
///
/// #example ```typst
/// #let colored-box = object(
///   rect,
///   normal: case(fill: blue),
///   highlighted: case(fill: yellow)
/// )
/// #colored-box(width: 2cm, height: 1cm)("normal")  // blue box
/// #colored-box(width: 2cm, height: 1cm)("highlighted")  // yellow box
/// ```
#let object(func, hidden: case(hide), ..defined-cases) = {
  assert(defined-cases.pos() == (), message: "Unexpected positional arguments")

  let cases = utils.map-dict-values(defined-cases.named(), make-case)

  (..args) => {
    let obj = _object(func.with(..args), hidden: hidden, cases)

    _make-object(obj)
  }
}

/// There are 3 sources of cases:
/// 1. The object: defined cases,
/// 2. The `tag`: defined cases,
/// 3. The canvas stage: may not be defined cases.
/// The `object` itself will combine all of the cases into one.
#let make-object(maybe-obj, hidden: case(hide), ..defined-cases) = {
  hidden = make-case(hidden)
  if type(maybe-obj) == function {
    let obj = maybe-obj(debug: true)

    if class-of(obj) == "object" {
      // add the other predefined-cases into the object
      defined-cases = defined-cases.named() + (hidden: hidden)
      obj.cases = utils.merge-dicts(base: obj.cases, defined-cases)

      return _make-object(obj)
    }
  }

  object(() => maybe-obj, ..defined-cases, hidden: hidden)()
}
