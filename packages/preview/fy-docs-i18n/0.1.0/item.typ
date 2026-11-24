#import "core.typ": default-matchers, error-message, i18n-item-matchers-check
#import "dict.typ": i18n-dict-check

// 多语言项的数据契约：dictionary<language: str, text: str>。
// Multilingual item contract: dictionary<language: str, text: str>.
// 内部类型检查器，符合契约返回 true，否则返回 false，不从公开入口导出。
// Internal type checker: true if valid, false otherwise; not exported by the entrypoint.
#let i18n-item-check(item) = {
  if type(item) != dictionary { return false }
  for (language, value) in item {
    if type(language) != str or language == "" or type(value) != str {
      return false
    }
  }
  true
}

// 输入经过字典类型检查后，其键对应的值即为多语言项。
// After dictionary validation, the value associated with the key is a multilingual item.
#let i18n-item-from(
  dict,
  key,
  allow-empty: false,
  matchers: default-matchers,
) = {
  if not (i18n-item-matchers-check(matchers)) {
    assert(false, message: error-message("matchers"))
  }
  if not (type(key) == str) {
    assert(false, message: error-message("key", matchers: matchers))
  }
  if not (type(allow-empty) == bool) {
    assert(false, message: error-message(
      "boolean",
      matchers: matchers,
      fields: (field: "allow-empty"),
    ))
  }
  if not (i18n-dict-check(dict)) {
    assert(false, message: error-message("dict", matchers: matchers))
  }
  if not (key in dict) {
    if allow-empty { return (:) }
    panic(error-message("absent", matchers: matchers, fields: (key: key)))
  }
  dict.at(key)
}

// 先按匹配器数组顺序，再按语言字典顺序查询。
// Search in matcher order first, then in language dictionary order.
// 第一次返回 true 时视为匹配；allow-empty 为 true 时无匹配返回 none。
// The first true result matches; no match returns none when allow-empty is true.
#let i18n-item-get(
  item,
  matchers: default-matchers,
  allow-empty: false,
) = {
  if not (i18n-item-check(item)) {
    assert(false, message: error-message("item", matchers: matchers))
  }
  if not (i18n-item-matchers-check(matchers)) {
    assert(false, message: error-message("matchers"))
  }
  if not (type(allow-empty) == bool) {
    assert(false, message: error-message(
      "boolean",
      matchers: matchers,
      fields: (field: "allow-empty"),
    ))
  }
  for matcher in matchers {
    for (language, value) in item {
      let matched = matcher(language)
      if not (type(matched) == bool) {
        assert(false, message: error-message(
          "matcher-result",
          matchers: default-matchers,
        ))
      }
      if matched { return value }
    }
  }
  if allow-empty { return none }
  panic(error-message("no-match", matchers: matchers))
}

// 立即报错，不依赖 context；消息与普通查询使用同一套匹配器。
// Panic immediately without context; use the same matchers as ordinary text queries.
#let i18n-panic(dict, key, matchers: default-matchers) = {
  let item = i18n-item-from(dict, key, matchers: matchers)
  panic(i18n-item-get(item, matchers: matchers))
}
