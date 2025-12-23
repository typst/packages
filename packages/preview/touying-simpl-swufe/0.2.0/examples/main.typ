#import "../lib.typ": *


#show: swufe-theme.with(
  // Lang and font configuration
  aspect-ratio: "16-9",
  lang: "zh",
  // Recommended KaiTi for Chinese slides
  font: ((name: "Libertinus Serif", covers: "latin-in-cjk"), "KaiTi", "Kaiti SC", "楷体"),


  // Basic information
  config-info(
    title: [Typst Slide Theme for Southwest University of Finance and Economics Based on Touying],
    subtitle: [基于Touying的西南财经大学Typst幻灯片模板],
    short-title: [Typst Slide Theme for SWUFE Based on Touying],
    authors: [雷超#super("1"), Lei Chao#super("1,2")],
    author: [Presenter: Lei Chao],
    date: datetime.today(),
    institution: ([#super("1")金融学院 西南财经大学], [#super("2")西南财经大学]),
    banner: image("../assets/swufebanner.svg"),
    logo: image("../assets/swufelogo.svg"),
  ),

  config-colors(
    primary: rgb(1, 83, 139),
    primary-dark: rgb(0, 42, 70),
    secondary: rgb(255, 255, 255),
    neutral-lightest: rgb(255, 255, 255),
    neutral-darkest: rgb(0, 0, 0),
  ),
)


#title-slide()

#outline-slide()

= Typst 与 Touying

== Why Typst

- Typst 是一门新的基于标记的排版系统，它强大且易于学习。你可以在 Typst 的#link("https://typst.app/docs")[文档]中找到更多信息。
- *语法简洁：*上手难度跟 Markdown 相当，文本源码可阅读性高。
- *编译速度快：*增量编译时间一般维持在*数毫秒*到*数十毫秒*。
- *环境搭建简单：*安装快速简便，官方 Web App 和本地 VS Code 均能*开箱即用*。Typst 原生支持中日韩等非拉丁语言，拒绝Latex中的繁琐设置。
- *现代脚本语言：*
  - 变量、函数、闭包与错误检查 + 函数式编程的纯函数理念。
  - 可嵌套的 `[标记模式]`、`{脚本模式}` 与 `$数学模式$` #strike[不就是 JSX 嘛]。
  - 统一的包管理，支持导入 WASM 插件和*按需自动安装*第三方包。

== Typst 对比其他排版系统

#slide[
  #set text(.7em)
  #let 难 = text(fill: rgb("#aa0000"), weight: "bold", "难")
  #let 易 = text(fill: rgb("#007700"), weight: "bold", "易")
  #let 多 = text(fill: rgb("#aa0000"), weight: "bold", "多")
  #let 少 = text(fill: rgb("#007700"), weight: "bold", "少")
  #let 慢 = text(fill: rgb("#aa0000"), weight: "bold", "慢")
  #let 快 = text(fill: rgb("#007700"), weight: "bold", "快")
  #let 弱 = text(fill: rgb("#aa0000"), weight: "bold", "弱")
  #let 强 = text(fill: rgb("#007700"), weight: "bold", "强")
  #let 较强 = text(fill: rgb("#007700"), weight: "bold", "较强")
  #let 中 = text(fill: blue, weight: "bold", "中等")
  #let cell(top, bottom) = stack(spacing: .2em, top, block(height: 2em, text(size: .7em, bottom)))

  #v(1em)
  #figure(
    table(
      columns: 8,
      stroke: none,
      align: center + horizon,
      inset: .5em,
      table.hline(stroke: 2pt),
      [排版系统], [安装难度], [语法难度], [编译速度], [排版能力], [模板能力], [编程能力], [方言数量],
      table.hline(stroke: 1pt),
      [LaTeX],
      cell[#难][选项多 + 体积大 + 流程复杂],
      cell[#难][语法繁琐 + 嵌套多 + 难调试],
      cell[#慢][宏语言编译\ 速度极慢],
      cell[#强][拥有最多的\ 历史积累],
      cell[#强][拥有众多的\ 模板和开发者],
      cell[#中][图灵完备\ 但只是宏语言],
      cell[#中][众多格式、\ 引擎和发行版],
      [Markdown],
      cell[#易][大多编辑器\ 默认支持],
      cell[#易][入门语法十分简单],
      cell[#快][语法简单\ 编译速度较快],
      cell[#弱][基于 HTML排版能力弱],
      cell[#中][语法简单\ 易于更换模板],
      cell[#弱][图灵不完备 \ 需要外部脚本],
      cell[#多][方言众多\ 且难以统一],
      [Word],
      cell[#易][默认已安装],
      cell[#易][所见即所得],
      cell[#中][能实时编辑\ 大文件会卡顿],
      cell[#强][大公司开发\ 通用排版软件],
      cell[#弱][二进制格式\ 难以自动化],
      cell[#弱][编程能力极弱],
      cell[#少][统一的标准和文件格式],
      [Typst],
      cell[#易][安装简单\ 开箱即用],
      cell[#中][入门语法简单\ 进阶使用略难],
      cell[#快][增量编译渲染\ 速度最快],
      cell[#较强][已满足日常\ 排版需求],
      cell[#强][制作和使用\ 模板都较简单],
      cell[#强][图灵完备\ 现代编程语言],
      cell[#少][统一的语法\ 统一的编译器],
      table.hline(stroke: 2pt),
    ),
  )
]

== 什么是 Touying
#tblock(title: [Touying])[
  Touying 是为 Typst 开发的幻灯片/演示文稿包。Touying 也类似于 LaTeX 的 Beamer，但是得益于 Typst，你可以拥有更快的渲染速度与更简洁的语法。你可以在 Touying 的#link("https://touying-typ.github.io/touying/zh/docs/intro")[文档]中详细了解 Touying。

  Touying 取自中文里的「投影」，在英文中意为 project。相较而言，LaTeX 中的 beamer 就是德文的投影仪的意思。
]
- 本文件就是基于Touying包编写的幻灯片示例。

= 快速入门
== Hello World
#slide[
  #set text(.5em)

  ````typ
  #v(0.5em)
  #show "Typst": set text(fill: blue, weight: "bold")
  #show "LaTeX": set text(fill: red, weight: "bold")
  #show "Markdown": set text(fill: purple, weight: "bold")

  Typst 是为 *学术写作* 而生的基于 _标记_ 的排版系统。

  Typst = LaTeX 的排版能力 + Markdown 的简洁语法 + 现代的脚本语言

  #underline[本示例文档]包括以下内容：

  + Typst 和 Touying 的简介
  + 快速入门 Typst
  + 其他功能

  ```py
  print('Hello Typst!')
  ```
  ````
][
  #v(0.5em)
  #show "Typst": set text(fill: blue, weight: "bold")
  #show "LaTeX": set text(fill: red, weight: "bold")
  #show "Markdown": set text(fill: purple, weight: "bold")

  Typst 是为 *学术写作* 而生的基于 _标记_ 的排版系统。

  Typst = LaTeX 的排版能力 + Markdown 的简洁语法 + 现代的脚本语言

  #underline[本示例文档]包括以下内容：

  + Typst 和 Touying 的简介
  + 快速入门 Typst
  + 其他功能
  ```py
  print('Hello Typst!')
  ```
]

== 列表

- 无序列表使用 `-` 作为标记：
  - 第一项
  - 第二项
    - 第二项的子项
  - 第三项

#v(1em)

+ 有序列表使用数字加点 `+` 或者自行编号作为标记：
  + 第一项
  + 第二项
    5. 第二项的子项
  + 第三项
== 插入公式
- Typst公式比Latex更简洁，不需要反斜杠`\`，直接使用命令名称即可。
  - 字母与字母之间需要空格隔开，否则会认为是命令。例如 `sum` 会被解析为 $sum$。
  - 如果需要用到多字母表示变量名称，需要用双引号`""`包裹。
  - Latex公式和Typst相互转换：#link("https://qwinsi.github.io/tex2typst-webapp/")[使用 tex2typst 把 LaTeX 数学公式转换成 Typst 版本]。

- *使用 `$...$` 包裹内联公式：*$J(theta) = EE_(pi_theta) [G_t ] = sum_(s in cal(S)) d^pi (s) V^pi (s) = sum_(s in cal(S)) d^pi (s) sum_(a in cal(A)) pi_theta (a|s) Q^pi (s, a)$
\
- *使用 `$ ... $` 包裹行间公式（两端有空格）：*
$
  公 式 Q_upright(t a r g e t) & = r + gamma Q^pi (s^prime, pi_theta (s^prime) + epsilon.alt) \
                   epsilon.alt & ~ upright(c l i p)(cal(N)(0, sigma), - c, c)
$

== 公式的编号和引用
#set math.equation(numbering: "(1)")
$
  A = lim_(n -> infinity) Delta x lr(\(a^2 +(a^2 + 2 a Delta x +(Delta x)^2))
  +(a^2 + 2 dot.op 2 a Delta x + 2^2 (Delta x)^2) \
  +(a^2 + 2 dot.op 3 a Delta x + 3^2 (Delta x)^2) \
  + ... \
  lr(+(a^2 + 2 dot.op(n - 1) a Delta x +(n - 1)^2 (Delta x)^2) \)) \
  = 1/3 (b^3 - a^3)
$ <eq>

- `@` 可以用来引用公式，例如上面的公式编号为 (@eq)。

== 插入图片
- 推荐使用 VSCode 中 #link("https://marketplace.visualstudio.com/items?itemName=yuzhong.typst-figure-pastetools")[Typst-figure-pasteTools] 插件，像 Word 一样复制粘贴图片即可自动生成 `#figure` 代码块。

#figure(
  image("../assets/swufelogo.svg", width: auto, height: 30%),
  caption: [西南财经大学校徽],
)



== 插入带阴影的图片
- 使用 `#shadow-figure()` 可以插入带阴影效果的图片，避免图片融入背景无法区分。
#shadow-figure(
  image("../thumbnail.webp", width: auto, height: 80%),
)

== 表格
- 推荐使用 VSCode中我制作的 #link("https://marketplace.visualstudio.com/items?itemName=leichaoL.typst-table-paste")[Typst-table-paste] 插件，将 Word、Excel 或者其他表格软件中的表格复制粘贴到 Typst 中即可自动生成 `#figure(table())` 代码块。

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    align: center + horizon,
    inset: .5em,
    table.hline(stroke: 2pt),
    [姓名], [年龄], [专业],
    table.hline(stroke: 1pt),
    [张三], [23], [金融学],
    [李四], [22], [经济学],
    [王五], [24], [会计学],
    table.hline(stroke: 2pt),
  ),
  caption: "一个示例表",
)



= 其他功能

== 双栏布局

#slide(composer: (1fr, 1fr))[
  我仰望星空，

  它是那样辽阔而深邃；

  那无穷的真理，

  让我苦苦地求索、追随。

  我仰望星空，

  它是那样庄严而圣洁；

  那凛然的正义，

  让我充满热爱、感到敬畏。
][
  我仰望星空，

  它是那样自由而宁静；

  那博大的胸怀，

  让我的心灵栖息、依偎。

  我仰望星空，

  它是那样壮丽而光辉；

  那永恒的炽热，

  让我心中燃起希望的烈焰、响起春雷。
]


== 内容跨页

豫章故郡，洪都新府。星分翼轸，地接衡庐。襟三江而带五湖，控蛮荆而引瓯越。物华天宝，龙光射牛斗之墟；人杰地灵，徐孺下陈蕃之榻。雄州雾列，俊采星驰。台隍枕夷夏之交，宾主尽东南之美。都督阎公之雅望，棨戟遥临；宇文新州之懿范，襜帷暂驻。十旬休假，胜友如云；千里逢迎，高朋满座。腾蛟起凤，孟学士之词宗；紫电青霜，王将军之武库。家君作宰，路出名区；童子何知，躬逢胜饯。

时维九月，序属三秋。潦水尽而寒潭清，烟光凝而暮山紫。俨骖騑于上路，访风景于崇阿。临帝子之长洲，得天人之旧馆。层峦耸翠，上出重霄；飞阁流丹，下临无地。鹤汀凫渚，穷岛屿之萦回；桂殿兰宫，即冈峦之体势。

披绣闼，俯雕甍，山原旷其盈视，川泽纡其骇瞩。闾阎扑地，钟鸣鼎食之家；舸舰弥津，青雀黄龙之舳。云销雨霁，彩彻区明。落霞与孤鹜齐飞，秋水共长天一色。渔舟唱晚，响穷彭蠡之滨，雁阵惊寒，声断衡阳之浦。

遥襟甫畅，逸兴遄飞。爽籁发而清风生，纤歌凝而白云遏。睢园绿竹，气凌彭泽之樽；邺水朱华，光照临川之笔。四美具，二难并。穷睇眄于中天，极娱游于暇日。天高地迥，觉宇宙之无穷；兴尽悲来，识盈虚之有数。望长安于日下，目吴会于云间。地势极而南溟深，天柱高而北辰远。关山难越，谁悲失路之人；萍水相逢，尽是他乡之客。怀帝阍而不见，奉宣室以何年？

嗟乎！时运不齐，命途多舛。冯唐易老，李广难封。屈贾谊于长沙，非无圣主；窜梁鸿于海曲，岂乏明时？所赖君子见机，达人知命。老当益壮，宁移白首之心？穷且益坚，不坠青云之志。酌贪泉而觉爽，处涸辙以犹欢。北海虽赊，扶摇可接；东隅已逝，桑榆非晚。孟尝高洁，空余报国之情；阮籍猖狂，岂效穷途之哭！

勃，三尺微命，一介书生。无路请缨，等终军之弱冠；有怀投笔，慕宗悫之长风。舍簪笏于百龄，奉晨昏于万里。非谢家之宝树，接孟氏之芳邻。他日趋庭，叨陪鲤对；今兹捧袂，喜托龙门。杨意不逢，抚凌云而自惜；钟期既遇，奏流水以何惭？

呜呼！胜地不常，盛筵难再；兰亭已矣，梓泽丘墟。临别赠言，幸承恩于伟饯；登高作赋，是所望于群公。敢竭鄙怀，恭疏短引；一言均赋，四韵俱成。请洒潘江，各倾陆海云尔。

#align(center)[
  滕王高阁临江渚，佩玉鸣鸾罢歌舞。\
  画栋朝飞南浦云，珠帘暮卷西山雨。\
  闲云潭影日悠悠，物换星移几度秋。\
  阁中帝子今何在？槛外长江空自流。\
]



// appendix by freezing last-slide-number
#show: appendix

== 附注

#slide[
  - 本模板基于 Touying 包开发，感谢 Touying 团队的辛勤付出与贡献。
  - 本模板是 Overleaf 模板仓库中 #link("https://www.overleaf.com/latex/templates/swufe-beamer-theme/hysqbvdbpnsm")[swufe-beamer-theme] 的 Typst 版本。模板仓库位于 #link("https://github.com/leichaoL/touying-simpl-swufe")，欢迎关注与贡献。
  - 更多 Typst 入门可以访问 OrangeX4 大佬的 #link("https://github.com/OrangeX4/typst-talk")[并不复杂的 Typst 讲座]。
]

==
#ending-slide("Thanks!")
