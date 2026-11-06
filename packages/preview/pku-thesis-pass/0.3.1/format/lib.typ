// ============================================================
// lib.typ — 包入口
// 北京大学学位论文 Typst 模板 (pku-thesis-pass)
//
// 北京大学学位论文（博士 / 硕士）模板，支持学术学位与专业学位
// 覆盖封面、版权声明、中英文摘要、目录、正文、图表、参考文献、附录、致谢、原创性声明等全部流程
//
// 命令行参数（--input key=value）：
//   --input blind=true|false               盲审模式
//   --input preview=true|false             预览模式（默认 true，链接显示蓝色，打印时请设置为 false）
//   --input always-start-odd=true|false    章节是否总是从奇数页开始
//   --input system=windows|macos|linux     系统字体方案
// ============================================================

// ========== 公开 API ==========

// 入口
#import "config.typ": config, system-state

// 字体方案
#import "utils/font.typ": font-set, fakebold-rules

// 工具
// 公开导出 cuti 伪粗体函数，供需要自定义描边的用户使用（模板内部加粗统一走 utils/bold.typ）
#import "imports.typ": show-cn-fakebold

// 组件
#import "components/booktab.typ": booktab, as-booktab, code-preview
#import "components/eqblock.typ": eq-block
#import "components/codeblock.typ": code-block
#import "components/subfigure.typ": subfigure
#import "components/theorem.typ": theorem, definition, lemma, corollary, proposition, property, example, remark, proof
#import "components/wordcount.typ": word-count-cjk, total-words, total-characters
