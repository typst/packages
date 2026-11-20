# coworkingview

Look up median flexible-office prices from a bundled snapshot of the [CoworkingView Price Index](https://coworkingview.com/en/tools/price-index).

Typst does not fetch the network. `data/price-index.json` is that snapshot, captured `2026-10-27T21:06:48.313Z`. The rows are the open tables behind the index: three published cities (Abu Dhabi, Berlin, Madrid) and the unpublished fixture city `example-town`, which has no prices. Every amount is copied from that capture.

The code in this directory is MIT. The Price Index figures are [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). `attribution()` returns the credit string from the capture. Keep it with any figure you republish. The snapshot has no photos, logos, or workspace descriptions.

Requires Typst 0.13.0 or newer.

## Usage

```typ
#import "@preview/coworkingview:0.1.0": *

#let berlin = rate("berlin", "flex_desk")
Flex desk in Berlin: #int(berlin.median) #berlin.currency/#berlin.unit,
sample #int(berlin.sample_size).

#attribution()
```

```typ
#import "@preview/coworkingview:0.1.0": rates-table

#rates-table(city: "berlin")
```

`rate` returns `none` when the snapshot has no such row. `rates-table` prints the attribution line under the table, including when the filter matches nothing.

## Functions

`rate(city, product)` returns one rates row, or `none`. `city` is a slug (`berlin`) or a display name (`Abu Dhabi`). Comparison ignores case and treats spaces, hyphens and underscores as the same separator. `product` is `flex_desk`, `fix_desk`, `private_office`, `day_pass` or `meeting_room`. `flex desk` matches `flex_desk`.

The row fields are `city_slug`, `city_name`, `country_code`, `currency`, `product`, `unit`, `median`, `p25`, `p75`, `sample_size`, `property_count`, `operator_count`, `low_confidence` and `as_of`. `median` is the published median. `p25` and `p75` are `none` when the index did not publish them. `low_confidence` is the flag from the capture.

`rates-table(city: none, product: none, products: none)` returns a table of matching rows, sorted by city name and then by product (`flex_desk`, `fix_desk`, `private_office`, `day_pass`, `meeting_room`). `products` is an array of product codes. When both `product` and `products` are set, a row must match both. The median column is the amount, currency and unit, for example `214 EUR/month`. An em dash means that percentile was not published. The last column is `yes` when `low_confidence` is true.

`cities()` returns the city rows in recorded order. Fields are `city_slug`, `city_name`, `country_code`, `currency`, `published`, `property_count`, `operator_count`, `entry_median`, `entry_min`, `entry_max`, `p25`, `p75`, `sample_size` and `as_of`. Empty fields are `none`.

`attribution()` returns the credit string unchanged:

> Source: CoworkingView Price Index (https://coworkingview.com/en/tools/price-index), as of October 2026. Licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). Aggregated figures only; no endorsement by CoworkingView or any operator is implied.

The same file stores the scope text that came with the capture:

> This licence covers the CoworkingView Price Index and catalogue data in this dataset: prices and price statistics, space and operator names, and descriptions written by CoworkingView. It does not cover, and this dataset does not contain: photos, logos, reviews or ratings, data obtained from Google, or any other content of coworkingview.com, its API or MCP server, which remain subject to their own terms. Names are included for identification only; no trademark rights in CoworkingView or operator names and marks are licensed.

## Example

[examples/price-index.typ](examples/price-index.typ) sets the full snapshot. [examples/berlin.typ](examples/berlin.typ) is the Berlin lookup. Both import `@preview/coworkingview:0.1.0`.

## Licence

Code: MIT, see [LICENSE](LICENSE).

`data/price-index.json`: CC BY 4.0, credited by `attribution()`.
