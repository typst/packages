#let type_check(
  tys,
  function,
) = {
  assert(
    type(tys) == array,
    message: "codly: the type of a codly argument must be an array"
  )

  (value_ty, use) => {
    value_ty in tys or (function and (not use) and value_ty == function)
  }
}

#let type_check_str(
  tys,
  function,
) = {
  assert(
    type(tys) == array,
    message: "codly: the type of a codly argument must be an array"
  )
  
  let out = "either a " + tys.map(str).join(", a ", last: ", or a ")
  let out_function = if function {
    "either a " + tys.map(str).join(", a ") + ", or a function that returns one of the previous types"
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
      if allow-fn and type(value) == function {
        value = value()
      }
      
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
    let tys = arg.ty.map(t => {
      let t = eval(t, mode: "code");
      if t == none {
        type(none)
      } else {
        t
      }
    })
    if arg.function and function in tys {
      panic("codly: `function` is not a valid type for an argument")
    }
    
    out.insert(
      key,
      state_with_type(
        key,
        type_check(tys, arg.function),
        type_check_str(tys, arg.function),
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