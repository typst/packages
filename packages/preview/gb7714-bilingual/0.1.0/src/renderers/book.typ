// GB/T 7714 双语参考文献系统 - 书籍渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation, get-terms
#import "../core/utils.typ": append-pages, build-pub-info, render-base

/// 书籍渲染
/// 格式：作者. 书名：卷号[M]. 版本. 出版地：出版者，年：页码.
#let render-book(
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
  let edition = f.at("edition", default: "")
  let volume = f.at("volume", default: "")
  let publisher = f.at("publisher", default: "")
  let address = f.at("address", default: f.at("location", default: ""))
  let year = str(f.at("year", default: "")) + year-suffix
  let pages = f.at("pages", default: "").replace("--", "-")
  let url = f.at("url", default: "")

  let type-id = render-type-id("book", has-url: url != "", version: version)
  let punct = get-punctuation(version, lang)

  // 构建标题+卷号
  let title-part = title
  if volume != "" {
    let vol-str = str(volume)
    // 检测是否为数值（纯数字或数字+字母如 2a）
    // 非数值（如 "第2卷"）直接使用，数值则添加前后缀
    let is-numeric = vol-str.match(regex("^[0-9]+[a-zA-Z]?$")) != none
    if is-numeric {
      if lang == "zh" {
        title-part += (
          punct.colon + terms.volume-prefix + vol-str + terms.volume-suffix
        )
      } else {
        title-part += punct.colon + terms.volume-prefix + vol-str
      }
    } else {
      title-part += punct.colon + vol-str
    }
  }
  title-part += type-id

  // 构建版本信息
  let edition-part = ""
  if edition != "" {
    let edition-str = str(edition)
    if lang == "zh" {
      edition-part = "第" + edition-str + "版"
    } else {
      let suffix = if (
        edition-str.ends-with("1") and not edition-str.ends-with("11")
      ) {
        "st"
      } else if edition-str.ends-with("2") and not edition-str.ends-with("12") {
        "nd"
      } else if edition-str.ends-with("3") and not edition-str.ends-with("13") {
        "rd"
      } else { "th" }
      edition-part = edition-str + suffix + " " + terms.edition
    }
  }

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

      if edition-part != "" {
        parts.push(edition-part)
      }

      // 出版信息 + 页码
      let pub-info = build-pub-info(
        address,
        publisher,
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
