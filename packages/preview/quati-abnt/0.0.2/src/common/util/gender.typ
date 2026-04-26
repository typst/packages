// # Gender. Gênero.

#let get_gender_ending(
  gender,
  masculine_ends_with_vowel: true,
  plural: false,
) = {
  if gender == "masculine" {
    if masculine_ends_with_vowel {
      "o"
    } else {
      if plural {
        "e"
      }
    }
  } else if gender == "feminine" {
    "a"
  }
  if plural {
    "s"
  }
}
