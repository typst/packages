# Changelog

## 0.1.0
- add license information
- prepare release for typst package page

## 0.0.2
- added hda themed template
- add new rendered pdf

## 0.0.1

The following section is a states direct changes compared to [forked DHBW
project](https://github.com/roland-KA/clean-dhbw-typst-template.git).

Originally forked from v0.3.1.

### Logo
The logo from [Hochschule Darmstadt - University of Applied Sciences] has been
used. The file has been taken from
[Wikipedia](https://de.m.wikipedia.org/wiki/Datei:Hda_logo.svg) and is similar
to the logo used in
[mbredel/thesis-template](https://github.com/mbredel/thesis-template).

### Font && Font Size

|Description|From (DHBW)|To (HDA)|
|---|---|---|
|`body-font`|`Source Serif 4`|`Palatino`|
|`heading-font`|`Source Serif 3`|`Palatino`|
|---|---|---|
|`h1-size`|`40pt`|`20pt`|
|`h2-size`|`16pt`|`11pt`|
|---|---|---|
|`h1` formatting|`fill: luma(80)`|(disabled)|
|chapter counter font|(not explicitly mentioned)|`New Computer Modern Math`|
|---|---|---|
|`page-grid`|`16pt`|`13.6pt`|
|link color|`show link: set text(fill: blue.darken(40%))`|disabled!|


### Margin

|Description|From (DHBW)|To (HDA)|
|---|---|---|
|`top`|`4cm`|`2.5cm`|
|`bottom`|`3cm`|`3cm`|
|`left`|`4cm`|`3cm + 5mm // left margin + BCOR`|
|`right`|`3cm`|`2.5cm`|
|`paper`|(not stated)|`a4`|

### Misc
- `h1` formatting: various margin and size adjustment|various margin and size
  adjustment in [81568b](https://github.com/stefan-ctrl/clean-hda-typst-template/commit/81568b3cbfb99ded764c61644215d265ce204c38)

