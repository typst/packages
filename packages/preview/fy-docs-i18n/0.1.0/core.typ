// 内部共享的默认匹配器、结构检查与错误查询，避免循环依赖。
// Shared default matchers, structural checks, and error lookup avoid circular imports.
#let default-matchers = (
  language => language == "zh-Hans",
  language => language.starts-with("zh"),
  language => language == "en",
)
#let i18n-item-matchers-check(matchers) = {
  if type(matchers) != array { return false }
  for matcher in matchers { if type(matcher) != function { return false } }
  true
}
#let _errors = (
  "zh-Hans": toml("i18n/errors/zh-Hans.toml"),
  en: toml("i18n/errors/en.toml"),
)

// 匹配器自身错误不能递归调用同一套匹配器，使用固定默认策略兜底。
// Errors in matchers must not invoke the same matchers recursively; use a fixed fallback.
#let error-message(key, matchers: default-matchers, fields: (:)) = {
  assert(
    type(key) == str,
    message: _errors.at("zh-Hans").at("template-arguments"),
  )
  assert(
    type(fields) == dictionary,
    message: _errors.at("zh-Hans").at("template-arguments"),
  )
  for (field, value) in fields {
    assert(
      type(value) == str,
      message: _errors.at("zh-Hans").at("template-arguments"),
    )
  }
  let selected = none
  if i18n-item-matchers-check(matchers) {
    for matcher in matchers {
      for (language, table) in _errors {
        let matched = matcher(language)
        if type(matched) != bool {
          return _errors.at("zh-Hans").at("matcher-result")
        }
        if matched {
          selected = table
          break
        }
      }
      if selected != none { break }
    }
  }
  if selected == none { selected = _errors.at("zh-Hans") }
  let message = selected.at(key)
  // 只替换原模板中的占位符，不再次解释插入值里的占位符。
  // Replace placeholders in the original template only; do not reinterpret inserted values.
  message.replace(regex("\\{[^{}]+\\}"), matched => {
    let field = matched.text.slice(1, matched.text.len() - 1)
    fields.at(field, default: matched.text)
  })
}
