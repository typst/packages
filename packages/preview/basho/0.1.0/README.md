# Basho — Vertical Japanese Typesetting for Typst

![Banner of Basho](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/example/banner.svg)

Basho (芭蕉) is a vertical Japanese typesetting (tategaki / 縦書き) package for Typst. It handles character boxes, tate-chu-yoko (TCY), ruby (furigana), automatic pagination, multi-column RTL layout, and kinsoku shori (Japanese line-breaking rules).

## Usage

### Minimal example

```typst
#import "@preview/basho:0.1.0": tate

#set text(font: "Harano Aji Mincho")
#set page(paper: "jp-business-card")

#show: tate

閑さや

　岩にしみ入る

　　蝉の声
```

![Minimal example](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/example/minimal.svg)

### Full example

An extended example with various features is available [here](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/example/Japanese-vertical.pdf). An example of Japanese novel typeset is available [here](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/example/Japanese-novel.pdf).

### Inline macros

| Macro | Description |
|---|---|
| `#tcy[body]` | Tate-chu-yoko — short horizontal text or content in a vertical column |
| `#vert[body]` | Force upright (one char or content per box, no rotation) |
| `#ruby(body, rt)` | Furigana annotation (accepts any content) |
| `#turn[body]` | Rotate content 90° clockwise |
| `#vblock[body]` | Rotated block (unrestricted width) |
| `#hblock[body]` | Horizontal block (no rotation) |

### Inline rendering

`#tate-inline(body, config)` renders content as a vertical stack without pagination — useful inside `#hblock[...]` or other upright contexts.

## Customization

Basho accepts a `config` dictionary on `#tate()` to tweak layout and rendering:

```typst
#tate(config: (
  layout: (columns: 2, paragraph-indent: 1.5em),
  sizing: (char-box: 1.2em),
))[...]
```

See [docs/configuration.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/configuration.md) for the full options reference and [docs/extending.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/extending.md) for custom modules.

### Feature peek

![Vertical layout with ruby annotations and multi-column](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/example/features-peek-1.svg)

<details>

<summary>Show code</summary>

```typst
#import "@preview/basho:0.1.0": hblock, ruby, tate, vblock
#set text(font: "Harano Aji Mincho")
#set page(width: 450pt,height: 350pt)


#tate(config: (layout: (columns: 2)))[
  = ポラーノの広場

  そのころわたくしは、モリーオ市の博物局に勤めて居りました。
  　十八等官でしたから役所のなかでも、ずうっと下の方でしたし#ruby("俸給", "ほうきゅう")もほんのわずかでしたが、受持ちが標本の採集や整理で生れ付き好きなことでしたから、わたくしは毎日ずいぶん愉快にはたらきました。殊にそのころ、モリーオ市では競馬場を植物園に#ruby("拵", "こしら")え直すというのでその景色のいいまわりにアカシヤを植え込んだ広い地面が、切符売場や信号所の建物のついたまま、わたくしどもの役所の方へまわって来たものですから、わたくしはすぐ宿直という名前で月賦で買った小さな蓄音器と二十枚ばかりのレコードをもって、その番小屋にひとり住むことになりました。わたくしはそこの馬を置く場所に板で小さなしきいをつけて一疋の山羊を飼いました。毎
]
```

</details>

![Math equations and tables](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/example/features-peek-2.svg)

<details>

<summary>Show code</summary>

```typst
#import "@preview/basho:0.1.0": hblock, ruby, tate, vblock
#set text(font: "Harano Aji Mincho")
#set page(width: 450pt,height: 350pt)

#tate[
  == Fourier変換
  次によって定義されるFourier変換
  $
    integral_(-oo)^(oo) f(x) e^(-2 pi i k x) d x, quad "where" x, k in R
  $
  は位置空間$x$から波数空間$k$への変換である。

  == 形容詞の活用表
  #hblock(table(
    columns: 2,
    tate[ク活用], [],
    tate[から], tate[未然形],
    tate[かり], tate[連用形],
    tate[◯], tate[終止形],
    tate[かる], tate[連体形],
    tate[かれ], tate[命令形],
  ))

  == 短冊
  #rect(
    fill: rgb(255, 240, 240),
    tate(
      [奥山に 紅葉踏みわけ 鳴く鹿の

        声きく時ぞ 秋は悲しき],
    ),
  )
]
```

</details>

---

## Architecture

Basho renders vertical text through a 5-stage pipeline built on a **Dependency Injection** architecture — every component (rendering transforms, TCY classification, kinsoku rules, list modules) is pluggable via a single `config` dictionary.

```mermaid
flowchart LR
    Input["Input content"] --> Flatten["1. Flatten"]
    Flatten --> Transform["2. Transform"]
    Transform --> Classify["3. Classify"]
    Classify --> Paginate["4. Paginate"]
    Paginate --> Render["5. Render"]
    Render --> Output["Output"]
```

## Learn more

| Document | Topics |
|---|---|
| [docs/architecture.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/architecture.md) | Full pipeline details, token types, node-renderer dispatch table, source map |
| [docs/configuration.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/configuration.md) | `config` deep-merge, full default-opts, factory function reference, override examples |
| [docs/kinsoku.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/kinsoku.md) | JIS X 4051 priority tiers, `default-resolver()` parameters, custom resolve functions |
| [docs/layout-hooks.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/layout-hooks.md) | Custom page layouts via hooks, bullet/numbered list module replacement |
| [docs/token-schema.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/token-schema.md) | All token types, fields, and helper functions |
| [docs/modules.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/modules.md) | Module contracts for TCY, rendering, kinsoku, and list modules |
| [docs/extending.md](https://github.com/KoyaTofu42/typst-basho/blob/0f49f8bbd95b5b2cc62d4393a3bccc25127f7ea3/docs/extending.md) | Step-by-step guide to writing custom modules |

## License

MIT
