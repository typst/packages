// typst compile --root . template/letter.typ
#import "@preview/nabcv:0.1.0": letter

#let ld = toml("letter.toml").letter // letter data

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
