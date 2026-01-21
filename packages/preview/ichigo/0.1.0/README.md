# ichigo - 苺

Homework Template - 作业模板

## Usage - 使用方法

```typ
#import "@preview/ichigo:0.1.0": config, prob

#show: config.with(
  course-name: "Typst 使用小练习",
  serial-str: "第 1 次作业",
  author-info: [
    sjfhsjfh from PKU-Typst
  ],
  author-names: "sjfhsjfh",
)

#prob[
  Calculate the 25th number in the Fibonacci sequence using Typst
][
  #let f(n) = {
    if n <= 2 {
      return 1
    }
    return f(n - 1) + f(n - 2)
  }
  #f(25)
]
```

## Documentation - 文档

[Click to download - 点击下载](https://github.com/PKU-Typst/ichigo/releases/download/v0.1.0/documentation.pdf)

## TODO - 待办

- [ ] Theme list
- [ ] Support custom(local) theme
