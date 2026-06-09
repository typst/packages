# asian-power

Force CJK characters to be emphasized.

# Usage

```
#import "@preview/asian-power:0.1.0": *

#show: asian-power
```

# Options

Options can be used like this:

```
#import "@preview/asian-power:0.1.0": *

#show: asian-power.with(
  han: true,
  kana: true,
  hangul: true,
  angle: -12deg,
  letterspace: 0.9em,
)
```

| Option      | Default | Description                                 |
| ----------- | ------- | ------------------------------------------- |
| han         | true    | Forces Han characters to be tilted.         |
| kana        | true    | Forces Kana characters to be tilted.        |
| hangul      | true    | Forces Hangul characters to be tilted.      |
| angle       | -12deg  | Decides amount of tilting.                  |
| letterspace | 0.9em   | Decides width of spaces between characters. |
