// GB/T 7714 双语参考文献系统 - 专利渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation
#import "../core/utils.typ": render-base

/// 专利渲染
/// 格式：专利申请者或所有者. 专利题名：专利号[P]. 公告日期：页码[引用日期].
#let render-patent(
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
  let patent-number = f.at("number", default: f.at("call-number", default: ""))
  let year = str(f.at("year", default: "")) + year-suffix
  let date = f.at("date", default: f.at("issued", default: year))
  let pages = f.at("pages", default: "").replace("--", "-")
  let url = f.at("url", default: "")

  let type-id = render-type-id("patent", has-url: url != "", version: version)
  let punct = get-punctuation(version, lang)

  // 题名：专利号[P]
  let title-part = title
  if patent-number != "" {
    title-part += punct.colon + patent-number
  }
  title-part += type-id

  // 使用基础渲染器
  render-base(
    entry,
    authors,
    year,
    punct,
    style,
    config,
    year-in-pub => {
      let parts = ()
      parts.push(title-part)
      // 公告日期：页码
      if year-in-pub and date != "" {
        let date-part = str(date)
        if pages != "" {
          date-part += punct.colon + pages
        }
        parts.push(date-part)
      } else if pages != "" {
        parts.push(pages)
      }
      parts
    },
  )
}
