#import emoji: star
#import "@preview/bone-resume:0.3.1": resume-init, resume-section

#show: resume-init.with(
  author: "张三",
  footer: [Powered by #link(
      "https://github.com/typst/packages/tree/main/packages/preview/bone-resume",
    )[BoneResume]],
)
#stack(dir: ltr, spacing: 1fr, text(24pt)[*张三*], stack(
  spacing: 0.75em,
  [微信: weixin],
  [电话: 188 8888 8888],
  [邮箱: #link("mailto:admin@qq.com")[admin\@qq.com]],
), stack(
  spacing: 0.75em,
  [GitHub: #link("https://github.com/zrr1999")[github.com/zrr1999]],
  [个人主页: #link("https://www.bone6.top")[www.bone6.top]],
), move(dy: -2em, box(height: 84pt, width: 60pt,fill: color.hsv(240deg, 10%, 100%), inset: 5pt, radius: 3pt)))

#v(-4em)
= 教育背景
西安电子科技大学 #h(2cm) 智能科学与技术专业（学士） #h(1fr) 2018.09-2022.07\
西安电子科技大学 #h(2cm) 计算机科学与技术专业（在读硕士） #h(1fr) 2022.09-2025.07

= 开源贡献
#resume-section(
  link("https://github.com/PaddlePaddle/CINN")[PaddlePaddle/CINN],
  "针对神经网络的编译器基础设施",
)[
  添加了 argmax, sort, gather, gather_nd, scatter_nd 等算子, 实现了 CSE Pass 和
  ReverseComputeInline 原语以及参与了一些单元测试补全，具体内容见
  #link(
    "https://github.com/PaddlePaddle/CINN/pulls?q=is%3Apr+author%3Azrr1999+is%3Aclosed",
  )[相关 PR]。
]

#resume-section(
  link("https://github.com/PaddlePaddle/Paddle")[PaddlePaddle/Paddle],
  "高性能单机、分布式训练和跨平台部署框架",
)[
  添加了 remainder\_, sparse_transpose, sparse_sum 三个算子， 实现了 TensorRT onehot
  算子转换功能，以及修复了一些bug，具体内容见
  #link(
    "https://github.com/PaddlePaddle/Paddle/pulls?q=is%3Apr+author%3Azrr1999+is%3Aclosed",
  )[相关 PR]。
]

= 实习经历
#resume-section(
  [#link("https://github.com/PaddlePaddle/PaddleSOT")[百度飞桨框架开发-动转静小组]（线上实习）],
  "2023.07.01-2023.10.31",
)[
主要工作是参与 #link("https://github.com/PaddlePaddle/PaddleSOT")[PaddleSOT] 的开发，主要贡献包括：
+ 添加注册优先级机制并重构模拟变量机制。
+ 优化字节码模拟执行报错信息和`GitHub Actions`日志信息。
+ 实现 `VariableStack` 并添加子图打断的`Python3.11`支持。
]
#resume-section(
  [#link("https://github.com/PaddlePaddle/Paddle")[百度飞桨框架开发-PIR项目]（线上实习）],
  "2023.11.01-2024.05.31",
)[
主要工作是参与 #link("https://github.com/PaddlePaddle/Paddle")[Paddle] 中 PIR
组件的开发，主要贡献包括：
+ Python API 适配升级。
+ API 类型检查的生成机制实现。
+ 添加 `InvalidType` 错误类型。
]

= 个人技能
#let stars(num) = {
  for _ in range(num) {
    [#emoji.star]
  }
}

#let level(num, desc: none) = {
  if desc == none {
    if num < 3 {
      desc = "了解"
    } else if num < 5 {
      desc = "掌握"
    } else if num < 7 {
      desc = "熟练"
    } else {
      desc = "精通"
    }
  }
  // [(#desc) #stars(num)]
  [#desc]
}

#grid(
  columns: (60pt, 1fr, auto),
  rows: auto,
  gutter: 6pt,
  "Python",
  [有丰富的大型开源项目开发经验，熟悉字节码等机制并有实际项目经验 ],
  level(8),
  "C/C++",
  [有较为丰富的大型开源项目开发经验，擅长编写高性能算子],
  level(5),
  "CUDA",
  [有一定的的大型开源项目算子开发经验],
  level(4),
  "JS/TS",
  [有多项前端或全栈小型项目开发经验，获得若干奖项],
  level(4),
  "Rust",
  [有局部修改其他开源项目的经历，了解基本的工具链],
  level(3),
  "Typst",
  [对 Typst 语言的实现原理有过了解，修复过官方示例中小错误],
  level(3),
  "LaTeX",
  [在本科期间，作为主要编写文档的工具使用至少三年],
  level(3),
)

