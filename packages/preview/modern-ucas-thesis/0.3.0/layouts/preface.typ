#import "../utils/style.typ": get-fonts, 字号, 行距
#import "../utils/page-foreground.typ": preface-foreground
#import "../utils/custom-numbering.typ": custom-numbering

// 前言
#let preface(
  // documentclass 传入参数
  twoside: false,
  info: (:),
  fonts: (:),
  fontset: "mac",
  // 其他参数（保留的行距默认值占位；preface 本体只负责页眉页脚与页码，
  // 不直接 set par，各前言页面的行距以各自函数的 set par 为准）
  // 1.25 倍行距：Typst leading 是额外间隙，取 行距.正文，勿写 1.25em。
  leading: 行距.正文,
  // 段前段后 0 磅：段间距不含行距，取与 leading 等值使段间基线距与行内一致。
  spacing: 行距.正文,
  justify: true,
  first-line-indent: (amount: 2em, all: true),
  // 章节编号格式
  numbering: custom-numbering.with(
    first-level: "第1章\u{3000}",
    depth: 3,
    "1.1\u{3000}",
  ),
  // 页眉
  display-header: true,
  // 页眉分隔线
  stroke-width: 0.8pt,
  reset-footnote: true,
  it,
) = {
  // 1.  默认参数
  info = (
    (
      title: ("基于 Typst 的", "中国科学院大学学位论文"),
    )
      + info
  )
  fonts = get-fonts(fontset) + fonts

  // 2. 分页：双面印刷时，自摘要起进入双面对开，强制摘要从奇数页（右页）开始。
  //    封面段（封面/英文封面/声明页）已改为单面连续分页，不再依赖 to:odd 隐式保证
  //    声明页落在奇数页，故此处须显式 pagebreak(to: "odd") 强制摘要奇数页起始。
  //    单面时 twoside 为 false，用 pagebreak(weak: true) 确保摘要从新页开始（若声明页
  //    末尾已在页首则不重复换页），使下方 counter(page).update(1) 在摘要首页起始处生效。
  //
  //    counter(page).update(1) 而非 update(0)：page counter 在 pagebreak 后的新页起始处
  //    生效，update(1) 使摘要首页 counter=1（奇），与物理奇数页一致——页码显示"I"、
  //    页眉按 odd(counter) 判定为奇数页显示"摘要"（而非论文题目）。若用 update(0)，
  //    摘要首页 counter=0（偶），页码渲染为"N"（numbering("I",0)="N"）、页眉误显论文题目。
  //    两种模式下 update(1) 均使首页 counter=1（双面因 pagebreak(to:odd) 后 update 在新页
  //    起点生效；单面因 pagebreak(weak) 后同理），行为统一。
  if twoside {
    pagebreak(to: "odd")
  } else {
    pagebreak(weak: true)
  }
  counter(page).update(1)
  // footer: none 必需：set page(numbering:) 会自动在页脚渲染一个环境样式的
  // 页码（auto footer），与下方 foreground 定制的页码重影，必须显式关闭。
  set page(numbering: "I", footer: none)

  // 3  页眉与页脚：页眉、页脚距页边界 1.5cm）
  // 不使用 page 的 header/footer + header-ascent/footer-descent（语义为"侵入 margin 的量"，
  // 无法精确表达"距边界 1.5cm"且会挤压正文区）。改用 page.foreground + place 绝对定位：
  //   place(top + center, dy: 1.5cm, ...)    —— 页眉锚定到页面顶边下方 1.5cm
  //   place(bottom + center, dy: -1.5cm, ...) —— 页脚锚定到页面底边上方 1.5cm
  // place 的父容器是整个页面（含 margin 区），dy 为正向下、负向上。
  // top-edge/bottom-edge: "bounds" 让文本框边界即字体边界，消除 ascender/descender 偏移，
  // 使 dy:1.5cm 精确等于"页眉文字顶边到页面顶边 1.5cm"。
  // 页眉分隔线用 block(width: 100% - 3.17cm - 3.17cm) 约束到正文区宽度（与左右页边距对齐）。
  set page(foreground: preface-foreground(
    info: info,
    fonts: fonts,
    display-header: display-header,
    stroke-width: stroke-width,
    reset-footnote: reset-footnote,
  ))

  it
}
