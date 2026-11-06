
// Import dependencies
#import "@preview/t4t:0.3.2": *
#import "@preview/codelst:2.0.0"
#import "@preview/showybox:2.0.1": showybox

#import "theme.typ"

// #################################
// # Some common utility functions #
// #################################

/// Shows #arg[code] as inline #doc("text/raw") text (with #arg(block: false)).
/// - #shortex(`#mty.rawi("some inline code")`)
///
/// - code (content): String content to be displayed as `raw`.
/// - lang (string): Optional language for syntax highlighting.
/// -> content
#let rawi( code, lang:none ) = raw(block: false, get.text(code), lang:lang)


/// Shows #arg[code] as inline #doc("text/raw") text (with #arg(block: false)) and with the given #arg[color]. This
/// supports no language argument, since #arg[code] will have a uniform color.
/// - #shortex(`#mty.rawc(purple, "some inline code")`)
///
/// - color (color): Color for the `raw` text.
/// - code (content): String content to be displayed as `raw`.
/// -> content
#let rawc( color, code ) = text(fill:color, rawi(code))


/// A #doc("layout/block") that is centered in its parent container.
/// #example[```
/// #mty.cblock(width:50%)[#lorem(40)]
/// ```]
///
/// - width (length): Width of the block.
/// - ..args (any): Argeuments for #doc("layout/block").
/// - body (content): Content of the block
/// -> content
#let cblock( width:90%, ..args, body ) = pad(
	left:(100%-width)/2, right:(100%-width)/2,
	block(width:100%, spacing: 0pt, ..args, body)
)


/// Create a frame around some content.
/// #ibox[Uses #package("showybox") and can take any arguments the
/// #cmd-[showybox] command can take.]
/// #example[```
/// #mty.frame(title:"Some lorem text")[#lorem(10)]
/// ```]
///
/// ..args (any): Arguments for #package[Showybox].
/// -> content
#let frame( ..args ) = showybox(
  frame: (
    border-color: theme.colors.primary,
    title-color: theme.colors.primary,
    thickness: .75pt,
    radius: 4pt,
    inset: 8pt
  ),
  ..args
)


/// An alert box to highlight some content.
/// #ibox[Uses #package("showybox") and can take any arguments the #cmd-[showybox] command can take.]
/// #example[```
/// #mty.alert(color:purple, width:4cm)[#lorem(10)]
/// ```]
#let alert(
	color: blue,
	width: 100%,
	size: .88em,
  ..style,
	body
) = showybox(
  frame: (
    border-color: color,
    title-color: color,
    body-color: color.lighten(88%),
    thickness: (left:2pt, rest:0pt),
    radius: 0pt,
    inset: 8pt
  ),
  width: width,
  ..style,
  text(size:size, fill:color.darken(60%), body)
)


/// Places a note in the margin of the page.
///
/// - pos (alignment): Either #value(left) or #value(right).
/// - gutter (length): Spacing between note and textarea.
/// - dy (length): How much to shift the note up or down.
/// - body (content): Content of the note.
/// -> content
#let marginnote(
	pos: left,
	gutter: .5em,
	dy: -1pt,
	body
) = {
	style(styles => {
		let _m = measure(body, styles)
		if pos.x == left {
			place(pos, dx: -1*gutter - _m.width, dy:dy, body)
		} else {
			place(pos, dx: gutter + _m.width, dy:dy, body)
		}
	})
}


// persistent state for index entries
#let __s_mty_index = state("@mty-index", ())


/// Removes special characters from #arg[term] to make it
/// a valid format for the index.
///
/// - term (string, content): The term to sanitize.
/// -> string
#let idx-term( term ) = {
	get.text(term).replace(regex("[#_()]"), "")
}


/// Adds #arg[term] to the index.
///
/// Each entry can be categorized by setting #arg[kind].
/// @@make-index can be used to generate the index for one kind only.
///
/// - term (string, content): An optional term to use, if it differs from #arg[body].
/// - hide (boolean): If #value(true), no content is shown on the page.
/// - kind (string): A category for ths term.
/// - body (content): The term or label for the entry.
/// -> (none, content)
#let idx(
  term: none,
  hide: false,
  kind: "term",
  body
) = locate(loc => {
	__s_mty_index.update(arr => {
		arr.push((
			term: idx-term(def.if-none(term, body)),
			body: def.if-none(term, body),
			kind: kind,
			loc: loc
		))
		arr
	})
	if not hide {
		body
	}
})


/// Creates an index from previously set entries.
///
/// - kind (string): An optional kind of entries to show.
/// - cols (integer): Number of columns to show the entries in.
/// - headings (function): Function to generate headings in the index.
///   Gets the letter for the new section as an argument:
///   #lambda("string", ret:"content")
/// - entries (function): A function to format index entries.
///   Gets the index term, the label and the location for the entry:
///   #lambda("string", "content", "location", ret:"content")
/// -> content
#let make-index(
	kind: none,
	cols: 3,
	headings: (h) => heading(level:2, numbering:none, outlined:false, h),
	entries: (term, body, locs) => [
		#link(locs.first(), body) #box(width: 1fr, repeat[.]) #{locs.map(loc => link(loc, strong(str(loc.page())))).join([, ])}\
	]
) = locate(loc => {
	let index = __s_mty_index.final(loc)
	let terms = (:)

	let kinds = (kind,).flatten()
	for idx in index {
		if is.not-none(kind) and idx.kind not in kinds {
			continue
		}
		let term = idx.term
		let l = upper(term.first())
		let p = idx.loc.page()

		if l not in terms {
			terms.insert(l, (:))
		}
		if term in terms.at(l) {
			if p not in terms.at(l).at(term).pages {
				terms.at(l).at(term).pages.push(p)
				terms.at(l).at(term).locs.push(idx.loc)
			}
		} else {
			terms.at(l).insert(term, (term:term, body:idx.body, pages: (p,), locs: (idx.loc,)))
		}
	}

	show heading: it => block([
		#block(spacing:0.3em, text(font:("Liberation Sans"), fill:theme.colors.secondary, it.body))
	])
	columns(cols,
		for l in terms.keys().sorted() {
			headings(l)

			// for (_, term) in terms.at(l) {
			for term-key in terms.at(l).keys().sorted() {
				let term = terms.at(l).at(term-key)
				entries(term.term, term.body, term.locs)
			}
		}
	)
})


/// Generate a version number from a version string or array.
/// The function takes a variable number of arguments and builds
/// a version string in _semver_ format:
/// - #shortex(`#mty.ver(0,1,1)`)
/// - #shortex(`#mty.ver(0,1,"beta-1")`)
/// - #shortex(`#mty.ver("1.0.2")`)
#let ver( ..args ) = {
  if args.pos().len() == 1 {
      [*#args.pos().first()*]
  } else {
    [*#args.pos().map(str).join(".")*]
  }
}


/// Highlight human names (with first- and lastnames).
/// - #shortex(`#mty.name("Jonas Neugebauer")`)
/// - #shortex(`#mty.name("J.", last:"Neugebauer")`)
///
/// - name (string): First or full name.
/// - last (string): Optional last name.
/// -> content
#let name( name, last:none ) = {
	if last == none {
		let parts = get.text(name).split(" ")
		last = parts.pop()
		name = parts.join(" ")
	}
	[#name #smallcaps(last)]
}


/// Show author information.
/// - #shortex(`#mty.author("Jonas Neugebauer")`)
/// - #shortex(`#mty.author((name:"Jonas Neugebauer"))`)
/// - #shortex(`#mty.author((name:"Jonas Neugebauer", email:"github@neugebauer.cc"))`)
///
/// - info (string, dictionary): Either a string with an author name or a dictionary with the `name` and `email` keys.
/// -> content
#let author( info ) = {
	if type(info) == "string" {
		return name(info)
	} else if "email" in info {
		return [#name(info.name) #link("mailto:" + info.email, rawi("<" + info.email + ">"))]
	} else {
		return name(info.name)
	}
}


/// Show a date with a given format.
/// - #shortex(`#mty.date("2023-09-25")`)
/// - #shortex(`#mty.date(datetime.today())`)
///
/// - d (datetime, string): Either a date as a string or #dtype("datetime").
/// - format (string): An optional #dtype("datetime") format string.
/// -> content
#let date( d, format:"[year]-[month]-[day]" ) = {
	if type(d) == "datetime" {
		d.display(format)
	} else {
		d
	}
}

/// Highlights some content with the #mty.primary("primary color").
#let primary = text.with(fill:theme.colors.primary)

/// Highlights some content with the #mty.secondary("secondary color").
#let secondary = text.with(fill:theme.colors.secondary)


/// Show a package name.
/// - #shortex(`#mty.package("codelst")`)
///
/// - name (string): Name of the package.
#let package( name ) = primary(smallcaps(name))

/// Show a module name.
/// - #shortex(`#mty.module("util")`)
///
/// - name (string): Name of the module.
#let module( name ) = rawc(theme.colors.module, name)


/// Creates a #doc("text/link") with an attached footnote showing the #arg[url].
/// - #shortex(`#mty.footlink("https://neugebauer.cc", "neugebauer.cc")`)
///
/// - url (string): The url for the link and the footnote.
/// - label (string): The label for the link.
/// -> content
#let footlink( url, label ) = [#link(url, label)#footnote(link(url))]

/// Creates a #doc("text/link") to a GitHub repository given in the format
/// `user/repository` and shows the url in a footnote.
/// - #shortex(`#mty.gitlink("jneug/typst-mantys")`)
///
/// - repo (string): Identifier of the repository.
/// -> content
#let gitlink( repo ) = footlink("https://github.com/" + repo, repo)

/// Creates a #doc("text/link") to a Typst package in the Typst package repository
/// at #link("https://github.com/typst/packages", "typst/packages").
/// - #shortex(`#mty.pkglink("codelst", (2,0,0))`)
///
/// - name (string): Name of the package.
/// - version (string): Version string of the package as an array of ints (e.g. (0,0,1)).
/// - namespace (string): The namespace to use. Defaults to `preview`.
/// -> content
#let pkglink( name, version, namespace:"preview" ) = footlink("https://github.com/typst/packages/tree/main/packages/" + namespace + "/" + name + "/" + version.map(str).join("."), package(name + sym.colon + version.map(str).join(".")))


// Tests if #arg[value] has a certain label attached.
// - #shortex(`#mty.is-a([#raw("some code")<x>], <x>)`)
// - #shortex(`#mty.is-a([#raw("some code")<x>], <y>)`)
//
// - value (content): The content to test.
// - label (label): A label to check for.
// #let is-a(value, label) = {
// 	return type(value) == "content" and value.has("label") and value.label == label
// }

/// Adds a label to a content element.
///
/// - mark (string, label): A label to attach to the content.
/// - elem (content): Content to mark with the label.
#let add-mark( mark, elem ) = {
  if not is.label(mark) {
    mark = alias.label(mark)
  }
  [#elem#mark]
}

/// Tests if #arg[value] has a certain label attached.
/// - #shortex(`#mty.has-mark(<x>, mty.add-mark(<x>, raw("some code")))`)
/// - #shortex(`#mty.has-mark(<x>, [#raw("some code")<x>])`)
/// - #shortex(`#mty.has-mark(<y>, [#raw("some code")<x>])`)
///
/// - mark (string, label): A label to check for.
/// - elem (content): The content to test.
#let has-mark( mark, elem ) = {
  if type(mark) != "label" {
    mark = label(mark)
  }
  return type(elem) == "content" and elem.has("label") and elem.label == mark
}

// Inverse of @@has-mark.
#let not-has-mark( mark, elem ) = not has-mark(mark, elem)


/// Mark content as an argument.
/// >>> mty.mark-arg("my arg").label == <arg>
#let mark-arg = add-mark.with(<arg>)

/// Test if #arg[value] is an argument created with #cmd-[arg].
/// >>> mty.is-arg(mty.mark-arg("my arg"))
#let is-arg = has-mark.with(<arg>)

/// Test if #arg[value] is no argument created with #cmd-[arg].
/// >>> mty.not-is-arg("my arg")
#let not-is-arg = not-has-mark.with(<arg>)


/// Mark content as a body argument.
/// >>> mty.mark-body("my body").label == <arg-body>
#let mark-body = add-mark.with(<arg-body>)

/// Test if #arg[value] is a body argument created with #cmd-[barg].
/// >>> mty.is-body(mty.mark-body("my body"))
#let is-body = has-mark.with(<arg-body>)

/// Test if #arg[value] is no body argument created with #cmd-[barg].
/// >>> mty.not-is-body("my body")
#let not-is-body = not-has-mark.with(<arg-body>)


/// Mark content as an argument sink.
/// >>> mty.mark-sink("my sink").label == <arg-sink>
#let mark-sink = add-mark.with(<arg-sink>)

/// Test if #arg[value] is an argument sink created with #cmd-[sarg].
/// >>> mty.is-sink(mty.mark-sink("my sink"))
#let is-sink = has-mark.with(<arg-sink>)

/// Test if #arg[value] is no argument sink created with #cmd-[sarg].
/// >>> mty.not-is-sink("my sink")
/// >>> not mty.not-is-sink(mty.mark-sink("my sink"))
#let not-is-sink = not-has-mark.with(<arg-sink>)

/// Mark content as a choices argument.
#let mark-choices = add-mark.with(<arg-choices>)

/// Test if #arg[value] is a choice argument created with #cmd-[choices].
#let is-choices = has-mark.with(<arg-choices>)

/// Test if #arg[value] is no choice argument created with #cmd-[choices].
#let not-is-choices = not-has-mark.with(<arg-choices>)


/// Mark content as a function argument.
/// >>> mty.mark-func("my function").label == <arg-func>
#let mark-func = add-mark.with(<arg-func>)

/// Test if #arg[value] is a function argument created with #cmd-[func].
/// >>> mty.is-func(mty.mark-func("my function"))
#let is-func = has-mark.with(<arg-func>)

/// Test if #arg[value] is no function argument created with #cmd-[func].
/// >>> mty.not-is-func("my function")
#let not-is-func = not-has-mark.with(<arg-func>)


/// Mark content as a lambda argument.
#let mark-lambda = add-mark.with(<arg-lambda>)

/// Test if #arg[value] is a lambda argument created with #cmd-[lambda].
/// >>> mty.is-lambda(mty.mark-lambda("a lambda"))
#let is-lambda = has-mark.with(<arg-lambda>)

/// Test if #arg[value] is no lambda argument created with #cmd-[lambda].
/// >>> mty.not-is-lambda("a lambda")
/// >>> not mty.not-is-lambda(mty.mark-lambda("a lambda"))
#let not-is-lambda = not-has-mark.with(<arg-lambda>)


/// Places an invisible marker in the content that can be modified
/// with a #var[show] rule.
/// #example[```
/// This marker not replaced: #mty.place-marker("foo1")
///
/// #show mty.marker("foo1"): "Hello, World!"
/// Here be a marker: #mty.place-marker("foo1")\
/// Here be a marker, too: #mty.place-marker("foo2")
/// ```]
///
/// - name (string): Name of the marker to be referenced later.
#let place-marker( name ) = {
  raw("", lang:"--meta-" + name + "--")
}


/// Creates a selector for a marker placed via @@place-marker.
/// #example[```
/// #show mty.marker("foo1"): "Hello, World!"
/// Here be a marker: #mty.place-marker("foo1")\
/// Here be a marker, too: #mty.place-marker("foo2")
/// ```]
///
/// - name (string): Name of the marker to be referenced.
#let marker( name ) = selector(raw.where(lang: "--meta-" + name + "--"))


/// Shows sourcecode in a frame.
/// #ibox[Uses #package[codelst] to render the code.]
/// See @sourcecode-examples for more information on sourcecode and examples.
///
/// - ..args (any): Argumente für #cmd-(module:"codelst")[sourcecode]
/// -> content
#let sourcecode( ..args ) = codelst.sourcecode(
  frame:none,
  ..args
)


/// Show a reference to a labeled line in a sourcecode.
/// #ibox[Uses #package[codelst] to show the reference.]
#let lineref = codelst.lineref


/// Show an example by evaluating the given raw code with Typst and showing the source and result in a frame.
///
/// See section II.2.3 for more information on sourcecode and examples.
///
/// - side-by-side (boolean): Shows the source and example in two columns instead of the result beneath the source.
/// - scope (dictionary): A scope to pass to #doc("foundations/eval").
/// - mode (string): The evaulation mode: #choices("markup", "code", "math")
/// - breakable (boolean): If the frame may brake over multiple pages.
/// - example-code (content): A #doc("text/raw") block of Typst code.
/// - ..args (content): An optional second positional argument that overwrites the evaluation result. This can be used to show the result of a sourcecode, that can not evaulated directly.
#let code-example(
	side-by-side: false,
	scope: (:),
	mode:"markup",
  breakable: false,
	example-code,
	..args
) = {
	if is.not-empty(args.named()) {
		panic("unexpected arguments", args.named().keys().join(", "))
	}
	if args.pos().len() > 1 {
		panic("unexpected argument")
	}

	let code = example-code
	if not is.raw(code) {
		code = example-code.children.find(is.raw)
	}
	let cont = (
		sourcecode(raw(lang:if mode == "code" {"typc"} else {"typ"}, code.text)),
	)
	if not side-by-side {
		cont.push(line(length: 100%, stroke: .75pt + theme.colors.text))
	}

  // If the result was provided as an argument, use that,
  // otherwise eval the given example as code or content.
	if args.pos() != () {
		cont.push(args.pos().first())
	} else {
    cont.push(eval(mode:mode, scope: scope, code.text))
	}

  frame(
    breakable: breakable,
    grid(
			columns: if side-by-side {(1fr,1fr)} else {(1fr,)},
			gutter: 12pt,
			..cont
		)
  )
}


// =================================
//  Regex for detecting values
// =================================

#let _re-join( ..parts ) = {
  return raw(parts.pos().map((r) => if type(r) == "string" {r} else {r.text}).join())
}
#let _re-or( ..parts ) = {
  return _re-join(`(`, parts.pos().map((r) => r.text).join("|"), `)`)
}
#let _re-numeric = `(\d+(\.\d+)?|\.\d+)`
#let _re-units = raw("(" + ("em","cm","mm","in","%","deg").join("|") + ")")
#let _re-numeric-unit = _re-join(
  _re-numeric, `(`, _re-units, `)?`
)
#let _re-bool = `(true|false)`
#let _re-halign = `(left|right|center)`
#let _re-valign = `(top|bottom|horizon)`
#let _re-align = _re-or(_re-halign, _re-valign)
#let _re-2dalign = _re-join(`(`,
  _re-halign, `(\s*\+\s*`, _re-valign, `)?`,
  `|`,
  _re-valign, `(\s*\+\s*`, _re-halign, `)?`,
`)`)
#let _re-special = `(auto|none)`
#let _re-color-names = _re-or(`black`, `white`, `blue`)
#let _re-color = _re-or(_re-color-names)
#let _re-stroke = _re-join(_re-numeric-unit, `\s*\+\s*`, _re-color)
#let _re-dict = ``
#let _re-arr = ``
#let _re-values = _re-join(
  `^`,
  _re-or(_re-special, _re-numeric-unit, _re-bool, _re-2dalign, _re-color),
  `$`
)
#let re-values = regex(_re-values.text)
#let match-value(v) = {
  if is.str(v) {
    return v.trim().match(re-values) != none
  } else {
    return false
  }
}

#let _re-func = `^\(.*\) => .+`
#let match-func(v) = {
  if is.str(v) {
    return v.trim().match(regex(_re-func.text)) != none
  } else {
    return false
  }
}
