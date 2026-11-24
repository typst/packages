/// 根据页芯网格大小设置页面边距
#let page-grid(
  /// 页芯宽度，单位为字符数。
  /// -> int
  width: 42,
  /// 页芯高度，单位为字符数。
  /// -> int
  height: 65,
  /// 页脚左侧的注释宽度，单位为字符数。
  /// -> int | length
  note-left: auto,
  /// 页脚右侧的注释宽度，单位为字符数。
  /// -> int | length
  note-right: auto,
  /// 其他参数，传递给 `page()` 函数中的 `margin` 参数。
  /// -> arguments
  ..args,
  /// 页面内容。
  /// -> content
  body
) = {
  let note-left = if type(note-left) == length { note-left } else if type(note-left) == int { note-left * 1em } else { 0em }
  let note-right = if type(note-right) == length { note-right } else if type(note-right) == int { note-right * 1em } else { 0em }
  set page(margin: (
    left: (100% - width * 1em) / 2 + note-left,
    right: (100% - width * 1em) / 2 + note-right,
    y: (100% - height * 1em) / 2,
    ..args.named()
  ))
  body
}