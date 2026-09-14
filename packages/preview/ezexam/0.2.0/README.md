# `ezexam`
![Typst Version](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fgbchu%2Fezexam%2Frefs%2Fheads%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/gbchu/ezexam/blob/main/LICENSE)
[![Online Documentation](https://img.shields.io/badge/online-Documentation-purple?logo=readthedocs)](https://ezexam.pages.dev/)

## Introduction
This template is primarily designed to help Chinese primary, middle and high school teachers or students in creating exams or handouts.


## Changelog
### 0 . 1 . 0
+ 初版发布

### 0 . 1 . 1
+ 修复 `choices` 方法中，若选项为图片时，设置宽度为百分比时，图片宽度无效的问题

### 0 . 1 . 2
+ 将 `secret` 修改为方法，可以自定义显示内容
+ 优化 `choices` 方法，当选项过长时，选项从第二行开始进行缩进。修复选项中既有文字又有图表时，标签和内容对不齐的问题
+ 将 `question` 方法的参数 `with-heading-label` 的默认值修改为 `false`
+ `explain` 方法新增参数 `show-number` 、修改参数 `title` 的默认值为 `none`，默认不显示
+ `setup` 方法新增参数 `enum-numbering`

### 0 . 1 . 3
+ 优化 `choices` 方法
+ 将 `question` 方法的参数名 `points-separate-par` 修改为 `points-separate`
+ 增加英文完型填空、7选5题型的支持，让 `paren` 和 `fillin` 方法可以使用题号作为占位符。使用详情查看 [`paren`](https://ezexam.pages.dev/reference/paren) 和 [`fillin`](https://ezexam.pages.dev/reference/fillin) 方法
+ `setup` 方法新增参数 `heading-numbering`，`heading-hanging-indent`，`enum-spacing`，`enum-indent` 提供更多自定义设置
+ 修复 `question` 个数超过9个时，内容对不齐的问题

### 0 . 1 . 4
+ 将 `LECTURE` 修改为 `HANDOUTS`，更加符合语义
+ 将 `explain` 方法名修改为 `solution`，更加符合语义
+ 修复当修改弥封线类型时，试卷最后一页没有更改的 bug
+ 添加水印功能，`setup` 方法新增参数 `watermark`，`watermark-size`，`watermark-color`，`watermark-font`，`watermark-rotate`

### 0 . 1 . 5
+ 修复水印被图片遮挡的 bug

### 0 . 1 . 6
+ 修复有序列表,内容带有 `box` 时，编号和内容对不齐的 bug
+ 新增化学方程式的单线桥、双线桥的支持；原子、离子结构示意图的支持。使用详情查看 [`化学相关`](https://ezexam.pages.dev/reference/chem)

### 0 . 1 . 7
+ 优化代码，确保 `heading-size` 只修改一级标题；并将其更名为 `h1-size`
+ 为 `title` 方法新增参数 `color`
+ 修复 `solution` 方法，当启用 `title` 时，如果解析内容过多，一页放不下，标题会跑到下一页的 bug；并将其参数 `above` 更名为 `top`；参数 `below` 更名为 `bottom`；统一参数名；添加参数 `padding-top`、`padding-bottom`
+ 去除 `question` 方法参数 `line-height`；该参数会影响题干之间的距离；该参数原本用于设置题目内容的行高，当题目中的公式比较高时，题号和题目内容会错位，这时可以通过该参数来微调。但是会造成内容每一行与行之间的间隔变大。可参考新增的参数 `padding-top`、`padding-bottom` 代替
+ 修复 `choices` 方法，调整其上下外边距导致选项之间的距离会跟着影响的 bug

### 0 . 1 . 8
+ 为 `mode`  添加新值 `SOLUTION`，当答案解析独立于试题存在时，使用此值可快速统一格式
+ 优化 `choices` 方法；将其参数 `column` 更名为 `columns`，做到和官方的 `columns` 参数一致
+ 废弃 `inline-square` 方法，推荐使用内置的 `table` 方法
+ 修复 `color-box` 方法报错的 bug
+ 优化 `secret` 、`zh-arabic` 方法
+ 优化 `question` 的编号实现方式；修改 `setup` 方法的参数 `enum-numbering` 的默认值为 `（1.i.a）`
+ 优化 `notice` 方法；新增参数 `indent` 、`hanging-indent`

### 0 . 1 . 9
+ 优化 `text-figure` 方法；考虑到文本内容较多，为了书写方便，将参数 `text` 修改为位置参数；新增参数 `figure` 、`style` 、`gap`
+ 优化 `question` 方法；修复当一个文档中组多套试卷时，会报警告的问题
+ 优化 `title` 、`score-box` 、`scoring-box` 方法
+ 优化代码

### 0 . 2 . 0
+ 添加 `cover` 方法；该方法可以生成一个封面。上个版本忘记添加进去了（🤡）
+ 添加 `underdot` 方法；在一些场景下，可以为文本添加着重号