/// Define the jyutping initials, finals and the tone set
#let jp-tones = "([1-6])"
#let jp-initials = "(ng|gw|kw|[bpmfdtnlgkhzcsjw])"
#let jp-finals = "((aa|oe|eo|yu|[aeiou])(ng|[iumnptk])?|m|ng)"
// Regex for a jyutping
#let regex-jyutping = regex("\b" + jp-initials + "?" + jp-finals + jp-tones + "?\b")

/// Split jyutping into beginning & ending
#let split-jyutping(jyutping) = {
  (0, 1, 4).map(n => jyutping.match(regex-jyutping).captures.at(n))
}
