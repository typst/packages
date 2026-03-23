# Pixel Family

[![CI build status](https://github.com/GiggleLiu/pixel-family/actions/workflows/ci.yml/badge.svg)](https://github.com/GiggleLiu/pixel-family/actions/workflows/ci.yml)

Inline pixel art characters for Typst, rendered as native vector graphics. Drop them into running text like emoji.

**[Download the manual (PDF)](https://github.com/GiggleLiu/pixel-family/releases/latest/download/manual.pdf)**

## Meet the Family

<table>
<tr>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/bob.svg" width="64" alt="Bob pixel character"><br><b>Bob</b><br>The Messenger</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/alice.svg" width="64" alt="Alice pixel character"><br><b>Alice</b><br>The Decoder</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/christina.svg" width="64" alt="Christina pixel character"><br><b>Christina</b><br>The Architect</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/mary.svg" width="64" alt="Mary pixel character"><br><b>Mary</b><br>The Auditor</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/eve.svg" width="64" alt="Eve pixel character"><br><b>Eve</b><br>The Eavesdropper</td>
</tr>
<tr>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/frank.svg" width="64" alt="Frank pixel character"><br><b>Frank</b><br>The Forger</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/grace.svg" width="64" alt="Grace pixel character"><br><b>Grace</b><br>The Authority</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/trent.svg" width="64" alt="Trent pixel character"><br><b>Trent</b><br>The Third Party</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/mallory.svg" width="64" alt="Mallory pixel character"><br><b>Mallory</b><br>The Attacker</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/victor.svg" width="64" alt="Victor pixel character"><br><b>Victor</b><br>The Verifier</td>
</tr>
<tr>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/ina.svg" width="64" alt="Ina pixel character"><br><b>Ina</b><br>The Analyst</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/murphy.svg" width="64" alt="Murphy pixel character"><br><b>Murphy</b><br>The Tester</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/bella.svg" width="64" alt="Bella pixel character"><br><b>Bella</b><br>The Herald</td>
</tr>
<tr>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/bolt.svg" width="64" alt="Bolt robot character"><br><b>Bolt</b><br>The Classic Bot</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/pixel-char.svg" width="64" alt="Pixel robot character"><br><b>Pixel</b><br>The Helper Drone</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/crank.svg" width="64" alt="Crank robot character"><br><b>Crank</b><br>The Industrial Bot</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/nova.svg" width="64" alt="Nova robot character"><br><b>Nova</b><br>The Sleek AI</td>
<td align="center"><img src="https://raw.githubusercontent.com/GiggleLiu/pixel-family/main/images/sentinel.svg" width="64" alt="Sentinel robot character"><br><b>Sentinel</b><br>The Guardian</td>
</tr>
</table>

Their names come from the cast of cryptography: Alice and Bob exchange secret messages, Eve eavesdrops, Frank forges signatures, Grace certifies keys, Trent arbitrates, Mallory attacks, and Victor verifies.

**[Vote for your favorite character!](https://github.com/GiggleLiu/pixel-family/discussions/1)**

## Quick Start

```typst
#import "@preview/pixel-family:0.2.0": *

Hello #bob() and #alice() are talking while #eve() listens.
```

Characters default to `1em` and center-align with surrounding text. Pass `size` for explicit sizing:

```typst
#bob(size: 3cm)
```

Use `baseline: 0pt` for bottom alignment:

```typst
#bob(size: 3cm, baseline: 0pt)
```

## Color Customization

Every character accepts `skin`, `hair`, `shirt`, and `pants`:

```typst
#bob(size: 3cm, hair: blue, shirt: red)
#alice(size: 3cm, hair: black, shirt: green)
```

Built-in skin tone presets: `skin-default`, `skin-light`, `skin-medium`, `skin-dark`.

## License

MIT
