// ============================================================
// wordcount.typ — 字数统计组件
// 提供正文/附录的字数、字符数统计：word-count-cjk 与统计结果读取
// ============================================================

#import "../imports.typ": word-count-of

/// 字数统计 show 规则：排除标题，累计 CJK 字数 / 总词数 / 字符数
/// 统计结果写入三个 state，供 total-words / total-characters 读取
/// 由 config() 的 body-wrap 在 word-count: true 时应用（统计正文与附录）
/// content: 待统计的正文内容（由 body-wrap 的 show 规则传入）
/// options: 传递给底层 wordometer::word-count-of 的额外参数
#let word-count-cjk(content, ..options) = {
  let stats = word-count-of(
    content,
    exclude: (heading),
    counter: s => (
      characters: s.replace(regex("\s+"), "").clusters().len(),
      words: s.matches(regex("\b[\w'’.,\-]+\b")).len(),
      words-cjk: s.matches(regex("[\p{Han}]|[\p{Latin}'’.,\-]+")).len(),
    ),
    ..options,
  )
  state("total-words-cjk").update(prev => prev + stats.words-cjk)
  state("total-words").update(prev => prev + stats.words)
  state("total-characters").update(prev => prev + stats.characters)
  content
}

/// 正文 CJK 字数统计结果
/// - 前提：config() 需开启 word-count: true（默认开启），并由 body-wrap 应用统计
/// - 返回：content，可直接在正文中显示，如 "#total-words" 渲染为具体字数
/// - 统计范围：正文与附录（排除标题），含中文标点附近的汉字与拉丁词
#let total-words = context state("total-words-cjk").final()

/// 正文字符数统计结果
/// - 前提：config() 需开启 word-count: true（默认开启），并由 body-wrap 应用统计
/// - 返回：content，可直接在正文中显示，如 "#total-characters" 渲染为具体字符数
/// - 统计范围：正文与附录（排除标题），去空白后计数
#let total-characters = context state("total-characters").final()
