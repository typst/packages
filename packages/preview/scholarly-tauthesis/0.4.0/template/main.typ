/*** main.typ
 *
 * The main document to be compiled. Run
 *
 *   typst compile main.typ
 *
 * to perform the compilation. If you are writing a multi-file
 * project, this file is where you need to include your content
 * files.
 *
***/

//// Initialize document type.

#import "@preview/scholarly-tauthesis:0.4.0" as tauthesis
#import "meta.typ"

#show: doc => tauthesis.tauthesis(
	fignumberwithinlevel : 1,
	eqnumberwithinlevel : 1,
	doc
)

//// Include your chapters here.
//
// Your text can be written entirely in this file, or split into
// multiple subfiles. If you do, you will need to import the
// preamble separately to those files, if you wish to use the
// commands.
//

#include("content/01.typ")
#include("content/02.typ")
#include("content/03.typ")
#include("content/04.typ")

#show: tauthesis.bibsettings

#bibliography(style: meta.citationstyle, "bibliography.bib")

//// Place appendix-related chapters here.

#show: doc => tauthesis.appendix(
	fignumberwithinlevel : 1,
	eqnumberwithinlevel : 1,
	doc
)

#include "content/A.typ"
