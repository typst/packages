#import "@preview/jastylest-zh.typ:0.1.0": *
#import "@preview/pointless-size:0.1.1": zh, zihao  // 引入对中式字号的支持
#import "@preview/cjk-unbreak:0.1.1": remove-cjk-break-space

#show: remove-cjk-break-space  // 现在在中文之间断行不再会插入空格

#let (article, textsf) = template(
  // seriffont: "STIX Two Text",
  // seriffont-cjk: "Noto Serif CJK SC",
  // sansfont: "Noto Serif",
  // sansfont-cjk: "Noto Sans CJK SC",
  // monofont: "Fira Mono"
  // monofont-cjk: "Noto Sans Mono CJK SC"
  // mathfont: "STIX Two Math",
  // kaiti-cjk: "FandolKai", 
  // paper: "a4",            // 纸张大小
  font-size: zh(-4),         // 字号
  code-font-size: zh(5),     // 代码字号
  // font-weight: "medium",  // 字体粗细
  // cols: 1,                // 多栏
  // titlepage: true,        // 标题页
  title: [jastylest-zh使用说明],
  office: [天朝理工大学 中文排版专业],
  author: [Mike Unknown],
  // date: none, // 日期，默认为当前日期
)
#show: article

#outline()


= 格式设定
jastylest是一个日文排版模板。jastylest-zh是基于中文排版特性优化的jastylest。

样式和标题的设置在上方，可以自行更改。

== 字体
默认字体为STIX Two Text/Math、Fira Sans/Mono和思源宋体/黑体。您也可以自行修改。

_斜体的默认中文字体是 FandolKai（需自行上传），您也可以自行在上方配置中更改。Fandol系列字体可以在 https://ctan.org/pkg/fandol 中下载。_

= 特殊功能
Typst在汉字和English之间插入了微小的空格。然而，行内公式$a b$和汉字之间，以及行内代码`ab`和汉字之间*默认*没有任何间隙。我们实施了一种方法来避免这种情况。现在行内公式/代码与汉字之间会有微小的空格。

如果插入连字符，例如 $beta$-胡萝卜素，则不会出现间隙。我们还在半宽圆括号的两端添加了间隙。例如：排版(typesetting)。

我们还为中英文混排的情况优化了引号。现在你可以在西文排版中使用ASCII“智能引号”，在中文排版中用中文输入法打出引号。破折号和省略号未能被优化。

#textsf[使用 ```typ #textsf[]``` 让被括号包裹的部分使用无衬线字体。_在这里使用italic也可以。_]

#noindent[使用 ```typ #noindent[]``` 让被括号包裹的部分取消缩进。]
