# (https://github.com/Tetragramm/flying-circus-typst-template/releases/tag/v3.3.0)
## Added
Updating for Typst version 0.13.1
Updating for new Cetz version
Added parameter to the template that facilitates single-plane, single-sheet books.  `body-only` hides the cover, title page, and table of contents.
## Removed
---
## Changed
Fixed some new bugs from the new compiler version.  Cetz was doing something odd.
Automatic font switching between Wingdings and Material Icons for the propeller synchronization symbol.

## Migration Guide from v3.2.1
N/A
---

# (https://github.com/Tetragramm/flying-circus-typst-template/releases/tag/v3.2.1)
## Added
Updating for Typst version 0.13.0
## Removed
---
## Changed
Tightened up some of the appearance to closer match the original book.
## Migration Guide from v3.2.0
Change all instances of `read('blah.json')` to `json('blah.json')`
The method of decoding json from a file has simplified. Now the methods always accept a dictionary, instead of a mix of string and dictionary.
---

# (https://github.com/Tetragramm/flying-circus-typst-template/releases/tag/v3.2.0)
## Added
Functions available:
- FCPlaybook
- FCShortNPC
- FCShortAirship

Updating for Typst version 0.12.0
## Removed
---
## Changed
N/A
## Migration Guide from v3.0.0
N/A
---

# (https://github.com/Tetragramm/flying-circus-typst-template/releases/tag/v3.0.0)
## Added
Functions available:
- FlyingCircus (The document style)
- FCPlane
- FCVehicleSimple
- FCVehicleFancy
- FCShip
- FCWeapon
- HiddenHeader
- KochFont
## Removed
---
## Changed
N/A
## Migration Guide from v0.1.X
N/A
---

# [v3.0.0](https://github.com/Tetragramm/flying-circus-typst-template/releases/tag/v3.0.0)
Initial Release is compatible with the latex v3.0.0, so versioning will start there.