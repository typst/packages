#import "../lib.typ" as project-lib
#import "@preview/zettyp:0.1.0": core, host, kickstart
#import core: eval

#let manifest = ".zettypst/source.toml"
#let read-file(path, encoding: "utf8") = read(
  "/" + host.path(path),
  encoding: encoding,
)
#let snapshot = kickstart.host.snapshot.with(project-lib)
#let check-errors = kickstart.host.check-errors
#let announce-node = kickstart.host.announce-node.with(
  display-value: project-lib.display-value,
)
#let notes = kickstart.host.notes.with(project-notes: project-lib.project-notes)
#let manifest-text = kickstart.host.manifest-text
#let verification = kickstart.host.verification
#let now = kickstart.host.now
