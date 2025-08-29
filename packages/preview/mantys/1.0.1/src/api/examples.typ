#import "../_deps.typ" as deps
#import "../core/document.typ"
#import "../util/utils.typ"
#import "../util/is.typ"
#import "../core/themes.typ": themable

#import "elements.typ": frame
#import "icons.typ": icon


/// Shows sourcecode in a @cmd:frame.
/// See @sec:examples for more information on sourcecode and examples.
/// ````example
/// #sourcecode(
///   title:"Example",
///   file:"sourcecode-example.typ"
/// )[```typ
/// #let module-name = "sourcecode-example"
/// ```]
/// ````
/// -> content
#let sourcecode(
  /// A title to show on top of the frame.
  /// -> str
  title: none,
  /// A filename to show in the title of the frame.
  /// -> str
  file: none,
  /// Arguments for #cmd-(module:"codly")[local].
  /// -> any
  ..args,
  /// A #typ.raw block of Typst code.
  /// -> content
  code,
) = {
  let header = ()
  if title != none {
    header.push(text(fill: white, title))
  }
  if file != none {
    header.push(h(1fr))
    header.push(text(fill: white, icon("file")) + sym.space.nobreak)
    header.push(text(fill: white, emph(file)))
  }

  frame(
    title: if header == () {
      ""
    } else {
      header.join()
    },
    deps.codly.local(..args, code),
  )
}


/// Shows some #typ.raw code in a @cmd:frame, but
/// without line numbers or other enhancements.
///
/// ````example
/// #codesnippet[```typc
/// let a = "some content"
/// [Content: #a]
/// ```]
/// ````
/// -> content
#let codesnippet(
  /// If #typ.v.true, line numbers are shown.
  /// -> bool
  number-format: none,
  /// Arguments for #cmd-(module:"codly")[local].
  /// -> any
  ..args,
  /// A #typ.raw block of Typst code.
  /// -> content
  code,
) = frame(deps.codly.local(number-format: number-format, ..args, code))


/// Show an example by evaluating the given #typ.raw code with Typst and showing the source and result in a @cmd:frame.
///
/// See @sec:examples for more information on sourcecode and examples.
///
/// -> content
#let example(
  /// Shows the source and example in two columns instead of the result beneath the source.
  /// -> content
  side-by-side: false,
  /// A scope to pass to #typ.eval.
  /// -> dict
  scope: (:),
  /// Additional imports for evaluating this example. Imports will be added as a preamble to #arg[example-code].
  /// -> dict
  imports: (:),
  /// Set to #typ.v.false to *not* use the global #arg[examples-scope] passed to @cmd:mantys.
  /// -> bool
  use-examples-scope: true,
  /// The evaulation mode: #choices("markup", "code", "math")
  /// -> str
  mode: "markup",
  /// If  #typ.v.true, the frame may brake over multiple pages.
  /// -> bool
  breakable: false,
  /// A #typ.raw block of Typst code.
  /// -> content
  example-code,
  /// An optional second positional argument that overwrites the evaluation result. This can be used to show the result of a sourcecode, that can not evaulated directly.
  /// -> content
  ..args,
) = context {
  if args.named() != (:) {
    panic("unexpected arguments", args.named().keys().join(", "))
  }
  if args.pos().len() > 1 {
    panic("unexpected argument")
  }

  let code = example-code
  if not code.func() == raw {
    code = example-code.children.find(it => it.func() == raw)
  }
  let cont = (
    raw(
      lang: if mode == "code" {
        "typc"
      } else {
        "typ"
      },
      code.text,
    ),
  )
  if not side-by-side {
    cont.push(themable(theme => line(length: 100%, stroke: .75pt + theme.text.fill)))
  }

  // If the result was provided as an argument, use that,
  // otherwise eval the given example as code or content.
  if args.pos() != () {
    cont.push(args.pos().first())
  } else if not use-examples-scope {
    cont.push(
      eval(
        mode: mode,
        scope: scope,
        utils.add-preamble(
          code.text,
          imports,
        ),
      ),
    )
  } else {
    let doc = document.get()
    cont.push(
      eval(
        mode: mode,
        scope: doc.examples-scope.scope + scope,
        utils.add-preamble(
          code.text,
          doc.examples-scope.imports + imports,
        ),
      ),
    )
  }

  frame(
    breakable: breakable,
    grid(
      columns: if side-by-side {
        (1fr, 1fr)
      } else {
        (1fr,)
      },
      gutter: 12pt,
      ..cont
    ),
  )
}


/// Same as @cmd:example, but with #arg(side-by-side: true).
/// -> content
#let side-by-side = example.with(side-by-side: true)


/// Show a "short example" by showing #arg[code] and the evaluation of #arg[code] separated
/// by #arg[sep]. This can be used for quick one-line examples as seen in @cmd:name and other command docs in this manual.
///
/// ```example
/// - #ex(`#name("Jonas Neugebauer")`)
/// - #ex(`#meta("arg-name")`, sep: ": ")
/// ```
/// -> content
#let ex(
  /// The #typ.raw code example to show.
  /// -> content
  code,
  /// The separator between #arg[code] and its evaluated result.
  /// -> content
  sep: [ #sym.arrow.r ],
  /// One of #choices("markup", "code", "math").
  /// -> str
  mode: "markup",
  /// A scope argument similar to @type:examples-scope.
  /// -> dict
  scope: (:),
) = context {
  let doc = document.get()
  raw(
    code.text,
    lang: "typ",
  )
  sep
  eval(
    utils.build-preamble(doc.examples-scope.imports) + code.text,
    mode: "markup",
    scope: doc.examples-scope.scope + scope,
  )
}


/// Alias for @cmd:ex.
/// #property(deprecated: true)
#let shortex = ex


/// Shows an import statement for this package. The name and version from the document are used by default.
/// #example[```
/// #show-import()
/// #show-import(repository: "@local", imports: "mantys", mode:"code")
/// ```]
/// -> content
#let show-import(
  /// Custom package repository to show.
  /// -> str
  repository: "@preview",
  /// What to import from the package. Use #value(none) to just import the package into the global scope.
  /// -> str | none
  imports: "*",
  /// Package name for the import.
  /// -> str | auto
  name: auto,
  /// Package version for the import.
  /// -> version | auto
  version: auto,
  /// One of #choices("markup", "code"). Will show the import in markup or code mode.
  /// -> str
  mode: "markup",
  /// Additional code to add after the import. Useful if your package requires some more steps for initialization.
  /// ```example
  /// #show-import(name: "codly", version: version(1,1,1), code: "#show: codly-init")
  /// ```
  /// -> str | auto
  code: none,
) = {
  document.use(doc => {
    let name = if name == auto {
      doc.package.name
    } else {
      name
    }
    let version = if version == auto {
      doc.package.version
    } else {
      version
    }
    codesnippet(
      raw(
        lang: if mode == "markup" {
          "typ"
        } else {
          "typc"
        },
        if mode == "markup" {
          "#"
        } else {
          ""
        }
          + "import \""
          + repository
          + "/"
          + name
          + ":"
          + str(version)
          + "\""
          + if imports != none {
            ": " + imports
          }
          + if code != none { "\n" + if is.raw(code) { code.text } else { code } },
      ),
    )
  })
}


/// Shows a git clone command for this package. The name and version from the document are used by default.
/// ```example
/// #show-git-clone()
/// #show-git-clone(repository: "typst/packages", out:"preview/mantys/1.0.0")
/// ```
#let show-git-clone(
  /// Custom package repository to show.
  /// -> str | auto
  repository: auto,
  /// Output path to clone into.
  /// -> str | none | auto
  out: auto,
  /// Syntax language to passs to #typ.raw.
  /// -> str
  lang: "bash",
) = {
  document.use(doc => {
    let repo = if repository == auto {
      doc.package.repository
    } else {
      repository
    }
    let url = if not repo.starts-with(regex("https?://")) {
      "https://github.com/" + repo
    } else {
      repo
    }
    let out = if out == auto {
      doc.package.name + "/" + str(doc.package.version)
    } else {
      out
    }

    codesnippet(
      raw(
        lang: lang,
        "git clone " + url + " " + out,
      ),
    )
  })
}
