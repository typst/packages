# name-it

Get the English names of integers.

## Example

![Example](./example.png)

```typ
#import "@preview/name-it:0.1.0": name-it

#set page(width: auto, height: auto, margin: 1cm)

- #name-it(-5)
- #name-it(-5, negative-prefix: "minus")
- #name-it(0)
- #name-it(1)
- #name-it(10)
- #name-it(11)
- #name-it(42)
- #name-it(100)
- #name-it(110)
- #name-it(1104)
- #name-it(11040)
- #name-it(11000)
- #name-it(110000)
- #name-it(1100004)
- #name-it(10000000000006)
- #name-it(10000000000006, show-and: false)
- #name-it("200000000000000000000000007")
```

## Usage

### `name-it`

Convert the given number into its English word representation.

```typ
#let name-it(num, show-and: true, negative-prefix: "negative") = { .. }
```

**Arguments:**

- `num`: [`int`],[`str`] &mdash; The number to name.
- `show-and`: [`bool`] &mdash; Whether an “and” should be used in certain
  places. For example, “one hundred ten” vs “one hundred and ten”.
- `negative-prefix`: [`str`] &mdash; The prefix to use for negative numbers.

[`str`]: https://typst.app/docs/reference/foundations/str/
[`int`]: https://typst.app/docs/reference/foundations/int/
[`bool`]: https://typst.app/docs/reference/foundations/bool/
