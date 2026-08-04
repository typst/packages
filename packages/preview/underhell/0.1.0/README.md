# Typst DND5E 模板

> **本项目说明**:本仓库是 [地狱之下 (UnderHell)](https://github.com/CrossDark/UnderHell) 项目的文档模板子模块,在此同步维护并按需调整。
>
> **出处与版权**:本模板源自 [coljac/typst-dnd5e](https://github.com/coljac/typst-dnd5e)(即 Typst Universe 中的 `dragonling` 包),作者 Colin Jacobs,基于 MIT 协议发布。感谢原作者的工作。

这是一个用于 DND 5E 内容的 [Typst](https://typst.app) 模板,适用于 [DMs Guild](https://www.dmsguild.com) 等场景。

模板名为 `underhell`,已发布至 Typst Universe,可通过 `#import "@preview/underhell:0.1.0": *` 导入。本仓库内_地狱之下_项目自身则通过相对路径引用:`#import "../模板/lib.typ": *`。

**注意**:本包已更新以兼容最新版本的 Typst (0.13),可提交至 Typst Universe。

参见[示例](https://github.com/coljac/typst-dnd5e),基本无需额外说明 —— 其中包含表格、属性方块和 breakout box 的示例,可作为你自己内容的起点。

![由 地狱之下 模板生成的示例冒险页面,展示怪物属性方块、表格和 breakout box](https://github.com/coljac/typst-dnd5e/assets/191407/76bbb6fc-70fb-4766-b40c-37b1a090422b)

## 基本用法

`dndmodule` 模板会为你初始化文档。你可能需要预先指定的参数如下:

- `title`:文档标题,将以文字形式渲染。若封面图已含标题则可省略。
- `subtitle`:封面底部的副标题/标语。
- `author`:你的名字。
- `cover`:用于封面的 `image`。
- `fancy-author`:将作者名放在 D&D 书籍常见的红色火焰装饰中。
- `logo`:提供 `image` 以在首页放置 logo。
- `font-size`:默认 `12pt`。
- `paper`:默认(合理地)为 `a4`(美国用户可改用 `us-letter`)。
- `add-title`:(布尔)是否在首页打印标题。例如若你自制了封面图,可设为 false。
- `bg`:内容页背景。`"default"`(羊皮纸,默认),`none` 为适合打印的白色背景,或传入 `image(...)` 使用自定义背景。
- `lang`:用于 `statbox` 和 `npcbox` 中本地化标签(Armor Class、Description 等)的双字母语言代码。默认为 `"en"`。仓库内置 `"it"`;可参照 `languages/en.toml` 在 `languages/<code>.toml` 添加自己的语言。

之后,几乎所有需求都可用基础 Typst 标记完成。模板还提供以下便捷函数:

`dnd`:按官方风格指南以小型大写字母打印 "Dungeons & Dragons"。

`dndtab(name, columns: (1fr, 4fr), breakable: false, ..contents)`:常规格式的表格。默认 2 列、比例 1:4;若 `breakable` 为 `true`,可跨页拆分。

`breakoutbox(title, contents)`:插入带彩色背景的方框,可选标题以小型大写显示。

`statbox(stats)`:接受如下格式的字典。`skillblock` 和 `traits` 可含任意键。traits 之后,若存在 "Actions"、"Reactions"、"Limited Usage"、"Equipment" 或 "Legendary Actions",将依次显示。

```
#statbox((
  name: "Creature name",
  description: [Size creature, alignment],
  ac: [20 (natural armor)],
  hp: [29 (1d10 + 33)],
  speed: [10ft, climb 10ft.],
  stats: (STR: 13, DEX: 14, CON: 18, INT: 5, WIS: 4, CHA: 7),  // 修正值将自动计算
  skillblock: (
      Skills: [Perception +6, Stealth +5],
      Senses: [passive Perception 13],
      Languages: [Gnomish],
      Challenge: [5 (1800 XP)]
  ),
  traits: (
    ("Trait name", [Trait desription]),
    // ..
    ("Trait name", [Trait desription])
),
  actions: (
    ("Multiattack", [While the monster remains alive, it is a thorn in the party's side.]),
    ("Saliva", [If a character is eaten by the monster, it takes 1d10 saliva damage per round.]),
    ("Tentacle squeeze", [If the monster has captured an enemy, it can squeeze them for 1d12 crushing damage.])
  )
))
```

`npcbox(npc)`:非玩家角色卡片。除 `name` 外所有字段均可选 —— 省略即跳过对应部分。属性使用与 `statbox` 相同的自动修正值表。

```
#npcbox((
  name: "Old Maggie of the Marsh",
  race: [Human],
  class: [Hedge witch],
  alignment: [Chaotic Good],
  stats: (STR: 9, DEX: 11, CON: 10, INT: 15, WIS: 17, CHA: 13),
  description: [A wizened crone with bright, knowing eyes...],
  background: [Born and raised in the marsh village...],
  roleplay: [
    - Speaks in proverbs and riddles.
    - Always offers tea.
  ],
))
```

`spell`:接受如下字典;所有属性均可选:

```
#spell((
  name: "",
  spell-type: [2nd level ...],
  properties: (
    ("Casting time", []),
    ("Range", []),
    ("Duration", []),
    ("Components", []),
  ),
  description: [Spell effects description]
  )
)
```

## 跨页图片与表格

模板内置两个辅助函数 `topfig` 和 `bottomfig`。以下代码:

```typst
#bottomfig(image("swordtorn.png", width=140%))
```

会将图片插入页面底部,横跨两栏,并抑制该页页脚。

![Bottom fig](https://github.com/user-attachments/assets/8ed0d215-245c-49d9-987a-4c8faf3392c7)

## 附录

`appendix` 函数用于在文末生成附录章节,自动将标题编号切换为字母格式(附录 A,子标题 A.1, A.1.1 ...)并重置计数器,避免与正文章节编号冲突。

- `title`:附录总标题,默认 `"附录"`。
- `numbering-fmt`:附录标题编号格式,默认 `"A.1."`。
- `..body`:附录正文内容。

```typst
#appendix[
  == 附录子标题
  附录正文内容...
]

// 也可通过 include 引入独立的附录文件
#appendix[
  #include "附录文件.typ"
]
```

## 致谢

灵感来自 [DND LaTeX module](https://github.com/rpgtex/DND-5e-LaTeX-Template)。

## 贡献者

- [@neuromancer89](https://github.com/neuromancer89) —— `bg` 参数及本地化系统(`lang` 参数、`languages/*.toml`)。
