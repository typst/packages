# [Metro](https://github.com/fenjalien/metro)
The Metro package aims to be a port of the Latex package siunitx. It allows easy typesetting of numbers and units with options. This package is very early in development and many features are missing, so any feature requests or bug reports are welcome!

Metro’s name comes from Metrology, the study scientific study of measurement.

**Bug reports, feature requests, and PRs are welcome!**

## Usage
Requires Typst v0.10.0+.
Use Typst's package manager:
```
#import "@preview/metro:0.2.0": *
```
You can also download the `src` folder and import `lib.typ` and import:
```
#import "src/lib.typ": *
```

See the manual for more detailed information: [manual.pdf](manual.pdf)

## Future Features (in no particular order)

- [ ] Angles
- [ ] Complex numbers
- [ ] Ranges, lists and products
- [ ] table extensions?
- [ ] Number parsing
  - [ ] Uncertainties
  - [x] Exponents
- [ ] Number post-processing 
  - [ ] rounding
  - [x] exponent modes