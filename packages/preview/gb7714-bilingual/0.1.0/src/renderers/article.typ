// GB/T 7714 双语参考文献系统 - 期刊文章渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation
#import "../core/utils.typ": build-journal-info, render-base

/// 期刊文章渲染
/// 格式：作者. 题名[J]. 刊名，年，卷（期）：页码.
#let render-article(
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
  let journal = f.at("journal", default: f.at("journaltitle", default: ""))
  let year = str(f.at("year", default: "")) + year-suffix
  let volume = f.at("volume", default: "")
  let number = f.at("number", default: f.at("issue", default: ""))
  let pages = f.at("pages", default: "").replace("--", "-")
  let doi = f.at("doi", default: "")
  let url = f.at("url", default: "")

  let type-id = render-type-id(
    "article",
    has-url: url != "" or doi != "",
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

      let pub-info = build-journal-info(
        journal,
        year,
        volume,
        number,
        pages,
        punct,
        include-year: if style == "author-date" { year-in-pub } else { true },
      )
      if pub-info != "" {
        parts.push(pub-info)
      }
      parts
    },
  )
}
