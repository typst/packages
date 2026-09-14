References with page number as needed
=====================================

This package, that is inspired by the [varioref](https://ctan.org/pkg/varioref)
LaTeX package, provides a couple of functions for cross-referencing, including
the page number when needed (that is, when the referenced content is not on the
same page).

Note that this is only usable with page numbering enabled!

Main functions
--------------

`vref(<label>)`:

* on the same page → “figure 1”;
* on a different page → “figure 1 page 1”;
* also accepts an optional
  [`supplement`](https://typst.app/docs/reference/model/ref/#parameters-supplement)
  for the textual reference.


`vpageref(<label>)` will produce:

* on the same page → nothing at all;
* on a different page → “page 1”;
* also accepts an optional
  [`supplement`](https://typst.app/docs/reference/model/ref/#parameters-supplement).

Additional functions
--------------------

`fullref(<label>)`:

* in all cases → “figure 1 page 1”;
* it is a concise equivalent to `@label #ref(<label>, form: "page")`;
* also accepts an optional
  [`supplement`](https://typst.app/docs/reference/model/ref/#parameters-supplement).

Limitations
===========

Contrary to the varioref LaTeX package, these functions do not produce anything
like “on the preceding page”, just plain page number references, just as
`#ref(<label>, form: "page")` would.

Maybe that could be implemented some day. :-)
