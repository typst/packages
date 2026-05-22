# Basho — Vertical Japanese Typesetting for Typst

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

### Full example

An extended example with various features is available [here](https://github.com/KoyaTofu42/typst-basho/blob/aa1fb00d18bf0c509112f60a80f22f8b1143ceb1/example/japanese-vertical.pdf). An example of Japanese novel typeset is available [here](https://github.com/KoyaTofu42/typst-basho/blob/aa1fb00d18bf0c509112f60a80f22f8b1143ceb1/example/Japanese_novel.pdf).

### Inline macros

| Macro | Description |
|---|---|
| `#tcy[str]` | Tate-chu-yoko — short horizontal text in a vertical column |
| `#vert[str]` | Force upright (one char per box, no rotation) |
| `#ruby(base, rt)` | Furigana annotation |
| `#turn[body]` | Rotate content 90° clockwise |
| `#vblock[body]` | Rotated block (unrestricted width) |
| `#hblock[body]` | Horizontal block (no rotation) |

### Inline rendering

`#tate-inline(body, config)` renders content as a vertical stack without pagination — useful inside `#hblock[...]` or other upright contexts.

---

## Architecture

Basho is built on a **Dependency Injection** architecture. Every component is pluggable via a single `config` dictionary. The rendering pipeline has four layers:

```
Input content
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Flatten   (flatten.typ → parser.typ)              │
│  Recursively walks Typst content tree, produces token array │
└─────────────────────────────────────────────────────────────┘
    │ array of token dicts
    ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Rendering transforms   (config.rendering[].transform) │
│  Normalization, spacing insertion, character rewriting      │
└─────────────────────────────────────────────────────────────┘
    │ modified token array
    ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: TCY filtering   (config.tcy[].filter)             │
│  Classifies auto-detected TCY runs → horizontal / rotated   │
└─────────────────────────────────────────────────────────────┘
    │ classified token array
    ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: Layout   (layout.typ → paginate → render)        │
│  Token measurement → pagination → kinsoku resolution →     │
│  node-renderer dispatch → column assembly → page output     │
└─────────────────────────────────────────────────────────────┘
    │ rendered content
    ▼
Output
```

### Layer-by-layer breakdown

#### Layer 1 — Flatten (`flatten.typ` + `parser.typ`)

Walks the Typst content tree recursively. Native elements (`text`, `strong`, `emph`, `heading`, `list`, `enum`, `equation`, metadata macros) are converted into flat token dictionaries:

```typst
(type: "char", text: "あ", bold: false, italic: false)
(type: "tcy", text: "ABC")
(type: "ruby", text: "漢字", ruby: "かんじ")
(type: "turn", text: content)
(type: "newline", text: "\n")
(type: "spacing", width: 0.25em)
(type: "hanging", text: "。")
```

Consecutive Latin/digit runs are automatically grouped into TCY tokens.

#### Layer 2 — Rendering transforms (`cfg.rendering[].transform`)

Each module in `config.rendering` can export a `transform(tokens) => tokens` function. These are applied in order:

| Module | Purpose |
|---|---|
| `default-rendering-params()` | Normalizes dashes (EM DASH → HORIZONTAL BAR) |
| `default-spacing()` | Inserts gaps between CJK and European text |
| `default-turn` | (no transform — provides node renderer) |
| `default-vblock` | (no transform — provides node renderer) |
| `default-hblock` | (no transform — provides node renderer) |
| `default-bullet-list-params()` | (registered dynamically — provides node renderer) |
| `default-numbered-list-params()` | (registered dynamically — provides node renderer) |

#### Layer 3 — TCY filtering (`cfg.tcy[].filter`)

Each TCY module exports a `filter(tokens, config) => tokens` function. The default module classifies auto-detected TCY runs into:
- **"horizontal"** — kept as TCY (e.g. short numbers like `42`)
- **"rotated"** — converted to `turn` tokens (e.g. `ABC`)
- **"char"** — split into individual upright `char` tokens

#### Layer 4 — Layout & Rendering

**Measurement** — every token is measured inside the layout context using `measure(render-char-token(...))`, producing an array of absolute heights.

**Pagination** (`paginate`) — iterates through tokens, accumulates height. When adding a token would exceed the column height, it calls `config.kinsoku.resolve(...)` to determine the line-breaking action.

**Kinsoku resolution** — see the dedicated section below.

**Node-renderer dispatch** — `renderer.typ` dispatches per token type:

| Token type | Renderer | Box |
|---|---|---|---|
| `char` | `char-box` | 1em × 1em (or reduced height for compression) |
| `tcy` | `render-tcy` | 1em × 1em, horizontal text, font size adapts |
| `hanging` | `render-hanging` | 1em × 0pt (overflows into gutter) |
| `ruby` | `render-ruby` | 1em × auto, ruby in right-side gutter |
| `turn` | `render-turn` | 1em × auto, rotated 90° |
| `vblock` | `render-vblock` | 1em × usable-height, rotated 90° |
| `hblock` | `render-hblock` | 1em × usable-height, horizontal |
| `spacing` | `render-spacing` | 1em × width (gap token) |
| `bullet-list-marker` | inline bullet | 1em × 1em |
| `heading-anchor` | inline heading | 0pt × 0pt (bookmark only) |

Custom node renderers can be injected via any module's `node-renderers` field.

**Column assembly** — columns are arranged right-to-left (RTL) in segments, with multi-page overflow via `colbreak()`.

---

## Config system

The `config` parameter on `#tate()` accepts a nested dictionary. `merge-config` deep-merges it with `default-opts`, so you only need to specify overrides:

```typst
#tate(config: (
  sizing: (char-box: 1.2em),
  layout: (columns: 3, gap: 0.8em),
))[...]
```

### Full default config

```typst
#(
  font: none,
  features: ("vert", "vrt2"),

  sizing: (
    char-box: 1em,
    ruby-size: 0.5em,
    ruby-offset: 1em,
    heading-scales: (1.5, 1.3, 1.15),
  ),

  categories: (
    classify: (text, config) => {
      if text.match(regex("^[0-9]{1,2}$")) != none { return "horizontal" }
      return "rotated"
    },
  ),

  layout: (
    columns: 1,
    gap: 1em,
    column-gap: 2em,
    hooks: (),
  ),

  kinsoku: default-resolver(),

  tcy: (default-tcy(),),

  rendering: (
    default-rendering-params(),
    default-spacing(),
    default-turn,
    default-vblock,
    default-hblock,
  ),

  list: (
    bullet: default-bullet-list-params(),
    numbered: default-numbered-list-params(),
  ),
)
```

---

## Kinsoku Shori (禁則処理)

Kinsoku shori controls how lines break at column boundaries. The default resolver implements four priority tiers matching the JIS X 4051 standard:

| Priority | Rule | Action |
|---|---|---|
| 0 | Unsplittable pairs (`——` `……`) | `push-previous` |
| 1 | Forbidden-start (Gyoto) — hanging | `burasagari` |
| 2 | Forbidden-start — compression (Oikomi) | `oikomi` |
| 3 | Forbidden-start — cascade | `push-previous` |
| — | Forbidden-end (Gyomatsu) | `push-previous` |
| — | Default | `oidashi` |

### Built-in resolver factory

```typst
#import "@preview/basho:0.1.0": tate
#import "@preview/basho:0.1.0/kinsoku.typ": default-resolver

// Defaults
config: (kinsoku: default-resolver())

// Oikomi mode (compression instead of hanging)
config: (kinsoku: default-resolver(mode: "oikomi"))

// Custom character sets
config: (kinsoku: default-resolver(
  hanging: "、。，．！？",
  forbidden-start: "）〕］｝",
))
```

### Parameters

| Parameter | Default | Description |
|---|---|---|
| `forbidden-start` | `）〕］｝〉》」』】)]}〞\u{201d}\u{2019}。、，．・：；ー～ぁぃぅぇぉっゃゅょゎァィゥェォッャュョヮヵヶ！？` | Characters that must not start a column |
| `forbidden-end` | `（〔［｛〈《「『【([{〝\u{201c}\u{2018}` | Characters that must not end a column |
| `hanging` | `、。，．` | Characters that can hang into the gutter |
| `unbreakable-chars` | `—―…‥` | Consecutive pairs of these chars are unsplittable |
| `compressible-punctuation` | `、。，．` | Characters eligible for Oikomi compression |
| `mode` | `"burasagari"` | `"burasagari"` (hang) or `"oikomi"` (compress) |
| `compression-per-punct` | `0.5` | Max compression per punct (× char-box size) |
| `consecutive-compression` | `0.25` | Additional compression for consecutive punct pairs |
| `resolve-fn` | `none` | Custom resolve function override |

### Custom resolve functions

The resolve signature is:

```typst
(col, next-token, next-height, config, cur-height, max-height) => (
  action: "burasagari" | "oikomi" | "push-previous" | "oidashi",
  compression-amount: length,  // only for oikomi
)
```

Standalone helpers are exported from `kinsoku.typ` for building custom resolvers:

```typst
#import "@preview/basho:0.1.0/kinsoku.typ":
  is-forbidden-start, is-forbidden-end, is-hanging,
  is-unbreakable-pair, is-compressible-punctuation,
  calculate-shrinkable-space, apply-spacing-compression,
  is-valid-line-end, default-resolver
```

### Full replacement

```typst
config: (kinsoku: (
  resolve: (col, token, h, config, cur-h, max-h) => {
    if token.type == "char" and token.text == "。" {
      return (action: "oidashi")
    }
    return (action: "push-previous")
  },
))
```

---

## Layout hooks

Override page-level layout by injecting a hook into `config.layout.hooks`:

```typst
config: (
  layout: (hooks: (
    (cols, font, gap, config) => {
      // Custom page layout
    },
  )),
)
```

The last hook wins. When no hook is set, the default layout stacks columns RTL with `align(right + top)`.

## List modules

Built-in list modules are self-contained dictionaries with a `flatten` function and `node-renderers`. Users can replace them entirely:

```typst
config: (
  list: (
    bullet: (marker: "•", flatten: ..., node-renderers: ...),
    numbered: (format: n => "(" + str(n) + ")", ...),
  ),
)
```

## License

MIT
