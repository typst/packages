#import "lib.typ": big, Big, bigg, Bigg, paired-delimiter
#set page(height: auto, width: auto, fill: white)

=== `delimitizer`: customize the size of the delimiter

#let parn = paired-delimiter("(", ")")

$
parn(size: bigg,
  parn(size: big, (a+b)times (a-b))
div
  parn(size: big, (c+d)times (c-d))
) + d \ = (a^2-b^2) / (c^2-d^2)+d
$
