
# Changelog

## Version 9.0 – _Initial release of `digidraw`_

- Implemented the function `#wave` which supports the main parts of the WaveDrom syntax.
- Added various customization settings to the `#wave` function to allow cool styling 

## Version 9.1

- Typo fixes

## Version 9.2

- **[Merge-Request](https://codeberg.org/joelvonrotz/typst-digidraw/pulls/1) by [ALVAROPING1](https://codeberg.org/ALVAROPING1)**<br> Expanded `stroke-tick-lines` to support a function with one parameter indicating the tick number. As a return value, either a dictionary (containing the stroke parameters) or a stroke is expected. This allows for styling tick lines at odd or even tick numbers
- Inspired by ALVAROPING1's feature, the tick line system has been expanded to also allow function based visibilty and stroke style reseting for specific lines 
- fixed some symbol transitions (transition from `z` symbol to `p`,`P`,`n`,`N`,`l`,`L`,`h`,`H`)
- added one new example to show of the new features
- updated manual to be on par with package version 0.9.2

## Version 9.3

### Highlight

- Internal refactoring of the `#wave` function
    - almost all symbols have now an upper part, a lower part and a body. Upper parts are merged together, leading to one long line, which then are decorated with the lower parts. The body is added behind these parts (see buses).

### Added
- Added `edge-overshoot` parameter to `#wave` to allow symbol lines to go over the wave edges (left and right)
- Added `tick-gutter` parameter, that defines the space between the tick numbers and the tick line (including `tick-overshoot`)
- Added `step3` parameter, that controls the end point of the bezier curves (i.e. symbols `"z"` or `"d"`)
- Added `bezier-controlpoint` parameter, that controls the beziers' control point (to make the curve ; might change the name at some point)
- Added `s-spacing`, `s-width` and `s-outside` parameters, that control the shape of the s-symbols of a time delay (symbol `"|"`)
- Added `others` parameter, which allows for additional cetz content to be added on top of the diagram. Using `"coordinates"` debug mode helps with finding the correct coordinates. 


### Changed
- `symbol-width` is now the size reference of the diagram
- Renamed `wave-height` to `symbol-height` and changed allowed value types
- Renamed `stroke-guides` to `guide-stroke` and added support for styling upper and lower guide lines
- Renamed `show-tick-lines` to `show-ticks`
- Renamed `stroke-tick-lines` to `tick-stroke`
- Renamed `inset-1` to `step1`
- Renamed `inset-2` to `step2`
- Split Debugging into four parts: `"labels"`, `"symbols"`, `"steps"` and `"coordinates"` (multiple can be activated)
- Updated docs to reflect the changes

### Removed
- Removed `wave-width` parameter, because I currently don't have an idea how to implement this with the new system. Plus, the user should be smart enough on how to limit the widths of a diagram by changing the wave strings.
- Removed `show-guides` parameter
- Removed `debug-offset` parameter (I might reimplement this at some point)
- Removed `size` parameter, as `symbol-width` represents this parameter
- Removed ability to reset configurations by passing `auto` to the respective parameter