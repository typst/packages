[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FTypsium%2Ftypsium%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://github.com/Typsium/typsium)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Typsium/typsium/blob/main/LICENSE)
![User Manual](https://img.shields.io/badge/manual-.pdf-purple)

# Typst Chemical Formula Package

A Typst package for typesetting chemical formulas, currently working on inorganic.

- Typeset chemical formulas with ease
- Reactions and equations, including reversible reactions
- Support for complex reaction conditions (e.g. temperature (T=), pressure (P=), etc.)

## Usage

To use Typsium, you need to include the package in your document:

```typst
#import "@preview/typsium:0.2.0": ce
#ce("[Cu(H2O)4]^(2+) + 4NH3 -> [Cu(NH3)4]^(2+) + 4H2O")
```

![result](https://raw.githubusercontent.com/Typsium/typsium/main/tests/README-graphic1/ref/1.png)
