#import "utils.typ": sanitize
#import "converters/branner.typ": convert-branner
#import "converters/praat.typ": convert-praat
#import "converters/sil.typ": convert-sil
#import "converters/xsampa.typ": convert-xsampa

#let branner(text, reverse: false) = convert-branner(
  sanitize(text),
  reverse: reverse,
)

#let praat(text, reverse: false) = convert-praat(
  sanitize(text),
  reverse: reverse,
)

#let sil(text, reverse: false) = convert-sil(
  sanitize(text),
  reverse: reverse,
)

#let xsampa(text, reverse: false) = convert-xsampa(
  sanitize(text),
  reverse: reverse,
)

