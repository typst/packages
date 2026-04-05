
#let type_check(
  ty,
  function,
) = {
  if type(ty) == array {
    let tys = ty.map(t => eval(t, mode: "code"))
    (value_ty, use) => {
      value_ty in tys or (function and (not use) and value_ty == function)
    }
  } else {
    let ty = eval(ty, mode: "code")
    (value_ty, use) => {
      value_ty == ty or (function and (not use) and value_ty == function)
    }
  }
}

#let type_check_str(
  ty,
  function,
) = {
  if type(ty) == array {
    let tys = ty.map(t => {
      let t = eval(t, mode: "code");
      if t == none {
        "none"
      } else {
        str(t)
      }
    })
    let out = "either a " + tys.join(", a ", last: ", or a ")
    let out_function = if function {
      "either a " + tys.join(", a ") + ", or a function that returns one of the previous types"
    } else {
      out
    }

    (use) => {
      if function and (not use) {
        out_function
      } else {
        out
      }
    }
  } else {
    (_) => ("a " + str(eval(ty, mode: "code")))
  }
}

#let state_with_type(
  name,
  type_check,
  type_check_str,
  default,
  allow-fn,
) = {
  let state = state("codly-" + name, default)

  (
    set-raw: (value) => {
      state.update((_) => value)
    },
    update: (value) => {
      assert(
        type_check(type(value), false),
        message: "codly: `" + name + "` must be " + type_check_str(false) + ", found: " + str(type(value)),
      )
      state.update((_) => value)
    },
    type_check: (value) => {
      assert(
        type_check(type(value), false),
        message: "codly: `" + name + "` must be " + type_check_str(false) + ", found: " + str(type(value)),
      )

      value
    },
    reset: () => {
      state.update((_) => default)
    },
    default: default,
  )
}

#let __codly-args = {
  let out = (:)
  let args = json("args.json")
  for (key, arg) in args {
    if arg.function and function in arg.ty {
      panic("codly: `function` is not a valid type for an argument")
    }
    
    out.insert(
      key,
      state_with_type(
        key,
        type_check(arg.ty, arg.function),
        type_check_str(arg.ty, arg.function),
        eval(arg.default, mode: "code"),
        arg.function,
      )
    )
  }

  out
}

#let __codly-defaults = {
  let out = (:)
  __codly-args.pairs().map(((key, value)) =>(key, value.default)).to-dict()
}

// Must be called in a context!
#let __codly-save() = {
  let out = (:)
  for (key, value) in __codly-args {
    out.insert(key, (value.get-raw)())
  }
  return out
}

// Must be called after `__codly_save`!
#let __codly-load(stored) = {
  for (key, value) in __codly-args {
    (value.set-raw)(stored.at(key))
  }
}