
#import "@preview/t4t:0.3.2": is, alias

#import "./mty.typ"
#import "./mty.typ": idx, make-index, module, package, lineref

#import "./theme.typ"


/// === Describing arguments and values <describing-arguments>
/// Highlight an argument name.
/// #shortex(`#meta[variable]`)
///
/// - name (string, content): Name of the argument.
/// -> content
#let meta( name ) = mty.rawc(theme.colors.argument, {sym.angle.l + name + sym.angle.r})
//#let meta = mty.rawc.with(theme.colors.argument)


/// Shows #arg[value] as content.
/// - #shortex(`#value("string")`)
/// - #shortex(`#value([string])`)
/// - #shortex(`#value(true)`)
/// - #shortex(`#value(1.0)`)
/// - #shortex(`#value(3em)`)
/// - #shortex(`#value(50%)`)
/// - #shortex(`#value(left)`)
/// - #shortex(`#value((a: 1, b: 2))`)
///
/// - value (any): Value to show.
/// -> content
#let value( value ) = {
  if is.str(value) and value.contains("=>") {
    return mty.rawc(theme.colors.value, value)
	} else if mty.is-choices(value) or mty.is-func(value) or mty.is-lambda(value) {
    return value
	} else {
		return mty.rawc(theme.colors.value, repr(value))
	}
}

#let _v = value

/// Highlights the default value of a set of #cmd[choices].
/// - #shortex(`#default("default-value")`)
/// - #shortex(`#default(true)`)
/// - #shortex(`#choices(1, 2, 3, 4, default: 3)`)
///
/// - value (any): The value to highlight.
/// -> content
#let default( value ) = mty.add-mark(<default>, underline(_v(value), offset:0.2em, stroke:1pt+theme.colors.value))

#let _d = default


/// Create a link to the reference documentation at #link("https://typst.app/docs/reference/").
/// #example[```
/// See the #doc("meta/locate") function.
/// ```]
///
/// - target (string): Path to the subpage of `https://typst.app/docs/reference/`.
///   The `lowercase` command for example is located in the category `text` and
///   has #arg(target: "text/lowercase").
/// - name (string): Optional name for the link. With #value(auto), the #arg[target]
///   is split on `/` and the last part is used.
/// - anchor (string): An optional HTML page anchor to append to the link.
/// - fnote (boolean): Show the reference link in a footnote.
/// -> content
#let doc( target, name:none, anchor:none, fnote:false ) = {
	if name == none {
		name = target.split("/").last()
	}
	let url  = "https://typst.app/docs/reference/" + target
  if mty.is.not-empty(anchor) {
    url += "#" + anchor
  }

	link(url, mty.rawi(name))
	if fnote {
		footnote(link(url))
	}
}


/// Shows a highlightd data type with a link to the reference page.
///
/// #arg[t] may be any value to pass to #doc("foundations/type") to get the type or a #dtype("string") with the name of a datatype. To show the `string` type, use #raw(lang:"typ", `#dtype("string")`.text). To force the parsing of the values type, set #arg(parse-type: true).
/// - #shortex(`#dtype("integer")`)
/// - #shortex(`#dtype(1deg)`)
/// - #shortex(`#dtype(true)`)
/// - #shortex(`#dtype(())`)
/// - #shortex(`#dtype(red)`)
///
/// - type (any): Either a value to take the type from or a string with the dataype name.
/// - fnote (boolean): If #value(true), the reference lin kis shown in a footnote.
/// - parse-type (boolean): If #arg[t] should always be passed to #doc("foundations/type").
/// -> content
#let dtype( type, fnote:false, parse-type:false ) = {
  if mty.not-is-func(type) and mty.not-is-lambda(type) {
    if parse-type or alias.type(type) != "string" {
      type = str(alias.type(type))
    }
  }

	let d = none
  if mty.is-func(type) {
    d = doc("types/function", fnote:fnote)
		type = "function"
  } else if mty.is-lambda(type) or type.contains("=>") {
		d = doc("types/function", name:type, fnote:fnote)
		type = "function"
	} else if type == "location" {
		d = doc("meta/locate", name:"location", fnote:fnote)
	} else if type == "any" {
		d = doc("types", name:"any", fnote:fnote)
	} else if type == "dict" {
		type = "dictionary"
		d = doc("types/dictionary", name:"dictionary", fnote:fnote)
	} else if type == "arr" {
		type = "array"
		d = doc("types/array", name:"array", fnote:fnote)
	} else if type == "regular experssion" {
		d = doc("construct/regex", name:"regular expression", fnote:fnote)
	} else if type.ends-with("alignment") {
		d = doc("layout/align/#parameters-alignment", name:type, fnote:fnote)
	} else {
		d = doc("types/" + type, fnote:fnote)
	}

	if type in theme.colors.dtypes {
		box(fill: theme.colors.dtypes.at(type), radius:2pt, inset: (x: 4pt, y:0pt), outset:(y:2pt), d)
	} else {
		d
	}
}


/// Shows a list of datatypes.
/// - #shortex(`#dtypes(false, "integer", (:))`)
/// - ..types (any): List of values to get the type for or strings with datatype names.
/// -> content
#let dtypes( ..types, sep: box(inset:(left:1pt,right:1pt), sym.bar.v)) = {
	types.pos().map(dtype.with(fnote:false)).join(sep)
}


/// Shows an argument, either positional or named. The argument name is highlighted with #cmd-[meta] and the value with #cmd-[value].
///
/// - #shortex(`#arg[name]`)
/// - #shortex(`#arg("name")`)
/// - #shortex(`#arg(name: "value")`)
/// - #shortex(`#arg("name", 5.2)`)
///
/// - ..args (any): Either an argument name (#dtype("string")) or a (`name`: `value`) pair either as a named argument or as exactly two positional arguments.
/// -> content
#let arg(..args) = {
	let a = none
	if args.pos().len() == 1 {
		a = meta(mty.get.text(args.pos().first()))
	} else if args.named() != (:) {
		a = {
			meta(args.named().keys().first())
			mty.rawi(sym.colon + " ")
      _v(args.named().values().first())
		}
	} else if args.pos().len() == 2 {
		a = {
			meta(args.pos().first())
			mty.rawi(sym.colon + " ")
      _v(args.pos().at(1))
		}
	} else {
		panic("Wrong argument count. Got " + repr(args.pos()))
		return
	}
	mty.add-mark(<arg>, a)
}


/// Shows a body argument.
/// #ibox(width:100%)[
///   Body arguments are positional arguments that can be given
///   as a separat content block at the end of a command.
/// ]
/// - #shortex(`#barg[body]`)
///
/// - name (string): Name of the argument.
/// -> content
#let barg( name ) = {
	let b = {
		mty.rawi(sym.bracket.l)
		meta(mty.get.text(name))
		mty.rawi(sym.bracket.r)
	}
  mty.mark-body(b)
}


/// Shows an argument sink.
/// - #shortex(`#sarg[args]`)
///
/// - name (string): Name of the argument.
/// -> content
#let sarg( name ) = {
	let s = ".." +meta( mty.get.text(name))
  mty.mark-sink(s)
}


/// Creates a list of arguments from a set of positional and/or named arguments.
///
/// #dtype("string")s and named arguments are passed to #cmd-[arg], while #dtype("content")
/// is passed to #cmd-[barg].
/// The result is to be unpacked as arguments to #cmd-[cmd].
/// #example[```
/// #cmd( "conditional-show", ..args(hide: false, [body]) )
/// ```]
/// - ..args (any): Either an argument name (#dtype("string")) or a (`name`: `value`) pair either as a named argument or as exactly two positional arguments.
/// -> array
#let args( ..args ) = {
	let arguments = args.pos().filter(mty.is.str).map(arg)
	arguments += args.pos().filter(mty.is.content).map(barg)
	arguments += args.named().pairs().map(v => arg(v.at(0), v.at(1)))
	arguments
}


/// Shows a list of choices possible for an argument.
///
/// If #arg[default] is set to something else than #value("__none__"), the value
/// is highlighted as the default choice. If #arg[default] is already given in
/// #arg[values], the value is highlighted at its current position. Otherwise
/// #arg[default] is added as the first choice in the list.
/// - #shortex(`#choices(left, right, center)`)
/// - #shortex(`#choices(left, right, center, default:center)`)
/// - #shortex(`#choices(left, right, default:center)`)
/// - #shortex(`#arg(align: choices(left, right, default:center))`)
/// -> content
#let choices( default: "__none__", ..values ) = {
	let list = values.pos().map(_v)
	if default != "__none__" {
		if default in values.pos() {
			let pos = values.pos().position(v => v == default)
			list.at(pos) = _d(default)
		} else {
			list.insert(0, _d(default))
		}
	}
	mty.add-mark(<arg-choices>, list.join(box(inset:(left:1pt,right:1pt), sym.bar.v)))
}


#let content( name ) = {
  mty.mark-lambda( "" + name )
}


/// Shows a Typst reserved symbol argument.
/// - #shortex(`#symbol("dot")`)
/// - #shortex(`#symbol("angle.l", module:"sym")`)
/// - #shortex(`#arg(format: symbol("angle.l", module:"sym"))`)
/// -> content
#let symbol( name, module: none ) = {
  let full-name = if mty.is.not-none(module) {
    mty.module(module) + `.` + mty.rawc(theme.colors.command, name)
  } else {
    mty.rawc(theme.colors.command, name)
  }
  mty.mark-lambda(full-name)
}


/// Create a function argument.
/// Function arguments may be used as an argument value with #cmd-[arg].
/// - #shortex(`#func("func")`)
/// - #shortex(`#func("clamp", module:"calc")`)
/// - #shortex(`#arg(format: func("upper"))`)
#let func( name, module: none ) = {
  if type(name) == "function" {
    name = repr(name)
  }
  let full-name = if mty.is.not-none(module) {
    mty.module(module) + `.` + mty.rawc(theme.colors.command, name)
  } else {
    mty.rawc(theme.colors.command, name)
  }
  mty.mark-func(emph(mty.rawi(sym.hash) + full-name))
}


/// Create a lambda function argument.
/// Lambda arguments may be used as an argument value with #cmd-[arg].
/// To show a lambda function with an argument sink, prefix the type with two dots.
/// - #shortex(`#lambda("integer", "boolean", ret:"string")`)
/// - #shortex(`#lambda("..any", ret:"boolean")`)
/// - #shortex(`#arg(format: lambda("string", ret:"content"))`)
/// -> content
#let lambda( ..args, ret:none  ) = {
  args = args.pos().map(v => {
    if v.starts-with("..") {
      ".." + dtype(v.slice(2))
    } else {
      dtype(v)
    }
  })
  if mty.is.arr(ret) and ret.len() > 0 {
    ret = sym.paren.l + ret.map(dtype).join(",") + if ret.len() == 1 {","} + sym.paren.r
  } else if mty.is.dict(ret) and ret.len() > 0 {
    ret = sym.paren.l + ret.pairs().map(pair => {sym.quote + pair.first() + sym.quote + sym.colon + dtype(pair.last())}).join(",") + sym.paren.r
  } else {
    ret = dtype(ret)
  }
  mty.mark-lambda(sym.paren.l + args.join(",") + sym.paren.r + " => " + ret )
}


/// === Describing commands <describing-commands>
/// Renders the command #arg[name] with arguments and adds an entry with
/// #arg(kind:"command") to the index.
///
/// #arg[args] is a collection of positional arguments created with #cmd[arg],
/// #cmd[barg] and #cmd[sarg].
///
/// All positional arguments will be rendered first, then named arguments
/// and all body arguments will be added after the closing paranthesis.
///
/// - #shortex(`#cmd("cmd", arg[name], sarg[args], barg[body])`)
/// - #shortex(`#cmd("cmd", ..args("name", [body]), sarg[args])`)
///
/// - name (string): Name of the command.
/// - module (string): Name of a module, the command belongs to.
/// - ret (any): Returned type.
/// - index (boolean): Whether to add an index entry.
/// - unpack (boolean): If #value(true), the arguments are shown in separate lines.
/// - ..args (any): Arguments for the command, created with the argument commands above or @@args.
/// -> content
#let cmd(name, module:none, ret:none, index:true, unpack:false, ..args) = {
  if index {
    mty.idx(kind:"cmd", hide:true)[#mty.rawi(sym.hash)#mty.rawc(theme.colors.command, name)]
  }

  mty.rawi(sym.hash)
  if mty.is.not-none(module) {
    mty.module(module) + `.`
  } else {
    // raw("", lang:"cmd-module")
    mty.place-marker("cmd-module")
  }
  mty.rawc(theme.colors.command, name)

  let fargs = args.pos().filter(mty.not-is-body)
  let bargs = args.pos().filter(mty.is-body)

	if unpack == true or (unpack == auto and fargs.len() >= 5) {
    mty.rawi(sym.paren.l) + [\ #h(1em)]
    fargs.join([`,`\ #h(1em)])
    [\ ] + mty.rawi(sym.paren.r)
	} else {
    mty.rawi(sym.paren.l)
    fargs.join(`, `)
    mty.rawi(sym.paren.r)
  }
	bargs.join()
	if ret != none {
    ret = (ret,).flatten()
		box(inset:(x:2pt), sym.arrow.r)//mty.rawi("->"))
		dtypes(..ret)
	}
}

/// Same as @@cmd, but does not create an index entry.
#let cmd- = cmd.with(index:false)


/// Shows the option #arg[name] and adds an entry with #arg(kind:"option")
/// to the index.
/// - #shortex(`#opt[examples-scope]`)
///
/// - name (string, content): Name of the option.
/// - index (boolean): Whether to create an index entry.
/// - clr (color): A color
/// -> content
#let opt(name, index:true, clr:blue) = {
	if index {
		mty.idx(kind:"option")[#mty.rawc(theme.colors.option, name)]
	} else {
		mty.rawc(theme.colors.option, name)
	}
}


/// Same as @@opt, but does not create an index entry.
#let opt- = opt.with(index:false)


/// Shows the variable #arg[name] and adds an entry to the index.
/// - #shortex(`#var[colors]`)
/// -> content
#let var( name ) = {
	mty.rawi(sym.hash)
	mty.rawc(theme.colors.command, name)
}

/// Same as @@var, but does not create an index entry.
#let var- = var


/// Creates a label for the command with name #arg[name].
///
/// - name (string): Name of the command.
/// - module (string): Optional module name.
/// -> label
#let cmd-label( name, module: "" ) = label(module + name + "()")


/// Creates a label for the variable with name #arg[name].
///
/// - name (string): Name of the variable.
/// - module (string): Optional module name.
/// -> label
#let var-label( name, module: "" ) = label(module + name)


#let __s_mty_command = state("@mty-command", none)


/// Displays information of a command by formatting the name, description and arguments.
/// See this command description for an example.
///
/// - name (string): Name of the command.
/// - label (string): Custom label for the command. Defaults to #value(auto).
/// - ..args (content): List of arguments created with the argument functions like @@arg.
/// - body (content): Description for the command.
/// -> content
#let command(name, label:auto, ..args, body) = [
  #__s_mty_command.update(name)
  #block(
    below: 0.65em,
    above: 1.3em,
    text(weight:600)[#cmd(name, unpack:auto, ..args)<cmd>]
  )
  #block(inset:(left:1em), spacing: 0pt, breakable:true, body)#cmd-label(mty.def.if-auto(name, label))
  #__s_mty_command.update(none)
  // #v(.65em, weak:true)
]

/// Displays information for a variable defintion.
/// #example[```
/// #variable("primary", types:("color",), value:green)[
///   Primary color.
/// ]
/// ```]
///
/// - name (string): Name of the variable.
/// - types (array): Array of types to be passed to @@dtypes.
/// - value (any): Default value.
/// - body (content): Description of the variable.
/// -> content
#let variable( name, types:none, value:none, label:auto, body ) = [
	#set terms(hanging-indent: 0pt)
	#set par(first-line-indent:0.65pt, hanging-indent: 0pt)
	/ #var(name)#{if value != none {" " + sym.colon + " " + _v(value)}}#{if types != none {h(1fr) + dtypes(..types)}}<var>: #block(inset:(left:2em), body)#var-label(mty.def.if-auto(name, label))
]

/// Displays information for a command argument.
/// See the argument list below for an example.
///
/// - name (string): Name of the argument.
/// - is-sink (boolean): If this is a sink argument.
/// - types (array): Array of types to be passed to @@dtypes.
/// - choices (array): Optional array of valid values for this argument.
/// - default (any): Optional default value for this argument.
/// - body (content): Description of the argument.
/// -> content
#let argument(
	name,
	is-sink: false,
	types: none,
	choices: none,
	default: "__none__",
	body
) = {
  types = (types,).flatten()

  v(.65em)
  block(
    above: .65em,
    stroke:.75pt + theme.colors.muted,
    inset: (top:10pt, left: -1em + 8pt, rest:8pt),
    outset: (left: 1em),
    radius: 2pt, {
    place(top+left, dy: -15.5pt, dx: 5.75pt,
      box(inset:2pt, fill:white,
        text(size:.75em, font:theme.fonts.sans, theme.colors.muted, "Argument")
      )
    )
    if is-sink {
      sarg(name)
    } else if default != "__none__" {
      arg(..mty.get.dict(name, default))
    }  else {
      arg(name)
    }
    h(1fr)
    if mty.is.not-none(types) { dtypes(..types) } else if default != "__none__" { dtype(default) }
    block(width:100%, below: .65em, inset:(x:.75em), body)
  })
}


/// A wrapper around @@command calls that belong to an internal module.
/// The module name is displayed as a prefix to the command name.
/// #example[```
/// #module-commands("mty")[
///   #command("rawi")[
///     Shows #arg[code] as inline #doc("text/raw") text (with #arg(block: false)).
///   ]
/// ]
/// ```]
///
/// - module (string): Name of the module.
/// - body (content): Content with @@command calls.
/// -> content
#let module-commands(module, body) = [
	// #let add-module = (c) => {
	// 	mty.marginnote[
	// 		#mty.module(module)
	// 		#sym.quote.angle.r.double
	// 	]
	// 	c
	// }
	// #show <cmd>: add-module
	// #show <var>: add-module
  // #show raw.where(lang:"cmd-module"): (it) => mty.module(module) + mty.rawi(sym.dot.basic)
  #show <cmd>: (it) => {
    show mty.marker("cmd-module"): (it) => {
      mty.module(module) + mty.rawi(sym.dot.basic)
    }
    it
  }
	#body
]

/// Creates a selector for a command label.
///
/// - name (string): Name of the command.
/// -> selector
#let cmd-selector(name) = selector(<cmd>).before(cmd-label(name))

/// Creates a reference to a command label.
///
/// - name (string): Name of the command.
/// - module (string): Optional module name.
/// - format (function): Function of #lambda("string", "location", ret:"content") to format the reference. The first argument is the name of the command (the same as #arg[name]) and the second is the location of the referenced label.
/// -> content
#let cmdref(name, module: none, format: (name, loc) => [command #cmd(name) on #link(loc)[page #loc.page()]]) = if module != none {
  // TODO use module in reference
} else {
  link(cmd-label(name), cmd-[name])
}
// locate(loc => {
// 	let res = query(cmd-selector(name), loc)
// 	if res == () {
// 		panic("No label <" + str(cmd-label(name)) + "> found.")
// 	} else {
// 		let e = res.last()
// 		format(name, e.location())
// 	}
// })

/// Creats a relative reference showing the text "above" or "below".
/// - #shortex(`#relref(cmd-label("meta"))`)
/// - #shortex(`#relref(cmd-label("shortex"))`)
///
/// - label (label): The label to reference.
/// -> content
#let relref( label ) = locate(loc => {
  let q = query(selector(label).before(loc), loc)
	if q != () {
		return link(q.last().location(), "above")
	} else {
    q = query(selector(label).after(loc), loc)
  }
  if q != () {
		return link(q.first().location(), "below")
	} else {
		panic("No label " + str(label) + " found.")
	}
})



#let update-examples-scope( imports ) = {
  state("@mty-imports-scope").update(imports)
}

// #let example(..args) = state("@mty-example-imports").display(
//   (imports) => mty.code-example(scope: imports, ..args)
// )
#let example(scope:(:), ..args) = if scope == none {
  mty.code-example(scope: (:), ..args)
} else {
  state("@mty-imports-scope").display(
    (imports) => mty.code-example(scope: imports + scope, ..args)
  )
}

#let side-by-side = example.with(side-by-side:true)

#let shortex( code, sep: sym.arrow.r, mode:"markup", scope:(:) ) = state("@mty-imports-scope").display(
  (imports) => [#raw(code.text, lang:"typ") #sep #eval(code.text, mode:"markup", scope:imports + scope)]
)

#let sourcecode( title: none, file: none, ..args, code ) = {
	let header = ()
	if mty.is.not-none(title) {
		header.push(text(fill:white, title))
	}
	if mty.is.not-none(file) {
		header.push(h(1fr))
		header.push(text(fill:white, emoji.folder) + " ")
		header.push(text(fill:white, emph(file)))
	}

	mty.sourcecode(
    frame: mty.frame.with(title: if header == () { "" } else { header.join() }),
    ..args,
    code,
  )
}

#let codesnippet = mty.sourcecode.with(frame: mty.frame, numbering: none)

#let ibox = mty.alert.with(color:theme.colors.info)
#let wbox = mty.alert.with(color:theme.colors.warning)
#let ebox = mty.alert.with(color:theme.colors.error)
#let sbox = mty.alert.with(color:theme.colors.success)

#let version( since:(), until:() ) = {
  if is.not-empty(since) or is.not-empty(until) {
    mty.marginnote(gutter: 1em, dy: 0pt, {
      set text(size:.8em)
      if is.not-empty(since) { [_since_ #text(theme.colors.secondary, mty.ver(..since))] }
      if is.not-empty(since) and is.not-empty(until) { linebreak() }
      if is.not-empty(until) { [until #text(theme.colors.secondary, mty.ver(..until))] }
    })
  }
}

#let __all__ = (
  arg: arg,
  args: args,
  argument: argument,
  barg: barg,
  choices: choices,
  cmd-: cmd-,
  cmd-label: cmd-label,
  cmd-selector: cmd-selector,
  cmd: cmd,
  cmdref: cmdref,
  codesnippet: codesnippet,
  command: command,
  content: content,
  doc: doc,
  dtype: dtype,
  dtypes: dtypes,
  default: default,
  ebox: ebox,
  // example: example,
  func: func,
  ibox: ibox,
  idx: idx,
  lambda: lambda,
  lineref: lineref,
  make-index: make-index,
  meta: meta,
  module-commands: module-commands,
  module: module,
  opt-: opt-,
  opt: opt,
  package: package,
  relref: relref,
  sarg: sarg,
  sbox: sbox,
  shortex: shortex,
  side-by-side: side-by-side,
  sourcecode: sourcecode,
  symbol: symbol,
  update-examples-scope: update-examples-scope,
  value: value,
  var-: var-,
  var: var,
  variable: variable,
  version: version,
  wbox: wbox,
)
