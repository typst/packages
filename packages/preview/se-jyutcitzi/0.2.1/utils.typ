// Define the jyutping initials, finals and the tone set
#let jp-tones = "[1-6]"
#let jp-initials = "(ng|gw|kw|[bpmfdtnlgkhzcsjw])"
#let jp-finals = "((aa|oe|eo|yu|[aeiou])(ng|[iumnptk])?)"

// Case A: Syllablic nasals (m or ng)
#let re-nasal = regex("\b(m|ng)" + jp-tones + "?\b")
// Case B: Other cases
#let re-other = regex("\b" + jp-initials + "?" + jp-finals + "?" + jp-tones + "?\b")

/// Split jyutping into beginning & ending
#let split-jyutping(jyutping) = (jp-initials, jp-finals, jp-tones).map(re => jyutping.find(regex(re)))
