
// Import main library functions
#import "./mty.typ"
// Import t4t functions
#import "./mty.typ": is-none, is-auto, is, def
// Import main user api
#import "api.typ"
#import "./api.typ": *

#import "./theme.typ"

// Import tidy theme
#import "./mty-tidy.typ"


/// Generate the default titlepage for the manual.
///
/// - name (string): Name for the package.
/// - title (string, content): The title for the manual (may differ from #arg[name]).
/// - subtitle (string, content): A subtitle shown below the title.
/// - description (string, content): A short description for the package (like the on ein `typst.toml`).
/// - authors (string, array): Authors for the package.
/// - urls (string, array): urls
/// - version (string, array):
/// - date (datetime):
/// - abstract (string, content):
/// - license (string, content):
/// - toc (boolean):
/// -> content
#let titlepage(
  name,
  title,
  subtitle,
  description,
  authors,
  urls,
  version,
  date,
  abstract,
  license,
  toc: true
) = [
	#set align(center)
	#set block(spacing: 2em)

	#block(text(fill:theme.colors.primary, size:2.5em,
		mty.def.if-none(name, title)
	))
	#if is.not-none(subtitle) {
		block(above:1em)[
      #set text(size:1.2em)
      #subtitle
    ]
	}

  #if (version, date, license).any((v) => v != none) {
    block({
      set text(size:1.2em)
      (
        if is.not-none(version) [ v#version ],
        if is.not-none(version) { mty.date(date) },
        if is.not-none(version) { license }
      ).join(h(4em))
    })
  }

	#if is.not-none(description) {
		block(description)
	}

  #block(
    def.as-arr(authors).map(mty.author).join( linebreak() )
  )
	#if is.not-none(urls) {
		block(def.as-arr(urls).map(link).join(linebreak()))
	}

	#if is.not-none(abstract) {
		block(width:75%)[
			#set align(left)
			//#set par(first-line-indent: .65em, hanging-indent: 0pt)
      #set par(justify: true)
			#show par: set block(spacing: 1.3em)
			#abstract
		]
	}

  #if toc [
    #set align(left)
    #set block(spacing: 0.65em)
    #show outline.entry.where(level: 1): it => {
      v(0.85em, weak:true)
      strong(it.body)
    }
    #text(size:1.4em, [*Table of contents*])
    #columns(2, outline(
      title: none,
      indent: auto
    ))
  ]

	#pagebreak()
]


/// Main entrypoint for Mantys to use in a global show-rule.
///
#let mantys(
  // Package info
  name: none,
  description: none,
  authors: (),
  repository: none,
  version: none,
  license: none,

  package: none,  // loaded toml file

  // Additional info
  title: none,
  subtitle: none,
  url: none,

  date: none,
  abstract: [],

  titlepage: titlepage,
  index: auto,

  examples-scope: (:),

  ..args,

  body
) = {
  mty.assert.that(
    is.not-none(name) or is.not-none(package),
    message:"You need to specifiy the package name or load the package info via ..toml(\"typst.toml\")."
  )

  if is-none(name) {
    ( name, description, authors,
      repository, version, license
    ) = ( "name", "description", "authors",
          "repository", "version", "license").map(
              (k) => package.at(k, default:none)
            )
  }

	set document(
		title: mty.get.text( mty.def.if-none(name, title) ),
		author: def.as-arr(mty.def.if-none(authors, "")).map((a) => if is.dict(a) { a.name } else { a }).first()
	)

	set page(
		..theme.page,
		header: locate(loc => {
			let elems = query(
				heading.where(level:2).before(loc),
				loc,
			)
			if elems != () {
				let elem = elems.last()
				h(1fr) + emph(counter(heading).at(loc).map(str).join(".") + h(.75em) + elem.body) + h(1fr)
			}
		}),
		footer: [
			#h(1fr)
			#counter(page).display("1")
			#h(1fr)
		]
	)
	set text(
    font: theme.fonts.text,
		size: theme.font-sizes.text,
		lang: "en",
		region: "EN",
    fill: theme.colors.text
	)
	set par(
		justify:true,
	)
	set heading(numbering: "I.1.")
	show heading: it => block([
		#v(0.3em)
		#text(fill:theme.colors.primary, counter(heading).display())
		#it.body
		#v(0.8em)
	])
	show heading.where(level: 1): it => {
		pagebreak(weak: true)
		block([
			#text(fill:theme.colors.primary,
			[Part #counter(heading).display()])\
			#it.body
			#v(1em)
		])
	}
	show heading: it => {
		set text(
      font:theme.fonts.headings,
      size://calc.max(theme.font.sizes.text, theme.font-sizes.headings * ( it.level))
        mty.math.map(4, 1, theme.font-sizes.text, theme.font-sizes.headings * 1.4, it.level)
    )
    it
	}

  // TODO: This would be a nice short way to set examples, but will
  // have weird formatting due to raw text having set the default
  // font and size before the show rule takes effect.
	// show raw.where(block:true, lang:"example"): it => mty.code-example(imports:example-imports, it)
	// show raw.where(block:true, lang:"side-by-side"): it => mty.code-example(side-by-side:true, imports:example-imports, it)
  show raw: set text(font:theme.fonts.code, size:theme.font-sizes.code)
  state("@mty-imports-scope").update(examples-scope)

  // Some common replacements
	show upper(name): mty.package(name)
	show "Mantys": mty.package
  // show "Typst": it => text(font: "Liberation Sans", weight: "semibold", fill: eastern)[typst] // smallcaps(strong(it))

  show figure.where(kind: raw): set block(breakable: true)

	titlepage(name, title, subtitle, description, authors, (url,repository).filter(is.not-none), version, date, abstract, license)

	body

	if index != none and index != () and index != (:) {
		[= Index]
    set text(.88em)
		if type(index) == "array" or type(index) == "string" {
			mty.make-index(kind:(index,).flatten())
		} else if type(index) == "dictionary" {
			for (header, kind) in index {
				[== #header]
				mty.make-index(kind:(kind,).flatten())
			}
		} else {
			mty.make-index()
		}
	}
}


#let tidyref(module, name) = {
  link(cmd-label(name, module:module), cmd-(name, module:module))
}


/// Show a module with #TIDY.
/// Wrapper for #cmd-[tidy.show-module].
#let tidy-module( data, ..args, include-examples-scope: false, extract-headings: 2, tidy: none ) = {
  let _tidy = tidy
  if is-none(_tidy) {
    import("@preview/tidy:0.2.0")
    _tidy = tidy
  }

  state("@mty-imports-scope").display(
    (imports) => {
      let scope = ("tidyref": tidyref) + api.__all__ + args.named().at("scope", default:(:))
      if include-examples-scope {
        scope += imports
      }

      let module-doc = _tidy.parse-module(
        data,
        ..mty.get.args(args)("name"),
        scope: scope
      )

      _tidy.show-module(
        module-doc,
        ..mty.get.args(args)(
          style: (
            get-type-color: mty-tidy.get-type-color,
            show-outline: mty-tidy.show-outline,
            show-parameter-list: mty-tidy.show-parameter-list,
            show-parameter-block: mty-tidy.show-parameter-block,
            show-function: mty-tidy.show-function.with(tidy: _tidy, extract-headings: extract-headings),
            show-variable: mty-tidy.show-variable.with(tidy: tidy),
            show-example: mty-tidy.show-example,
            show-reference: mty-tidy.show-reference
          ),
          first-heading-level: 2,
          show-module-name: false,
          sort-functions: false,
          show-outline: true
        )
      )
    }
  )
}
