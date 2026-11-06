#import "../src/lib.typ": *

= Combinations

== Counting
=== Default (no repetition)
#count-combinations(5, 3)
#count-combinations(5, 5)
#count-combinations(5, 0)

=== With repetition
#count-combinations-with-repetition(5, 3)
#count-combinations-with-repetition(5, 5)
#count-combinations-with-repetition(5, 0)

=== Without repetition
#count-combinations-no-repetition(5, 3)
#count-combinations-no-repetition(5, 5)
#count-combinations-no-repetition(5, 0)

== Indices
=== Default (no repetition)
#get-combinations(5, 3)
#get-combinations(5, 5)
#get-combinations(5, 0)

=== With repetition
#get-combinations-with-repetition(5, 3)
#get-combinations-with-repetition(5, 5)
#get-combinations-with-repetition(5, 0)

=== Without repetition
#get-combinations-no-repetition(5, 3)
#get-combinations-no-repetition(5, 5)
#get-combinations-no-repetition(5, 0)

== Elements
#let my-arr = (10, 20, 30, 40, 50)

=== Default (no repetition)
#get-combinations(my-arr, 3)
#get-combinations(my-arr, 5)
#get-combinations(my-arr, 0)

=== With repetition
#get-combinations-with-repetition(my-arr, 3)
#get-combinations-with-repetition(my-arr, 5)
#get-combinations-with-repetition(my-arr, 0)

=== Without repetition
#get-combinations-no-repetition(my-arr, 3)
#get-combinations-no-repetition(my-arr, 5)
#get-combinations-no-repetition(my-arr, 0)