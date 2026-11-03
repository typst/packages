// Typst 0.15.1: prefill SBD 001001 and exam code 0101 on the 12-4-6 sheet.
#let ma-de = "0101"
#state("sbd").update("1001")
#state("made").update(ma-de)
#include "12-4-6ngang.typ"
