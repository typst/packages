# Gru

[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](./LICENSE)

A despicable [Typst](https://typst.app/) template.

## Usage

To use this template, first import it:

```typ
#import "@preview/gru:0.1.0": gru
```

Then use a `show` rule:

```typ
#show: gru.with(last-content: [content for last pages])
```

The `last-content` parameter is optional. If you provide content, it will show up on the last two pages.

Put your main content after the `show` rule.

For an example, check out [`sample/lorem.pdf`](./sample/lorem.pdf).

## License

This is [MIT-licensed](./LICENSE).
