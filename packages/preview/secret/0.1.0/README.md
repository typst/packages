# Secret

This package currently provides a very simple method to safely redact information from redered documents.

NOTE: Information will not be redacted in the source `.typ` files.

The `redact` function replaces text with a rectangle box. The text is not rendered underneath the box, due to the use of the builtin `hide` function.
