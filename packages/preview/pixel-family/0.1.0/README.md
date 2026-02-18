# Pixel Family

[![CI](https://github.com/GiggleLiu/pixel-family/actions/workflows/ci.yml/badge.svg)](https://github.com/GiggleLiu/pixel-family/actions/workflows/ci.yml)

Inline pixel art characters for Typst, drawn as vector graphics with [CeTZ](https://github.com/cetz-package/cetz). Drop them into running text like emoji.

**[Download the manual (PDF)](https://github.com/GiggleLiu/pixel-family/releases/latest/download/manual.pdf)**

## Meet the Family

<table>
<tr>
<td align="center"><img src="images/bob.svg" width="64"><br><b>Bob</b><br>The Messenger</td>
<td align="center"><img src="images/alice.svg" width="64"><br><b>Alice</b><br>The Decoder</td>
<td align="center"><img src="images/christina.svg" width="64"><br><b>Christina</b><br>The Architect</td>
<td align="center"><img src="images/mary.svg" width="64"><br><b>Mary</b><br>The Auditor</td>
<td align="center"><img src="images/eve.svg" width="64"><br><b>Eve</b><br>The Eavesdropper</td>
</tr>
<tr>
<td align="center"><img src="images/frank.svg" width="64"><br><b>Frank</b><br>The Forger</td>
<td align="center"><img src="images/grace.svg" width="64"><br><b>Grace</b><br>The Authority</td>
<td align="center"><img src="images/trent.svg" width="64"><br><b>Trent</b><br>The Third Party</td>
<td align="center"><img src="images/mallory.svg" width="64"><br><b>Mallory</b><br>The Attacker</td>
<td align="center"><img src="images/victor.svg" width="64"><br><b>Victor</b><br>The Verifier</td>
</tr>
<tr>
<td align="center"><img src="images/ina.svg" width="64"><br><b>Ina</b><br>The Analyst</td>
<td align="center"><img src="images/murphy.svg" width="64"><br><b>Murphy</b><br>The Tester</td>
<td align="center"><img src="images/bella.svg" width="64"><br><b>Bella</b><br>The Herald</td>
<td></td>
<td></td>
</tr>
</table>

Their names come from the cast of cryptography: Alice and Bob exchange secret messages, Eve eavesdrops, Frank forges signatures, Grace certifies keys, Trent arbitrates, Mallory attacks, and Victor verifies.

## Quick Start

```typst
#import "@preview/pixel-family:0.1.0": *

Hello #bob() and #alice() are talking while #eve() listens.
```

Characters default to `1em` and scale with surrounding text. Pass `size` for explicit sizing:

```typst
#bob(size: 3cm)
```

## Color Customization

Every character accepts `skin`, `hair`, `shirt`, and `pants`:

```typst
#bob(size: 3cm, hair: blue, shirt: red)
#alice(size: 3cm, hair: black, shirt: green)
```

Built-in skin tone presets: `skin-default`, `skin-light`, `skin-medium`, `skin-dark`.

## Build

```bash
make          # compile manual + render SVGs
make manual   # compile manual.pdf only
make images   # render character SVGs only
make clean    # remove generated files
```

## License

MIT
