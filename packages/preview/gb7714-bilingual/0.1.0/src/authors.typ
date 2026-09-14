// GB/T 7714 双语参考文献系统 - 作者格式化模块

#import "versions/mod.typ": get-author-format-rules, get-terms

/// 格式化作者列表
/// - parsed-names: citegeist 解析的 parsed_names
/// - lang: 语言 ("zh" | "en")
/// - version: 标准版本 ("2015" | "2025")
/// - max-authors: 最多显示的作者数量，超过则显示 "等" / "et al."
/// - allow-anonymous: 是否允许返回 "佚名"（默认 true）
#let format-authors(
  parsed-names,
  lang,
  version: "2025",
  max-authors: 3,
  allow-anonymous: true,
) = {
  let names = parsed-names.at("author", default: ())
  if names.len() == 0 {
    // 尝试 editor
    names = parsed-names.at("editor", default: ())
  }
  if names.len() == 0 {
    // 无作者时返回 "佚名" 或空
    if allow-anonymous {
      let terms = get-terms(version, lang)
      return terms.anonymous
    } else {
      return ""
    }
  }

  let terms = get-terms(version, lang)
  let rules = get-author-format-rules(version)

  // 作者分隔符：根据版本选择（CSL 规范）
  // 2015: 默认英文逗号 ", "
  // 2025: 中文逗号 "，"（<name delimiter="，"/>）
  let delimiter = if version == "2025" { "，" } else { ", " }

  // 格式化单个名字
  let format-name(name) = {
    let family = name.at("family", default: "")
    let given = name.at("given", default: "")
    let prefix = name.at("prefix", default: "") // 如 "van", "de"
    let suffix = name.at("suffix", default: "") // 如 "Jr.", "III"

    if lang == "zh" {
      // 中文：姓名连写，不加空格（通常无 prefix/suffix）
      family + given
    } else {
      // 英文：根据版本规则决定大小写
      let family-case-fn = if rules.family-uppercase { upper } else { x => x }

      // prefix 作为姓的一部分（demote-non-dropping-particle="never"）
      // 但 prefix 始终保持原样，不受 text-case 影响
      let full-family = if prefix != "" {
        prefix + " " + family-case-fn(family)
      } else {
        family-case-fn(family)
      }

      // 名缩写（始终大写）
      // hyphen-to-space: true → "Jean-Pierre" → "J P"
      // hyphen-to-space: false → "Jean-Pierre" → "J-P"
      let hyphen-sep = if rules.hyphen-to-space { " " } else { "-" }
      let initials = given
        .split(" ")
        .map(part => {
          part
            .split("-")
            .map(g => {
              if g.len() > 0 { upper(g.first()) } else { "" }
            })
            .join(hyphen-sep)
        })
        .join(" ")

      // suffix 放在名缩写后面（保留原样）
      // 注意：当 given 为空时（如组织名），不添加空格
      if suffix != "" {
        if initials != "" {
          full-family + " " + initials + ", " + suffix
        } else {
          full-family + ", " + suffix
        }
      } else {
        if initials != "" {
          full-family + " " + initials
        } else {
          full-family
        }
      }
    }
  }

  if names.len() <= max-authors {
    names.map(format-name).join(delimiter)
  } else {
    // 超过 max-authors 时，显示前 3 个 + 等/et al.
    (
      names.slice(0, max-authors).map(format-name).join(delimiter)
        + delimiter
        + terms.et-al
    )
  }
}

/// 格式化正文引用中的作者（简短形式）
/// - parsed-names: citegeist 解析的 parsed_names
/// - lang: 语言 ("zh" | "en")
/// - version: 标准版本 ("2015" | "2025")
#let format-author-intext(parsed-names, lang, version: "2025") = {
  let names = parsed-names.at("author", default: ())
  if names.len() == 0 {
    names = parsed-names.at("editor", default: ())
  }
  if names.len() == 0 {
    // 无作者时返回 "佚名"
    let terms = get-terms(version, lang)
    return terms.anonymous
  }

  let terms = get-terms(version, lang)
  let first = names.first()
  let family = first.at("family", default: "")
  let prefix = first.at("prefix", default: "")

  // prefix 作为姓的一部分（如 "van Beethoven"）
  let first-author = if prefix != "" and lang != "zh" {
    prefix + " " + family
  } else {
    family
  }

  // 2 个或更多作者时加 "等" 或 "et al."
  if names.len() >= 2 {
    first-author + " " + terms.et-al
  } else {
    first-author
  }
}
