#import "../_deps.typ" as deps
#import "../core/themes.typ": themable
#import "../core/styles.typ"
#import "icons.typ": icon
#import "../util/utils.typ"


/// #is-themable()
/// Create a frame around some content.
/// #info-alert[Uses #package("showybox") and can take any arguments the
/// #cmd-[showybox] command can take.]
/// #example[```
/// #frame(title:"Some lorem text")[#lorem(10)]
/// ```]
/// -> content
#let frame(
  /// Arguments for #package[Showybox].
  /// -> content
  ..args,
) = themable(theme => deps.showybox.showybox(
  frame: (
    border-color: theme.primary,
    title-color: theme.primary,
    thickness: .75pt,
    radius: 4pt,
    inset: 8pt,
  ),
  ..args,
))


/// #is-themable()
/// An alert box to highlight some content.
/// #example[```
/// #alert("success")[#lorem(10)]
/// ```]
/// -> content
#let alert(
  /// The type of the alert. One of #value("info"), #value("warning"), #value("error") or #value("success").
  /// -> str
  alert-type,
  /// Content of the alert.
  /// -> content
  body,
) = themable(
  (theme, alert-type, body) => (theme.alert)(alert-type, body),
  alert-type,
  body,
)


/// #is-themable()
/// An info alert.
/// ```example
/// #info-alert[This is an #cmd-[info-alert].]
/// ```
/// -> content
#let info-alert = alert.with("info")

/// #is-themable()
/// A warning alert.
/// ```example
/// #warning-alert[This is an #cmd-[warning-alert].]
/// ```
/// -> content
#let warning-alert = alert.with("warning")

/// #is-themable()
/// An error alert.
/// ```example
/// #error-alert[This is an #cmd-[error-alert].]
/// ```
/// -> content
#let error-alert = alert.with("error")

/// #is-themable()
/// A success alert.
/// ```example
/// #success-alert[This is an #cmd-[success-alert].]
/// ```
/// -> content
#let success-alert = alert.with("success")

/// #is-themable()
/// Show a package name.
/// - #ex(`#package("codelst")`)
/// -> content
#let package(
  /// Name of the package.
  /// -> str
  name,
) = themable(theme => text(theme.emph.package, smallcaps(name)))

/// #is-themable()
/// Show a module name.
/// - #ex(`#module("util")`)
/// -> content
#let module(
  /// Name of the module.
  /// -> str
  name,
) = themable(theme => text(theme.emph.module, utils.rawi(name)))


/// Highlight human names (with first- and lastnames).
/// - #ex(`#name("Jonas Neugebauer")`)
/// - #ex(`#name("J.", last:"Neugebauer")`)
/// -> content
#let name(
  /// First or full name.
  /// -> str
  name,
  /// Optional last name.
  /// -> str | none
  last: none,
) = {
  if last == none {
    let parts = utils.get-text(name).split(" ")
    last = parts.pop()
    name = parts.join(" ")
  }
  [#name #smallcaps(last)]
}


/// #is-themable()
/// Sets the text color of #arg[body] to a color from the @type:theme.
/// #arg[color] should be a key from the @type:theme.
/// - #ex(`#colorize([Manual], color: "muted.fill")`)
/// -> content
#let colorize(
  /// Content to color.
  /// -> content
  body,
  /// Key of the color in the theme.
  /// -> str
  color: "primary",
) = themable(theme => text(
  fill: utils.dict-get(theme, color, default: black),
  body,
))

/// #is-themable()
/// Colors #barg[body] in the themes primary color.
/// - #ex(`#primary[Manual]`)
/// -> content
#let primary(
  /// Content to color.
  /// -> content
  body,
) = themable(theme => text(fill: theme.primary, body))


/// #is-themable()
/// Colors #barg[body] in the themes secondary color.
/// - #ex(`#secondary[Manual]`)
/// -> content
#let secondary(
  /// Content to color.
  /// -> content
  body,
) = themable(theme => text(fill: theme.secondary, body))


/// Creates a #typ.version from #sarg[args]. If the first argument is a version, it is returned as given.
/// - #ex(`#ver(1, 4, 2)`)
/// - #ex(`#ver(version(1, 4, 3))`)
/// -> version
#let ver(
  /// Components of the version.
  /// -> version | int
  ..args,
) = {
  if type(args.pos().first()) != version {
    version(..args.pos())
  } else {
    args.pos().first()
  }
}


/// Show a margin note in the left margin.
/// See @cmd:since and @cmd:until for examples.
/// -> content
#let note(
  /// Arguments to pass to #cmd(module: "drafting", "margin-note").
  /// -> any
  ..args,
  /// Body of the note.
  /// -> content
  body,
) = {
  // deps.drafting.margin-note(..args)[
  //   // #set align(right)
  //   #set text(.7em)
  //   #body
  // ]
  deps.marginalia.note(
    reverse: true,
    numbered: false,
    ..args,
  )[
    // #set align(right)
    #set text(.7em, style: "normal")
    #body
  ]
}


/// #is-themable()
/// Show a margin-note with a minimal package version.
/// - #ex(`#since(1,2,3)`)
/// #property(see: (<cmd:note>, <cmd:ver>))
/// -> content
#let since(
  /// Components of the version number.
  /// -> int | version
  ..args,
) = {
  note(
    styles.pill(
      "emph.since",
      (
        icon("arrow-up") + sym.space.nobreak + "Introduced in " + str(ver(..args))
      ),
    ),
  )
}

/// #is-themable()
/// Show a margin-note with a maximum package version.
/// - #ex(`#until(1,2,3)`)
/// #property(see: (<cmd:note>, <cmd:ver>))
/// -> content
#let until(
  /// Components of the version number.
  /// -> int | version
  ..args,
) = note(
  styles.pill(
    "emph.until",
    (
      icon("arrow-down") + sym.space.nobreak + "Available until " + str(ver(..args))
    ),
  ),
)


/// #is-themable()
/// Show a margin-note with a version number.
/// - #ex(`#changed(1,2,3)`)
/// #property(see: (<cmd:note>, <cmd:ver>))
/// -> content
#let changed(
  /// Components of the version number.
  /// -> int | version
  ..args,
) = note(
  styles.pill(
    "emph.changed",
    (
      icon("arrow-switch") + sym.space.nobreak + "Changed in " + str(ver(..args))
    ),
  ),
)


/// #is-themable()
/// Show a margin-note with a deprecated warning.
/// - #ex(`#deprecated()`)
/// #property(see: (<cmd:note>, <cmd:ver>))
/// -> content
#let deprecated() = note(
  styles.pill(
    "emph.deprecated",
    (
      icon("circle-slash") + sym.space.nobreak + "deprecated"
    ),
  ),
)


/// #is-themable()
/// Show a margin-note with a minimal Typst compiler version.
/// - #ex(`#compiler(1,2,3)`)
/// #property(see: (<cmd:note>, <cmd:ver>))
/// -> content
#let compiler(
  /// Components of the version number.
  /// -> int | version
  ..args,
) = note(
  styles.pill(
    "emph.compiler",
    (
      deps.codly.typst-icon.typ.icon + sym.space.nobreak + str(ver(..args))
    ),
  ),
)


/// #is-themable()
/// Show a margin-note with a context warning.
/// - #ex(`#requires-context()`)
/// #property(see: (<cmd:note>, <cmd:ver>))
/// -> content
#let requires-context() = note(
  styles.pill(
    "emph.context",
    (
      icon("pulse") + sym.space.nobreak + "context"
    ),
  ),
)
