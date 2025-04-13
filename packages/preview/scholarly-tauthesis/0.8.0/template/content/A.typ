/** A.typ
 *
 * This is an example appendix chapter in a multi-file typst project.
 *
***/

#import "../preamble.typ": *
#import "@preview/scholarly-tauthesis:0.8.0" as tauthesis

= Example attachment <example-attachment>

The point of attachments is to allow an author of a scientific work to attach
research-related objects, that would interrupt the natural flow of the main
matter or deviate from its main points, to the work. For example, large tables,
long derivations of mathematical formulae or detailed implementations of
algorithms in a specific programming language are better placed in the
attachments.

In the main matter, it is better to present algorithmic descriptions in
pseudo-code, as this allows the presentation to omit details related to the
specific programming language being used, which makes the description more
portable. In the case of mathematical theorems, the main matter presentation
should contain at least the pre- and post-conditions of the theorem, but unless
its proof is a main point of the work, it is better to put it into the
attachments, and tell the reader which attachment it can be found from via a
cross-reference.
