// =============================================================================
// 跨越晨昏 包主入口文件 (Package Entrypoint)
// =============================================================================
// 此文件是 跨越晨昏 包的核心模块，定义了：
// 1. make-header() — 构建网站导航栏
// 2. kych-web() — 主模板函数，根据 target() 自动适配 HTML 或 PDF 输出
//
// 基于 tufted (https://github.com/vsheg/tufted) 修改而来
// 原始作品 Copyright (c) 2025 Vsevolod Shegolev, MIT License
// =============================================================================

// --- 导入子模块 ---
// 从同目录下的各子模块导入 show 规则 (template-xxx)
// 这些规则会根据 target() 自动适配 HTML/PDF 行为
#import "math.typ": template-math       // 数学公式渲染规则
#import "refs.typ": template-refs       // 交叉引用渲染规则
#import "notes.typ": template-notes     // 脚注渲染规则（转为侧注）
#import "figures.typ": template-figures // 图表渲染规则
// 导入布局辅助函数
#import "layout.typ": full-width, margin-note

// -----------------------------------------------------------------------------
// make-header：生成网站导航栏
// -----------------------------------------------------------------------------
// 仅在 HTML 输出时生效，PDF 输出时跳过（无实际意义）。
//
// 参数：
//   links - 导航链接数组，每个元素为 (href, title) 元组，如 ("/", "首页")
//           若为 none 则不渲染导航栏
// 返回：html.header 元素（HTML）或 none（PDF）
#let make-header(links) = {
  if target() == "html" {
    html.header(
      if links != none {
        // 生成 <nav> 导航栏，遍历所有链接生成 <a> 标签
        html.nav(
          for (href, title) in links {
            html.a(href: href, title)
          },
        )
      },
    )
  }
}

// -----------------------------------------------------------------------------
// kych-web：主模板函数（HTML / PDF 自适应）
// -----------------------------------------------------------------------------
// 此函数是用户实际使用的入口函数，通过 show 规则应用模板。
// 根据 target() 自动切换行为：
//   - HTML 输出：构建完整的 <html><head><body> 结构，加载 Tufte CSS
//   - PDF 输出：使用标准 Typst 文档结构，侧注降级为脚注
//
// 用户无需修改 .typ 源文件，只需切换编译格式即可：
//   typst compile --format html page.typ  # 生成 HTML 网页
//   typst compile --format pdf page.typ   # 生成 PDF 文档
//
// 参数：
//   header-links - 导航栏链接列表，默认为 none（不显示导航，PDF 中忽略）
//   title        - 页面标题，默认为 "跨越晨昏"
//   lang         - 页面语言代码，默认为 "zh"
//   css          - CSS 样式表列表（仅 HTML 输出使用）
//   content      - 页面主体内容（由用户提供的 Typst 内容）
#let kych-show(
  header-links: none,
  title: "跨越晨昏",
  lang: "zh",
  css: (
    "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
    "/assets/kych.css",
    "/assets/custom.css",
  ),
  content,
) = {
  // --- 应用 Show 规则（HTML/PDF 通用）---
  // 各子模块内部已通过 target() 判断做不同处理（在 show 规则处理器中，上下文已知）：
  //   template-math:    HTML → <span/figure role="math">, PDF → 默认行为
  //   template-refs:    HTML → <a> 链接, PDF → 默认行为
  //   template-notes:   HTML → 侧注 (marginnote), PDF → 默认脚注
  //   template-figures: HTML → 标题移到边距, PDF → 默认行为
  show: template-math
  show: template-refs
  show: template-notes
  show: template-figures

  // 设置文档语言（影响连字符、引号样式等排版细节）
  set text(lang: lang)

  // 使用 context 包裹，让 target() 在运行时可用
  context {
    if target() == "html" {
      // ======== HTML 输出：构建完整网页结构 ========
      html.html(
        lang: lang,
        {
          // <head> 区域
          html.head({
            html.meta(charset: "utf-8")
            html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
            html.title(title)

            for (css-link) in css {
              html.link(rel: "stylesheet", href: css-link)
            }
          })

          // <body> 区域
          html.body({
            make-header(header-links)

            // Tufte CSS 使用 article + section 结构控制正文宽度和边距
            html.article(
              html.section(content),
            )
          })
        },
      )
    } else {
      // ======== PDF 输出：标准 Typst 文档结构 ========
      set document(title: title)

      // 导航栏在 PDF 中无意义，直接跳过，不调用 make-header
      content
    }
  }
}
