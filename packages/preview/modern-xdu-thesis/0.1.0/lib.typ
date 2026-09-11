// 西安电子科技大学学位论文 Typst 模板 — 包入口（硕士；本科入口见 bachelor.typ）
//
// 依据：docs/格式规格.md（硕士数值的唯一规则源）、docs/本科规格.md（本科数值）
// 公开 API：
//   documentclass(degree:, blind:, info:, fonts:) — 配置入口
//   返回的对象暴露全部页面函数（前置 6 页 / 索引 5 页 / 正文 / 后置 4 部分）
//   以及辅助：引用、索引题注、双语文献。
//   版本：硕士页面与版式已全部实现，经官方 templet.pdf 逐页对照 + 一份 112 页真实论文压测。

#import "utils/style.typ": 字号, 字体
#import "utils/counters.typ": 索引题注
#import "utils/bilingual-bib.typ": 双语文献
// 本科实现保留独立文件入口；这里只导出模块命名空间，不接入任何硕士版式路径。
#import "bachelor.typ" as bachelor
#import "layouts/doc.typ": doc
#import "pages/cover.typ": cover
#import "pages/title-cn.typ": title-cn
#import "pages/title-en.typ": title-en
#import "pages/declaration.typ": declaration
#import "pages/abstract.typ": abstract
#import "pages/abstract-en.typ": abstract-en
#import "pages/list-of-figures.typ": list-of-figures
#import "pages/list-of-tables.typ": list-of-tables
#import "pages/notation.typ": notation
#import "pages/abbreviations.typ": abbreviations
#import "pages/outline.typ": outline-page
#import "layouts/mainmatter.typ": mainmatter, 引用
#import "pages/acknowledgement.typ": acknowledgement
#import "pages/appendix.typ": appendix
#import "pages/references.typ": references
#import "pages/bio.typ": bio

// ============================================================
// 校验
// ============================================================
#let 校验参数(degree, blind) = {
  assert(degree in ("academic", "professional"),
    message: "degree 必须是 \"academic\" 或 \"professional\"，当前是 " + repr(degree))
  assert(type(blind) == bool,
    message: "blind 必须是布尔值")
}

// ============================================================
// 占位函数。现有页面均已实现，此处保留该机制以防后续新增页面时
// 忘记接线——未实现的页面会给出明确中文提示而不是静默失败。
// ============================================================
#let 未实现(名称) = {
  panic("页面函数 `" + 名称 + "` 尚未实现，请暂时不要在论文模板中调用它。")
}

// ============================================================
// documentclass
// ============================================================
#let documentclass(
  degree: "academic",
  blind: false,
  fonts: (:),
  info: (:),
  ..rest,
) = {
  校验参数(degree, blind)

  // 默认 info 字段（与 doc.typ 内的默认值一致；这里再放一份方便测试时不依赖 doc）
  let 默认info = (
    title: ("基于 Typst 的西安电子科技大学学位论文模板",),
    title-en: ("XIDIAN UNIVERSITY Thesis Template for Typst",),
    author: "张三",
    author-en: "Zhang San",
    department: "某学院",
    department-en: "School of XX",
    discipline: "电子科学与技术",
    discipline-en: "Electronic Science and Technology",
    subdiscipline: "电磁场与微波技术",
    domain: "人工智能",
    domain-en: "Artificial Intelligence",
    degree-name: "工学硕士",
    degree-name-en: "Master of Engineering",
    supervisor: ("李四", "教授"),
    supervisor-en: ("Li Si", "Professor"),
    enterprise-supervisor: (none, none),
    enterprise-supervisor-en: (none, none),
    school-code: "10701",
    clc: "TN82",
    student-id: "1234567890",
    secret-level: "公开",
    submit-date: (year: 2025, month: 6),
    keywords: ("关键词一", "关键词二", "关键词三"),
    keywords-en: ("Keyword One", "Keyword Two", "Keyword Three"),
    // 后置部分数据
    acknowledgement: [请在此撰写致谢内容。],
    appendix: [请在此撰写附录内容。],
    references: (
      "广西壮族自治区林业厅. 广西自然保护区[M]. 北京: 中国林业出版社, 1993.",
      "蒋有绪, 郭泉水, 马娟等. 中国森林群落分类及其群落学特征[M]. 北京: 科学出版社, 1998.",
      "ELGAMMAL A, LIU B, ELHOSEINY M, et al. Can a machine learning model learn to generate images in the style of an artist by learning about styles and deviating from style norms[J]. arXiv preprint, 2017.",
      "KOSEKI A, MOMOSE H, KAWAHITO M, et al. Compiler: US, 828402[P/OL]. 2002-05-25[2002-05-28].",
    ),
    bio: (
      ("基本情况", "张三，男，陕西西安人，1982 年 8 月出生，西安电子科技大学 XX 学院 XX 专业 2008 级硕士研究生。"),
      ("教育背景", "2004 年 9 月至 2008 年 7 月，就读于 XX 大学 XX 专业，获工学学士学位。"),
      ("攻读硕士学位期间的研究成果", "1. 发表学术论文（第一作者）：张三, 李四. 论文题目[J]. 期刊名, 2025, 12(3): 45-52.\n2. 申请（授权）专利（第一发明人）：张三, 李四. 专利名称: 中国, 专利号[P]. 2025-01-01."),
    ),

    // 符号对照表 / 缩略语对照表数据
    notation: (("α", "衰减系数"), ("λ", "波长"), ("f", "频率")),
    abbreviations: (("MIMO", "Multiple-Input Multiple-Output", "多输入多输出"),
      ("OFDM", "Orthogonal Frequency Division Multiplexing", "正交频分复用")),
    abstract: [这是一段示例中文摘要。请用真实内容替换。],
    abstract-en: [This is a sample English abstract. Replace it with real content.],
  )
  let 合并info = 默认info + info

  return (
    // ---- 正文辅助（供 template 直接调用）----
    引用: 引用,
    索引题注: 索引题注,
    双语文献: 双语文献,

    // ---- 顶层元数据 ----
    degree: degree,
    blind: blind,
    fonts: fonts,
    info: 合并info,

    // ---- 全局样式入口（被 #show: doc 调用）----
    doc: (..args) => doc(
      degree: degree, blind: blind,
      fonts: fonts, info: 合并info,
      ..args,
    ),

    // ---- 前置部分的 6 个页面 ----
    cover: (..args) => cover(
      degree: degree, blind: blind,
      fonts: fonts, info: 合并info, ..args,
    ),
    title-cn: (..args) => title-cn(
      degree: degree, blind: blind,
      fonts: fonts, info: 合并info, ..args,
    ),
    title-en: (..args) => title-en(
      degree: degree, blind: blind,
      fonts: fonts, info: 合并info, ..args,
    ),
    declaration: (..args) => declaration(
      degree: degree, blind: blind,
      fonts: fonts, info: 合并info, ..args,
    ),
    abstract: (..args) => abstract(
      degree: degree, blind: blind,
      fonts: fonts, info: 合并info, ..args,
    ),
    abstract-en: (..args) => abstract-en(
      degree: degree, blind: blind,
      fonts: fonts, info: 合并info, ..args,
    ),

    // ---- 5 个索引类页面 ----
    list-of-figures: (..args) => list-of-figures(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),
    list-of-tables: (..args) => list-of-tables(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),
    notation: (..args) => notation(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),
    abbreviations: (..args) => abbreviations(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),
    outline-page: (..args) => outline-page(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),

    // ---- 正文 ----
    mainmatter: (..args) => mainmatter(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),

    // ---- 后置部分 ----
    appendix: (..args) => appendix(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),
    references: (..args) => references(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),
    acknowledgement: (..args) => acknowledgement(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),
    bio: (..args) => bio(
      degree: degree, blind: blind, fonts: fonts, info: 合并info, ..args),
  )
}
