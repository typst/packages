#import "../lib.typ": *

#let code="= Hello,World!
== I love typst
+ fast
+ easy
+ beautiful"

#getExample(code)
#getExample(code,merge_handler: mergeRow)
#getExample(code,merge_handler: mergeColumn)
#getExample(code,merge_handler: coloredMerge)
