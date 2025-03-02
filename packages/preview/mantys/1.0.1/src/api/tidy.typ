
#import "../_deps.typ" as deps
#import "../_api.typ" as api

#import "../core/tidy.typ" as tidy-style
#import "../core/document.typ"

// Internal helper to pre-configure tidy
#let _show-module = deps.tidy.show-module.with(
  first-heading-level: 2,
  show-module-name: false,
  sort-functions: auto,
  show-outline: true,
)

#let _post-process-module(module-doc, module-args: (:), func-opts: (:), filter: func => true) = {
  let functions = module-doc.functions.filter(filter)

  for (i, func) in functions.enumerate() {
    for (key, value) in func-opts {
      functions.at(i).insert(key, value)
    }
  }

  module-doc.functions = functions
  return module-doc
}


/// Parses and displays a library file with #package("Tidy").
/// #sourcecode[```typ
///  #tidy-module("utils", read("../src/lib/utils.typ"))
/// ```]
/// -> content
#let tidy-module(
  /// Name of the module.
  /// -> str
  name,
  /// Data of the module, usually read with #typ.read.
  /// -> str
  data,
  /// Additional scope for evaluating the modules docstrings.
  /// -> dictionary
  scope: (:),
  /// Optional module name for functions in this module.
  /// By default, all functions will be displayed without a module prefix. This will add a module to the functions by passing
  /// #arg[module] to @cmd:command.
  ///
  /// #frame[
  /// Without module: #cmd[some-command]
  ///
  /// With module: #cmd(module: "util")[another-command]
  /// ]
  ///
  /// Note that setting this will also change function labels to include the module.
  /// -> str
  module: none,
  /// A filter function to apply after parsing the module data. For each function in the module the parsed information is passed to #arg[filter]. It should return #typ.v.true if the function should be displayed and #typ.v.false otherwise.
  /// -> function
  filter: func => true,
  /// Set to #typ.v.true to enable #package[Tidy]s legacy parser (pre version 0.4.0).
  /// -> bool
  legacy-parser: false,
  /// Additional arguments to be passed to
  /// #cmd(module:"tidy", "show-module").
  /// -> any
  ..tidy-args,
) = {
  context {
    let doc = document.get()
    let scope = (
      if doc.examples-scope != none {
        doc.examples-scope.scope
      } else {
        (:)
      }
        + scope
    )

    let module-doc = deps.tidy.parse-module(
      data,
      name: name,
      scope: scope,
      label-prefix: if module == none { "cmd:" } else { module + ":" },
      enable-curried-functions: true,
      old-syntax: legacy-parser,
    )

    module-doc = _post-process-module(
      module-doc,
      // TODO: (jneug) still necessary if label-prefix is module? => Filtering
      func-opts: (
        module: module,
      ),
      filter: filter,
    )

    _show-module(module-doc, style: tidy-style, ..tidy-args.named())
  }
}
