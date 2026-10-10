#import "core.typ": default-matchers, error-message, i18n-item-matchers-check
#import "dict.typ": i18n-dict-from
#import "item.typ": i18n-item-from, i18n-item-get, i18n-panic

// 捕获默认匹配策略；各调用可用 matchers 命名参数单独覆盖。
// Capture default matchers; individual calls may override them with the matchers argument.
#let i18n-config(matchers: default-matchers) = {
  if not (i18n-item-matchers-check(matchers)) {
    assert(false, message: error-message("matchers"))
  }
  (
    dict-from: i18n-dict-from.with(matchers: matchers),
    item-from: i18n-item-from.with(matchers: matchers),
    item-get: i18n-item-get.with(matchers: matchers),
    panic: i18n-panic.with(matchers: matchers),
  )
}
