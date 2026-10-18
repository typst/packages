// ============================================================
// config/cli.typ — 命令行参数解析与系统状态
// ============================================================

/// 字符串转布尔值："true"/"1" → true, "false"/"0" → false, 否则返回默认值。
#let _parse-bool(value, default) = {
  if value == none { default }
  else if value == "true" or value == "1" { true }
  else if value == "false" or value == "0" { false }
  else { default }
}

/// 系统字体方案状态，供内容文件字体校验时读取当前生效的方案
#let system-state = state("sys", "default")

/// --input blind=true|false
#let _cli-blind = _parse-bool(sys.inputs.at("blind", default: none), none)
/// --input preview=true|false
#let _cli-preview = _parse-bool(sys.inputs.at("preview", default: none), none)
/// --input always-start-odd=true|false
#let _cli-always-start-odd = _parse-bool(sys.inputs.at("always-start-odd", default: none), none)
/// --input system=windows|macos|linux
#let _cli-system = sys.inputs.at("system", default: none)
