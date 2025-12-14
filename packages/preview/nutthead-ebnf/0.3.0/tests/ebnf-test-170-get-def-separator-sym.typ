#import "../ebnf.typ" : *

== Test: `_get-def-separator-sym`

=== Test 1 `_get-def-separator-sym()`

#context _get-def-separator-sym()

=== Test 2 `_get-def-separator-sym()`

1. `_update-config("sym-separator", "/")`

#context _update-config("sym-separator", "/")

2. `_get-def-separator-sym()`

#context _get-def-separator-sym()