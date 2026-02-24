// GB/T 7714 双语参考文献系统 - 书籍渲染器

#import "../authors.typ": format-authors
#import "../types.typ": render-type-id
#import "../versions/mod.typ": get-punctuation, get-terms
#import "../core/utils.typ": append-pages, build-pub-info, render-base

/// 书籍渲染
/// 格式：作者. 书名：卷号[M]. 版本. 出版地：出版者，年：页码.
/// 析出文献格式：作者. 章节标题//主书名[M]. 出版地：出版者，年：页码.
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
  let entry-type = lower(entry.entry_type)

  let authors = format-authors(entry.parsed_names, lang, version: version)
  let title = f.at("title", default: "")
  let booktitle = f.at("booktitle", default: "") // 析出文献的主书名
  let edition = f.at("edition", default: "")
  let volume = f.at("volume", default: "")
  let publisher = f.at("publisher", default: "")
  let address = f.at("address", default: f.at("location", default: ""))
  let year = str(f.at("year", default: "")) + year-suffix
  let pages = f.at("pages", default: "").replace("--", "-")
  let url = f.at("url", default: "")
  let mark = f.at("_resolved_mark", default: none)
  let medium = f.at("_resolved_medium", default: none)

  // 使用实际条目类型（collection → [G]，其他 → [M]）
  let type-id = render-type-id(
    entry-type,
    has-url: url != "",
    version: version,
    mark: mark,
    medium: medium,
  )
  let punct = get-punctuation(version, lang)

  // 判断是否为析出文献（inbook, incollection, chapter）
  let is-analytic = (
    entry-type in ("inbook", "incollection", "chapter") and booktitle != ""
  )

  // 辅助函数：添加卷号后缀
  let format-volume(base, vol) = {
    if vol == "" { return base }
    let vol-str = str(vol)
    // 检测是否为数值（纯数字或数字+字母如 2a）
    // 非数值（如 "第2卷"）直接使用，数值则添加前后缀
    let is-numeric = vol-str.match(regex("^[0-9]+[a-zA-Z]?$")) != none
    if is-numeric {
      if lang == "zh" {
        base + punct.colon + terms.volume-prefix + vol-str + terms.volume-suffix
      } else {
        base + punct.colon + terms.volume-prefix + vol-str
      }
    } else {
      base + punct.colon + vol-str
    }
  }

  // 获取析出文献来源责任者（bookauthor 优先，其次 editor）
  let source-authors = ""
  if is-analytic {
    // 尝试 bookauthor 字段（原始字符串，citegeist 可能不解析）
    let bookauthor-raw = f.at("bookauthor", default: "")
    if bookauthor-raw != "" {
      source-authors = bookauthor-raw
    } else {
      // 尝试 editor
      let editor-names = entry.parsed_names.at("editor", default: ())
      if editor-names.len() > 0 {
        source-authors = format-authors(
          (author: editor-names),
          lang,
          version: version,
          allow-anonymous: false,
        )
      }
    }
  }

  // 构建标题部分
  // 析出格式：章节标题[M]// 来源责任者. 主书名：卷号
  // 非析出格式：书名：卷号[M]
  let title-part = if is-analytic {
    let source-title = format-volume(booktitle, volume)
    if source-authors != "" {
      title + type-id + "// " + source-authors + ". " + source-title
    } else {
      title + type-id + "//" + source-title
    }
  } else {
    format-volume(title, volume) + type-id
  }

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
