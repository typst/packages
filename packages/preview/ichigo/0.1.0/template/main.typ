#import "@preview/ichigo:0.1.0": config, prob

#show: config.with(
  course-name: "Typst 使用小练习",
  serial-str: "第 1 次作业",
  author-info: [
    sjfhsjfh from PKU-Typst
  ],
  author-names: "sjfhsjfh",
  title-style: "simple",
  theme-name: "sketch",
  heading-numberings: ("1.", none, "(1)", "a."),
)

#set text(lang: "zh")

#prob(title: "Warm-up")[
  尝试用 Typst 完成以下任务：
  =
  计算 Fibonacci 数列的第 25 项
  =
  生成九九乘法表
][
  =
  ```typ
  #let fib(n) = {
    if n in (1, 2) {
      return 1
    }
    return fib(n - 1) + fib(n - 2)
  }
  #fib(25)
  ```

  #let fib(n) = {
    if n in (1, 2) {
      return 1
    }
    return fib(n - 1) + fib(n - 2)
  }

  运行得到结果 #fib(25)

  也可以根据通项公式
  $
    f_n = 1 / sqrt(5) (((1 + sqrt(5)) / 2)^n - ((1 - sqrt(5)) / 2)^n)
  $

  ```typ
  #let fib(n) = {
    let lambda-1 = (1 + calc.sqrt(5)) / 2
    let lambda-2 = (1 - calc.sqrt(5)) / 2
    return calc.round((1 / calc.sqrt(5)) * calc.pow(lambda-1, n) - (1 / calc.sqrt(5)) * calc.pow(lambda-2, n))
  }
  #fib(25)
  ```

  #let fib(n) = {
    let lambda-1 = (1 + calc.sqrt(5)) / 2
    let lambda-2 = (1 - calc.sqrt(5)) / 2
    return calc.round((1 / calc.sqrt(5)) * calc.pow(lambda-1, n) - (1 / calc.sqrt(5)) * calc.pow(lambda-2, n))
  }

  计算得到第 25 项 #fib(25)

  =

  ```typ
  #set text(size: 8pt)
  #figure(
    table(
      columns: 10,
      $times$, ..range(1, 10).map(x => [#x]),
      ..range(1, 10).map(x => ([#x], ..range(1, 10).map(y => $#y times #x = #(x * y)$))).flatten()
    ),
    caption: [九九乘法表],
  )
  ```
  #set text(size: 8pt)
  #figure(
    table(
      columns: 10,
      $times$, ..range(1, 10).map(x => [#x]),
      ..range(1, 10).map(x => ([#x], ..range(1, 10).map(y => $#y times #x = #(x * y)$))).flatten()
    ),
    caption: [九九乘法表],
  )
]
