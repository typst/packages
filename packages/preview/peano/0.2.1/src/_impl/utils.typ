#let build-option-flags(..args) = {
  let args = args.pos()
  let flags = 0
  let digit = 1
  for b in args {
    if b { flags = flags.bit-or(digit) }
    digit = digit.bit-lshift(1)
  }
  bytes((flags,))
}