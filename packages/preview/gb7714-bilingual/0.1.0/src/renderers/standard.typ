// GB/T 7714 双语参考文献系统 - 标准渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-entry-type-rules, get-punctuation, get-terms
#import "../core/utils.typ": append-access-info, build-pub-info, smart-join

/// 标准渲染
/// 格式：标准号  标准名称[S]. 出版地：出版者，出版年.
/// 注意：标准号在最前面
#let render-standard(
  entry,
  lang,
  year-suffix: "",
  style: "numeric",
  version: "2025",
  config: (show-url: true, show-doi: true, show-accessed: true),
) = {
  let f = entry.fields
  let terms = get-terms(version, lang)

  // 标准通常没有个人作者，可能有发布机构
  let authors = format-authors(
    entry.parsed_names,
    lang,
    version: version,
    allow-anonymous: false,
  )
  let title = f.at("title", default: "")
  // 标准号
  let number = f.at("number", default: "")
  let year = str(f.at("year", default: "")) + year-suffix
  let publisher = f.at("publisher", default: f.at("organization", default: ""))
  let address = f.at("address", default: f.at("location", default: ""))
  let url = f.at("url", default: "")

  let type-id = render-type-id("standard", has-url: url != "", version: version)

  // 使用集中配置
  let punct = get-punctuation(version, lang)
  let type-rules = get-entry-type-rules(version)
  // 标准号和标题之间用全角空格
  let ideographic-space = "\u{3000}"

  let parts = ()

  // 根据版本规则决定是否显示作者
  if type-rules.standard-has-author {
    if style == "author-date" {
      if authors != "" {
        parts.push(authors + punct.comma + year)
      }
    } else {
      if authors != "" {
        parts.push(authors)
      }
    }
  }

  // 标准号 + 标题[S]
  let title-part = ""
  if number != "" {
    title-part = number + ideographic-space
  }
  title-part += title + type-id
  parts.push(title-part)

  // 出版信息（使用公共函数处理字段缺失）
  // 年份：numeric 模式总是在出版信息中
  // author-date 模式：如果没有作者（如 2025 标准），年份也放在出版信息中
  let year-in-pub = (
    style == "numeric" or not type-rules.standard-has-author or authors == ""
  )
  let pub-info = build-pub-info(
    address,
    publisher,
    year,
    punct,
    include-year: year-in-pub,
  )
  if pub-info != "" {
    parts.push(pub-info)
  }

  let result = smart-join(parts)
  append-access-info(result, entry, config: config)
}
