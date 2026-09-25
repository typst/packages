# cbcp.typ

Typst port of the `cbcp` Rust crate: deterministic BCP 47 locale-ID casting
and vendor code mapping. Downstream repositories vendor this file alongside
its LGPL notices, following the family snapshot practice.

See the [repository README](../README.md) for the rule and the
[vectors](../tests/README.md) for the contract. `typst/tests/test.typ`
holds the assertion suite; compile it to verify.

## License

Copyright 2026 Julian Y. Richard Corbet. Licensed under
LGPL-3.0-only WITH LicenseRef-corbet-linking-exception
(`LICENSES/LGPL-3.0-linking-exception.txt`, byte-identical to the
canonical exception text in the repository). Complete texts ship with
the repository, the npm/crates.io/PyPI distributions and the GitHub
release (<https://github.com/corbet-labs/cbcp/tree/v0.1.0/LICENSES>).
