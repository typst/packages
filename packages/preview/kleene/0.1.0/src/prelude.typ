// These functions are used so frequently that they need to be accessible without
// prefix, but also they pollute the namespace so we don't want to *-import them
// at the toplevel.
// Instead simply `#import kleene.prelude: *` in a local scope to have access
// to all combinators and rule builders.

#import "operators.typ": label, star, regex, iter, fork, drop, eof, maybe, rewrite, peek, neg, try

#import "builders.typ": pat, yy, nn, rw

