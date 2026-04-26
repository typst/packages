# Backtrack

Backtrack is a simple and performant Typst library that determines the current
compiler version and provides an API for comparing, displaying, and observing
versions.

Unlike the built-in [version API][v0-9-0-version-api] which is only available on
Typst 0.9.0+, Backtrack works on any[*](#version-support) Typst version. It uses
the built-in API when available so that it'll continue to work on all future
Typst versions without modification.

Additionally, it:
- doesn't noticeably impact compilation time. All version checks are extremely
  simple, and newer versions are checked first to avoid overhead from supporting
  old versions.
- is automatically tested on _every_ supported Typst version to ensure
  reliability.
- can be downloaded and installed manually in addition to being available as a
  package.

[v0-9-0-version-api]: https://github.com/typst/typst/pull/2016

## Example

```typ
#import "@preview/backtrack:1.0.0": current-version, versions

You are using Typst #current-version.displayable!
#{
  if current-version.cmpable <= versions.v2023-03-28.cmpable [
    That is ancient.
  ] else if current-version.cmpable < versions.v0-5-0.cmpable [
    That is old.
  ] else [
    That is modern.
  ]
}
```

## Installation

There are two ways to install the library:
- Use the package on Typst 0.6.0+. This is as simple as adding the following
  line to your document:
  ```typ
  #import "@preview/backtrack:1.0.0"
  ```
- Download and install the library manually:
  1. Download and extract the latest [release][releases].
  2. Rename `src/lib.typ` to `src/backtrack.typ`.
  3. Move/copy `COPYING` into `src/`.
  4. Rename the `src/` directory to `backtrack/`.
  5. Move/copy the newly-renamed `backtrack/` directory into your project.
  6. Add the following line to your document:
     ```typ
     #import "[path/to/]backtrack/backtrack.typ"
     ```

[releases]: https://github.com/TheLukeGuy/backtrack/releases

## Documentation

See [DOCS.md](DOCS.md). It's quite short. 😀

## Version Support

Backtrack compiles on and can detect these versions:

| Version              | Status | Notes                                   |
| -------------------- | :----: | --------------------------------------- |
| 0.6.0+               |   ✅    | Also available as a package             |
| March 28, 2023–0.5.0 |   ✅    |                                         |
| March 21, 2023       |   ✅    | Initial public/standalone Typst release |
| February 25, 2023    |   🟡    | Detects as February 15, 2023            |
| February 12–15, 2023 |   ✅    |                                         |
| February 2, 2023     |   🟡    | Detects as January 30, 2023             |
| January 30, 2023     |   ✅    |                                         |

The partially-supported versions _may_ be possible to detect, but they're tricky
since most of their changes are content-related. Content values were opaque up
until the March 21, 2023 release, making it difficult to automatically check for
the presence of these changes.

## Copying

Copyright © 2023 [Luke Chambers][github-profile]

Backtrack is licensed under the Apache License, Version 2.0. You can find a copy
of the license in [COPYING](COPYING) or online at
<https://www.apache.org/licenses/LICENSE-2.0>.

[github-profile]: https://github.com/TheLukeGuy
