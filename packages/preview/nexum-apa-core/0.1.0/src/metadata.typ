// Normalize the author's metadata.yaml into a stable internal schema.
// Keep raw YAML keys and defaults out of the document composition module.
#let normalize-metadata(data) = (
  title: data.at("title", default: "Untitled document"),
  authors: data.at("authors", default: ()),
  affiliation: data.at("affiliation", default: none),
  faculty: data.at("faculty", default: none),
  institution: data.at("institution", default: none),
  program: data.at("program", default: none),
  course: data.at("course", default: none),
  instructor: data.at("instructor", default: none),
  date: data.at("date", default: none),
  laboratory: data.at("laboratory", default: none),
  practice: data.at("practice", default: none),
  group: data.at("group", default: none),
  keywords: data.at("keywords", default: ()),
)
