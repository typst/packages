# Slashion

You might not like the inline fraction displayed in a vertical layout. Just use **Slashion** to convert it to a slash fraction.

```typ
#import "@preview/slashion:0.1.1": slash-frac
#show math.equation.where(block: false): slash-frac
```

You may also use it solely

```typ
#import "@preview/slashion:0.1.1": slash-frac as sfrac
$sfrac(1/2)$, $sfrac(3, 4)$ or even $sfrac((5 + 6) / 7 + 8)$ are acceptable.
```

## Notice

1. This function converts only the outermoest fraction.
2. This function has an option to turn off the auto parenthesizing feature: `slash-frac.with(parens: false)`
