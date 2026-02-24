# Changelog

### Version 0.4.1

- Fixes error in `#powerset` function (#8).

### Version 0.4.0

:warning: Version 0.4.0 is a major rewrite of finite to make it compatible with Typst 0.12 and CeTZ 0.3.0. This includes some minor breaking changes, mostly in how layouts work, but overall functionality should be the same. 

### Version 0.3.2

- Fixed an issue with final states not being recognized properly (#5)

### Version 0.3.1

- Added styling options for initial states:
	- `stroke` sets a stroke for the marking.
	- `scale` scales the marking by a factor.
- Updated manual.

### Version 0.3.0

- Bumped `tools4typst` to v0.3.2.
- Introducing automaton specs as a data structure.
- Changes to `automaton` command:
	- Changed `label-format` argument to `state-format` and `input-format`.
	- `layout` can now take a dictionary with (`state`: `coordinate`)  pairs to position states.
- Added `#powerset` command, to transform a NFA into a DFA.
- Added `#add-trap` command, to complete a partial DFA.
- Added `#accepts` command, to test a word against an NFA or DFA.
- Added `transpose-table` and `get-inputs` utilities.
- Added "Start" label to the mark for initial states.
	- Added option to modify the mark label for initial states.
- Added anchor option for loops, to position the loop at one of the eight default anchors.
- Changed `curve` option to be the height of the arc of the transition.
	- This makes styling more consistent over longer distances.
- Added `rest` key to custom layouts.

### Version 0.2.0

- Bumped CeTZ to v0.1.1.

### Version 0.1.0

- Initial release submitted to [typst/packages](https://github.com/typst/packages).
