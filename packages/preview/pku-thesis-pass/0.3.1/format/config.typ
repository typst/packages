// ============================================================
// config.typ — 学位论文模板总控入口
// config() 返回闭包字典 + 配置值，用户通过 cfg.xxx 方式调用
//
// 命令行参数（--input key=value）：
//   --input blind=true|false               盲审模式
//   --input preview=true|false             预览模式（默认 true，链接显示蓝色，打印时请设置为 false）
//   --input always-start-odd=true|false    章节是否总是从奇数页开始
//   --input system=windows|macos|linux     系统字体方案
// ============================================================

// ========== 子模块导入 ==========

#import "utils/number.typ": appendix
#import "config/cli.typ": _cli-blind, _cli-preview, _cli-always-start-odd, _cli-system, system-state
#import "config/resolve.typ": resolve-font, resolve-supplements, resolve-bib, make-smartpagebreak
#import "config/builder.typ": build-pages
#import "components/wordcount.typ": total-words, total-characters

// ========== 参数化配置入口 ==========

/// 论文主配置函数，返回闭包字典（DI 模式）
/// 返回字典，通过 `cfg.xxx` 方式调用各页面函数和配置值
///
/// 基本信息：
///   author-zh — 中文姓名
///   author-en — 英文姓名
///   student-id — 学号
///   blind-id — 盲审论文编号
///   thesis-name — 论文类型（博士/硕士学位论文）
///   header-text — 页眉统一文本
///   title-zh — 中文题目
///   title-en — 英文题目
///   school — 院系
///   first-major — 一级学科
///   major-zh — 专业中文名
///   major-en — 专业英文名
///   direction — 研究方向
///   supervisor-zh — 导师中文名
///   supervisor-en — 导师英文名
///   degree-type — "academic"(学术) / "professional"(专业)
///   year — 论文提交年份
///   month — 论文提交月份
///
/// 排版配置：
///   system — 系统字体方案："windows"/"macos"/"linux"（默认 "windows"）
///   blind — 盲审模式（默认 false）
///   preview — 预览模式（链接显示蓝色，默认 true）
///   first-line-indent — 首行缩进（默认 2em）
///   always-start-odd — 章节从奇数页开始（默认 true）
///   clean-declaration — 声明页清除页眉页码（默认 false）
///   outline-depth — 目录深度（默认 3）
///   word-count — 统计正文字数（默认 false）
///   achievement-outlined — "攻读学位期间发表的论文"页是否入目录（默认 true）
///   supplements — 自定义引用记号
///   use-latexref — 是否启用 LaTeX 引用兼容（默认 false）
///   latexref-prefixes — LaTeX 引用剥离前缀列表
///   codly-args — 控制代码块行号、背景色、语言图标等
///   logo — 封面校徽图片路径（默认 none 显示占位框）
///   wordmark — 封面校名字标图片路径（默认 none 显示占位框）
///
/// 参考文献：
///   override-bib — 使用 Typst 原生 bibliography（默认 false）
///   bib-file — BibTeX 文件，`path` 类型
///   bib-style — "numeric"(顺序编码) / "author-date"(著者-出版年)
///   bib-version — "2015" / "2025"
///   bib-cn-first — 中文文献优先（默认 true）
///   bib-pinyin-override — 拼音排序覆写

#let config(
  // ========== 基本信息 ==========
  author-zh: "张三",
  author-en: "San Zhang",
  student-id: "23000xxxxx",
  blind-id: "L2023XXXXX",
  thesis-name: "博士研究生学位论文",
  header-text: "北京大学博士学位论文",
  title-zh: "北京大学学位论文 Typst 模板",
  title-en: "Typst Template for Peking University Thesis",
  school: "某个院系",
  first-major: "某个一级学科",
  major-zh: "某个专业",
  major-en: "Some Major",
  direction: "某个研究方向",
  supervisor-zh: "李四",
  supervisor-en: "Si Li",
  degree-type: "academic",
  year: 2026,
  month: 6,
  // ========== 排版配置 ==========
  system: "windows",
  blind: false,
  preview: true,
  first-line-indent: 2em,
  always-start-odd: true,
  clean-declaration: false,
  outline-depth: 3,
  supplements: (:),
  use-latexref: false,
  latexref-prefixes: ("fig:", "tbl:", "eqt:", "lst:", "img:", "alg:"),
  achievement-outlined: true,
  word-count: false,
  codly-args: (:),
  logo: none,
  wordmark: none,
  // ========== 参考文献 ==========
  override-bib: false,
  bib-file: none,
  bib-style: "numeric",
  bib-version: "2015",
  bib-cn-first: true,
  bib-pinyin-override: (:),
) = {
  // 命令行参数覆盖
  let blind = if _cli-blind != none { _cli-blind } else { blind }
  let preview = if _cli-preview != none { _cli-preview } else { preview }
  let always-start-odd = if _cli-always-start-odd != none { _cli-always-start-odd } else { always-start-odd }

  // 字体方案、引用记号、参考文献解析
  let (resolved-system, font, style) = resolve-font(system, _cli-system)
  let supplements = resolve-supplements(supplements)
  let bib-content = resolve-bib(bib-file)
  let smartpagebreak = make-smartpagebreak(always-start-odd)

  // 封装上下文，传入页面构建器
  let ctx = (
    style: style,
    font: font,
    system: resolved-system,
    blind: blind,
    preview: preview,
    first-line-indent: first-line-indent,
    smartpagebreak: smartpagebreak,
    supplements: supplements,
    bib-content: bib-content,
    word-count: word-count,
    outline-depth: outline-depth,
    achievement-outlined: achievement-outlined,
    clean-declaration: clean-declaration,
    codly-args: codly-args,
    use-latexref: use-latexref,
    latexref-prefixes: latexref-prefixes,
    header-text: header-text,
    thesis-name: thesis-name,
    title-zh: title-zh,
    title-en: title-en,
    author-zh: author-zh,
    author-en: author-en,
    student-id: student-id,
    school: school,
    first-major: first-major,
    major-zh: major-zh,
    major-en: major-en,
    direction: direction,
    supervisor-zh: supervisor-zh,
    supervisor-en: supervisor-en,
    blind-id: blind-id,
    degree-type: degree-type,
    year: year,
    month: month,
    logo: logo,
    wordmark: wordmark,
    override-bib: override-bib,
    bib-style: bib-style,
    bib-version: bib-version,
    bib-cn-first: bib-cn-first,
    bib-pinyin-override: bib-pinyin-override,
  )

  let pages = build-pages(ctx, system-state)

  pages + (
    appendix: appendix,
    font: font,
    style: style,
    system: resolved-system,
    blind: blind,
    preview: preview,
    always-start-odd: always-start-odd,
    first-line-indent: first-line-indent,
    achievement-outlined: achievement-outlined,
    smartpagebreak: smartpagebreak,
    total-words: total-words,
    total-characters: total-characters,
  )
}
