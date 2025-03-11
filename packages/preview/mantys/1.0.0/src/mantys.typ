
#import "core/document.typ"
#import "core/themes.typ" as themes: color-theme, create-theme
#import "core/index.typ": *
#import "core/layout.typ"
#import "api/tidy.typ": *

#import "_api.typ": *

#import "_deps.typ": codly, showybox

#let mantys-init(
  theme: themes.default,
  ..args,
) = {
  let doc = document.create(..args)

  let mantys-func = body => {
    document.save(doc)

    // Add assets metadata to document
    for asset in doc.assets [#metadata(asset)<mantys:asset>]

    // Asset mode skips rendering the body
    if sys.inputs.at("mode", default: "full") == "assets" {
      return
    }

    // coerce theme to dictionary
    let theme = if type(theme) == module {
      dictionary(theme)
    } else {
      theme
    }

    // theme.page-init(doc)
    // set page(paper: "a4")
    show: layout.page-init(doc, theme)

    let title-page-func = theme.title-page
    title-page-func(doc, theme)

    if sys.inputs.at("debug", default: "false") in ("true", "1") {
      page(flipped: true, columns: 2)[
        #set text(10pt)
        #doc
      ]
    }
    pagebreak(weak: true)

    body

    // Show index if enabled and at least one entry
    if doc.show-index {
      pagebreak(weak: true)
      [= Index]
      columns(3, make-index())
    }

    let last-page-func = theme.last-page
    last-page-func(doc, theme)
  }

  return (doc, mantys-func)
}

/// Main MANTYS template function.
/// Use it to initialize the template:
/// ```typ
/// #show: mantys(
///   // initialization
/// )
/// ```
#let mantys(..args) = {
  let (_, mantys) = mantys-init(..args)
  return mantys
}

/// Reads some information about the current commit from the
/// local `.git` directory. The result can be passed to #cmd[mantys] with the #arg[git] key.
///
/// Since MANTYS can't read files from outside its package directory,
/// #cmd-[git-info] needs the #builtin[read] function to be
/// passed in.
/// - read (function): The builtin #builtin[read] function.
/// - git-root (string): relative path to the `.git` directory.
/// -> dictionary
#let git-info(reader, git-root: "../.git") = {
  if git-root.at(-1) != "/" {
    git-root += "/"
  }
  let head-data = reader(git-root + "HEAD")
  let m = head-data.match(regex("^ref: (\S+)"))
  if m == none {
    return none
  }

  let ref = m.captures.at(0)

  let branch = ref.split("/").last()
  let hash = reader(git-root + ref).trim()

  return (
    branch: branch,
    hash: hash,
  )
}
