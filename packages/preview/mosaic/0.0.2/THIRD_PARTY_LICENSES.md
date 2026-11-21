# Third-party licenses

Mosaic is released under the MIT License (see `LICENSE`), with the exception noted below for the bundled Metropolis theme. This file records the third-party work that the published package draws on.

## Metropolis Beamer theme

Mosaic's bundled `metropolis` theme adapts the visual design of the **Metropolis** Beamer theme by Matthias Vogelgesang:

- <https://github.com/matze/mtheme>

Metropolis is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0): <https://creativecommons.org/licenses/by-sa/4.0/>. Attribution is given to Matthias Vogelgesang, and the adaptation is offered under the same CC BY-SA 4.0 license. The original theme sources are not redistributed here.

The files covered by CC BY-SA 4.0 rather than MIT are:

- `src/themes/metropolis.typ`
- `src/themes/metropolis/definition.typ`
- `src/themes/metropolis/layouts.typ`
- `src/themes/metropolis/tokens.typ`

## Touying fitting utilities and frozen-state mechanism

Parts of `src/fit.typ` are adapted from Touying 0.7.4, commit [`a8abe0d`](https://github.com/touying-typ/touying/commit/a8abe0d832024038c4174d9bb8182f202bde1209), including work credited by Touying to Andreas Kröpelin / Polylux PR #91 and ntjess.

The selected counter/state rewind in `src/deck-state.typ` and `src/slide/runtime.typ` was informed by Touying's `_rewind-states` helper and subslide preamble at the same commit. Mosaic uses an explicit opt-in API and a renderer-local pre-slide location rather than Touying's broader configuration.

Touying copyright notice and license:

> Copyright (c) 2026 OrangeX4 <orangex4@qq.com>
> Copyright (c) 2026 zral0kh
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.
