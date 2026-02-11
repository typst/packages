#import "../utils.typ": split-jyutping

// Test standard cases
#assert(split-jyutping("waa2") == ("w", "aa", "2"))
#assert(split-jyutping("sing1") == ("s", "ing", "1"))

// Test edge cases
#assert(split-jyutping("aa") == (none, "aa", none))       // Final only
#assert(split-jyutping("ng") == (none, "ng", none))       // Syllabic nasal only
#assert(split-jyutping("soeng") == ("s", "oeng", none))   // No tone
#assert(split-jyutping("oi3") == (none, "oi", "3"))       // No initial
