#import "@preview/twilight-book:0.1.3" : *

#show: book.with(
  title: [晨昏之书],
  theme: "abyss",
  depth: 1,
  wrapper: (heading, content) => {
    heading
    nest-block(depth: 2, content)
  },
  inset: 1em,
  preface: "一个多主题模板",
  date: datetime(year: 2025, month: 11, day: 25),
)

= 正文

// 在这里编写正文 / Write the main content here
