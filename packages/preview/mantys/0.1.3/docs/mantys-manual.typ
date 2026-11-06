#import "../src/mantys.typ": *

// Some fancy logos
// credits go to discord user @adriandelgado
#let TeX = style(styles => {
  set text(font: "New Computer Modern")
  let e = measure("E", styles)
  let T = "T"
  let E = text(1em, baseline: e.height * 0.31, "E")
  let X = "X"
  box(T + h(-0.15em) + E + h(-0.125em) + X)
})

#let LaTeX = style(styles => {
  set text(font: "New Computer Modern")
  let a-size = 0.66em
  let l = measure("L", styles)
  let a = measure(text(a-size, "A"), styles)
  let L = "L"
  let A = box(scale(x: 110%, text(a-size, baseline: a.height - l.height, "A")))
  box(L + h(-a.width * 0.67) + A + h(-a.width * 0.25) + TeX)
})

#let cnltx = package("CNLTX")
#let TIDY = package("Tidy")

#let shell( title:"shell", sourcecode ) = {
	mty.frame(
		stroke-color: black,
		bg-color: luma(42),
		radius: 0pt,
		{
			set text(fill:rgb(0,255,36))
			sourcecode
		}
	)
}

#import "@preview/tidy:0.2.0"

#let show-module(name, scope:(:)) = tidy-module(
  read("../src/" + name + ".typ"),
  name: name,
  include-examples-scope: true,
  tidy: tidy,
  extract-headings: 3
)

#show: mantys.with(
	..toml("../typst.toml"),

  title: "The Mantys Package",
	subtitle: [#strong[MAN]uals for #strong[TY]p#strong[S]t],
	date: datetime.today(),
	abstract: 	[
		#package[Mantys] is a Typst template to help package and template authors to write manuals. It provides functionality for consistent formatting of commands, variables, options and source code examples. The template automatically creates a table of contents and a command index for easy reference and navigation.

    For even easier manual creation, MANTYS works well with TIDY, the Typst docstring parser.

    The main idea and design was inspired by the #LaTeX package #cnltx by #mty.name[Clemens Niederberger].
	],

  examples-scope: (
    mty: mty,
    ..api.__all__,
    example: api.example
  )
)

= About

Mantys is a Typst package to help package and template authors to write consistently formatted manuals. The idea is that, as many Typst users are switching over from #TeX, they are used to the way packages provide a PDF manual for reference. Though in a modern ecosystem there are other ways to write documentation (like #mty.footlink("https://rust-lang.github.io/mdBook/")[mdBook] or #mty.footlink("https://asciidoc.org")[AsciiDoc]), having a manual in PDF format might still be beneficial, since many users of Typst will generate PDFs as their main output.

The design and functionality of Mantys was inspired by the fantastic #LaTeX package #mty.footlink("https://ctan.org/pkg/cnltx")[#cnltx] by #mty.name[Clemens Niederberger]#footnote[#link("mailto:clemens@cnltx.de", "clemens@cnltx.de")].

This manual is supposed to be a complete reference of Mantys, but might be out of date for the most recent additions and changes. On the other hand, the source file of this document is a great example of the things Mantys can do. Other than that, refer to the README file in the GitHub repository and the source code for Mantys.

#wbox[
	Mantys is in active development and its functionality is subject to change. Until version 1.0.0 is reached, the command signatures and layout may change and break previous versions. Keep that in mind while using Mantys.

  Contributions to the package are very welcome!
]

= Usage

== Using Mantys

Just import MANTYS inside your `typ` file:
#codesnippet[```typ
#import "@preview/mantys:0.1.3": *
```]

=== Initializing the template

After importing MANTYS the template is initialized by applying a show rule with the #cmd[mantys] command passing the necessary options using `with`:
#codesnippet[```typ
#show: mantys.with(
	...
)
```]

#cmd-[mantys] takes a bunch of arguments to describe the package. These can also be loaded directly from the `typst.toml` file in the packages' root directory:
#codesnippet[```typ
#show: mantys.with(
	..toml("typst.toml"),
  ...
)
```]

#command("mantys", ..args(name:	none, title: none,
	subtitle: none,
	info: none,
	authors: (),
	url: none,
	repository: none,
	license: none,
	version: none,
	date: none,
	abstract: content("[]"),
	titlepage: func(titlepage),
	examples-scope: (:),
	[body]), sarg[args])[
		#argument("titlepage", default:func(titlepage))[
			A function that renders a titlepage for the manual. Refer to #cmdref("titlepage") for details.
		]
		#argument("examples-scope", default:(:))[
			Default scope for code examples.

			```typc
			examples-scope: (
			  cmd: mantys.cmd
			)
			```

			For further details refer to #cmdref("example").
		]

		All other arguments will be passed to #cmd-[titlepage].

		All uppercase occurrences of #arg[name] will be highlighted as a packagename. For example #text(hyphenate:false, "MAN\u{2060}TYS") will appear as Mantys.
]

== Available commands

#show-module("api")

=== Source code and examples <sourcecode-examples>

Mantys provides several commands to handle source code snippets and show examples of functionality. The usual #doc("text/raw") command still works, but theses commands allow you to highlight code in different ways or add line numbers.

Typst code examples can be set with the #cmd[example] command. Simply give it a fenced code block with the example code and Mantys will render the code as highlighted Typst code and show the result underneath.

#example[````
  #example[```
  This will render as *content*.

  Use any #emph[Typst] code here.
  ```]
````]

The result will be generated using #doc("foundations/eval") and thus run in a local scope without access to imported functions. To pass your functions or modules to #cmd-[example] either set the #opt[examples-scope] option in the intial #cmd[mantys] call or pass a #arg[scope] argument to #cmd-[example] directly.

See #relref(cmd-label("example")) for how to use the #cmd-[example] command.

#ibox[
	To use fenced code blocks in your example, add an extra backtick to the example code:

	#example[`````
    #example[````
      ```rust
      fn main() {
        println!(\"Hello World!\");
      }
      ```
    ````]
  `````]
]

#command("example", ..args(side-by-side: false, imports:(:), mode:"code", [example-code], [result]))[
  Sets #barg[example-code] as a #doc("text/raw") block with #arg(lang: "typ") and the result of the code beneath. #barg[example-code] need to be `raw` code itself.

	#example[````
    #example[```
      *Some lorem ipsum:*\
      #lorem(40)
    ```]
	````]

	#argument("example-code", types:"content")[
		A block of #doc("text/raw") code representing the example Typst code.
	]
	#argument("side-by-side", default:false)[
		Usually, the #arg[example-code] is set above the #arg[result] separated by a line. Setting this to #value(true) will set the code on the left side and the result on the right.
	]
	#argument("scope", default:(:))[
		The scope to pass to #doc("foundations/eval").

    Examples will always import the #opt[examples-scope] set in the initial #cmd-[mantys] call. Passing this argument to an #cmd-[example] call _additionally_ make those imports available in thsi example. If an example should explicitly run without imports, pass #arg(scope: none):
    #sourcecode[````typ
    #example[`I use #opt[examples-scope].`]

    #example(scope:none)[```
    // This will fail: #opt[examples-scope]
    I can't use `#opt()`, because i don't use `examples-scope`.
    ```]
    ````]
	]
	#argument("mode", default:"code", choices:("code","markup", "math"))[
		The mode to evaluate the example in. See #doc("foundations/eval", name:"eval/mode", anchor:"parameters-mode") for more information.
	]
	#argument("result", types:"content")[
		The result of the example code. Usually the same code as #arg[example-code] but without the `raw` markup. See #relref(<example-result-example>) for an example of using #barg[result].

		#wbox(width:100%)[#arg[result] is optional and will be omitted in most cases!]
	]

	Setting #arg(side-by-side: true) will set the example on the left side and the result on the right and is useful for short code examples. The command #cmd-[side-by-side] exists as a shortcut.

	#example[````
    #example(side-by-side: true)[```
      *Some lorem ipsum:*\
      #lorem(20)
    ```]
	````]

	#barg[example-code] is passed to #tidyref("mty", "sourcecode") for processing.

	If the example-code needs to be different than the code generating the result (for example, because automatic imports do not work or access to the global scope is required), #cmd-[example] accepts an optional second positional argument #barg[result]. If provided, #barg[example-code] is not evaluated and #barg[result] is used instead.

	#example[````
    #example[```
      #value(range(4))
    ```][
      The value is: #value(range(4))
    ]
	````]<example-result-example>
]

#command("side-by-side", ..args(scope: (:), mode: "code", [example-code], [result]) )[
	Shortcut for #cmd("example", arg(side-by-side: true)).
]

#command("sourcecode", ..args(title:none, file:none, [code]))[
	If provided, the #arg("title") and #arg("file") argument are set as a titlebar above the content.

	#argument("code", types:dtype("content"))[
		A #cmd[raw] block, that will be set inside a bordered block. The `raw` content is not modified and keeps its #arg("lang") attribute, if set.
	]
	#argument("title", types:dtype("string"), default:none)[
		A title to show above the code in a titlebar.
	]
	#argument("file", types:dtype("string"), default:none)[
		A filename to show above the code in a titlebar.
	]

	#cmd-[sourcecode] will render a #doc("text/raw") block with linenumbers and proper tab indentions using #package[codelst] and put it inside a #tidyref("mty", "frame").

	If provided, the #arg("title") and #arg("file") argument are set as a titlebar above the content.

	#example(raw("#sourcecode(title:\"Some Rust code\", file:\"world.r\")[```rust
	fn main() {
		println!(\"Hello World!\");
	}
```]"))
]

#command("codesnippet", barg[code])[
	A short code snippet, that is shown without line numbers or title.

	#example[````
  #codesnippet[```shell-unix-generic
  git clone https://github.com/jneug/typst-mantys.git mantys-0.0.3
  ```]
  ````]
]

#command("shortex", ..args(sep: symbol("sym.arrow.r"), [code]))[
  Display a very short example to highlight the result of a single command. #arg[sep] changes the separator between code and result.

  #example[```
  - #shortex(`#emph[emphasis]`)
  - #shortex(`#strong[strong emphasis]`, sep:"::")
  - #shortex(`#smallcaps[Small Capitals]`, sep:sym.arrow.r.double.long)
  ```][
  - #shortex(`#emph[emphasis]`)
  - #shortex(`#strong[strong emphasis]`, sep:"::")
  - #shortex(`#smallcaps[Small Capitals]`, sep:sym.arrow.double.r)
  ]
]

=== Other commands

#command("package")[
	Shows a package name:

  - #shortex(`#package[tablex]`)
  - #shortex(`#mty.package[tablex]`)
]

#command("module")[
	Shows a module name:

  - #shortex(`#module[mty]`)
  - #shortex(`#mty.module[mty]`)
]

#command("doc", ..args("target", name:none, fnote:false))[
  Displays a link to the Typst reference documentation at #link("https://typst.app/docs"). The #arg[target] need to be a relative path to the reference url, like #value("text/raw"). #cmd-[doc] will create an appropriate link URL and cut everything before the last `/` from the link text.

  The text can be explicitly set with #arg[name]. For #(fnote: true) the documentation URL is displayed in an additional footnote.

  #example[```
  Remember that #doc("meta/query") requires a #doc("meta/locate", name:"location") obtained by #doc("meta/locate", fnote:true) to work.
  ```]

  #wbox[
    Footnote links are not yet reused if multiple links to the same reference URL are placed on the same page.
  ]
]

#command("command-selector", arg[name])[
  Creates a #doc("types/selector") for the specified command.

  #example[```
  // Find the page of a command.
  #let cmd-page( name ) = locate(loc => {
    let res = query(cmd-selector(name), loc)
    if res == () {
      panic("No command " + name + " found.")
    } else {
      return res.last().location().page()
    }
  })

  The #cmd-[mantys] command is documented on page #cmd-page("mantys").
  ```]
]

// #let pkg = mty.package
// #let module = mty.module
// #let idx = mty.idx
// #let make-index = mty.make-index

// #let doc( target, name:none, fnote:false ) = {


=== Using Tidy

MANTYS can be used with the docstring parser #TIDY, to create a manual from the comments above each function. See the #TIDY manual for more information on this.

MANTYS ships with a #TIDY template and a helper function to use it.

#command("tidy-module", ..args("data", include-examples-scope: false, extract-headings: 2, tidy: none), sarg("args"))[
  #cmd-[tidy-module] calls #cmd(module:"tidy")[parse-module] and #cmd(module:"tidy")[show-module] on the provided #arg[tidy] instance. If no instance is provided, the current #TIDY version from the preview repository is used.

  Setting #arg(include-examples-scope: true) will add the #opt[examples-scope] passed to #cmd-[mantys] to the evaluation of the module.

  To extract headings up to a certain level from function docstrings and showing them between function documentations, set #arg[extract-headings] to the highest heading level that should be extracted. #arg(extract-headings: none) disables this.

  This manual was compiled with #arg(extract-headings: 3) and thus the @describing-arguments heading was shown before the description of #tidyref("api", "meta").
]


=== Templating and styling

#command("titlepage", ..args("name", "title", "subtitle", "info", "authors", "urls", "version", "date", "abstract", "license"))[
  The #cmd-[titlepage] command sets the default titlepage of a Mantys document.

  To implement a custom title page, create a function that takes the arguments shown above and pass it to #cmd[mantys] as #arg[titlepage]:
  #sourcecode[```typ
  #let my-custom-titlepage( ..args ) = [*My empty title*]

  #show: mantys.with(
    ..toml("typst.toml"),
    titlepage: my-custom-titlepage
  )
  ```]

  A #arg[titlepage] function gets passed the package information supplied to #cmd-[mantys] with minimal preprocessing. The function has to check for #value(none) values for itself. The only argument with a guaranteed value is #arg[name].
]

=== Utilities

Most of MANTYS functionality is located in a module named #module[mty]. Only the main commands are exposed at a top level to keep the namespace pollution as minimal as possible to prevent name collisions with commands belonging to the package / module to be documented.

The commands provide some helpful low-level functionality, that might be useful in some cases.

#ibox[
  Some of the utilities of previous versions are now covered by #package[tools4typst].
]

#module-commands("mty")[
  #show-module("mty")
] // end module mty

=== Tidy template
#module-commands("mty-tidy")[
  #show-module("mty-tidy")
] // end module mty-tidy
