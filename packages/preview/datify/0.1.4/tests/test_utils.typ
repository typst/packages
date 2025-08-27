// To compile this file : typst compile --root .. .\test_utils.typ

#import "../src/utils.typ": first-letter-to-upper, pad, safe-slice

#assert(first-letter-to-upper("hello") == "Hello")
#assert(first-letter-to-upper("world") == "World")
#assert(first-letter-to-upper("שלום") == "שלום")
#assert(first-letter-to-upper("שָׁלוֹם") == "שָׁלוֹם")
#assert(pad(5, 2) == "05")
#assert(pad(123, 5) == "00123")
#assert(safe-slice("Août", 3) == "Aoû")
