#import "@preview/wordometer:0.1.5": word-count-of

// Word count (auto-tracked, CJK characters)
#let wordcount() = context state("total-words-cjk").final()

// Word count tracking — wraps content, updates global state
#let word-count-tracked(content) = {
  let stats = word-count-of(
    content,
    exclude: (heading, table, raw, figure.caption),
    counter: s => {
      let cleaned = s.replace(regex("\s+"), "")
      (
        words-cjk: cleaned.clusters().len(),
      )
    },
  )
  state("total-words-cjk").update(prev => prev + stats.words-cjk)
  content
}
