// 第三章:把 Markdown 文件导入文档。做法参考 tufted:
// cmarker 负责转译,scope 把 Markdown 图片变成带题注的 figure,
// math: mitex 让 $…$ / $$…$$ 里的 LaTeX 公式也能渲染。
// / Chapter 3: import Markdown — cmarker transpiles, scope renders Markdown
// images as captioned figures, mitex handles inline LaTeX math.
#import "../配置.typ": *
#import "@preview/cmarker:0.1.10": render
#import "@preview/mitex:0.2.7": mitex

= 关于

本页由项目根目录的 `README.md` 渲染而来——Markdown 也能直接进正文:

#render(
  read("../README.md"),
  h1-level: 2,          // Markdown 的 # → Typst 的 ==,与本节层级接上
  set-document-title: false,
  math: mitex,
  scope: (
    // Markdown 的 ![alt](src) → 带题注的 figure。
    // src 相对 README.md 解析,而这里在 内容/ 下,故补一级 ../。
    image: (source, alt: none, format: auto) => figure(
      image("../" + source, alt: alt, format: format, width: 100%),
      caption: alt,
    ),
  ),
)
