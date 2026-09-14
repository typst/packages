<!--
SPDX-License-Identifier: GPL-3.0-or-later
-->

# testyfy

by [Andreas Hartmann (@hartan)][01]

Assert specific conditions and requirements in [typst][typst].

[01]: https://gitlab.com/hartan


## Table of Contents

<!--toc:start-->
- [testyfy][0]
    - [Table of Contents][a]
    - [Project description][b]
    - [Who this project is for][c]
    - [Project dependencies][d]
    - [Instructions for using testyfy][e]
    - [Documentation][f]
    - [Contributing][g]
    - [Getting help][h]
<!--toc:end-->

[0]: #testyfy
[a]: #table-of-contents
[b]: #project-description
[c]: #who-this-project-is-for
[d]: #project-dependencies
[e]: #instructions-for-using-testyfy
[f]: #documentation
[g]: #contributing
[h]: #getting-help


## Project description

With `testyfy` you can check conditions and assumptions in [typst][typst]-Documents (syn. "assert").
The first unfulfilled condition terminates document compilation with an expressive error message.

Unlike the generic [`assert()`][b0] function in [typst][typst], this package provides many
specialized functions for certain situations. In addition, the functions from this package try to
provide helpful error messages by default, allowing partial customization by callers.

[b0]: https://typst.app/docs/reference/foundations/assert/


## Who this project is for

This project is intended for end users as well as authors of [typst][typst] packages that want to
explicitly check whether user input and/or data from external documents (JSON/YAML/...) satisfies
certain criteria such as data formats.


## Project dependencies

None, all you need is [typst][typst].


## Instructions for using testyfy

Import the package in a [typst][typst] document, like so:

```typst
#import "@preview/testyfy:0.2.0"
```

The available versions (in the example *0.2.0*) can be taken [from the releases][releases]. Now you
can assert conditions:

```typst
#import "@preview/testyfy:0.2.0"

Here's a bit of text.
#testyfy.typeof(5, int) // Validate inputs, ...
And here is, without a gap, even more text.
```

Detailed instructions can be found in the [documentation][f].


## Documentation

**TL;DR**: [Docs for the latest version][f0]

Next to a list of all functions, the documentation also contains a few examples for how to use this
code. The documentation for a specific version of this package is always attached as asset to [the
respective release][releases].

The documentation can be created locally. The following command creates a PDF version of the docs
including references to external sources etc.:

```bash
bin/make pdf
```

The following command shows an overview of all unreleased changes:

```bash
bin/make changelog
```

[f0]: https://gitlab.com/api/v4/projects/72702551/packages/generic/release/0.2.0/docs.pdf


## Contributing

All contributions are welcome, don't hesitate to open merge requests. The contributed code must be
documented and should (ideally) include tests to verify the basic functionality.

All tests live in the `test/` subfolder. The following command runs all the tests:

```bash
./test/run.sh
# Or alternatively
bin/make test
```

If existing source code is changed it's easily possible that many tests start failing (due to e.g.
changed line numbers in panic messages). In this case the reference outputs for tests can be updated
as follows:

```bash
./test/run.sh -u
```

The script `test/add.sh` adds new tests and is used like this:

```bash
/test/add.sh <<"TYPST"
#panic("Amazing test code here")
TYPST
```

It creates the following output:

```bash
test_status='1'
test_stdin='#panic("Amazing test code here")'
test_stdout=''
test_stderr=$'error: panicked with: "Amazing test code here"
  ┌─ stdin.typ:1:1
  │
1 │ #panic("Amazing test code here")
  │  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
```

The output must be written into a file with an ending of `.test`, for example:

```bash
./test/add.sh <<"TYPST" > test/my-amazing.test
...
TYPST
```

If in doubt, both `test/run.sh` and `test/add.sh` explain their functionality when passing `--help`
as argument:

```bash
./test/run.sh --help
./test/add.sh --help
```


## Getting help

Is something not working as expected? Is a function buggy or broken? Do you have wishes and/or
feedback? Please let us know! Open an [issue on GitLab][h0] and tell us what's on your mind.

[h0]: https://gitlab.com/hartang/typst/testyfy/-/issues/new


<!-- Globale Quellen -->
[typst]: https://typst.app/docs/
[releases]: https://gitlab.com/hartang/typst/testyfy/-/releases
