// GB/T 7714 双语参考文献系统 - 会议论文渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation, get-terms
#import "../core/utils.typ": append-access-info, build-author-year, smart-join

/// 会议论文渲染
/// - entry: 文献条目
/// - lang: 语言 ("zh" | "en")
/// - year-suffix: 年份后缀（用于消歧）
/// - style: 引用风格 ("numeric" | "author-date")
/// - version: 标准版本 ("2015" | "2025")
#let render-inproceedings(
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
  // 2025 优先使用 eventtitle（会议名称），2015 使用 booktitle
  let booktitle = if version == "2025" {
    f.at("eventtitle", default: f.at("booktitle", default: ""))
  } else {
    f.at("booktitle", default: f.at("eventtitle", default: ""))
  }
  let year = str(f.at("year", default: "")) + year-suffix
  let pages = f.at("pages", default: "").replace("--", "-")
  let address = f.at("address", default: f.at("location", default: ""))
  let publisher = f.at("publisher", default: f.at("organization", default: ""))
  let url = f.at("url", default: "")

  let type-id = render-type-id(
    "inproceedings",
    has-url: url != "",
    version: version,
  )

  // 使用集中配置
  let punct = get-punctuation(version, lang)

  let parts = ()

  // 处理作者和年份
  let year-in-pub = true
  if style == "author-date" {
    let ay = build-author-year(authors, year, punct)
    if ay.author-part != none {
      parts.push(ay.author-part)
    }
    year-in-pub = ay.year-in-pub
  } else {
    if authors != "" {
      parts.push(authors)
    }
  }

  // 出处信息：2015 和 2025 格式有差异
  if version == "2015" {
    // 2015: 题名[C]//会议名称. 地点：出版者，年：页码
    parts.push(title + type-id + "//" + booktitle)

    let pub-info = ""
    if address != "" {
      pub-info += address
      // 只有当后面有 publisher 时才加冒号
      if publisher != "" {
        pub-info += punct.colon
      }
    }
    if publisher != "" {
      pub-info += publisher
    }
    // 年份（numeric 或作者为空的 author-date）
    if year-in-pub and year != "" {
      if pub-info != "" {
        pub-info += punct.comma
      }
      pub-info += year
    }
    // 页码前加冒号
    if pages != "" {
      pub-info += punct.colon + pages
    }
    if pub-info != "" {
      parts.push(pub-info)
    }
  } else {
    // 2025: 题名[C]//会议名称，日期：页码（全在一个 part 内）
    let conf-info = title + type-id + "//" + booktitle
    // 年份（numeric 或作者为空的 author-date）
    if year-in-pub and year != "" {
      conf-info += punct.comma + year
    }
    if pages != "" {
      conf-info += punct.colon + pages
    }
    parts.push(conf-info)
  }

  let result = smart-join(parts)
  append-access-info(result, entry, config: config)
}
