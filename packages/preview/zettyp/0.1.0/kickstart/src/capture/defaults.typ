#import "../../../host/lib.typ" as host
// Default capture rendering and bibliography integration.
#let bibliography-path = "ref.bib"
#let render(req, id) = {
  let values = (
    (abstract: req.abstract, tags: (("capture",) + req.keywords).dedup())
      + req.metadata
  )
  (
    "#import \"../.zettypst/lib.typ\": *\n"
      + "#let zk-metadata = zk_metadata.with(.."
      + repr(values)
      + ")\n"
      + "#show: zettel.with(metadata: zk-metadata)\n\n"
      + "= #text("
      + repr(req.title)
      + ") <"
      + id
      + ">\n\n"
  )
}
#let extra-effects(
  req,
  id,
  path,
  read-file: none,
  bibliography-path: bibliography-path,
) = {
  if req.at("bibliography", default: none) == none { return () }
  let before = read-file("index.typ")
  if before.contains("bibliography(") { return () }
  (
    host.replace(
      "index.typ",
      before,
      before + "\n#bibliography(" + repr(bibliography-path) + ")\n",
    ),
  )
}
