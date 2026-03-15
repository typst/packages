# Changelog

### Version 0.5.1
- Inputs can now be arbitrary content or have a content label assigned (#1)
- State, transition and input labels are now part of the automaton spec.
- Fixed individual loop styles being overridden by global styles (by @hxjerry)
- Documentation improvements (thanks @CSharperMantle) (#23)
- Fixes loop bug in transitions with `curve: -1` (#17)
- Fixed some bugs in utility functions.
- `#accepts` now rejects all words for automata without a final state and no longer panics.
- Bumped CeTZ to v0.4.2
- New `diagraph` layout which uses the [diagraph-layout](https://typst.app/universe/package/diagraph-layout) package.

### Version 0.5.0

- :warning: New layout system:
	- Layouts are no longer CeTZ groups and are only used as a parameter to `#automaton`.
- :warning: Breaking style changes:
	- Changed label color attribute from `color` to `fill` for consistency.
	- The default for `state.label.fill` and `transition.label.fill` is now `none` and sets the color of the label to `stroke.paint`.
	- The default value for `transition.curve` is now `1.0` for an easier understanding of the influence on the curvature.
- Added `flaci` module to load and display files exported from [FLACI](http://flaci.com):
	- `flaci.load` loads a FLACI file as a `finite` automaton specification.
	- `flaci.automaton` displays a FLACI file as a `finite` automaton.


### Version 0.4.2

- Fixed label rotation for transitions.
- Bumped dependencies:
	- CeTZ 0.3.0 :arrow_upper_right: 0.3.1
	- t4t 0.3.1 :arrow_upper_right: 0.4.0

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
	- `layout` can now take a dictionary with (`state`: `coordinate`) pairs to position states.
- Added `#powerset` command, to transform an NFA into a DFA.
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
