// GB/T 7714 双语参考文献系统 - 学位论文渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation
#import "../core/utils.typ": append-pages, build-pub-info, render-base

/// 学位论文渲染
/// 格式：作者. 题名[D]. 地址：学校，年：页码.
#let render-thesis(
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
  let school = f.at("school", default: f.at("institution", default: ""))
  let year = str(f.at("year", default: "")) + year-suffix
  let address = f.at("address", default: f.at("location", default: ""))
  let pages = f.at("pages", default: "").replace("--", "-")
  let url = f.at("url", default: "")

  let type-id = render-type-id("thesis", has-url: url != "", version: version)
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

      // 出版信息 + 页码
      let pub-info = build-pub-info(
        address,
        school,
        year,
        punct,
        include-year: year-in-pub,
      )
      pub-info = append-pages(pub-info, pages, punct)
      if pub-info != "" {
        parts.push(pub-info)
      }
      parts
    },
  )
}
