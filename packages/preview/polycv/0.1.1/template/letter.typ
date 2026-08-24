// typst compile --root . template/letter.typ
#import "@preview/polycv:0.1.1": letter, load-cv-data

// Load, resolve `inherit:` and validate (loader closure defined here so paths
// resolve against your project; invalid data stops the compile at the field).
#let fmt = sys.inputs.at("fmt", default: "yaml")
#let data-file = sys.inputs.at("data", default: if fmt == "toml" { "letter.toml" } else { "letter.yml" })
#let ld = load-cv-data(data-file, f => if fmt == "yaml" { yaml(f) } else { toml(f) }).letter

// Document metadata (required for tagged PDF output, e.g. --pdf-standard ua-1)
#set document(title: ld.sender.name, author: ld.sender.name)

#show: letter.with(
  sender: ld.sender,
  recipient: {
    let r = ld.at("recipient", default: (:))
    if r.at("name", default: "") != "" [*#r.name* \ ]
    if r.at("title", default: "") != "" [#r.title \ ]
    if r.at("company", default: "") != "" [*#r.company* \ ]
    if r.at("address", default: "") != "" [#r.address]
  },
  date: ld.at("metadata", default: (:)).at("date", default: "auto"),
  subject: ld.content.at("subject", default: none),
  salutation: ld.content.at("salutation", default: none),
  closing: ld.content.at("closing", default: [Kind regards]),
)

#for para in ld.content.at("body", default: ()) {
  eval(para.paragraph, mode: "markup")
  v(8pt)
}
