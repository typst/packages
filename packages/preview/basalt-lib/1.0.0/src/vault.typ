#import "xlink.typ": format-xlinks
#import "note.typ": new-root

#let apply-formatters(formatters, body, ..args) = {
  if formatters.len() == 0 {
    return body
  }

  show: formatters.first().with(..args.named())
  apply-formatters(formatters.slice(1), body, ..args)
}

#let new-vault(
  note-paths: (),
  formatters: (),
  include-from-vault: none,
) = {
  if include-from-vault == none {
    panic("include-from-vault is a required argument to " + repr(new-vault) + ". Add it as `path => include path`")
  }
  if type(include-from-vault) != function {
    panic("include-from-vault must be a function, specifically `path => include path`")
  }

  let formatter = apply-formatters.with((
    formatters,
    format-xlinks.with(include-from-vault, note-paths),
  ).flatten())

  return (
    new-note: (body, ..meta) => new-root(
      body,
      formatter: formatter,
      meta: meta.named()
    ),
  )
}
