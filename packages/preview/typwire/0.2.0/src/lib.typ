// `typst.toml`'s `entrypoint` pins this filename, so the real
// implementation lives in `typwire.typ` instead and this file just
// re-exports it.
#import "typwire.typ": call, cbor, debug, decode, encode, json
