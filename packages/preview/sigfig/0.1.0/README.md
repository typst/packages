# `sigfig`

`sigfig` is a [Typst](https://typst.app/) package for rounding numbers with [significant figures](https://en.wikipedia.org/wiki/Significant_figures) and [measurement uncertainty](https://en.wikipedia.org/wiki/Measurement_uncertainty).

## Overview

```typ
#import "@preview/sigfig:0.1.0": round, urounds
#import "@preview/unify:0.5.0": num

$ #num(round(98654, 3)) $
$ #num(round(2.8977729e-3, 4)) $
$ #num(round(-.0999, 2)) $
$ #num(urounds(114514.19, 1.98)) $
$ #num(urounds(1234.5678, 0.096)) $
```

yields

<img src="https://github.com/typst/packages/assets/20166026/f3d69c3c-bc67-484f-81f9-80a10913fd11" width="240px">

## Documentation

### `round`

`round` is similar to JavaScript's `Number.prototype.toPrecision()` ([ES spec](https://tc39.es/ecma262/multipage/numbers-and-dates.html#sec-number.prototype.toprecision)).

```typ
#assert(round(114514, 3) == "1.15e5")
#assert(round(1, 5) == "1.0000")
#assert(round(12345, 10) == "12345.00000")
#assert(round(.00000002468, 3) == "2.47e-8")
```

Note that what is different from the ES spec is that there will be no sign ($+$) if the exponent after `e` is positive.

### `uround`

`uround` rounds a number with its uncertainty, and returns a string of both.

```typ
#assert(uround(114514, 1919) == "1.15e5+-2e3")
#assert(uround(114514.0, 1.9) == "114514+-2")
```

### `urounds`

`uround` rounds a number with its uncertainty, and returns a string of both with the same exponent, if any.

You can use `num` in `unify` to display the result.

## License

MIT © 2024 OverflowCat ([overflow.cat](https://about.overflow.cat)).
