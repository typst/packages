# Reproducible scientific documents from the start
It is encouraged to create scientific documents which are reproducible
on the long-term. In order to facilitate reproducibility in this UGent
template, Guix is used and the appropiate files are situated in this
directory.

If you don't care about long-term (bit-)reproducibility, just remove
this `.guix/` directory and disregard any mention of guix.

## Guix and Typst integration
The integration is not yet ideal.
~~I'm blocked on the fact that Typst is not yet well integrated into guix.
This way, we cannot easily copy `template/.guix` into a fresh project
and make sure it can be used reproducibly with guix. To do this now,
too much boilerplate would be involved
(see https://codeberg.org/th1j5/masterpraktijkproef-eduma for an example
of the end-goal; it involves a lot of boilerplate/duplication).
The next steps are to integrate this boilerplate code into guix proper or
a dedicated channel, then hopefully this template directory can be made
useful.~~
