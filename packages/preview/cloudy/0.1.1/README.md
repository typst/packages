<!--
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: (C) 2025 Andreas Hartmann <hartan@7x.de>

Upstream-Project: <https://gitlab.com/tgdp/templates>
Configured-For-Version: 1.4.0
-->

# Cloudy

A word cloud generator for [`typst`][typst].

By [Andreas Hartmann (@hartan)][0]

![A word cloud with a colorful selection of differently-sized words and icons][1]{width=100%}

[0]: https://gitlab.com/hartan
[1]: ./assets/demo.svg


## Table of contents

1. [Project description][a]
1. [Who this project is for][b]
1. [Project dependencies][c]
1. [Usage][f]
1. [Additional documentation][g]
1. [Troubleshooting][h]
1. [Contributing][i]
1. [Getting help][j]
1. [License and Copying][k]

[a]: #project-description
[b]: #who-this-project-is-for
[c]: #project-dependencies
[f]: #usage
[g]: #additional-documentation
[h]: #troubleshooting
[i]: #contributing
[j]: #getting-help
[k]: #license-and-copying


## Project description

With cloudy you can generate so-called word clouds, a kind of visualization that arranges words or
any other kind of element in a cloud-like pattern. Word clouds are commonly used to visualize the
frequency of words in texts, but this package will happily arrange anything you give it.


## Who this project is for

This project is targeted at document authors looking for a playful way to display big quantities of
words or similar elements. It is especially suited in situations where the elements to be displayed
can be weighed (i.e. varied in size) meaningfully.


## Project dependencies

All you need to use this project is an installation of [`typst`][typst].


## Usage

Import the package into your document like this:

```typst
#import "@preview/cloudy:0.1.1"
```

Now you can create clouds of whatever content you like:

```typst
#set page(width: 3cm, height: 3cm)
#cloudy.cloud((
    box(inset: 2pt, stroke: red, text(size: 16pt, "Hello")),
    box(inset: 4pt, stroke: green, text(size: 12pt, "Typst")),
    box(inset: 3pt, stroke: blue, text(size: 10pt, "Community!")),
))
```

And the result looks like this:

![A word cloud saying "Hello Typst Community!" in colored boxes with shuffled order][f0]

[f0]: assets/usage.png


## Additional documentation

**TL;DR**: [Docs for the latest version][g0]

Next to a list of all functions, the documentation also contains a few examples for how to use this
code. The documentation for a specific version of this package is always attached as asset to [the
respective release][g1].

The documentation can be created locally provided you have set up the development environment for
this project (refer to the [Contributing section][i]). The following command creates a PDF version
of the docs including references to external sources etc.:

```bash
bin/make pdf
```

More (verified working) examples can be found [in the examples directory][g2].

[g0]: https://gitlab.com/hartang/typst/cloudy/-/releases/0.1.1/downloads/docs.pdf
[g1]: https://gitlab.com/hartang/typst/cloudy/-/releases
[g2]: ./examples/


## Troubleshooting

*There's nothing here yet, please let us know if the project gave you trouble!*


## Contributing

We accept various contributions (including bug reports, bug fixes, feature suggestions, ...). Please
refer to [the CONTRIBUTING guide][i0] for additional information.

[i0]: ./CONTRIBUTING.md


## Getting help

If you need help, take a look at [our issue tracker][issue_tracker]. If you feel your particular
problem isn't handled there, [please open an issue][open_an_issue] and let us know.


## License and Copying

Copyright (C)  2025 Andreas Hartmann

This program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License in [the license file][d0] along
with this program. If not, see <https://www.gnu.org/licenses/>.

[d0]: ./COPYING


[typst]: https://typst.app
<!-- Project-specific sources -->
[open_an_issue]: https://gitlab.com/hartang/typst/cloudy/-/issues/new?type=ISSUE
[issue_tracker]: https://gitlab.com/hartang/typst/cloudy/-/issues?state=all
