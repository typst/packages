// GB/T 7714 双语参考文献系统 - 版本配置入口

#import "v2015.typ": config-2015
#import "v2025.typ": config-2025

// 版本 -> 配置映射
#let _configs = (
  "2015": config-2015,
  "2025": config-2025,
)

/// 获取版本配置
#let get-version-config(version) = {
  _configs.at(version, default: config-2025)
}

/// 根据版本和语言获取术语
#let get-terms(version, lang) = {
  let config = get-version-config(version)
  if lang == "zh" { config.terms-zh } else { config.terms-en }
}

/// 根据版本获取类型映射
#let get-type-map(version) = {
  get-version-config(version).type-map
}

/// 根据版本获取引用格式配置
#let get-citation-config(version) = {
  get-version-config(version).citation
}

/// 获取标点符号配置
#let get-punctuation(version, lang) = {
  get-version-config(version).punctuation
}

/// 获取作者格式化规则
#let get-author-format-rules(version) = {
  get-version-config(version).author-format
}

/// 获取条目类型相关规则
#let get-entry-type-rules(version) = {
  get-version-config(version).entry-type-rules
}
