# shuxuejuan

> [!NOTE]
> Due to limited bandwidth, the manual and examples are provided in Chinese only and may contain occasional oversights.  
> If you need further assistance while reading the manual, the examples, the source code, or using this package, feel free to reach out via [Issues](https://github.com/VWWVVW/shuxuejuan/issues) or [Discussions](https://github.com/VWWVVW/shuxuejuan/discussions).

`shuxuejuan` (数学卷, meaning "math exam paper" in Chinese) is a simple Typst package that helps construct math exam papers with minimal setup.

## Setup

### As a template

```typ
#import "@preview/shuxuejuan:0.2.0": *
#show: shuxuejuan
```

Then use it like:

```typ
= 选择题

== 下列各说法中正确的是#br[BCD]。#op(
  $emptyset in emptyset$,
  $emptyset subset.eq emptyset$,
  $emptyset in {emptyset}$,
  $emptyset subset.eq {emptyset}$,
)
```

### As a normal package

```typ
#import "@preview/shuxuejuan:0.2.0": *
```

Then use it like:

```typ
#qst(level: 1)[选择题]

#qst[
  下列各说法中正确的是#br[BCD]。#op(
    $emptyset in emptyset$,
    $emptyset subset.eq emptyset$,
    $emptyset in {emptyset}$,
    $emptyset subset.eq {emptyset}$,
  )
]
```

### Settings

```typ
#context env-upd(
  font-size: env-get("font-size") + (medium: 11pt),
  qst-style: COMPOSER.GRID,
  fn-number: sxj-counter-with-acc-to-nums-normal,  // Note: 常用。
  qst-tag-w: (auto, 1em, 1em),
  ans-shown: false,                                // Note: 常用。
  ans-color: color.rgb(238, 0, 0),
  ref-style: 1,
)
```

## Example

![Compiled `example.typ`.](./docs/outputs/example.png)

[Source code to this example](./docs/example.typ).

## Manual (First Page)

![Compiled `manual.typ` (first page only).](./docs/outputs/manual-p1.png)

Complete [source code to this manual](./docs/manual.typ), [pre-compiled pdf](./docs/outputs/manual.pdf?raw=true).

## Update Strategy

To avoid unnecessary version bumps[^1], all updates are promptly pushed to the [origin repository](https://github.com/VWWVVW/shuxuejuan), and synced to [typst/packages](https://github.com/typst/packages/blob/main/packages/preview/shuxuejuan) after they're tested. Small updates, including documentation fixes and code changes that don't affect the output, are typically synced with a multi-week delay.

Therefore, if you want to read the manual, view the examples, or submit a PR... please download the latest code from the origin repository:

```bash
git clone https://github.com/VWWVVW/shuxuejuan.git
```

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

[^1]: See [policy regarding package edits](https://github.com/typst/packages/issues/2671) in typst/packages.