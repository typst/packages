#import "@local/stp:0.1.0": *

#show: template

#outline()

#include "document/example.typ"

#bibliography("sources.bib")

#attachment(
  "обязательное",
  "Секретный DeepSeek API"
)
#include "document/attachment.typ"

#attachment(
  "обязательное",
  "Листинг кода"
)

#source-text(
  "../README.md",
  "README",
)
#source-text(
  "document/attachment.typ",
  "attachment.typ",
)
#source-text(
  "main.typ",
  "main.typ",
)

#attachment(
  "рекомендуемое",
  "Самый секретный DeepSeek API"
)
#include "document/attachment.typ"

#attachment(
  "справочное",
  "Наиболее секретный DeepSeek API, никто вообще не в курсе, что это"
)
#include "document/attachment.typ"

