/// Disables warnings emitted under the namespace `namespace`.
/// Use like: `#disable-warnings("font-warnings")`
/// To enable warnings, use the `enable-warnings` function with the same namespace.
///
/// - namespace (str): The namespace for which to disable warnings. Uses `'warnings::namespace'` as the state key internally.
/// -> function
#let disable-warnings(namespace) = {
  assert(
    type(namespace) == str,
    message: "Namespace passed to `disable-warnings` must be a string.",
  )
  state("warnings::" + namespace).update(false)
}
/// Enables warnings emitted under the namespace `namespace`.
/// Use like: `#enable-warnings("font-warnings")`
/// To disable warnings, use the `disable-warnings` function with the same namespace.
///
/// - namespace (str): The namespace for which to enable warnings. Uses `'warnings::{namespace}'` as the state key internally.
/// -> function
#let enable-warnings(namespace) = {
  assert(
    type(namespace) == str,
    message: "Namespace passed to `enable-warnings` must be a string.",
  )
  state("warnings::" + namespace).update(true)
}

#let delete-font-warning = range(21).map(i => "\u{0008}").sum()

/// Registers a warning namespace. This is not necessary, but is encouraged to avoid collisions with other packages. Returns a context expression so you cannot compute with a return value.
///
/// - namespace (str): The namespace to register. Uses `'warnings::{namespace}'` as the state key internally.
/// - panic (bool): Whether to panic if the namespace is already registered. If false emits a warning instead. Default is true.
/// -> context
#let register-namespace(namespace, panic: true) = context {
  assert(
    type(namespace) == str,
    message: "Namespace passed to `register-namespace` must be a string.",
  )
  if state("warnings::" + namespace).get() != none {
    if panic {
      panic(
        "Warning namespace '"
          + namespace
          + "' is already registered by some other package. Please choose a different namespace to avoid collisions.",
      )
    } else {
      let namespace-already-registered = delete-font-warning + "[uniwarn] Warning namespace '" + namespace + "' is already registered by some other package. Please choose a different namespace to avoid collisions."
      [#set text(font: namespace-already-registered)]
    }
  }
  state("warnings::" + namespace).update(true)
}


/// Display a warning message with `set text(font: ..)` magic.
/// By default, warnings are enabled. To disable warnings, use the `disable-warnings` function.
///
/// Note that this won't show the real location where the warning occured, but this function body instead. As such you should put some info about the cause, location and how to fix it in the message.
///
/// - namespace (str): The warning namespace. Choose it carefully to avoid collisions with other packages. use e.g. your package name. This will use a state with the key `'warnings::namespace'` to store whether the warning is enabled or disabled.
/// - prefix (str): The warning prefix.
/// - message (str): The warning message.
/// -> content
#let warning(namespace: "cstm", prefix: "[custom] ", message) = context {
  let message = if state("warnings::" + namespace, true).get() {
    delete-font-warning + prefix + message
  } else {
    "libertinus serif"
  }
  set text(font: message)
}

#let debug(namespace: "cstm", prefix: "[custom] ", message) = context {
  let message = if state("warnings::" + namespace, true).get() {
    message
  } else {
    "libertinus serif"
  }
  let print = if message == "libertinus serif" {
    ""
  } else {
    message
  }
  text(font: message, print)
}
