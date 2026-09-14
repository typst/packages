

// Typst ACL style - https://github.com/coli-saar/tracl
// by Alexander Koller <koller@coli.uni-saarland.de>

// ** Remember to update the version history in README.md too **
// 
// 2026-01-11 v0.8.0 - better presentation of authors; bump pergamon to 0.7.0; many bugfixes and improvements
// 2025-12-10 v0.7.1 - bumped pergamon dependency to 0.6.0
// 2025-11-01 v0.7.0 - default font now TeX Gyre Termes; use Pergamon for references; compatible with Typst 0.14
// 2025-03-28 v0.6.0 - improved lists and line numbers
// 2025-03-28 v0.5.2 - bumped blinky dependency to 0.2.0
// 2025-03-02 v0.5.1 - fixed font names so as not to overwrite existing Typst symbols
// 2025-02-28 v0.5.0 - adapted to Typst 0.13, released to Typst Universe
// 2025-02-18 v0.4, many small changes and cleanup, and switch to Nimbus fonts
// v0.3.2, ensure page numbers are printed only in anonymous version
// v0.3.1, fixed "locate" deprecation
// v0.3, adjusted some formatting to the ACL style rules
// v0.2, adapted to Typst 0.12
// 
// 
#import "src/tracl-pergamon.typ": print-acl-bibliography
#import "src/tracl-titlebox.typ": make-authors, title-footnote, affil-ref, affiliation
#import "src/tracl.typ": tracl-serif, tracl-sans, tracl-mono, email, darkblue, abstract, appendix, acl
