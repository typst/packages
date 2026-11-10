
# Changelog

## Version 9.0 – _Initial release of `digidraw`_

- Implemented the function `#wave` which supports the main parts of the WaveDrom syntax.
- Added various customization settings to the `#wave` function to allow cool styling 

## Version 9.1

- Typo fixes

## Version 9.2

- **[Merge-Request](https://codeberg.org/joelvonrotz/typst-digidraw/pulls/1) by _[ALVAROPING1](https://codeberg.org/ALVAROPING1)**<br> Expanded `stroke-tick-lines` to support a function with one parameter indicating the tick number. As a return value, either a dictionary (containing the stroke parameters) or a stroke is expected. This allows for styling tick lines at odd or even tick numbers

- Inspired by ALVAROPING1's feature, the tick line system has been expanded to also allow function based visibilty and stroke style reseting for specific lines 

- fixed some symbol transitions (transition from `z` symbol to `p`,`P`,`n`,`N`,`l`,`L`,`h`,`H`)

- added one new example to show of the new features

- updated manual to be on par with package version 0.9.2
