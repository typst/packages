// 全量单页入口 → URL /(站点首页)。
// 本示例演示"内容/ 目录树 = 网页 URL":相对 内容/ 的路径即 URL 段。
//   内容/index.typ         → /
//   内容/世界纲要.typ       → /世界纲要/
//   内容/生物/index.typ     → /生物/          (目录页:目录名即 URL 段)
//   内容/生物/怪动植物.typ   → /生物/怪动植物/
// 页面集合由构建脚本扫 内容/**/*.typ 得到(空文件也算一页);配置.typ 的 导航
// 只配导航卡片,不定义 URL。独立页由 页面.typ 编译(见其头部注释)。
// / Full single-page entry → URL /. The 内容/ tree defines the site URLs.
#import "配置.typ": *

#show: 网页模板

// 站内导航卡片(仅网页):顶层页入口,PDF 不渲染。
// / In-site nav cards (web only).
#if is_web() [
  #html.elem("nav", attrs: (class: "uh-navcards",))[
    #for (路径, 名) in 导航.filter(p => not p.at(0).contains("/")) [
      #html.elem("a", attrs: (class: "uh-navcard", href: "/" + 路径 + "/"))[#名]
    ]
  ]
]

== Element-system demo

Elements are named by their 普通-system term (e.g. 怪动植物). #元素("怪动植物") = 怪动植物 (formal). Switch to the "别名" system for the alias:

#设置元素系统("别名")
Alias system: #元素("怪动植物"), #元素("怪动物")

#设置元素系统("academic")
Academic: #元素("超级系统") (怪动植物 missing there, falls back to 普通: #元素("怪动植物"))

#设置元素系统("普通")
Back to 普通: #元素("怪动植物")

#outline(title: "Table of Contents\n")
#colbreak()
#heading(outlined: false, level: 1)[Credits]

*Designer* Personface McHumanhead

*Template* UnderHell

#lorem(25)
#pagebreak()

#place(
  top + center,
  float: true,
  scope: "parent",
  clearance: 2em,
)[
= A headline that grabs your attention
]

== Adventure awaits!

#品牌#super("TM") is a fictional world building game.
#lorem(180) OK!

== A location

#lorem(233)

== A hook

#lorem(233)

=== This person

#lorem(45)

=== That person

#lorem(85)

#表格("Random occurences", [*d10*], [*Result*], [1], [A tingling in the extremities], [2-8], [Nothing interesting occurs], [10], [All the PCs burst into flame])

#lorem(150)

// 需要图片时:把图片放进本项目,再按相对路径引用(相对引用该字符串的文件所在目录):
// #顶部图(image("内容/图.png", width: 140%))   // 页面顶部大图,横跨两栏,抑制该页页脚
// #底部图(image("内容/图.png", width: 140%))   // 页面底部大图

= More things!

#lorem(204)

#提示框("Look here!")[#lorem(44)]

#lorem(390)

#提示框("Something to note")[#lorem(133)]
#lorem(300)

#lorem(400)
#属性框((
  name: "Monster",
  description: [Large monstrosity, neutral evil],
  ac: [20 (natural armor)],
  hp: [29 (1d10 + 33)],
  speed: [10ft, climb 10ft.],
  stats: (STR: 13, DEX: 14, CON: 18, INT: 5, WIS: 4, CHA: 7),
  skillblock: (
      Skills: [Perception +6, Stealth +5],
      Senses: [darkvision 60ft, passive Perception 13],
      Languages: [-],
      Challenge: [5 (1800 XP)]
  ),
  traits: (
    ("Scary Appearance", [While the monster is being ferocious, enemies are at -2 to all WIS saving throws.]),
    ("Reaching Tentacles", [The monster has six slimy tentacles. Each tentacle
    can be attacked (AC 20; 10 hit points; immune to psychic damage). Destroying a tentacle makes the monster angry.])
),
  Actions: (
    ("Multiattack", [While the monster remains alive, it is a thorn in the party's side.]),
    ("Saliva", [If a character is eaten by the monster, it takes 1d10 saliva damage per round.]),
    ("Tentacle squeeze", [If the monster has captured an enemy, it can squeeze them for 1d12 crushing damage.])
  )
))

== A monster

#lorem(200)

= Notable NPCs

#人物框((
  name: "Old Maggie of the Marsh",
  race: [Human],
  class: [Hedge witch],
  alignment: [Chaotic Good],
  stats: (STR: 9, DEX: 11, CON: 10, INT: 15, WIS: 17, CHA: 13),
  description: [A wizened crone with bright, knowing eyes and hands stained green from years of brewing. She wears a patched shawl and rarely steps outside without her crooked walking stick.],
  background: [Born and raised in the marsh village, Maggie has been the local wise-woman for as long as anyone can remember. Some say she once turned a tax collector into a frog; she neither confirms nor denies it.],
  roleplay: [
    - Speaks in proverbs and riddles ("A still pond hides the deepest fish.")
    - Always offers tea, and is mildly offended if it's refused.
    - Knows everyone's secrets, but only trades them for favours.
  ],
))

#人物框((
  name: "Captain Bren Holloway",
  race: [Half-elf],
  class: [Veteran],
  description: [A weather-beaten soldier with a missing left ear and a crooked smile. Wears a faded militia tabard over well-kept chain.],
  roleplay: [
    - Punctuates every sentence with "right then".
    - Trusts the party only after they've bought him a drink.
  ],
))

= Spells

#法术((
  name: "Dancing Legs",
  spell-type: [2nd level evocation],
  properties: (
    ("Casting time", [Special]),
    ("Range", [Self]),
    ("Duration", [Until long rest]),
    ("Components", [V, S]),
  ),
  description: [Your legs start dancing, and you dance compulsively, and in an experimental fashion. #lorem(20)]
  )
)

#法术((
  name: "Clapping Hands",
  spell-type: [2nd level evocation],
  properties: (
    ("Casting time", [Special]),
    ("Range", [Self]),
    ("Duration", [Until long rest]),
    ("Components", [V, S]),
  ),
  description: [Your legs start dancing, and you dance compulsively, and in an experimental fashion. #lorem(20)]
  )
)
