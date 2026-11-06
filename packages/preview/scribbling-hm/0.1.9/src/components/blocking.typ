#import "../translations.typ" as t

#let blocking-notice(
  gender: none,
  thesis-type: none
) = {

  v(1fr)

  t.blocking-notice(thesis-type: thesis-type, gender: gender)

  v(1fr)
}
