// ============================================================
// bold.typ — 统一加粗入口
// ============================================================
//
// 模板的字体加粗规则：任何字体被加粗时，
//   - 有真粗体 → weight: "bold"（交给字体匹配，真粗体）
//   - 无真粗体 → cuti 描边伪粗体（show-cn-fakebold）
//
// ------------------------------------------------------------------
// 一、唯一事实来源：font.typ 的 fakebold-rules
// ------------------------------------------------------------------
//   表义：true = 该字体无真粗体（需描边）；false = 有真粗体。
//
//   | 字体 | Windows              | macOS               | Linux                 |
//   |------|----------------------|---------------------|-----------------------|
//   | 黑体 | true（SimHei 无）     | false（PingFang 有） | false（思源黑体有）    |
//   | 宋体 | true（NSimSun 无）    | true（STSong 无）    | false（思源宋体有）    |
//   | 楷体 | true（KaiTi 无）      | true（STKaiti 无）   | true（AR PL UKai 无）  |
//   | 仿宋 | true（FangSong 无）   | true（STFangsong 无）| true（FandolFang 无）  |
//
// ------------------------------------------------------------------
// 二、唯一入口：本文件的 bold()
// ------------------------------------------------------------------
//   #let bold(body, fakebold, ..args)
//     - fakebold=true  无真粗体 → show-cn-fakebold(text(weight: "bold"))
//       （cuti 只描边汉字，拉丁字符仍走 weight: "bold" 真粗体）
//     - fakebold=false 有真粗体 → text(weight: "bold")
//     - ..args 透传 size/font 等
//
// ------------------------------------------------------------------
// 三、一条全局规则（layouts/setup.typ）
// ------------------------------------------------------------------
//   show strong: it => bold(it.body, style.正文.fakebold)
//   - 只拦 strong（正文 *加粗* / #strong[]），不拦 text(weight: "bold")，
//     因此 Arial 的 ABSTRACT 等不会被误描边。
//   - 门控取 正文.fakebold（= 宋体标志），因为 strong 的实际使用点
//     （正文强调、三线表表头、定理标签）都在宋体上下文里。
//
// ------------------------------------------------------------------
// 四、style 字典中仅 3 个 fakebold 字段被消费
// ------------------------------------------------------------------
//   - 正文.fakebold     → setup.typ 全局 show strong
//   - 封面题目.fakebold → covers.typ 封面题目
//   - 声明.fakebold     → declaration.typ 声明标题
//
//   各元素加粗现状：
//   - 正文/表头/定理标签（宋体）：Windows/macOS 描边，Linux 真粗体
//   - 封面题目（黑体）：Windows 描边，macOS/Linux 真粗体
//   - 声明标题（宋体）：Windows/macOS 描边，Linux 真粗体
//   - ABSTRACT（Arial 拉丁）：三平台真粗体（直接传 false）
//   - 各级标题（黑体）：不加粗（weight: regular），仅靠黑体重字形
//
// ------------------------------------------------------------------
// 五、设计原则
// ------------------------------------------------------------------
//   - 所有加粗（正文强调、封面题目、声明标题等）都应经由此入口，
//     避免各页面各自硬编码 show-cn-fakebold。
//   - 拉丁字体（Times New Roman / Arial 等）始终有真粗体，直接传 false。
//   - 本函数是内部工具，不从 lib.typ 导出；公开 API 仍是 fakebold-rules
//     与 show-cn-fakebold。

#import "../imports.typ": show-cn-fakebold

/// 统一加粗：fakebold=true 无真粗体 → cuti 描边；false 有真粗体 → weight:bold
/// ..args 透传给 text（如 size、font）
#let bold(body, fakebold, ..args) = {
  if fakebold {
    show-cn-fakebold(text(weight: "bold", ..args, body))
  } else {
    text(weight: "bold", ..args, body)
  }
}
