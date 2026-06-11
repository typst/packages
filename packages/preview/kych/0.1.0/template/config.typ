// =============================================================================
// 用户模板配置文件 (Template Configuration)
// =============================================================================
// 这是 跨越晨昏 模板的入口文件（在 typst.toml 中声明为 template.entrypoint）。
// 用户在初始化项目后可以修改此文件来自定义网站配置。
//
// 基于 tufted (https://github.com/vsheg/tufted) 修改而来
// 原始作品 Copyright (c) 2025 Vsevolod Shegolev, MIT License
//
// 工作原理：
//   kych.kych-show 是主模板函数
//   .with() 方法预设部分参数，返回一个新的模板函数 template
//   用户在内容文件中使用 `#show: template` 应用此配置
// =============================================================================

// 导入 跨越晨昏 包（版本号需与 typst.toml 中的 package.version 一致）
#import "@preview/kych:0.1.0"

// 创建预设参数的模板函数
// 用户可在此处修改以下配置：
//   - header-links: 导航栏链接（href 路径 → 显示文字）
//   - title:         网站标题（显示在浏览器标签页中）
//   - lang:          网站语言（可选，默认为 "zh"）
//   - css:           自定义 CSS 文件列表（可选，默认加载 Tufte CSS）
#let template = kych.kych-show.with(
  // 导航栏链接配置：每个元素为 (路径, 显示名称)
  header-links: (
    "/": "首页",
    "/docs/": "文档",
    "/blog/": "博客",
    "/cv/": "简历",
  ),
  title: "跨越晨昏",
)