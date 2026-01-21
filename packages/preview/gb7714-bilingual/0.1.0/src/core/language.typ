// GB/T 7714 双语参考文献系统 - 语言检测模块

/// 检测文献条目的语言
/// 优先级：language 字段 > langid 字段 > 正文汉字检测 > 默认英文
#let detect-language(entry) = {
  let fields = entry.at("fields", default: (:))

  // 1. 优先检查 language 字段
  let lang = fields.at("language", default: "")
  if lang != "" {
    let lang-lower = lower(lang)
    if "zh" in lang-lower or "chinese" in lang-lower or "中" in lang-lower {
      return "zh"
    }
    if "en" in lang-lower or "english" in lang-lower {
      return "en"
    }
  }

  // 2. 检查 langid 字段 (biblatex 风格)
  let langid = fields.at("langid", default: "")
  if langid != "" {
    if "zh" in lower(langid) or "chinese" in lower(langid) {
      return "zh"
    }
    if "en" in lower(langid) or "english" in lower(langid) {
      return "en"
    }
  }

  // 3. Fallback: 检测标题/作者是否含中文
  let title = fields.at("title", default: "")
  let author = fields.at("author", default: "")
  let text-to-check = title + author

  // 检测是否有至少两个连续汉字
  if text-to-check.find(regex("\p{Han}{2,}")) != none {
    return "zh"
  }

  // 默认为英文
  return "en"
}
