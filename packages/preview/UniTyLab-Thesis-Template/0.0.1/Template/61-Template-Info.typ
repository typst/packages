// Imports
#import "config.typ": *

= Template Information
Version: #template-info \
Purpose: #template-purpose \
Licence: #template-licence \
Author: #template-owner 

#let font = context text.font
#let font-size = context text.size
#let font-leading = context par.leading
#let lang = context text.lang

Font: #font \
Size: #font-size \
Leading: #font-leading \
Language Settings: #lang 

#link("sadfa")[Typst Universe Package]