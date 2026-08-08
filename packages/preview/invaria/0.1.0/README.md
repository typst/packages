# Invaria

This is a Typst package for providing (physical) constants. It is derived from the following sources:

- Fundamental Physical Constants of [NIST](http://physics.nist.gov/constants) (2022 CODATA recommended values)[^1]
  - [PDF](https://physics.nist.gov/cuu/pdf/all.pdf)
  - [Text](https://physics.nist.gov/cuu/Constants/Table/allascii.txt)


## Usage

The constants are grouped into categories just like in the NIST CODATA database. Some variables can occur in multiple of those categories, just use the one that fits you best.

Each constant is a [typst dictionary](https://typst.app/docs/reference/foundations/dictionary/) and its variable name is the normalized quantity name. The dictionary contains the various information of the constant e.g.
```typst
#let electron_mass = (
  val: 9.1093837139e-31,
  uncert: 2.8e-40,
  unit: "kg",
  symbol: "$m_{\rm e}$",
  quantity: "electron mass",
)
```

Currently, the following information is included:

| Key      | Description | Additional information |
|----------|-------------|------------------------|
| `val`    | The constant value |  |
| `uncert` | The constants uncertainty<br>(in the unit of the value) | `none` if exact |
| `unit`   | The unit of the constant | See [issue #3](https://github.com/q-wertz/invaria/issues/3) |
| `symbol` | The symbol as the constant is usually written | Currently LaTeX code, see [issue #10](https://github.com/q-wertz/invaria/issues/10) |
| `quantity` | The name of the constant |  |

**Sidenote:**\
There is also a `.yaml` file containing all the constants.

### Importing Constants

There are various ways to use the imports:
- Usage by full identifier
  ```
  #import "@preview/invaria:0.1.0"

  #invaria.codata2022.defined_constants.speed_of_light_in_vacuum
  ```
  This could be useful in case you want to compare the same constant from different datasources.
- Youc can only load the CODATA2022 constants
  ```typst
  #import "@preview/invaria:0.1.0": codata2022

  #codata2022.defined_constants.speed_of_light_in_vacuum
  ```
  Useful if you are using a lot of constants but want to stay in the same data source.
- Only load a single category
  ```typst
  #import "@preview/invaria:0.1.0": codata2022.defined_constants

  #defined_constants.speed_of_light_in_vacuum
  ```
- Only load a single constant
  ```typst
  #import "@preview/invaria:0.1.0": codata2022.defined_constants.speed_of_light_in_vacuum

  #speed_of_light_in_vacuum
  ```

### Using the Constants

You can use the constants for example in calculations
```typst
#import "@preview/invaria:0.1.0": codata2022.defined_constants.speed_of_light_in_vacuum

#let earth-moon-distance = 385000e3

In vacuum light travels with a velocity of #speed_of_light_in_vacuum.val meters per second.
That means, that it takes light #{ calc.round(earth-moon-distance / speed_of_light_in_vacuum.val, digits: 2) } to get from the moon to earth.
```


## Development

The idea of this library is to use a python script to extracts the information from various data sources, combine it, structure it and output the typst files.

You can use e.g. `pipx` or `uv` to run the `extract_tool.py`:
- `uv`:
  ```shell
  uv run tools/invaria_extract_tool.py
  ```
- `pipx`:
  ```shell
  pipx run tools/invaria_extract_tool.py
  ```

The tool uses the NIST ALLASCII table as basis and enriches it with information scraped from the NIST CODATA website.


### Planned Features

- [ ] Integration with typst packages, providing supports for typesetting numbers and units
    - [ ] [unify](https://typst.app/universe/package/unify)
    - [ ] [zero](https://typst.app/universe/package/zero)

## References
[^1]: Eite Tiesinga, Peter J. Mohr, David B. Newell, and Barry N. Taylor (2024), "The 2022 CODATA Recommended Values of the Fundamental Physical Constants" (Web Version 9.0). Database developed by J. Baker, M. Douma, and S. Kotochigova. Available at https://physics.nist.gov/constants, National Institute of Standards and Technology, Gaithersburg, MD 20899.
