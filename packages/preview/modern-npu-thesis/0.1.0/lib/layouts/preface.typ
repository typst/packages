#import "../utils/style.typ": 字体, 字号
#import "../utils/header.typ": graduate-header-title, header-render
#import "../utils/custom-heading.typ": active-heading, heading-display

// ============================================
// 一级标题统一配置
// 用于摘要、目录、致谢、正文章节等所有页面
// ============================================

// 一级标题间距（前置部分和正文部分统一使用）
#let heading-above = 2 * 14pt - 0.7em  // 标题上方间距，约 31pt
#let heading-below = 2 * 17pt - 0.7em  // 标题下方间距，约 31pt

// 兼容旧名称的别名
#let preface-heading-above = heading-above
#let preface-heading-below = heading-below

// 标题字体配置
#let preface-heading-font = fonts => fonts.黑体  // 函数，传入 fonts 返回字体
#let preface-heading-size = 字号.三号
#let preface-heading-weight = "regular"  // "regular" 不加粗, "bold" 加粗

// 标题样式函数 - 供各页面调用
#let preface-heading-style(it, fonts, centered: true) = {
  set text(
    font: preface-heading-font(fonts),
    size: preface-heading-size,
    weight: preface-heading-weight,
  )
  set block(above: 0pt, below: preface-heading-below)
  if centered {
    set align(center)
    it
  } else { it }
}

// 前言
#let preface(
  twoside: false,
  doctype: "master",
  fonts: (:),
  display-header: true,
  ..args,
  it,
) = {
  fonts = 字体 + fonts

  // 1. 设置页码逻辑
  // 注意：pagebreak 放在 set page 之前
  pagebreak(weak: true, to: if twoside { "odd" })
  counter(page).update(1)

  // 2. 页面全局设置
  set page(
    footer: context align(center)[
      #set text(size: 字号.小五)
      #counter(page).display("I")
    ],
  )

  // 3. 页眉设置
  // 我们直接在这里针对 it 应用 show rule，或者直接 set page
  show: it => {
    set page(
      header: context {
        if not display-header { return none }

        let loc = here()
        let is-graduate = (doctype == "master" or doctype == "doctor")

        // 默认显示当前章节
        let header-content = heading-display(active-heading(level: 1, prev: false))

        // 双面模式下的偶数页替换为校名
        if twoside and calc.rem(loc.page(), 2) == 0 and is-graduate {
          header-content = graduate-header-title(doctype)
        }

        if is-graduate {
          header-render(header-content, fonts: fonts)
        }
      },
    )
    it
  }

  // 4. 统一控制前置部分一级标题的间距
  // 使用 Typst 官方推荐的 block 方式，避免手动 v() 间距
  show heading.where(level: 1, numbering: none): set block(
    above: preface-heading-above,
    below: preface-heading-below,
  )

  it
}
