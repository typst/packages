// Public API. Import the package as a module and reach everything through it:
//
//   #import "@preview/ucph-lehmann-thesis:0.1.0" as ul
//   #show: ul.thesis.with(..)
//   ul.colors.red, ul.logos.seal, ul.logo("logo-da", width: 5cm)

#import "thesis.typ": thesis, appendix, default-font, default-heading-font, normal-page
#import "frontpage.typ": ucph-header
#import "logos.typ": logo, logos, variants as logo-variants
#import "utils.typ": count-characters
#import "colors.typ" as colors
