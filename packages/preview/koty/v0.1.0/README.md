# koty

`koty` is a tiny [Typst](https://github.com/typst/typst) package that (for now,) does two things:

1. rendering correct particle for a given Korean word
2. formatting an integer number in Korean (12345 -> 1만 2345)

## Usage

```typst
#import "@preview/koty:0.1.0": get-ko-josa, get-ko-number

현재 #get-ko-josa("비트코인", "는") #get-ko-number(177308000)원입니다.

// 현재 비트코인은 1억 7730만 8000원입니다.
```

For more information including every features and full list of particles supported, check out [examples/usage.typ](examples/usage.typ).

## Contributing

Pull requests are welcome. Any feature suggestions are also welcome. For major changes, please open an issue first to discuss what you would like to change.

Please note that koty uses `camelCase` for everything except exported functions and their arguments, which use `kebab-case`.

Please make sure to provide thorough explanations in [examples/usage.typ](examples/usage.typ).

## License

koty is available under the MPLv2 license. See the LICENSE file for more info.
