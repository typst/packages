// ============================================================
// spine.typ — 书脊页
// 用于打印装订时在书脊上显示论文标题与作者，非北大规范强制要求。
// 标题显示在页面右侧上方、作者显示在页面右侧下方，
// 中文字符保持正立、整体旋转 90°，读取方向与书脊一致。
// 盲审（blind: true）时不显示作者，只保留标题。
// ============================================================

/// 书脊页
/// title: 论文中文标题
/// author: 作者中文姓名
/// font: 字体方案（style.typ 中的 font-set 字典）
/// text-font: 书脊文字所用字体名（"宋体"/"仿宋" 等）
/// text-size: 书脊文字字号（style.typ 中的 size 键或长度）
/// blind: 盲审模式，true 时省略作者
#let spine-page(
  title: none,
  author: none,
  font: none,
  style: none,
  blind: false,
) = {
  set page(margin: style.书脊.margin)
  set text(font: style.书脊.font, size: style.书脊.size)

  // 标题去除 \n 换行（封面标题可手动换行，书脊标题需保持连续），与封面盲审标题处理一致
  let clean-title = if type(title) == str {
    title.split("\n").map(it => it.trim()).join(" ")
  } else {
    title
  }

  // 标题：页面右侧上方，竖排（整体转 90° 后中文逐字再转 -90° 保持正立）
  place(right + top, {
    show regex("[\p{script=Han}]"): it => box(rotate(it, -90deg))
    rotate(clean-title, 90deg, origin: right + top, reflow: true)
  })

  // 作者：页面右侧下方；盲审时不显示
  if not blind and author != none {
    place(right + bottom, {
      show regex("[\p{script=Han}]"): it => box(rotate(it, -90deg), width: 1cm)
      rotate(author, 90deg, origin: right + top, reflow: true)
    })
  }
}
