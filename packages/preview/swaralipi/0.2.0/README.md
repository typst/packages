# Swaralipi

A Typst package for typesetting Indian Classical and Semi-Classical music notations. `Swaralipi` allows you to write music notations and lyrics using regular English letters and renders them into a beautiful rhythmic grid (Taal).

## Features

- **Intuitive Notation**: Uses standard English letters for Swaras (S, R, G, m, P, D, N, r, g, M, d, n).
- **Rhythmic Grid (Taal)**: Automatically generates grids for various Taals with beat numbering and symbols (+, 0, 2, 3, etc.).
- **Bibhag Separation**: Use the vertical bar `|` to separate different bibhags (measures).
- **Lyrics Support**: Easily align lyrics with musical notes.
- **Ornaments**: Supports Meend (slurs), Kan (grace notes), and octave markers.
- **Customizable**: Options for wrapping, matra numbering, and more.

## Installation

Import the package into your Typst file:

```typst
#import "@preview/swaralipi:0.2.0"
```

## Notation System

### Swaras
- **Suddha (Natural)**: `S`, `R`, `G`, `m`, `P`, `D`, `N` (Note: `m` is Suddha Ma)
- **Komal (Flat)**: `r`, `g`, `d`, `n`
- **Tivra (Sharp)**: `M` (Tivra Ma)
- **Rest/Long Note**: `-`

### Octaves
- **Lower Octave**: Add a dot `.` after the note (e.g., `S.`, `N..`).
- **Higher Octave**: Add a single quote `'` after the note (e.g., `S'`, `G''`).

### Ornaments
- **Meend (Slur)**: Wrap notes in parentheses: `(S R G)`
- **Kan (Grace Note)**: Wrap grace notes in curly braces before the main note: `{R}G`
- **Offset Marker**: Use the `>` prefix at the start of a bibhag to start notation from the next beat (prefills empty beats).
- **Stroke Notation (#S)**: Use the `#S` prefix for a line to specify instrument strokes (e.g., `da`, `ra`, `dir`). These align with the beats just like lyrics and are translated into the target script.
- **Horizontal Separator**: Use three or more hyphens `---` on a line by itself to create a horizontal rule (separator) between rhythmic rows.
- **Lists**: Lines starting with `+` are automatically numbered sequentially. Lines starting with `-` are rendered with bullet points (`•`).
- **Phrase Markers**: Use `,` (comma) or `;` (semicolon) at the end of a note to mark the end of a musical phrase, such as in a *Tehai* (e.g., `GM P,G MP, GM`).

You can use the `apply-swaralipi` function to automatically render all `note` raw blocks.

```typst
#import "@preview/swaralipi:0.2.0": apply-swaralipi
#show: apply-swaralipi
```

## Examples

### Yaman Vilambit (Tintal)
````typst
```note[taal: tintal]
                      |                           |           >   GG  | R    SS    N.D.D.    NR
G      G    G    RR   | G     MM    P      MM | G    R    S       |
                      |                           |           >   RR  | S    N.N.  G.        P.
D.     N.   S    RR   | G     MM    P      M   | G    R    S       |
```
````

### Yaman Taan
````typst
```note[taal: tintal]
D.N.SR  N.SRG   SRGM    RGMP   | GMPD   MPDN   PDNS'   DNS'R'| G'R'S'N  R'S'ND  S'NDP  NDPM | DPMG  RS,GG  R-,SS  N.-,R-
```
````

### Song with Lyrics (Ektal)
````typst
```note[taal: ektal3, wrapped: false]
   G  -  G  | G  Gm -R | GD   P -  | - M  P | {S}N. - - | -S -R -G | RSN. -S -  | - S  S
#L এ  -  ম |  নি  হা  র |  আ  মা  - | য় না  হি  |  সা  - - | -  -  - |  জে   -   - | - এ  রে
-------
   N.RS. - R| R  R  -  | R  R - | - R RG|  SR -SRG G| G  G  -  | G -  -     | - -  -
#L প  র তে |  গে  লে   - |  লা   গে   - | - এ   রে |  ছ   র   তে    | গে  লে  - |  বা  জে   -  | - -  -
---
```
````

## Supported Taals

Many popular Taals are included out of the box:
- `dadra`: 6 beats rhythmic cycle with 3/3 divisions.
- `rupak`: 7 beats rhythmic cycle with 3/2/2 divisions.
- `tivra`: 7 beats rhythmic cycle with 3/2/2 divisions.
- `kaharba`: 8 beats rhythmic cycle with 4/4 divisions.
- `jhaptal`: 10 beats rhythmic cycle with 2/3/2/3 divisions.
- `sultal`: 10 beats rhythmic cycle with 2/2/2/2/2 divisions.
- `ektal`: 12 beats rhythmic cycle with 2/2/2/2/2/2 divisions.
- `ektal3`: Rabindrik ektal 12 beats rhythmic cycle with 3/3/3/3 divisions.
- `chautal`: 12 beats rhythmic cycle with 2/2/2/2/2/2 divisions (often used for Dhrupad).
- `dipchandi`: 14 beats rhythmic cycle with 3/4/3/4 divisions.
- `dhamar`: 14 beats rhythmic cycle with 5/2/3/4 divisions.
- `adachautal`: 14 beats rhythmic cycle with 2/2/2/2/2/2/2 divisions.
- `tintal`: 16 beats rhythmic cycle with 4/4/4/4 divisions.

## Options

Options can be passed in brackets after the `note` tag:

- `taal`: Specify the taal name (e.g., `[taal: tintal]`). Defaults to `none` (renders as a standard notes block without a grid).
- `matra`: Control the appearance of the beat/matra underlining:
  - `show`: Only show the underline for multi-pitch beats (default).
  - `hide`: Hide all beat underlines.
  - `always`: Show the underline for every beat, including single-pitch ones.
- `wrapped`: Set to `true` (default) or `false` to enable or disable automatic line wrapping for long compositions.
- `lang`: Specify the musical notation script and system:
  - `en`: Standard English notation (default).
  - `bn`: Bengali script notation.
  - `hi`: Hindi/Devnagari script notation.
  - `bn_a`: Akarmatrik notation style in Bengali script.
- `taal-separator`: Control how vertical lines for bibhag separation are displayed:
  - `none`: No vertical lines are displayed at all for bibhag separation.
  - `between`: Only vertical lines between bibhags are shown; outer-most boundary lines are hidden (default).
  - `all`: All vertical lines, including the left and right-most boundaries, are displayed.
- `taal-header`: Control the appearance of rhythmic markers at the top of the grid. Combine multiple values using the `+` sign (e.g., `matra+bol`):
  - `none`: Do not show matra, bol, or bibhag markers at all, including the horizontal line below them.
  - `bibhag`: Show only bibhag markers like Sam (+), Tali (2, 3), and Khali (0) (default).
  - `bol`: Show the rhythmic syllables/bols (Dha, Dhin, etc.) extracted from the taal definition.
  - `matra`: Show only matra/beat markers (1, 2, 3, etc.).
  - `all`: A shorthand to show all markers together (`bibhag+bol+matra`).

---

Happy Composing! 🎵
