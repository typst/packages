// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `languages` data entries are as follows:
// 
// array: string
// none

#import "../process/enum.typ"
#import "../utils.typ"

// array: str
#let process-lang(body) = {
  if not body.keys().contains("languages") { return }
  if body.languages == none { return (proc: [--], amount: 1) }

  let processed = body.languages.map(lang => {
    utils.translate-t-word-if-possible("languages", lang, enum.languages)
  })

  return (proc: processed.join(", "), amount: body.languages.len())
}
