
#import "../util/is.typ"
#import "../util/utils.typ"
#import "../core/index.typ": idx
#import "../core/themes.typ": themable
#import "../core/styles.typ"

#import "icons.typ"
#import "values.typ"
#import "types.typ": dtype, dtypes
#import "links.typ": link-builtin
#import "elements.typ" as elements: module as _module


/// Highlight an argument name.
///
/// #ex(`#meta[variable]`)
/// -> content
#let meta(
  /// Name of the argument.
  /// -> str | content
  name,
  /// Prefix to #arg[name].
  /// -> str | content | symbol
  l: sym.angle.l,
  /// Prefix to #arg[name].
  /// -> str | content | symbol
  r: sym.angle.r,
) = styles.meta(name, l: l, r: r)


/// Shows an argument, either positional or named.
/// The argument name is highlighted with @cmd:meta and the value with @cmd:value.
///
/// - #ex(`#arg[name]`)
/// - #ex(`#arg("name")`)
/// - #ex(`#arg(name: "value")`)
/// - #ex(`#arg("name", 5.2)`)
///
/// -> content
#let arg(
  /// Either an argument name (#dtype("string")) or a (`name`: `value`) pair either as a named argument or as exactly two positional arguments.
  /// -> any
  ..args,
  _value: values.value,
) = {
  let a = none
  if args.pos().len() == 1 {
    a = styles.arg(utils.get-text(args.pos().first()))
  } else if args.named() != (:) {
    a = {
      styles.arg(args.named().keys().first())
      utils.rawi(sym.colon + " ")
      _value(args.named().values().first())
    }
  } else if args.pos().len() == 2 {
    a = {
      styles.arg(args.pos().first())
      utils.rawi(sym.colon + " ")
      _value(args.pos().at(1))
    }
  } else {
    panic("Wrong argument count. Got " + repr(args.pos()))
    return
  }
  a
}


/// Shows a body argument.
/// #info-alert[
///   Body arguments are positional arguments that can be given
///   as a separat content block at the end of a command.
/// ]
///
/// - #ex(`#barg[body]`)
///
/// -> content
#let barg(
  /// Name of the argument.
  /// -> str
  name,
) = styles.barg(name)


/// Shows a "code" argument.
/// #info-alert)[
///   "Code" are blocks og Typst code wrapped in braces: `{ ... }`. They are not an actual argument, but evaluate to some other type.
/// ]
/// - #ex(`#carg[code]`)
/// -> content
#let carg(
  /// Name of the argument.
  /// -> str
  name,
) = styles.carg(name)


/// Shows an argument sink / variadic argument.
/// - #ex(`#sarg[args]`)
/// -> content
#let sarg(
  /// Name of the argument.
  /// -> str
  name,
) = styles.sarg(name)


/// Creates a list of arguments from a set of positional and/or named arguments.
///
/// #typ.t.string;s and named arguments are passed to @cmd:arg, while #typ.t.content
/// arguments are passed to @cmd:barg.
/// The result should be unpacked as arguments to @cmd:cmd.
/// #example[```
/// #cmd( "conditional-show", ..args(hide: false, [body]) )
/// ```]
///
/// -> array
#let args(
  /// Either an argument name (#typ.t.string) or a (`name`: `value`) pair either as a named argument or as exactly two positional arguments.
  /// -> any
  ..args,
) = {
  let arguments = args.pos().filter(is.str).map(arg)
  arguments += args.pos().filter(is.content).map(barg)
  arguments += args.named().pairs().map(v => arg(v.at(0), v.at(1)))
  arguments
}


/// Create a lambda function argument.
///
/// Lambda arguments may be used as an argument value with @cmd:arg.
/// #info-alert[To show a lambda function with an
/// argument sink, prefix the type with two dots.]
///
/// - #ex(`#lambda(int, str)`)
/// - #ex(`#lambda("ratio", "length")`)
/// - #ex(`#lambda("int", int, ret:bool)`)
/// - #ex(`#lambda("int", int, ret:(int,str))`)
/// - #ex(`#lambda("int", int, ret:(name: str))`)
/// - #ex(`#lambda("int", int, ret:(str,))`)
///
/// -> content
#let lambda(
  /// Argument types of the function parameters.
  /// -> str | type
  ..args,
  /// Type of the returned value.
  /// -> str | type
  ret: none,
) = {
  // TODO: (jneug) improve implementation (use #styles)
  args = args
    .pos()
    .map(v => {
      if type(v) == str and v.starts-with("..") {
        ".." + dtype(v.slice(2))
      } else {
        dtype(v)
      }
    })
  if type(ret) == array and ret.len() > 0 {
    ret = (
      sym.paren.l
        + ret.map(dtype).join(",")
        + if ret.len() == 1 {
          ","
        }
        + sym.paren.r
    )
  } else if type(ret) == dictionary and ret.len() > 0 {
    ret = (
      sym.paren.l
        + ret
          .pairs()
          .map(pair => {
            pair.first() + sym.colon + dtype(pair.last())
          })
          .join(",")
        + sym.paren.r
    )
  } else {
    ret = dtype(ret)
  }
  styles.lambda(args, ret)
}


/// #property(changed: version(1,0,0))
/// Renders the command #arg[name] with arguments and adds an entry with
/// #arg(kind:"cmd") to the index.
///
/// #sarg[args] is a collection of positional arguments created with @cmd:arg,
/// @cmd:barg and @cmd:sarg (or @cmd:args).
///
/// All positional arguments will be rendered first, then named arguments
/// and all body arguments will be added after the closing paranthesis. The relative order of each argument type is kept.
///
/// #example[```
/// - #cmd("cmd", arg[name], sarg[args], barg[body])
/// - #cmd("cmd", ..args("name", [body]), sarg[args], module:"mod")
/// - #cmd("clamp", arg[value], arg[min], arg[max], module:"math", ret:int, unpack:true)
/// ```]
///
/// -> content
#let cmd(
  /// Name of the command.
  /// -> str
  name,
  /// Name of the commands module. Will be used as a prefix and appear in the index.
  /// -> str
  module: none,
  /// Return type.
  /// -> str | type
  ret: none,
  /// If #typ.v.false, this location is not added to the index.
  /// -> bool
  index: true,
  /// If #typ.v.true, the arguments are shown in separate lines.
  /// -> bool
  unpack: false,
  /// Arguments for the command, created with individual argument commands (@cmd:arg, @cmd:barg, @cmd:sarg) or @cmd:args.
  /// -> content
  ..args,
) = {
  if index in (true, "main") {
    idx(
      name,
      kind: "cmd",
      main: index == "main",
      display: styles.cmd(name, module: module),
    )
  }

  // TODO: (jneug) Add module marker ?
  // themable(theme => text(theme.commands.command, utils.rawi(name)))
  styles.cmd(name, module: module)

  let fargs = args.pos().filter(arg => not is.barg(arg))
  let bargs = args.pos().filter(is.barg)

  if fargs == () { } else if unpack == true or (unpack == auto and fargs.len() >= 5) {
    utils.rawi(sym.paren.l) + [\ #h(1em)]
    fargs.join([`,`\ #h(1em)])
    [\ ] + utils.rawi(sym.paren.r)
  } else {
    utils.rawi(sym.paren.l)
    fargs.join(`, `)
    utils.rawi(sym.paren.r)
  }
  bargs.join()
  if ret != none {
    ret = (ret,).flatten()
    box(inset: (x: 2pt), sym.arrow.r) //utils.rawi("->"))
    ret.map(dtype).join(" | ") //dtypes(..ret)
  }
}


/// Same as @cmd:cmd, but does not create an index entry (#arg(index: false)).
/// -> content
#let cmd- = cmd.with(index: false)


/// Shows the variable #arg[name] and adds an entry to the index.
/// - #ex(`#var[colors]`)
/// -> content
#let var(
  /// Name of the variable.
  /// -> str
  name,
  /// Name of the commands module. Will be used as a prefix and appear in the index.
  /// -> str
  module: none,
  /// If #typ.v.false, this location is not added to the index.
  /// -> bool
  index: true,
) = {
  if index in (true, "main") {
    idx(
      name,
      kind: "var",
      main: index == "main",
      display: styles.cmd(name, module: module, color: "variable"),
    )
  }
  styles.cmd(name, module: module, color: "variable")
}


/// Same as var, but does not create an index entry.
/// -> content
#let var- = var.with(index: false)


/// Displays a built-in Typst function with a link to the documentation.
/// - #ex(`#builtin[context]`)
/// - #ex(`#builtin(module:"math")[clamp]`)
/// -> content
#let builtin(
  /// Name of the function (eg. `raw`).
  /// -> str, content
  name,
  /// Optional module name.
  /// -> str
  module: none,
) = {
  let name = utils.get-text(name)
  link-builtin(name, styles.cmd(name, color: "builtin", module: module))
}


// Internal map of known command properties.
#let _properties = (
  default: (k, v) => elements.alert("none")[*#utils.rawi(k)*: #utils.rawi(v)],
  //
  deprecated: (..) => elements.note(
    dy: -2em,
    styles.pill(
      "emph.deprecated",
      (
        icons.icon("circle-slash") + sym.space.nobreak + "deprecated"
      ),
    ),
  ),
  //
  since: (_, v) => elements.note(
    dy: -2em,
    styles.pill(
      "emph.since",
      (
        icons.icon("arrow-up") + sym.space.nobreak + "Introduced in " + str(v)
      ),
    ),
  ),
  //
  until: (_, v) => elements.note(
    dy: -2em,
    styles.pill(
      "emph.until",
      (
        icons.icon("arrow-down") + sym.space.nobreak + "Available until " + str(v)
      ),
    ),
  ),
  //
  requires-context: (..) => elements.note(
    dy: -2em,
    styles.pill(
      "emph.context",
      (
        icons.icon("pulse") + sym.space.nobreak + "context"
      ),
    ),
  ),
  //
  compiler: (_, v) => elements.note(
    dy: -2em,
    styles.pill(
      "emph.compiler",
      (
        icons.typst + sym.space.nobreak + str(v)
      ),
    ),
  ),
  //
  changed: (_, v) => elements.note(
    dy: -2em,
    styles.pill(
      "emph.changed",
      (
        icons.icon("arrow-switch") + sym.space.nobreak + "Changed in " + str(v)
      ),
    ),
  ),
  //
  see: (
    _,
    v,
  ) => elements.info-alert[#icons.icon("link-external") see #{(v,).flatten().map(t => if is.str(t) { link(t, t) } else { ref(t) } ).join(", ")}],
  //
  todo: (_, v) => elements.success-alert[#text(fill: green)[#icons.icon("check") *TODO*] #v],
)


/// Shows a command property (annotation).
/// This should be used in the #barg[body] of @cmd:command to
/// annotate a function with some special meaning.
///
/// Properties are provided as named arguments to the @cmd:property
/// function.
///
/// The following properties are currently known to MANTYS:
/// #property(since: version(1,0,1))
/// / since #dtypes(version, str): Marks this function as available since a given package version.
///
/// #property(until: version(0,1,4))
/// / until #dtypes(version, str): Marks this function as available until a given package version.
///
/// #property(deprecated: version(1,0,1))
/// / deprecated #dtypes(bool, version, str): Marks this function as deprecated. If set to a version, the function is supposed to stay availalbel until the given version.
///
/// #property(changed: version(0,12,0))
/// / changed #dtypes(version, str): Marks function that changed in a specific package version.
///
/// #property(compiler: version(0,12,0))
/// / compiler #dtypes(version, str): Marks this function as only available on a specific compiler version.
///
/// #property(requires-context: true)
/// / requires-context #dtype(bool): Requires a function to be used inside #builtin[context].
///
/// #property(see: (<cmd:mantys>, "https://github.vom/jneug/typst-mantys"))
/// / see #dtype(array) of #dtypes(str, label): Adds references to other commands or websites.
///
/// #property(todo: [
///   - Add documentation.
///   - Add #arg[foo] paramter.
/// ])
/// / todo #dtypes(str, content): Adds a todo note to the function.
///
/// Other named properties will be shown as given:
/// #property(module: "utilities")
#let property(
  /// Property name / value pairs.
  /// -> any
  ..args,
) = {
  for (k, v) in args.named() {
    if k in _properties {
      (_properties.at(k))(k, v)
    } else {
      (_properties.default)(k, v)
    }
  }
}


/// Displays information of a command by formatting the name, description and arguments.
/// See this commands description for an example.
///
/// The command is formated with @cmd:cmd and an index entry is added that is marked as the
/// "main" index entry for this command.
/// -> content
#let command(
  /// Name of the command.
  /// -> str
  name,
  /// Custom label for the command.
  /// -> string | auto | none
  label: auto,
  /// Dictionary of properties to be passed to @cmd:property.
  /// -> dictionary
  properties: (:),
  /// List of arguments created with the argument functions (@cmd:arg, @cmd:barg, @cmd:sarg) or @cmd:args.
  /// -> content
  ..args,
  /// Description of the command. Usually some text and a series of @cmd:argument descriptions.
  /// -> content
  body,
) = block()[
  #if label not in (none, false) {
    if label in (auto, true) {
      utils.place-reference(
        utils.create-label(name, module: args.named().at("module", default: none)),
        "cmd",
        "command",
      )
    } else {
      utils.place-reference(label, "cmd", "command")
    }
  }
  #block(
    below: 0.65em,
    above: 1.3em,
    breakable: false,
    {
      property(..properties)
      text(weight: 600, cmd(name, unpack: auto, index: "main", ..args))
    },
  )
  //#pad(left: 1em, body)//#cmd-label(mty.def.if-auto(name, label))
  // #v(.65em, weak:true)
  #block(inset: (left: 1em), width: 100%, body)
]


/// Displays information for a variable definition.
/// #example[```
/// #variable("primary", types:("color",), value:green)[
///   Primary color.
/// ]
/// ```]
/// -> content
#let variable(
  /// Name of the variable.
  /// -> string
  name,
  /// Array of types to be passed to @cmd:dtypes.
  /// -> array
  types: none,
  /// Default value.
  /// -> any
  value: none,
  /// Custom label for the variable.
  /// -> string | auto | none
  label: auto,
  /// Dictionary of properties to be passed to @cmd:property.
  /// -> dictionary
  properties: (:),
  /// Description of the variable.
  /// -> content
  body,
) = [
  #set terms(hanging-indent: 0pt)
  #set par(first-line-indent: 0.65pt, hanging-indent: 0pt)
  #let types = (types,).flatten()
  #property(..properties)
  / #var(name, index: "main")#if value != none {
      sym.colon + " " + values.value(value)
    }#if types != (none,) {
      h(1fr) + dtypes(..types)
    }: #block(inset: (left: 2em), body)
]


/// Displays information for a command argument.
/// See the argument list below for an example.
///
/// #example[```
/// #argument("category", default:"utilities")[
///   #lorem(10)
/// ]
///
/// #argument("category", choices: ("a", "b", "c"), default:"d")[
///   #lorem(10)
/// ]
///
/// #argument("style-args", title:"Style Arguments",
///     is-sink:true, types:(length, ratio))[
///   #lorem(10)
/// ]
/// ```]
/// -> content
#let argument(
  /// Name of the argument.
  /// -> str
  name,
  /// If this is a variadic argument.
  /// -> bool
  is-sink: false,
  /// Array of types to be passed to @cmd:dtypes.
  /// -> array | none
  types: none,
  /// Optional array of valid values for this argument.
  /// -> array | none
  choices: none,
  /// Optional default value for this argument. Will be automatically included in #arg[choices] if it is missing. To allow #value(none) as a default value, the default is #value("__none___").
  /// -> any
  default: "__none__",
  /// Title in the border of the surronding #typ.block.
  /// -> str | none
  title: "Argument",
  /// Dictionary of properties to be passed to @cmd:property.
  /// -> dictionary
  properties: (:),
  /// Optional information about the command this argument is attached to. Setting this to the name of a command will create a label for this argument in the form of `@cmd:cmd-name.arg-name`.
  ///
  /// #ex(`@cmd:argument.title`)
  ///
  /// #package[Tidy] will automatically set this to the appropriate command.
  /// -> str | dictionary
  command: none,
  /// Description of the argument.
  /// -> content
  body,
  _value: values.value,
) = {
  types = (types,).flatten()

  // TODO (jneug) can this be automated?
  if command != none {
    if type(command) == str {
      command = (name: command)
    }

    utils.place-reference(
      utils.create-label(command.name, arg: name, module: command.at("module", default: none)),
      "arg",
      "argument",
    )
  }

  v(.65em)
  /// TODO (jneug) use styles.typ
  themable(theme => block(
    width: 100%,
    above: .65em,
    stroke: .75pt + theme.muted.fill,
    inset: (top: 10pt, rest: 8pt),
    radius: 2pt,
    {
      property(..properties)
      // Place title
      if title != none {
        place(
          top + left,
          dy: -15.5pt,
          dx: 5.75pt,
          box(
            inset: 2pt,
            fill: white,
            text(size: .75em, font: theme.fonts.sans, theme.muted.fill, title),
          ),
        )
      }
      if is-sink {
        sarg(name)
      } else if default != "__none__" {
        arg(name, default, _value: _value)
      } else {
        arg(name)
      }
      h(1fr)
      if types != (none,) {
        dtypes(..types)
      } else if default != "__none__" {
        dtype(type(default))
      }
      block(width: 100%, below: .65em, inset: (x: .75em), body)
    },
  ))
}


/// Creates a reference to the command #arg[name].
/// This is equivalent to using `@cmd:name`.
/// - #ex(`#cmdref("cmdref")`)
/// - #ex(`@cmd:cmdref`)
/// -> content
#let cmdref(
  /// Name of the command.
  /// -> str
  name,
  /// Optional module name.
  /// -> str
  module: none,
  // TODO (jneug) add index argument (?)
) = {
  ref(utils.create-label(name, module: module))
}


/// Creates a reference to the argument #arg[name].
/// This is equivalent to using `@cmd:command.name`.
/// - #ex(`#argref("argref", "name")`)
/// - #ex(`@cmd:argref.name`)
/// -> content
#let argref(
  /// Name of the command.
  /// -> str
  command,
  /// Name of the argument.
  /// -> str
  name,
  /// Optional module name.
  /// -> str
  module: none,
) = {
  ref(utils.create-label(command, arg: name, module: module))
}


/// Creates a reference to the custom type #arg[name].
/// This is equivalent to using `@type:name`.
///
/// Note that the custom type has to be declared first. See @subsec:custom-types for more information about custom types.
///
/// //- #ex(`#typeref("author")`)
/// //- #ex(`@type:author`)
/// -> content
#let typeref(
  /// Name of the custom type.
  /// -> content
  name,
) = ref(utils.create-label(name, prefix: "type"))
