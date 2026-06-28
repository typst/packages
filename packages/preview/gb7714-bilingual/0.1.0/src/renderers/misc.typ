// GB/T 7714 双语参考文献系统 - 其他类型渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation
#import "../core/utils.typ": render-base

/// 通用渲染 (misc/其他)
/// 格式：作者. 题名[Z]. 出版方式，年. 注释.
#let render-misc(
  entry,
  lang,
  year-suffix: "",
  style: "numeric",
  version: "2025",
  config: (show-url: true, show-doi: true, show-accessed: true),
) = {
  let f = entry.fields

  let authors = format-authors(entry.parsed_names, lang, version: version)
  let title = f.at("title", default: "")
  let year = str(f.at("year", default: "")) + year-suffix
  let note = f.at("note", default: "")
  let howpublished = f.at("howpublished", default: "")

  let type-id = render-type-id(
    entry.entry_type,
    has-url: f.at("url", default: "") != "",
    version: version,
  )
  let punct = get-punctuation(version, lang)

  render-base(
    entry,
    authors,
    year,
    punct,
    style,
    config,
    year-in-pub => {
      let parts = ()
      parts.push(title + type-id)
      if howpublished != "" {
        parts.push(howpublished)
      }
      if year-in-pub and year != "" {
        parts.push(year)
      }
      if note != "" {
        parts.push(note)
      }
      parts
    },
  )
}
