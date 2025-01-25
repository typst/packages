#import "@preview/cetz:0.3.1"
#import "@preview/fletcher:0.5.2" as fletcher: node, edge
#import "@preview/touying:0.5.3": *
#import "@preview/touying-dids:0.1.0:": *

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: dids-theme.with(
  // Lang and font configuration
  lang: "zh",
  font: ("Libertinus Serif", "Source Han Sans SC", "Source Han Sans"),

  // Basic information
  config-info(
    title: [AAA],
    subtitle: [BBB],
    author: [Vincent],
    date: datetime.today(),
    institution: [],
  ),

  // Pdfpc configuration
  // typst query --root . ./examples/main.typ --field value --one "<pdfpc-file>" > ./examples/main.pdfpc
  config-common(preamble: pdfpc.config(
    duration-minutes: 30,
    start-time: datetime(hour: 14, minute: 10, second: 0),
    end-time: datetime(hour: 14, minute: 40, second: 0),
    last-minutes: 5,
    note-font-size: 12,
    disable-markdown: false,
    default-transition: (
      type: "push",
      duration-seconds: 2,
      angle: ltr,
      alignment: "vertical",
      direction: "inward",
    ),
  )),
)

#title-slide()

#outline-slide()

= Typst 与 Touying

== Typst 与 Touying

#tblock(title: [Typst])[
  Typst 是一门新的基于标记的排版系统，它强大且易于学习。本演示文稿不详细介绍 Typst 的使用，你可以在 Typst 的#link("https://typst.app/docs")[文档]中找到更多信息。
]

#tblock(title: [Touying])[
  Touying 是为 Typst 开发的幻灯片/演示文稿包。Touying 也类似于 LaTeX 的 Beamer，但是得益于 Typst，你可以拥有更快的渲染速度与更简洁的语法。你可以在 Touying 的#link("https://touying-typ.github.io/touying/zh/docs/intro")[文档]中详细了解 Touying。

  Touying 取自中文里的「投影」，在英文中意为 project。相较而言，LaTeX 中的 beamer 就是德文的投影仪的意思。
]

= Touying 幻灯片动画

== 简单动画

使用 ```typ #pause``` #pause 暂缓显示内容。

#pause

就像这样。

#meanwhile

同时，#pause 我们可以使用 ```typ #meanwhile``` 来 #pause 显示同时其他内容。

#speaker-note[
  使用 ```typ config-common(show-notes-on-second-screen: right)``` 来启用演讲提示，否则将不会显示。
]


== 复杂动画 - Mark-Style

在子幻灯片 #touying-fn-wrapper((self: none) => str(self.subslide)) 中，我们可以：

使用 #uncover("2-")[```typ #uncover``` 函数]（预留空间）

使用 #only("2-")[```typ #only``` 函数]（不预留空间）

#alternatives[多次调用 ```typ #only``` 函数 \u{2717}][使用 ```typ #alternatives``` 函数 #sym.checkmark] 从多个备选项中选择一个。


== 复杂动画 - Callback-Style

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  在子幻灯片 #self.subslide 中，我们可以：

  使用 #uncover("2-")[```typ #uncover``` 函数]（预留空间）

  使用 #only("2-")[```typ #only``` 函数]（不预留空间）

  #alternatives[多次调用 ```typ #only``` 函数 \u{2717}][使用 ```typ #alternatives``` 函数 #sym.checkmark] 从多个备选项中选择一个。
])


== 数学公式动画

在 Touying 数学公式中使用 `pause`:

#touying-equation(`
  f(x)  &= pause x^2 + 2x + 1  \
        &= pause (x + 1)^2  \
`)

#meanwhile

如您所见，#pause 这是 $f(x)$ 的表达式。

#pause

通过因式分解，我们得到了结果。

= 与其他 Typst 包集成

== CeTZ 动画

在 Touying 中集成 CeTZ 动画：

#cetz-canvas({
  import cetz.draw: *

  rect((0,0), (5,5))

  (pause,)

  rect((0,0), (1,1))
  rect((1,1), (2,2))
  rect((2,2), (3,3))

  (pause,)

  line((0,0), (2.5, 2.5), name: "line")
})


== Fletcher 动画

在 Touying 中集成 Fletcher 动画：

#fletcher-diagram(
  node-stroke: .1em,
  node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
  spacing: 4em,
  edge((-1,0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
  node((0,0), `reading`, radius: 2em),
  edge((0,0), (0,0), `read()`, "--|>", bend: 130deg),
  pause,
  edge(`read()`, "-|>"),
  node((1,0), `eof`, radius: 2em),
  pause,
  edge(`close()`, "-|>"),
  node((2,0), `closed`, radius: 2em, extrude: (-2.5, 0)),
  edge((0,0), (2,0), `close()`, "-|>", bend: -40deg),
)

== 其他例子

// #tblock(title: [Pinit, MiTeX, Codly, Ctheorems...])[
//   Touying 社区正在探索与更多 Typst 包的集成，详细情况可查阅#link("https://touying-typ.github.io/zh/docs/category/package-integration/")[文档]。
// ]

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
  阁中帝子今何在？槛外长江空自流。
]

// appendix by freezing last-slide-number
#show: appendix

== 附注

#slide[
  - 您可以使用：
    ```sh
    typst init @preview/touying-dids
    ```
    来创建基于本模板的演示文稿项目。

  - 本模板仓库位于 #link("https://github.com/RaVincentHuang/touying-dids")，欢迎关注与贡献。
]
