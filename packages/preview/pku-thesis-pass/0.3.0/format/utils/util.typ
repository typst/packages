// ============================================================
// util.typ — 通用辅助函数
// ============================================================

/// 将用户传入的文件路径解析为可被 `image()` / `read()` 直接使用的路径
/// - `path` 类型：在调用处创建，可穿透包沙箱访问用户项目文件
/// - `str` 类型：按本地开发模式处理，路径相对项目根目录（函数位于 format/ 下，需回溯一层）
#let resolve-path(p) = if type(p) == path { p } else { ("../" + p) }

/// 返回元素除指定字段外的其余字段字典
#let _filtered-fields(el, keys) = el.fields().pairs().filter(p => p.first() not in keys).to-dict()

/// LaTeX 引用兼容（use-latexref）
/// 当 `@fig:xxx` 等带前缀引用解析失败时，剥离前缀后重新解析 `@xxx`，
/// 方便从 LaTeX 迁移的文档沿用 `\ref{fig:xxx}` 风格的标签写法。
/// 已成功解析的引用原样返回，不影响模板现有的引用处理。
#let show-latexref(prefixes, doc) = {
  show ref: it => {
    if it.element != none { return it }
    let target = str(it.target)
    let stripped = for p in prefixes {
      if target.starts-with(p) { target.slice(p.len()) + break }
    }
    if stripped == none { return it }
    ref(label(stripped), .._filtered-fields(it, ("target", "element", "citation")))
  }
  doc
}

/// 校验图片文件不是 eps 格式（Typst 的 `image()` 仅支持 png/jpg/gif/webp/svg/pdf）
/// 通过文件头魔数 `%!PS-Adobe` 识别 eps，避免报出晦涩的 "unknown image format"
/// 返回原路径，以便直接传给 `image()`
#let ensure-not-eps(p) = {
  let b = read(p, encoding: none)
  assert(
    not (b.len() >= 10 and b.slice(0, 10) == bytes("%!PS-Adobe")),
    message: "图片不支持 eps 格式：Typst 仅支持 png/jpg/gif/webp/svg/pdf，请先转换为支持的格式，或者直接用 CTAN pkuthss 包里的 PDF 文件",
  )
  p
}
