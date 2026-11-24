// spacing.typ — 行间距主题解析
// 输入主题名 → 输出 (leading, para-spacing, heading-v) config dict

/// Resolve a spacing theme name to concrete values.
/// 解析间距主题名，返回配置字典。
///
/// - `theme` (str): `"compact"` | `"normal"` | `"relaxed"`
/// - returns: `(leading: length, para-spacing: length, heading-v: length)`
#let resolve(theme) = {
  if theme == "compact" {
    (leading: 0.75em, para-spacing: 0.9em, heading-v: 1em)
  } else if theme == "relaxed" {
    (leading: 0.75em, para-spacing: 0.9em, heading-v: 2%)
  } else { // normal (default)
    (leading: 0.75em, para-spacing: 0.9em, heading-v: 1em)
  }
}
