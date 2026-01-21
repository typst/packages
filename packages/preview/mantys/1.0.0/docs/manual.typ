#import "../src/mantys.typ": *
#import "../src/_api.typ" as mantys-api
#import "../src/core/schema.typ" as s
#import "_assets.typ": assets

#let show-module(name, scope: (:), ..tidy-args) = tidy-module(
  name,
  read("../src/" + name + ".typ"),
  show-module-name: false,
  ..tidy-args.named(),
)

#let balanced-cols(cols, clearance: .0pt, ..column-args, body) = {
  context {
    let m = measure(body)
    let h = calc.ceil((m.height / 1pt) / cols) * (1pt + clearance)
    block(height: h, columns(cols, ..column-args, body))
  }
}

#let theme-var = var-.with(module: "themes")


#import "@preview/swank-tex:0.1.0": TeX, LaTeX

#show "CNLTX": package
#show "TIDY": _ => package("Tidy")

#show: mantys(
  ..toml("../typst.toml"),
  name: "Mantys",

  subtitle: [#text(eastern, weight:600)[MAN]uals for #text(eastern, weight:600)[TY]p#text(eastern, weight:600)[S]t],
  date: datetime.today(),
  abstract: [
    MANTYS is a Typst template to help package and template authors write beautiful and useful manuals. It provides functionality for consistent formatting of commands, variables and source code examples. The template automatically creates a table of contents and a command index for easy reference and navigation.

    For even easier manual creation, MANTYS works well with TIDY, the Typst docstring parser.

    The main idea and design were inspired by the #LaTeX package CNLTX by #name[Clemens Niederberger].
  ],

  show-index: false,
  wrap-snippets: true,

  git: git-info(file => read(file)),

  examples-scope: (
    scope: (
      mantys: mantys-api,
      is-themable: () => place(
        top,
        dy: -5mm,
        note(
          styles.pill(
            "emph.context",
            (
              icon("paintbrush") + sym.space.nobreak + "Styled by the " + typeref("theme")
            ),
          ),
        ),
      ),
    ),
    imports: (mantys: "*"),
  ),

  assets: assets,
)

#pagebreak(weak: true)
= About <sec:about>

Mantys is a Typst package to help package and template authors write manuals. The idea is that, as many Typst users are switching over from #TeX, they are used to the way packages provide a PDF manual for reference. Though in a modern ecosystem there are other ways to write documentation (like #link("https://rust-lang.github.io/mdBook/")[mdBook] or #link("https://asciidoc.org")[AsciiDoc]), having a manual in PDF format might still be beneficial since many users of Typst will generate PDFs as their main output.

This manual is a complete reference of all of MANTYS features. The source file of this document is a great example of the things MANTYS can do. Other than that, refer to the README file in the GitHub repository and the source code for MANTYS.

== Acknowledgements

Mantys was inspired by the fantastic #LaTeX package #link("https://ctan.org/pkg/cnltx")[CNLTX] by #name[Clemens Niederberger]#footnote[#link("*mailto:clemens@cnltx.de", "clemens@cnltx.de")].

Thanks to #github-user("tingerrr") and others for contributing to this package and giving feedback.

Thanks to #github-user("Mc-Zen") for developing #github("Mc-Zen/tidy").

== Dependencies

MANTYS is build using some of the great packages provided by the Typst community:
#balanced-cols(3, clearance: .05pt)[
  #let import-data = read("../src/_deps.typ")
  #for imp in import-data.split("\n") {
    if imp != "" {
      let m = imp.match(regex("^#import \"@preview/([^:]+?):(.+)\"$"))
      if m != none [
        - #universe(m.captures.at(0), version:m.captures.at(1)) (#m.captures.at(1))
      ]
    }
  }
]

== Some Terminology

Since MANTYS was first developed as a port of CNLTX, some terms used are derived from the original #LaTeX package.

Functions are called "commands" and paramteres "arguments". This has the benefit of avoiding collisions with the native #typ.t.function type.

To display formatted commands, arguments and types inline use the abbreviated command versions like @cmd:cmd[-] or @cmd:arg[-].

To fully document a command or argument use the block commands like @cmd:command[-] and @cmd:argument[-].

Some commands add an entry to the #link(<sec:index>, "Index"). Those commands usually have a Minus-variant that skips this step (like @cmd:cmd[-] and @cmd:cmd-[-]).

A "custom type" is a type defined by the package usually in the form of a dictionary schema. Read @subsec:custom-types for more information.


= Quickstart <sec:quickstart>

In your project root run `typst init`:
#codesnippet[```bash
  typst init "@preview/mantys" docs
  ```]

Your project folder should look something like this:
#codesnippet(inset: 1.5pt)[```
  .
  ├── docs
  │   └── manual.typ
  └── typst.toml
  ```]

```
.
├── docs
│   └── manual.typ
└── typst.toml
```

Open `docs/manual.typ` in your editor, delete the arguments in the @cmd:mantys[-] call at the top from #arg[name] to #arg[respository]. Then uncomment the line ```..toml("../typst.toml"),```.

The top of your manual should look like this:
#sourcecode[```typ
  #show: mantys(
    ..toml("../typst.toml"),
  )
  ```]

Fill in the rest of the information like #arg[subtitle] or #arg[abstract] to your liking. Select a #link(<sec:bundled-themes>, "Theme") you like.

All uppercase occurrences of #arg[name] will be highlighted as a package name. For example #text(hyphenate:false, "MAN\u{2060}TYS") will appear as MANTYS.

Start writing your manual.

If you alread use TIDY to document your functions, use @cmd:tidy-module to parse and display a module directly in MANTYS:
#sourcecode[```typ
  TIDY-module("utils", read("../src/lib/utils.typ"))
  ```]

Read @subsec:using-tidy for more details about using TIDY with MANTYS.

= Usage <sec:usage>

Initialize your manual using `typst init`:
#codesnippet[```bash
  typst init "@preview/mantys" docs
  ```]

#info-alert[We suggest to initialize the template inside a `docs` subdirectory to keep your manual separated from your packages source files.]

If you prefer to manually setup your manual, create a `.typ` file and import MANTYS at the top:

#show-import(name: "mantys")

== Project structure <subsec:project-structure>

You can setup your project in any way you like, but a common project structure for Typst packages looks like this:

#codesnippet(inset: 1.5pt)[```
  .
  ├── LICENSE
  ├── README.md
  ├── docs
  │   ├── assets
  │   │   └── example.typ
  │   └── manual.typ
  ├── src
  │   └── lib.typ
  ├── tests
  └── typst.toml
  ```]

MANTYS' defaults are configured with this structure in mind and will let you easily setup your manual.

== Initializing the template <sec:init>

After importing MANTYS the template is initialized by applying a show rule with the @cmd:mantys command.

@cmd:mantys[-] requires some information to setup the template with an initial title page. Most of the information can be read directly from the `typst.toml` of your package:
```typ
#show: mantys(
	..toml("../typst.toml"),
  ... // other options
)
```

#info-alert[Change the path to the `typst.toml` file according to your project structure.]
#warning-alert[Note that since #version(1,0,0) @cmd:mantys no longer requires the use of #typ.with.]

#command(
  "mantys",

  sarg("doc"),
)[
  #argument("doc", is-sink: true)[
    MANTYS initializes the @type:document from the provided arguments. Refer to the scheme in @sec:the-document for all possible options and how to use the @type:document.
  ]

  #argument("theme", types: ("theme",), command: "mantys")[
    The @type:theme to use for the manual.
  ]

  All other arguments will be passed to #cmd-[titlepage].
]

== The MANTYS document <sec:the-document>
The arguments passed to @cmd:mantys are used to initialize the @type:document, a dictionary holding information required for the manual.

The following keys can be passed to @cmd:mantys:

#frame[
  #set text(.88em)
  #schema(
    "document",
    s.document,
    child-schemas: (
      package: "package",
      template: "template",
      examples-scope: "examples-scope",
    ),
  )
]

#argument("title", default: none, types: content, command: "mantys")[
  If no title is provided, the title is taken from the @type:package. If no package information is provided, an error is thrown.

  Will be populated from the information in #arg[package] if omitted.
]
#argument("subtitle", default: none, types: content, command: "mantys")[
  A subtitle for the manual.
]
#argument("urls", default: none, types: (array, str), command: "mantys")[
  An array of URLs associated with this package.
]
#argument("date", default: none, types: (datetime, str), command: "mantys")[
  A date for the manual or package.
]
#argument("abstract", default: none, types: content, command: "mantys")[
  An abstract to appear on the #cmd-[titlepage].
]
#argument("package", default: (:), types: "package", command: "mantys")[
  The @type:package information (usually read from `typst.toml`).
]
#argument("template", default: none, types: "template", command: "mantys")[
  The @type:template information (usually read from `typst.toml`).
]
#argument("show-index", default: true, command: "mantys")[
  By default, an index of commands, variabes and other keywords is generated at the end of the document. Setting this to #typ.v.false will disable the index. You can manually generate an index by using @cmd:make-index.
]
#argument("show-outline", default: true, command: "mantys")[
  By default, a table of contents is generated on the title page. Setting this to #typ.v.false will disable the outline.

  #warning-alert[The title page is generated by the theme and might ignore this setting.]
]
#argument("show-urls-in-footnotes", default: true, command: "mantys")[
  By default, the URLs of links generated by #typ.link will be shown in a footnote. #typ.v.false disables this behaviour.
]
#argument("index-references", default: true, command: "mantys")[
  By default, referencing a command, argument or type will create an index entry. This can be disabled on a per reference basis.

  Setting #arg[index-references] to #typ.v.false will reverse this and disable index entries but allows you to enable them per reference.

  See @sec:referencing-commands for more information about references.
]

#argument("examples-scope", default: (:), command: "mantys")[
  Default scope for code examples. The examples scope is a #typ.t.dict with two keys: `scope` and `imports`. The `scope` is passed to #typ.eval for evaluation. `imports` maps module names to a set of imports that should be prepended to example code as a preamble.

  *Schema*:
  #schema(
    "examples-scope",
    (
      scope: (:),
      imports: (:),
    ),
  )

  For example, if your package is named `my-pkg` and you want to import everything from your package into every examples scope, you can add the following #arg[examples-scope]:

  #codesnippet[```typc
    examples-scope: (
      scope: (
        pkg: my-pkg
      ),
      imports: (
        pkg: "*"
      )
    )
    ```]

  The #arg[scope] and #arg[imports] are passed to TIDY for evaluating docstring examples.

  For further details refer to @sec:showing-examples and @cmd:example.
]
#argument("theme-options", default: (:), command: "mantys")[
  Options to be used by themes (see @sec:themes).
]
#argument("assets", default: (:), types: (array, "asset"), command: "mantys")[
  MANTYS can add #typ.metadata to the manual to be queried by external tools. See @subsec:schema-asset for more information.

  The repository at #github("jneug/typst-mantys") contains an `assets` script to query Typst assets from a MANTYS manual and compile them before compiling the manual.
]

#argument("git", types: ("dictionary",), command: "mantys")[
  MANTYS can show information about the current commit in the manuals footer. This is useful if you compile your manual with a CI workflow like GitHub Actions.

  The git information is read with the @cmd:git-info command. To allow MANTYS to read local files from your project you need to provide a reader function to @cmd:git-info[-].

  ```typ
  #mantys(
    ..toml("../typst.toml"),

    git: git-info((file) => read(file))
  )
  ```

  The function assumes the project structure seen in @subsec:project-structure. For other layouts provide the location of the `.git` folder via the #arg[git] argument.
]

==== Schema for package information <subsec:package>
#frame(
  schema(
    "package",
    s.package,
    child-schemas: (
      authors: "author",
    ),
    expand-schemas: true,
  ),
)

The @type:package is exactly the same schema used for the `package` key in the `toml.typst` file. See #link("https://github.com/typst/packages?tab=readme-ov-file#package-format", "the official doumentation") for a full description of all keys.

#warning-alert[
  Providing a #arg[name] for the package is mandatory.
]

#info-alert[
  Usually the #arg[package] is loaded directly from the `typst.toml` file and passed to @cmd:mantys.
]

==== Schema for template information <subsec:template>
#frame(
  schema(
    "template",
    s.template,
  ),
)

The @type:template is exactly the same schema used for the `template` key in the `toml.typst` file. See #link("https://github.com/typst/packages?tab=readme-ov-file#templates", "the official doumentation") for a full description of all keys.

#info-alert[
  The #arg[template] is optional and may be #typ.v.none.
]

==== Schema for asset information <subsec:schema-asset>
#frame(
  schema(
    "asset",
    s.asset,
  ),
)

MANTYS can add #typ.metadata about required assets to the document. External tooling may query the document for these assets at the `<mantys:asset>` label and compile these before compiling the manual itself.

#info-alert[
  You can find a simple script in the MANTYS GitHub repository (#github-file("jneug/typst-mantys", "scripts/assets")) to automatically compile Typst assets.
]

External tools should query the document with the input `mode=assets`. This will stop rendering of the document after setting the required metadata and thus speed up the query.

#codesnippet[```bash
  typst query --root . --input mode=assets --field 'value' docs/manual.typ '<mantys:asset>'
  ```]

Each queried asset has an `id`, a source file `src` and a description `dest`. An external tool should compile `src` to `dest`.

Usually the order of assets is important since later assets might depend on earlier ones. For example the first two assets for this manual look like this:
#codesnippet[```json
  {
    "id": "theme-cnltx-pages",
    "src": "assets/examples/theme-cnltx-pages.typ",
    "dest": "assets/examples/theme-cnltx-pages/{n}.png"
  },
  {
    "id": "assets/examples/theme-cnltx.png",
    "src": "assets/examples/theme-cnltx.typ",
    "dest": "assets/examples/theme-cnltx.png"
  }
  ```]

The first entry compiles a multipage example for the CNLTX theme into multiple `png` images and the second combines them into one. The result can be seen in @subsubsec:theme-cnltx.

#info-alert[
  If your manual requires a lot of assets it might be a good idea to collect them into a separate file like #github-file("jneug/typst-mantys", "docs/assets.typ") and import it in your manual.
]

==== Schema for author information <subsec:author>
#frame(schema("author", s.author))

Information about the package authors can be provided in different formats. In the document they will be accessible as dictionaries with a `name` key. The other information is optional.

If the author is provided as a #typ.t.str, MANTYS will try to find additional information like an email address.

For example:
#codesnippet[```typ
  "J. Neugebauer @jneug <github@neugebauer.cc>"
  ```]

will be parsed into
#codesnippet[```typc
  {
    name: "J. Neugebauer",
    email: "github@neugebauer.cc",
    github: "jneug",
  }
  ```]

==== Loading git information <subsec:git-info>

#command("git-info", arg("reader"), arg(git-root: "../.git"))[
  Loads information about the current commit from the git repository at #arg[git-root].

  #argument("reader", types: "function")[
    A function that reads a file and returns its content: #lambda("str", ret: "str")

    Usually this will look like this:
    ```typc
    (filename) => read(filename)
    ```
  ]

  #example(scope: (git-info: git-info.with(git-root: "../../.git")))[```
    #git-info((filename) => read(filename))
    ```]
]

=== Accessing document data

There are two methods to access information from the MANTYS #dtype("document"):

1. Using commands from the #module[document] module or
2. using @cmd:mantys-init instead of @cmd:mantys.

==== Using the `document` module

The usual way to access the @type:document is by calling one of the #module[document] functions.

#show-module("core/document", module: "document")

==== Custom initialization

Instead of using @cmd:mantys in a #typ.show rule, you can initialize MANTYS using @cmd:mantys-init directly (@cmd:mantys[-] essentially is a shortcut for using @cmd:mantys-init[-]).

#command("mantys-init", ret: array)[
  Calling this function will return a tuple with two elements:

  / [0]: The MANTYS #dtype("document").
  / [1]: The MANTYS template function to be used in a #typ.show rule.
]

Calling @cmd:mantys-init directly will give you direct access to the @type:document in your manual:
#sourcecode[```typ
  #let (doc, mantys) = mantys-init(..toml("../typst.toml"))

  #show: mantys

  This is the manual for #doc.package.name version #str(doc.package.version).
  ```]

= Documenting commands <sec:docs>

#warning-alert[#icons.warning This section need to be written. Refer to @sec:commands for the documentation of all available commands.]

== Using Tidy <subsec:using-tidy>

MANTYS was build with TIDY in mind and replaces the default template used by TIDY. If you already use docstrings to document your code, you can easily show your function documentation in your MANTYS manual.

@cmd:tidy-module is the main entrypoint for using TIDY in MANTYS. The command will call #cmd(module:"tidy")[parse-module] and #cmd(module:"tidy")[show-module] for you and setup MANTYS as the template.

Since MANTYS can't read your packages files, you need to call #typ.read and pass the result to the function (same as you would do for #cmd-(module:"tidy")[parse-module]).

#show-module(
  "api/tidy",
  show-outline: false,
  omit-private-parameters: true,
  sort-functions: false,
)

For easier usage it is recommended to define a custom function in the header of your manual like this:
#sourcecode[```typ
  #let show-module(name, ..tidy-args) = tidy-module(
    name,
    read("../src/" + name + ".typ"),
    // Some defaults you want to set
    ..tidy-args.named(),
  )
  ```]

See @sec:commands for an example of the result of @cmd:tidy-module.

#info-alert[
  When using TIDY, most MANTYS concepts also apply to docstrings. For example, cross-referencing commands is done with the `cmd:` prefix. All MANTYS commands like @cmd:arg or @cmd:property are available in docstring.
]

== Documenting custom types and validation schemas

MANTYS provides support for documentation of custom data types and validation schemas as provided by #universe("valkyrie").

In general a custom type is an anchor in the document that defines a structured schema for some kind of data, that is used in your package. A #typ.t.dict with some mandatory keys for example. See @type:document and other schmeas in this manual for examples.

A custom type can appear anyplace in the manual where a data type can appear, like in argument descriptions:
#example[```typ
  #argument("theme", types:("theme","module"))[
    The theme for this manual.
  ]
  ```]

==== Defining custom types <subsec:custom-types>
#custom-type("custom-type", color: rgb("#dc41f1"))

Place a custom type anchor with the @cmd:custom-type command.

#command("custom-type", arg("name"), arg(color: auto), label: none)[
  Places a custom type anchor in the document. Any occurrences of the data type #arg[name] will link to this location in the manual. THe anchor itself is invisible.
]

==== Defining a custom type schema <subsec:custom-schema>
#custom-type("schema", color: rgb("#dc41f1"))

If your custom type is defined by a dictionary schema, you cann simply pass an example to @cmd:schema to show a summary of the required keys and types.

@cmd:schema also accepts a #universe("valkyrie") validation schema.

#command("schema", arg("name"), arg("definition"), arg(color: auto), label: none)[

]

#warning-alert[
  Support for #package[valkyrie] schemas is still in development. Some aspects (like optional keys) are not yet supported.
]

See @type:document and other custom types in this manual for examples.

== Referencing commands and types <sec:referencing-commands>

You can use the builtin `@` short-syntax for referencing commands, arguments and custom-types in your document.

#grid(
  columns: (1fr, 1fr),
  gutter: 4%,
  [Use the `cmd` prefix to reference custom types in the manual or use @cmd:cmdref.], example[`@cmd:mantys`],
  [Add an argument name after a dot to reference arguments of a command or use @cmd:argref.],
  example[`@cmd:mantys.theme`],

  [Use the `type` prefix to reference custom types in the manual or use @cmd:typeref.], example[`@type:custom-type`],
)

Referencing a command will create an index entry. To prevent this, add `[-]` as a supplement. If @cmd:mantys.index-references was set to #typ.v.false, no index entries are created by default but adding `[+]` to a reference will set one.

```side-by-side
@cmd:utils:dict-get[-]

@cmd:mantys.index-references[+]
```

Referencing the builtin commands and types can be done via the @cmd:builtin and @cmd:dtype commands. For these cases MANTYS also provides shortcuts in the #var-("typ") dictionary.

- #ex(`#typ.raw`)
- #ex(`#typ.t.dict`)
- #ex(`#typ.v.false`)

See @sec:shortcuts for a full list of available shortcuts.

== Displaying examples <sec:showing-examples>

Showing examples is easy by using the #link(<sec:examples>, "example commands"). Wrapping any typst code in @cmd:example or @cmd:side-by-side will show the raw code and the evaluated result in a @cmd:frame.

#info-alert[
  @cmd:side-by-side is an alias for @cmd:example with #arg(side-by-side: true) set.
]

By default, any #typ.raw blocks with the language set to `example` or `side-by-side` will automatically be wrapped inside the corresponding command.

#example[````typ
  ```example
  Some *bold* text.
  ```

  ```side-by-side
  Some *bold* text.
  ```
  ````]

#info-alert[
  To show an example with fenced #typ.raw code, use more than three backticks for the example environment:
  `````typ
  ````example
  ```typ
  #let number = 4
  ```
  ````
  `````
]

=== Preventing example evaluation

Sometimes you don't want the example to be evaluated by Typst and provide the result yourself. In that case, simply add another content block after the example code:

````example
#example[
  ```typ
  Some #strong[bold] text?
  ```
][
  Some #emph[bold] text?
]
````

=== Setting the evaluation scope <subsec:evaluation-scope>

Examples are evaluated with the scope set by @cmd:mantys.examples-scope.

@cmd:example takes two arguments to modify the scope of examples: @cmd:example.scope and @cmd:example.imports.

The #arg[scope] is passed to #typ.eval as the scope argument while the #arg[imports] are prepended to the raw code as #typ.import statements.

The #arg[scope] passed to @cmd:example[-] is merged with the `scope` from #arg[examples-scope] passed to @cmd:mantys. By passing #arg(use-examples-scope: false), the #arg[examples-scope] is ignored.

The #arg[imports] are parsed into a preamble by @cmd:utils:build-preamble. The value is a #typ.t.dict with `(module: import)` pairs that are prepended to the raw code of the example:
#example[```typ
    #utils.add-preamble(
      "#rawi[Some] @cmd:command.",
      (
        mantys: "cmd",
        utils: "rawi",
      ),
    )
  ```]

The @cmd:mantys.examples-scope is passed to TIDY for evaluating examples in docstrings.

=== Displaying other sourcecode

Any #typ.raw code will be passed to #universe("codly") for display. You can pass new defaults to #package[CODLY] via the #cmd(module:"codly")[codly] command.

#example[```typ
  Some `raw` code
  over *multiple*
  lines.
  ```][
  #codly.local(```typ
  Some `raw` code
  over *multiple*
  lines.
  ```)
]

To modify the display you can wrap the #typ.raw block inside the @cmd:codesnippet[-] or @cmd:sourcecode[-] commands. By default both commands add a @cmd:frame around the content.

@cmd:codesnippet can be used for small snippets of code like the `typst init` line seen in @sec:usage. The command disables line numbers. Any arguments will be passed to #cmd(module:"codly", "local").

#info-alert[
  Previous versions of MANTYS would wrap any #typ.raw block inside @cmd:codesnippet[-]. This was changed to allow more flexibility when showing code. To enable the old behaviour, pass #arg(wrap-snippets: true) to @cmd:mantys[-].
]

@cmd:sourcecode will wrap the #typ.raw block in a frame for nicer display.

#example[````typ
  #sourcecode[```typ
  #let a = "Hello"
  #strong(a), World!
  ```]
  ````]

= Customizing the template <sec:customize>

== Themes <sec:themes>

MANTYS provides support for color themes and can be styled within certain boundries. The template comes with a few bundled themes but you can easily create a custom theme.

#error-alert[
  #icons.warning Theme support is considered *experimental* and might be removed in future versions if it proves to be not stable enough. Compilation times can get somewhat slow and my guess is that themes are a major factor.
]

=== Using themes <sec:using-themes>

To set the theme for your manual, simply provide a #arg[theme] argument to @cmd:mantys and set it to one of the bundled themes (see @sec:bundled-themes), a #typ.t.dict or a #typ.module with the required color, font and style information.

Some themes can be further customized by options that get passed to @cmd:mantys in the #arg[theme-options] key.

#codesnippet(```typ
#show: mantys(
  ..toml-info(read),

  theme: themes.orly,
  theme-options: (
    pic: image("assets/logo.png", width: 100%, )
  )
)
```)

#{ }

=== Bundled themes <sec:bundled-themes>

==== Typst theme <subsec:theme-default>
#grid(
  columns: (1fr, 50%),
  column-gutter: 5%,
  [
    The default theme for MANTYS. Based on the Typst documentation and website.
    #frame(arg(theme: "default", _value: theme-var))
    #text(.88em)[Example: This manual.]
  ],
  image("assets/examples/theme-typst.png", width: 100%),
)

==== Modern theme
#grid(
  columns: (1fr, 50%),
  column-gutter: 5%,
  [
    A slightly more modern theme for the digital age. Based on the #link("https://creativecommons.org/2019/10/30/cc-style-guide/", [Creative Commons Style Guide]).
    #frame(arg(theme: "modern", _value: theme-var))
    #text(.88em)[Example: The manual for #universe("finite").]
  ],
  image("assets/examples/theme-modern.png", width: 100%),
)

==== CNLTX theme <subsubsec:theme-cnltx>
#grid(
  columns: (1fr, 50%),
  column-gutter: 5%,
  [
    This theme is based on the original CNLTX template.
    #frame(arg(theme: "cnltx", _value: theme-var))
  ],
  image("assets/examples/theme-cnltx.png", width: 100%),
)

==== O'Rly#super[?] theme
#grid(
  columns: (1fr, 50%),
  column-gutter: 5%,
  [
    This theme uses the #universe("fauxreilly") package to create a style similar to an O'Reilly book.
    #frame(arg(theme: "orly", _value: theme-var))
  ],
  image("assets/examples/theme-orly.png", width: 100%),
)

===== Theme Options
#argument("title-image", types: content)[
  #typ.content to be passed to the #arg[pic] argument of #cmd-("orly", module:"fauxreilly").
]

=== Creating a custom theme <sec:creating-themes>

A theme is a #typ.t.dict ot #typ.module with a set of predefined keys for color and font information. See the #link(<subsec:theme-default>, "default theme") for a full list of keys and their meaning.

#balanced-cols(3, clearance: 0pt)[
  #schema("theme", themes.default, color: _type-colors.color)
]

#arg[primary] and #arg[secondary] are the main color scheme of the theme. #arg[fonts] is a #typ.t.dict of the main fontsets used.

#arg[page-init] is a #typ.t.func called during template initialization to add custom #typ.set rules and other global settings to the document. #arg[title-page] and #arg[last-page] are called once at the beginning and end of the document to add a title and final page to the manual respectively. All three are functions of #lambda(ret:"content", "document", "theme").

#arg[alert] is a function #lambda(str, content, ret:content) that receives an #arg[alert-type]

#info-alert[When writing a custom theme, remember to add #typ.pagebreak at the end of #arg[title-page], if your title page is supposed to be on its own page. Same goes for #arg[last-page].]

=== Theme helpers

If you don't want to create a complete #dtype("theme") on your own, but want to modify the color scheme of an existing theme, you can quickly do that with one of these helper functions.

#command("create-theme", sarg[theme-spec], arg(base-theme: "default", _value: theme-var))[
  Creates a theme from the passed in arguments. #sarg[theme-spec] should be key-value pairs from the #dtype("theme") specification. Any missing keys are copied from the theme passed in as #arg[base-theme].
]

#command("color-theme", arg[primary], arg[secondary], sarg[theme-spec], arg(base-theme: "default", _value: theme-var))[
  Creates a new theme from a #arg[primary] and a #arg[secondary] color. Further arguments are passed to @cmd:create-theme along with #arg[base-theme].

  #codesnippet[```typ
    #show: mantys(
      ..toml-info(read),

      theme: color-theme(blue, red, muted: (fill: yellow), base: themes.cnltx),
    )
    ```]
]

== The index <sec:index>

MANTYS adds an index of all commands and custom types to the end of the manual. You can modify this index in several ways.

=== Adding entries to the index

Using @cmd:idx you can add new entries to the index. Entries may be categorized by #arg[kind]. Commands have #arg(kind: "cmd") set and custom types #arg(kind: "type"). You may add arbitrary new types. If your package handles colors, you may want to add a "color" category like this:
```typc
idx("red", kind: "color")
```

=== Showing index entries by category

The default index can be disabled by passing #arg(show-index: false) to @cmd:mantys.

To manually show an index in the manual, use @cmd:make-index.

// #command("make-index", arg(kind: auto))[
//   Shows an index of the specified #arg[kind].
// ]
#show-module("core/index", show-outline: false)

This example creates an index of hex-colors. Since they all start with `#`, the grouping function is changed to group by the red component of the color.
#example[```typ
  #for c in (red, green, yellow, blue) {
    idx(
      c.to-hex(),
      kind:"color",
      display:box(inset:2pt,baseline:3pt,fill:c, text(white, c.to-hex())))
  }

  #block(height:10em, columns(2)[
    #make-index(
      kind:"color",
      entry-format: (term, pages) => [#term #box(width: 1fr, repeat[.]) (#pages.join(", "))\ ],
      grouping: it => it.term.slice(1, count:2)
    )
  ])
  ```]

Index entries are defined by a #arg[term] and a #arg[kind] that groups terms.
#schema(
  "index-entry",
  (
    term: str,
    kind: str,
    main: bool,
    display: content,
  ),
)

== Examples <sec:examples>

= Available commands <sec:commands>

// #show-module("mantys")

== API
#let apis = (
  Commands: "api/commands",
  Types: "api/types",
  Values: "api/values",
  Links: "api/links",
  Elements: "api/elements",
  Examples: "api/examples",
  Icons: "api/icons",
)
#for (name, file) in apis {
  [=== #name]
  show-module(file, omit-private-parameters: true, sort-functions: false)
}

== Utilities
#show-module("util/utils", module: "utils")

== Shortcut collection of builtin types <sec:shortcuts>

The #var("typ") dictionary is a shortcut to the common Typst builtin functions, types (#var("typ.t")) and values (#var("typ.v")).

=== Shortcuts for builtin commands <subsec:shortcuts-builtins>
#balanced-cols(
  3,
  {
    set text(.88em)
    for (k, v) in typ {
      if type(v) != dictionary [
        / #var-("typ." + k):
      ]
    }
  },
)

=== Shortcuts for builtin types <subsec:shortcuts-types>
#balanced-cols(
  3,
  {
    set text(.88em)
    for (k, v) in typ.t [
      / #var-("typ.t." + k):
    ]
  },
)

=== Shortcuts for builtin values <subsec:shortcuts-values>
#balanced-cols(
  3,
  {
    set text(.88em)
    for (k, v) in typ.v [
      / #var-("typ.v." + k):
    ]
  },
)

= Index
#columns(3, make-index(kind: ("cmd", "arg", "type")))
