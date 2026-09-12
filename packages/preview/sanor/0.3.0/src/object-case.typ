#import "class.typ": class, class-of, is-class
#import "utils.typ" as utils: strfmt

#let Case(stylers, wrappers) = class(
  "modifier",
  stylers: stylers,
  wrappers: wrappers,
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
/// -> case
#let case(
  /// Named stylers and positional wrapper functions.
  /// -> any
  ..modifiers
) = {
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

#let resolve-case(maybe-case, defined: (:)) = {
  if class-of(maybe-case) == "modifier" {
    return maybe-case
  }
  if class-of(maybe-case) == str {
    return resolve-case(defined.at(maybe-case))
  }
  if class-of(maybe-case) == dictionary {
    return case(..maybe-case)
  }
  if class-of(maybe-case) == function {
    return case(maybe-case)
  }

  return case(it => maybe-case)
}

#let call-object(obj, ..cases) = {
  let cases = cases.pos().map(c => resolve-case(c, defined: obj.cases))
  let case = combine-case(..cases)
  utils.pipe((obj.func)(..case.stylers), ..case.wrappers)
}

/// Creates an object with different states.
///
/// This function creates a reusable object that can be displayed in different
/// states defined by cases. The object can be called with different case names
/// to apply various modifications.
///
/// -> object
#let object(
  /// The base function to create the object.
  /// -> function
  func,
  /// The case to use when the object is hidden.
  /// -> case | function 
  hidden: case(hide), 
  /// Named cases defining different states.
  /// -> arguments
  ..defined-cases
) = {
  assert(defined-cases.pos() == (), message: "Unexpected positional arguments")

  defined-cases = defined-cases.named()
  defined-cases.base = Case((:), (it => it,))
  defined-cases.hidden = resolve-case(hidden, defined: defined-cases)

  (..args) => Object(func.with(..args), cases: defined-cases)
}

// There are 3 sources of cases:
// 1. The object: defined cases,
// 2. The `tag`: defined cases,
// 3. The canvas stage: may not be defined cases.
// The `object` itself will combine all of the cases into one.
#let provide-object(obj, hidden: case(hide), ..defined-cases) = {
  if class-of(obj) == "object" {
    // add the other predefined-cases into the object
    defined-cases = defined-cases.named()
    if hidden != auto { defined-cases += (hidden: hidden) }
    obj.cases = utils.merge-dicts(base: obj.cases, defined-cases)
  } else {
    obj = object(() => obj, ..defined-cases, hidden: hidden)()
  }

  return (..resolved-cases) => call-object(obj, ..resolved-cases)
}
