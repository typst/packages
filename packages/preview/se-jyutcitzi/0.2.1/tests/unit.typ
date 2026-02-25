#import "../utils.typ": split-jyutping

// Test standard cases
#assert(split-jyutping("waa2") == ("w", "aa", "2"))
#assert(split-jyutping("sing1") == ("s", "ing", "1"))

// Test edge cases
#assert(split-jyutping("f") == ("f", none, none))         // Initial only
#assert(split-jyutping("aa") == (none, "aa", none))       // Final only
#assert(split-jyutping("m") == ("m", none, none))         // Syllabic nasal only
#assert(split-jyutping("soeng") == ("s", "oeng", none))   // No tone
#assert(split-jyutping("oi3") == (none, "oi", "3"))       // No initial
#assert(split-jyutping("m5") == ("m", none, "5"))         // No final
