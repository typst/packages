#import "../../plain-document.typ": plain-document
#import "../../../lib/_mod.typ": *

#let deliberation(
  title: none, // required
  meeting: none, // required
  authors: (), // required
  lang: "sv",
  date: datetime.today(),
  doc-type: "",
  body,
) = {
  required(title, "title", fn: "deliberation", hint: "document title, e.g. title: \"Skattmästaren till verkligheten\"")
  required(meeting, "meeting", fn: "deliberation", hint: "meeting identifier, e.g. meeting: \"HTM1\"")
  required(
    authors,
    "authors",
    fn: "deliberation",
    hint: "list of author dicts, e.g. authors: ((name: \"Truls Teknolog\", position: \"Funktionär inom Informationsutskottet\", message: \"Lund, dag som ovan\"),)",
  )

  show: plain-document.with(
    title: [#doc-type: #title],
    meeting: meeting,
    lang: lang,
    date: date,
    doc-type: doc-type,
  )

  set document(author: authors.map(a => a.name))
  show par: move-par

  body
  author-signatures(authors)
}
