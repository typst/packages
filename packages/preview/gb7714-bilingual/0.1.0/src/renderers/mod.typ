// GB/T 7714 双语参考文献系统 - 渲染器入口

#import "article.typ": render-article
#import "book.typ": render-book
#import "conference.typ": render-inproceedings
#import "thesis.typ": render-thesis
#import "patent.typ": render-patent
#import "standard.typ": render-standard
#import "report.typ": render-report
#import "webpage.typ": render-webpage
#import "misc.typ": render-misc

// 类型 -> 渲染函数映射
#let _renderers = (
  // 期刊文章
  "article": render-article,
  // 书籍
  "book": render-book,
  "inbook": render-book,
  "incollection": render-book,
  // 会议论文
  "inproceedings": render-inproceedings,
  "conference": render-inproceedings,
  // 学位论文
  "phdthesis": render-thesis,
  "mastersthesis": render-thesis,
  "thesis": render-thesis,
  // 专利
  "patent": render-patent,
  // 标准
  "standard": render-standard,
  // 报告
  "techreport": render-report,
  "report": render-report,
  // 网页/在线资源
  "online": render-webpage,
  "webpage": render-webpage,
  "www": render-webpage,
)

// 检测是否为标准（citegeist 不支持 @standard，返回 unknown）
#let _is-standard-entry(entry) = {
  let f = entry.at("fields", default: (:))
  let number = f.at("number", default: "")
  let std-prefixes = ("GB", "ISO", "IEC", "IEEE", "ANSI", "DIN", "JIS", "BS")
  std-prefixes.any(p => upper(number).starts-with(p))
}

/// 根据类型选择渲染函数
#let render-entry(
  entry,
  lang,
  year-suffix: "",
  style: "numeric",
  version: "2025",
  config: (show-url: true, show-doi: true, show-accessed: true),
) = {
  let raw-type = lower(entry.entry_type)

  // 智能类型检测
  let entry-type = if raw-type == "unknown" and _is-standard-entry(entry) {
    "standard"
  } else {
    raw-type
  }

  // 查找渲染函数，未找到则使用 misc
  let renderer = _renderers.at(entry-type, default: render-misc)

  renderer(
    entry,
    lang,
    year-suffix: year-suffix,
    style: style,
    version: version,
    config: config,
  )
}
