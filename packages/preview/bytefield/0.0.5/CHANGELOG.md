# Changelog

## [0.0.5] - (Unreleased)

### Added
- Option to style the header with a background color (`fill`) and stroke (`stroke`).
- Option to specify the row heights of the bytefield with a `row` argument.

## [0.0.4] - (2024-02-18)

This release is a complete refactor of the bytefield package.

Huge thanks to [nopeslide](https://github.com/nopeslide) for his many ideas through out this process and the annotation feature.

⚠️ Warning: This release breaks some stuff:

- The `bitheader` argument was dropped. The header is now defined with the new `bitheader()` function.
- The `flagtext` helper function was removed.


### Added

Just a short list of some new features which have been added.

- `note` and `group` field to add annotations on the left and right of the bytefield.
- First draft of the new `bitheader` api.
- Multirow and breaking fields look much nicer now.
- ... see [example.typ](example.typ) for what is possible now.

### Changed

Functions are now grouped and separated into multiple files.

**`bytefield.typ`**

Contains now only the entry points to the package and exposes the user facing api and a collection of common network protocols

**`lib/api.typ`**

Contains the user facing api.

**`lib/gen.typ`**

Holds all functions for the new generation pipeline system. 
As of now the this contains.
- generation of meta data which is necessary for further processing.
- finalization of bf-fields, like indexing and additional information.
- generation of bf-cells from the bf-fields
- generation of the final outcome by mapping bf-cells to tablex cells 

**`lib/types.typ`**

Contains all type definitions and creator functions.

The following types are defined: `bf-field`, `data-field`, `note-field`, `header-field`, `bf-cell`, `header-cell`

**`lib/states.typ`**

Contains states which are used for global config with `bf-config`

- Added state for defining the `row_height` of the table
- Added state for defining the `header-font-size`

**`lib/asserts.typ`**

Contains some assertion functions

**`lib/utils.typ`**

Contains some utility functions 


## [0.0.3] - 2023-11-20

- Added "smart" bit headers thanks to [hgruniaux](https://github.com/hgruniaux)
  - Added "smart-firstline" to only consider the first row for calculation.
- Added option to pass an `int` as bitheader, which shows all multiples of this number.
- Added experimental "text_header" support by passing a `dictionary` to bitheader.
- Fixed bitheader number alignment on edge cases. (This could be improved and extended in a future version.)



## [0.0.2]

- Added support for reversed bitheader order with `msb_first:true`.
- Quick way to show all headerbits with `bitheader: "all"`.
- Updated `flagtext` center alignment.


## [0.0.1]

Initial Release

- Added `bytefield`, as main function to create an new bytefield diagram. 
- Added `bit`, `bits`, `byte`, `bytes`, `padding`, as high level API for adding fields to a bytefield. 
- Added `flagtext` as a utility function to create rotate text for short flag descriptions.
- Added `ipv4`, `ipv6`, `icmp`, `icmpv6`, `dns`, `tcp`, `udp` as predefined diagrams.
