---
title: ucpc.colors
supports: ["0.1.0"]
---

This is a module that predefines colors mainly used in algorithm competitions. You can use the colors used as difficulty tier colors in [solved.ac](https://solved.ac).

<table
  style="text-align: center; vertical-align: middle;"
>
  <thead>
    <td scope="col">Name</td>
    <td scope="col">V</td>
    <td scope="col">IV</td>
    <td scope="col">III</td>
    <td scope="col">II</td>
    <td scope="col">I</td>
  </thead>
  <tbody>
    <tr>
      <th scope="row">brown / bronze</th>
      <td><img src="https://placehold.co/16x16/9d4900/9d4900" /></td>
      <td><img src="https://placehold.co/16x16/a54f00/a54f00" /></td>
      <td><img src="https://placehold.co/16x16/ad5600/ad5600" /></td>
      <td><img src="https://placehold.co/16x16/b55d0a/b55d0a" /></td>
      <td><img src="https://placehold.co/16x16/c67739/c67739" /></td>
    <tr>
    <tr>
      <th scope="row">bluegray / silver</th>
      <td><img src="https://placehold.co/16x16/38546e/38546e" /></td>
      <td><img src="https://placehold.co/16x16/3d5a74/3d5a74" /></td>
      <td><img src="https://placehold.co/16x16/435f7a/435f7a" /></td>
      <td><img src="https://placehold.co/16x16/496580/496580" /></td>
      <td><img src="https://placehold.co/16x16/4e6a86/4e6a86" /></td>
    </tr>
    <tr>
      <th scope="row">yellow / gold</th>
      <td><img src="https://placehold.co/16x16/d28500/d28500" /></td>
      <td><img src="https://placehold.co/16x16/df8f00/df8f00" /></td>
      <td><img src="https://placehold.co/16x16/ec9a00/ec9a00" /></td>
      <td><img src="https://placehold.co/16x16/f9a518/f9a518" /></td>
      <td><img src="https://placehold.co/16x16/ffb028/ffb028" /></td>
    </tr>
    <tr>
      <th scope="row">cyan / platinum</th>
      <td><img src="https://placehold.co/16x16/00c78b/00c78b" /></td>
      <td><img src="https://placehold.co/16x16/00d497/00d497" /></td>
      <td><img src="https://placehold.co/16x16/27e2a4/27e2a4" /></td>
      <td><img src="https://placehold.co/16x16/3ef0b1/3ef0b1" /></td>
      <td><img src="https://placehold.co/16x16/51fdbd/51fdbd" /></td>
    </tr>
    <tr>
      <th scope="row">skyblue / diamond</th>
      <td><img src="https://placehold.co/16x16/009ee5/009ee5" /></td>
      <td><img src="https://placehold.co/16x16/00a9f0/00a9f0" /></td>
      <td><img src="https://placehold.co/16x16/00b4fc/00b4fc" /></td>
      <td><img src="https://placehold.co/16x16/2bbfff/2bbfff" /></td>
      <td><img src="https://placehold.co/16x16/41caff/41caff" /></td>
    </tr>
    <tr>
      <th scope="row">cherry / ruby</th>
      <td><img src="https://placehold.co/16x16/e0004c/e0004c" /></td>
      <td><img src="https://placehold.co/16x16/ea0053/ea0053" /></td>
      <td><img src="https://placehold.co/16x16/f5005a/f5005a" /></td>
      <td><img src="https://placehold.co/16x16/ff0062/ff0062" /></td>
      <td><img src="https://placehold.co/16x16/ff3071/ff3071" /></td>
    </tr>
    <tr>
      <th scope="row">ghudegy</th>
      <td colspan="5"><img src="https://placehold.co/16x16/8769af/8769af" /></td>
    </tr>
    <tr>
      <th scope="row">unrated</th>
      <td colspan="5"><img src="https://placehold.co/16x16/2d2d2d/2d2d2d" /></td>
    </tr>
  </tbody>
</table>

## General
```typst
color.brown: array<coolor>
color.bluegray: array<coolor>
color.yellow: array<coolor>
color.cyan: array<coolor>
color.skyblue: array<coolor>
color.cherry: array<coolor>
```

Each color pallete of general colors is array contains 5 colors

**example**
```typst
#text(fill: ucpc.color.brown.at(2))[Brown 3rd color]
```

## solved.ac Difficulty Tier Colors
```typst
color.bronze: (I: color, II: color, III: color, IV: color, V: color)
color.silver: (I: color, II: color, III: color, IV: color, V: color)
color.gold: (I: color, II: color, III: color, IV: color, V: color)
color.platinum: (I: color, II: color, III: color, IV: color, V: color)
color.diamond: (I: color, II: color, III: color, IV: color, V: color)
color.ruby: (I: color, II: color, III: color, IV: color, V: color)
```

Each color pallete of solved.ac Difficulty tier Colors have struct like below:

```typst
color.[tier].I: Color of [tier] I
color.[tier].II: Color of [tier] II
color.[tier].III: Color of [tier] III
color.[tier].IV: Color of [tier] IV
color.[tier].IV: Color of [tier] V
```

**example**
```typst
Difficult: #text(fill: ucpc.color.diamond.III)[Challenging]
```

## Misc
```typst
color.misc.ghudegy
color.misc.unrated
```

- `ghudegy` means bug and is an unofficial expression in Baekjun Online Judgement that refers to problems that require ad-hoc series or very unusual ideas. Defined as purple in ucpc-solutions.

- `unrated`: black (not `#000000`)
