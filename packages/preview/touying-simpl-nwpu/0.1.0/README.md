# 西北工业大学 Touying 幻灯片主题

基于 Touying 构建的西北工业大学（NWPU）演示模板，使用学校官网提供的蓝色/白色校标，并以 NWPU 蓝 `#0054A3` 作为默认主色。

## 快速使用

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/touying-simpl-nwpu:0.1.0": *

#show: nwpu-theme.with(config-info(
  title: [Your Title],
  subtitle: [Your Subtitle],
  author: [Author],
  date: datetime.today(),
  institution: [Northwestern Polytechnical University],
))

#title-slide()
#outline-slide()

= Section

== Slide Title

Slide content.

== End <touying:unoutlined>

#end-slide[Thank you!]
```

也可运行：

```sh
typst init @preview/touying-simpl-nwpu:0.1.0
```

## 视觉资源

模板中的 NWPU 蓝色与白色校标来自西北工业大学官网。其他背景和装饰均由 Typst 原生图形生成，不依赖其他高校的视觉资源。

## License

MIT License。学校名称与校标的使用应遵循西北工业大学相关规范。
