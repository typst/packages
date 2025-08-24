// #import "../lib.typ": template
#import "@preview/casual-szu-report:0.1.0": template

#show: template.with(
  course-title: [养鸡学习],
  experiment-title: [养鸡],
  faculty: [养鸡学院],
  major: [智能养鸡],
  instructor: [鸡老师],
  reporter: [鸡],
  student-id: [4144010590],
  class: [养鸡99班],
  experiment-date: datetime(year: 1983, month: 9, day: 27),
  features: (
    "Bibliography": "template/refs.bib",
  ),
)

= 实验目的与要求

== First

#lorem(42)

=== Second

此開卷第一回也。作者自云曾歷過一番夢幻之後，故將真事隱去，而借「通靈」說此《石頭記》一書也，故曰「甄士隱」云云。但書中所記何事何人？自己又云：今風塵碌碌，一事無成，忽念及當日所有之女子，一一細考較去，覺其行止見識皆出我之上，我堂堂鬚眉，誠不若彼裙釵。我實愧則有餘，悔又無益，大無可如何之日也！當此日，欲將已往所賴天恩祖德錦衣紈袴之時，飫甘饜肥之日，背父兄教育之恩，負師友規訓之德，以致今日一技無成，半生潦倒之罪，編述一集，以告天下。知我之負罪固多，然閨閣中歷歷有人，萬不可因我之不肖自護己短，一并使其泯滅也。所以蓬牖茅椽，繩床瓦灶，並不足妨我襟懷。況那晨風夕月，階柳庭花，更覺得潤人筆墨。我雖不學無文，又何妨用假語村言敷衍出來，亦可使閨閣昭傳，復可破一時之悶，醒同人之目，不亦宜乎？故曰「賈雨村」云云。更於篇中間用「夢」「幻」等字，卻是此書本旨，兼寓提醒閱者之意。

= 实验内容

Transformer is all you need. @vaswani2023attentionneed

#lorem(42)

= 实验仪器

+ 1
+ 2
+ 3
  + 3.1
    + 3.1.1

#lorem(42)

= 实验原理

#figure(
  image("img/AnimalWell.png", width: 60%),
  caption: [2 Rabbits],
) <AnimalWell>

感盤古開闢，三皇治世，五帝定倫，世界之間，遂分為四大部洲：曰東勝神洲，曰西牛賀洲，曰南贍部洲，曰北俱蘆洲。這部書單表東勝神洲。海外有一國土，名曰傲來國。國近大海，海中有一座名山，喚為花果山。此山乃十洲之祖脈，三島之來龍，自開清濁而立，鴻濛判後而成。真個好山！有詞賦為證。賦曰：

勢鎮汪洋，威寧瑤海。勢鎮汪洋，潮湧銀山魚入穴；威寧瑤海，波翻雪浪蜃離淵。水火方隅高積上，東海之處聳崇巔。丹崖怪石，削壁奇峰。丹崖上，彩鳳雙鳴；削壁前，麒麟獨臥。峰頭時聽錦雞鳴，石窟每觀龍出入。林中有壽鹿仙狐，樹上有靈禽玄鶴。瑤草奇花不謝，青松翠柏長春。仙桃常結果，修竹每留雲。一條澗壑籐蘿密，四面原堤草色新。正是百川會處擎天柱，萬劫無移大地根。

如@AnimalWell

#figure(
  table(
    columns: (2em, auto, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [],
      [*Area*],
      [*Parameters*],
    ),

    emoji.bagel,
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    emoji.sandwich, $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  ),
  caption: [Some formulas],
) <SomeFormulas>

= 实验步骤

Ciallo～(∠・ω< )⌒☆. 如@SomeFormulas

= 结果记录与分析

#lorem(42)

= 实验结论

#lorem(42)

#quote(
  block: true,
  attribution: [Czesław Miłosz],
)[
  Irony is the glory of slaves.
]
