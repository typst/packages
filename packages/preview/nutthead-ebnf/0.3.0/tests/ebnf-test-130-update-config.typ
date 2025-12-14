#import "../ebnf.typ" : *

== Test: `_update-config`

=== `_configuration.get()`

#context repr(_configuration.get())

=== Test: `_update-config("sym-prod", "=")`

1. `_update-config("sym-prod", "=")`

#context _update-config("sym-prod", "=")

2. `_configuration.get()`

#context repr(_configuration.get())