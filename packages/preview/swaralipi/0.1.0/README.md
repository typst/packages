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
#import "@preview/swaralipi:0.1.0"
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

## Usage

You can use the `render_composition` function or set up a show rule for raw blocks to use the `note` language tag.

```typst
#show raw: it => if it.lang == "note" {
  render_composition(it.text, it.lang)
} else { it }
```

## Examples

### Yaman Vilambit (Tintal)
```note[taal: tintal]
                      |                           |           >   GG  | R    SS    N.D.D.    NR
G      G    G    RR   | G     MM    P      MM | G    R    S       |
                      |                           |           >   RR  | S    N.N.  G.        P.
D.     N.   S    RR   | G     MM    P      M   | G    R    S       |
```

### Yaman Taan
```note[taal: tintal]
D.N.SR  N.SRG   SRGM    RGMP   | GMPD   MPDN   PDNS'   DNS'R'| G'R'S'N  R'S'ND  S'NDP  NDPM | DPMG  RS,GG  R-,SS  N.-,R-
```

### Song with Lyrics (Ektal)
```note[taal: ektal3, wrapped: false]
   G  -  G  | G  Gm -R | GD   P -  | - M  P | {S}N. - - | -S -R -G | RSN. -S -  | - S  S
#L এ  -  ম |  নি  হা  র |  আ  মা  - | য় না  হি  |  সা  - - | -  -  - |  জে   -   - | - এ  রে
-------
   N.RS. - R| R  R  -  | R  R - | - R RG|  SR -SRG G| G  G  -  | G -  -     | - -  -
#L প  র তে |  গে  লে   - |  লা   গে   - | - এ   রে |  ছ   র   তে    | গে  লে  - |  বা  জে   -  | - -  -
---
```

## Supported Taals

Many popular Taals are included out of the box:
- `tintal` (16 beats)
- `dadra` (6 beats)
- `ektal`, `ektal3` (12 beats)
- `kaharba` (8 beats)
- `rupak` (7 beats)
- `jhaptal` (10 beats)
- And more: `chautal`, `dipchandi`, `dhamar`, `adachautal`.

## Options

Options can be passed in brackets after the `note` tag:

- `taal`: Specify the taal name (e.g., `[taal: tintal]`).
- `matra`: `true`/`false` to show/hide beat underlining (default: `true`).
- `wrapped`: `true`/`false` to wrap long compositions (default: `true`).

---

Happy Composing! 🎵
