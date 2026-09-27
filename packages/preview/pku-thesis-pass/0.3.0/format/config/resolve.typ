// ============================================================
// config/resolve.typ — 字体、参考文献、引用记号、智能分页解析
// ============================================================

#import "../utils/style.typ": build
#import "../utils/font.typ": font-set, fakebold-rules
#import "../utils/supplement.typ": supplement
#import "../utils/util.typ": resolve-path
#import "../utils/counter.typ": skippedstate

/// 解析系统字体方案：CLI 参数优先，否则用 config() 参数
/// 返回 (resolved-system, font, style)
#let resolve-font(system, _cli-system) = {
  let resolved-system = if _cli-system != none { _cli-system } else { system }
  let font = font-set.at(resolved-system, default: font-set.windows)
  let fakebold = fakebold-rules.at(resolved-system, default: fakebold-rules.windows)
  let style = build(font, fakebold: fakebold)
  (resolved-system: resolved-system, font: font, style: style)
}

/// 合并用户自定义引用记号
#let resolve-supplements(supplements) = {
  let merged = supplement
  for (key, value) in supplements {
    merged.insert(key, value)
  }
  merged
}

/// 读取参考文献文件
/// 路径应使用 path 类型，字符串路径按本地模式处理
#let resolve-bib(bib-file) = if bib-file != none {
  read(resolve-path(bib-file))
}

/// 智能分页：always-start-odd: true 时章节从奇数页开始
#let make-smartpagebreak(always-start-odd) = {
  () => {
    if always-start-odd {
      skippedstate.update(false)
      pagebreak(weak: true)
      skippedstate.update(true)
      pagebreak(to: "odd", weak: true)
      skippedstate.update(false)
    } else {
      pagebreak(weak: true)
    }
  }
}
