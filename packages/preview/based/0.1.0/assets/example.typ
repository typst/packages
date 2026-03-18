#import "../src/lib.typ": base64, base32, base16

#set text(size: 14pt)
#set page(
  width: auto,
  height: auto,
  margin: 1em,
  background: box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
  ),
)

#table(
  columns: 3,

  raw(base64.encode("Hello world!")),
  raw(base32.encode("Hello world!")),
  raw(base16.encode("Hello world!")),

  str(base64.decode("SGVsbG8gd29ybGQh")),
  str(base32.decode("JBSWY3DPEB3W64TMMQQQ====")),
  str(base16.decode("48656C6C6F20776F726C6421"))
)
