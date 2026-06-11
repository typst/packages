// =============================================================================
// 首页内容 (Homepage)
// =============================================================================
// 网站首页模板，演示了 跨越晨昏 模板的核心特性：
// 1. 侧注 (margin-note) 的使用 — 在页面边距中插入图片和文字
// 2. Markdown 嵌入 — 读取 README.md 并渲染为网页内容
// =============================================================================

// 导入模板配置（template 函数和 kych 模块）
#import "../config.typ": template, kych
// 导入 cmarker 包，用于将 Markdown 渲染为 Typst 内容
#import "@preview/cmarker:0.1.8"
// 应用 kych 模板
#show: template

// 页面主标题（一级标题）
= 跨越晨昏

// --- 侧注示例：图片 ---
// margin-note 将内容显示在页面右侧边距中
#kych.margin-note({
  // 雌性凤头潜鸭和幼鸭
  image("imgs/tufted-duck-female-with-duckling.webp")
  // 雄性凤头潜鸭
  image("imgs/tufted-duck-male.webp")
})

// --- 侧注示例：文字 ---
// 关于凤头潜鸭 (Tufted Duck) 的趣味科普
#kych.margin-note[
  凤头潜鸭（_Aythya fuligula_）是一种原产于欧亚大陆的中型潜水鸭。以其潜水能力著称，可以潜入极深的水域觅食。
]

// --- Markdown 嵌入区域 ---
  // 注意：此页面内容是从 README.md 文件自动生成的
#{
  // 读取项目根目录的 README.md 文件内容
  let md-content = read("../README.md")
  // 移除一级标题（README 中的 "# 跨越晨昏"），因为页面上方已经显示了标题
  let md-content = md-content.trim(regex("\s*#.+?\n")) // 移除一级标题

  // 使用 cmarker 将 Markdown 渲染为 Typst 内容
  // scope 参数允许自定义 Markdown 中图片的渲染方式
  cmarker.render(
    md-content,
    scope: (
      // 重定义 Markdown 图片语法 ![]() 的处理方式
      image: (source, alt: none, format: auto) => figure(image(
        "../" + source, // 调整图片路径：Markdown 文件在根目录，图片在 template/imgs/
        alt: alt,        // 无障碍替代文本
        format: format,  // 图片格式（自动检测）
      )),
    ),
  )
}