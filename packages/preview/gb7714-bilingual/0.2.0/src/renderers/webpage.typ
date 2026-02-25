// GB/T 7714 双语参考文献系统 - 网页/电子资源渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation, get-terms
#import "../core/utils.typ": (
  append-access-info, build-author-year, format-accessed-date, smart-join,
)

/// 网页/电子资源渲染
/// 格式：作者. 题名[EB/OL]. (发布日期)[引用日期]. URL.
#let render-webpage(
  entry,
  lang,
  year-suffix: "",
  style: "numeric",
  version: "2025",
  config: (show-url: true, show-doi: true, show-accessed: true),
) = {
  let f = entry.fields
  let terms = get-terms(version, lang)

  let authors = format-authors(entry.parsed_names, lang, version: version)
  let title = f.at("title", default: "")
  let year = str(f.at("year", default: "")) + year-suffix
  // 发布日期
  let date = f.at("date", default: "")
  let url = f.at("url", default: "")
  let note = f.at("note", default: "")

  // 网页默认是 EB/OL
  let type-id = render-type-id("webpage", has-url: true, version: version)

  // 使用集中配置
  let punct = get-punctuation(version, lang)

  let parts = ()

  // 处理作者和年份
  let year-in-date = false // 年份是否需要放入日期部分
  if style == "author-date" {
    let ay = build-author-year(authors, year, punct)
    if ay.author-part != none {
      parts.push(ay.author-part)
    }
    year-in-date = ay.year-in-pub
  } else {
    if authors != "" {
      parts.push(authors)
    }
  }

  // 题名[EB/OL]
  parts.push(title + type-id)

  let result = smart-join(parts)

  // 发布日期和访问日期：CSL 格式 "题名[EB/OL].（发布日期）[访问日期]"
  // 发布日期括号使用集中配置
  let date-part = ""
  if date != "" {
    date-part += punct.lparen + str(date) + punct.rparen
  }
  // 访问日期
  if config.show-accessed {
    let accessed = format-accessed-date(entry)
    if accessed != "" {
      date-part += accessed
    }
  }
  // 添加日期部分（用句号分隔）
  if date-part != "" {
    result = result.trim(".") + "." + date-part
  }

  // URL（网页文献的关键信息）
  if config.show-url and url != "" {
    result += ". " + url
  }

  // DOI
  let doi = f.at("doi", default: "")
  if config.show-doi and doi != "" {
    if not result.ends-with(".") {
      result += "."
    }
    result += " DOI:" + doi
  }

  // 确保以句号结尾
  if not result.ends-with(".") {
    result += "."
  }

  result
}
