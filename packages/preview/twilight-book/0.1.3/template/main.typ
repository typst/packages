#import "@preview/twlight-book:0.1.3" : *

#show: book.with(
  title: [暮光之书],
  theme: "abyss",
  depth: 1,
  wrapper: (heading, content) => {
    heading
    nest-block(depth: 2, content)
  },
  inset: 1em,
  preface: "ewf",
  date: datetime(year: 2025, month: 11, day: 25),
)

= 正文

dfg
