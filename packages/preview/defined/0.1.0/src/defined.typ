#import "@preview/valkyrie:0.2.1" as z

#import "utils.typ":*

#let scope = state("defined-scope", sys.inputs)

/// Check if a value is defined.
/// - name (string): The name of the value to check.
/// - from (state): The scope to check the value in.
/// -> (boolean): Whether the value is defined.
#let defined(name, from: scope) = {
  type-check(name, z.either(z.content(), z.string()))

  let real-name = stringfy(name)

  type-check(from.get(), z.dictionary((:)))
  return from.get().keys().contains(real-name)
}

/// Define a value.
/// - name (string): The name of the value to define.
/// - from (state): The scope to define the value in.
/// -> (function): A function that takes a value and defines it.
#let define(name, from: scope) = {
  let real-name = stringfy(name)

  let fn(value) = {
    from.update((inner) => {
      if inner.keys().contains(real-name) {
        error("\"" + real-name + "\" redefined.")
      }

      inner.insert(real-name, value)
      return inner
    })
  }

  return fn
}

/// Define values from a dictionary.
/// - data (dictionary): The values to define.
/// - from (state): The scope to define the values in.
#let from-scope(data, from: scope) = {
  type-check(data, z.dictionary((:)))

  from.update((inner) => {
    for (key, value) in data {
      if inner.keys().contains(key) {
        error("Value " + key + " is already defined.")
      }

      inner.insert(key, value)
    }
    return inner
  })
}

/// Unset a value.
/// - name (string): The name of the value to unset.
/// - from (state): The scope to unset the value in.
#let undef(name, from: scope) = {
  let real-name = stringfy(name)

  from.update((inner) => {
    inner.remove(real-name)
    return inner
  })
}

/// Resolve a value.
/// - name (string): The name of the value to resolve.
/// - from (state): The scope to resolve the value in.
/// -> (any): The resolved value.
#let resolve(name, from: scope) = {
  let real-name = stringfy(name)

  return from.get().at(real-name, default: none)
}

/// Evaluate an expression.
/// - expr (any): The expression to evaluate.
/// - from (state): The scope to evaluate the expression in.
/// - mode (string): The mode to evaluate the expression in.
/// -> (any): The result of the evaluation.
#let expand(expr, from: scope, mode: "code") = {
  return eval(expr, mode: mode, scope: from.get())
}
