#let p = plugin("./lure.wasm")

/// Normalize an URL.
///
/// If necessary, `input` will be UTF-8 percent-encoded.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.parse")[`Url::parse`]
/// and #link("https://docs.rs/url/latest/url/struct.Url.html#impl-Display-for-Url")[`Display::fmt`] in rust docs.
///
/// = Examples
///
/// #example(`
///   // Unchanged for regular URLs
///   #assert.eq(
///     normalize("https://en.wikipedia.org/w/index.php?title=%25&redirect=no"),
///     "https://en.wikipedia.org/w/index.php?title=%25&redirect=no",
///   )
///
///   // Encoded for non-ASCII URLs
///   #assert.eq(
///     normalize("https://law.go.kr/법령/보건의료기본법/제3조"),
///     "https://law.go.kr/%EB%B2%95%EB%A0%B9/%EB%B3%B4%EA%B1%B4%EC%9D%98%EB%A3%8C%EA%B8%B0%EB%B3%B8%EB%B2%95/%EC%A0%9C3%EC%A1%B0",
///   )
///   #assert.eq(
///     normalize("https://w3c.github.io/clreq/README.zh-Hans.html#讨论"),
///     "https://w3c.github.io/clreq/README.zh-Hans.html#%E8%AE%A8%E8%AE%BA",
///   )
///   #assert.eq(
///     normalize("https://w3c.github.io/clreq/README.zh-Hant.html#討論"),
///     "https://w3c.github.io/clreq/README.zh-Hant.html#%E8%A8%8E%E8%AB%96",
///   )
///   #assert.eq(
///     normalize("https://ja.wikipedia.org/wiki/アルベルト・アインシュタイン"),
///     "https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%AB%E3%83%99%E3%83%AB%E3%83%88%E3%83%BB%E3%82%A2%E3%82%A4%E3%83%B3%E3%82%B7%E3%83%A5%E3%82%BF%E3%82%A4%E3%83%B3",
///   )
/// `)
///
/// = Panics
///
/// If the function can not parse an URL from the given string
/// with this URL as the base URL, a `ParseError` will be thrown.
///
/// - input (str):
/// -> str
#let normalize(input) = str(p.parse_display_fmt(bytes(input)))

/// Parse an URL into a `dict` of components.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#impl-Debug-for-Url")[`Debug::fmt`] and related functions in rust docs.
///
/// = Fields of the returned `dict`
///
/// == `scheme: str`
///
/// The scheme of this URL, lower-cased, as an ASCII string without the ‘:’ delimiter.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.scheme")[`Url::scheme` in rust docs].
///
/// #example(`
///   #assert.eq(
///     parse("file:///tmp/foo").scheme,
///     "file",
///   )
/// `)
///
/// == `cannot-be-a-base: bool`
///
/// Whether this URL is a cannot-be-a-base URL, meaning that parsing a relative URL string with this URL as the base will return an error.
///
/// This is the case if the scheme and `:` delimiter are not followed by a `/` slash, as is typically the case of `data:` and `mailto:` URLs.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.cannot_be_a_base")[`Url::cannot_be_a_base` in rust docs].
///
/// #example(`
///   #assert.eq(parse("ftp://rms@example.com").cannot-be-a-base, false)
///   #assert.eq(parse("unix:/run/foo.socket").cannot-be-a-base, false)
///   #assert.eq(parse("data:text/plain,Stuff").cannot-be-a-base, true)
/// `)
///
/// == `username: str`
///
/// The username for this URL (typically the empty string) as a percent-encoded ASCII string.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.username")[`Url::username` in rust docs].
///
/// #example(`
///   #assert.eq(parse("ftp://rms@example.com").username, "rms");
///   #assert.eq(parse("ftp://:secret123@example.com").username, "");
///   #assert.eq(parse("https://example.com").username, "");
/// `)
///
/// == `password: str | none`
///
/// The password for this URL, if any, as a percent-encoded ASCII string.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.password")[`Url::password` in rust docs].
///
/// #example(`
///   #assert.eq(parse("ftp://rms:secret123@example.com").password, "secret123")
///   #assert.eq(parse("ftp://:secret123@example.com").password, "secret123")
///   #assert.eq(parse("ftp://rms@example.com").password, none)
///   #assert.eq(parse("https://example.com").password, none)
/// `)
///
/// == `host: str | none`
///
/// The string representation of the host (domain or IP address) for this URL, if any.
///
/// Non-ASCII domains are punycode-encoded per IDNA if this is the host of a special URL, or percent encoded for non-special URLs. IPv6 addresses are given between `[` and `]` brackets.
///
/// Cannot-be-a-base URLs (typical of `data:` and `mailto:`) and some `file:` URLs don’t have a host.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.host_str")[`Url::host_str` in rust docs].
///
/// #example(`
///   #assert.eq(parse("https://127.0.0.1/index.html").host, "127.0.0.1")
///   #assert.eq(parse("ftp://rms@example.com").host, "example.com")
///   #assert.eq(parse("unix:/run/foo.socket").host, none)
///   #assert.eq(parse("data:text/plain,Stuff").host, none)
/// `)
///
/// == `port: int | none`
///
/// The port number for this URL, if any.
///
/// Note that default port numbers are never reflected by the serialization. Please use `parse-supplementary("…").port-or-known-default` if you want a default port number returned.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.port")[`Url::port` in rust docs].
///
/// #example(`
///   #assert.eq(parse("https://example.com").port, none)
///   #assert.eq(parse("https://example.com:443/").port, none)
///   #assert.eq(parse("ssh://example.com:22").port, 22)
/// `)
///
/// == `path: str`
///
/// The path for this URL, as a percent-encoded ASCII string. For cannot-be-a-base URLs, this is an arbitrary string that doesn’t start with ‘/’. For other URLs, this starts with a ‘/’ slash and continues with slash-separated path segments.
///
/// Note that this field is a string. Please use the `parse-supplementary("…").path-segments` if you want the path split into segments.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.path")[`Url::path` in rust docs].
///
/// #example(`
///   #assert.eq(
///     parse("https://example.com/api/versions?page=2").path,
///     "/api/versions",
///   )
///   #assert.eq(
///     parse("https://example.com").path,
///     "/",
///   )
///   #assert.eq(
///     parse("https://example.com/countries/việt nam").path,
///     "/countries/vi%E1%BB%87t%20nam",
///   )
/// `)
///
/// == `query: str | none`
///
/// This URL’s query string, if any, as a percent-encoded ASCII string.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.query")[`Url::query` in rust docs].
///
/// Note that this field is a string. Please use the `parse-supplementary("…").query-pairs` if you want the query parsed into (key, value) pairs.
///
/// #example(`
///   #assert.eq(
///     parse("https://example.com/products?page=2").query,
///     "page=2",
///   )
///   #assert.eq(
///     parse("https://example.com/products").query,
///     none,
///   );
///   #assert.eq(
///     parse("https://example.com/?country=español").query,
///     "country=espa%C3%B1ol",
///   )
/// `)
///
/// == `fragment: str | none`
///
/// This URL’s fragment identifier, if any.
///
/// A fragment is the part of the URL after the `#` symbol. The fragment is optional and, if present, contains a fragment identifier that identifies a secondary resource, such as a section heading
/// of a document.
///
/// In HTML, the fragment identifier is usually the id attribute of a an element that is scrolled to on load. Browsers typically will not send the fragment portion of a URL to the server.
///
/// *Note:* the parser did _not_ percent-encode this component, but the input may have been percent-encoded already.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.fragment")[`Url::fragment` in rust docs].
///
/// #example(`
///   #assert.eq(
///     parse("https://example.com/data.csv#row=4").fragment,
///     "row=4",
///   )
///   #assert.eq(
///     parse("https://example.com/data.csv#cell=4,1-6,2").fragment,
///     "cell=4,1-6,2",
///   )
/// `)
///
/// = Panics
///
/// If the function can not parse an URL from the given string
/// with this URL as the base URL, a `ParseError` will be thrown.
///
/// - input (str):
/// -> dict
#let parse(input) = cbor(p.parse_debug_fmt(bytes(input)))

/// Parse an URL and get a `dict` of supplementary information.
///
/// These fields can usually be inferred from the result of `parse`, but are represented in a handier way.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html")[related functions in rust docs].
///
/// = Fields of the returned `dict`
///
/// == `origin: (str, str, int) | none`
///
/// The origin of this URL (https://url.spec.whatwg.org/#origin).
///
/// `(scheme, host, port)` for a tuple origin, and `none` for an opaque origin.
///
/// The origin is determined based on the scheme as follows:
///
/// - If the scheme is “blob” the origin is the origin of the URL contained in the path component. If parsing fails, it is an opaque origin.
///
/// - If the scheme is “ftp”, “http”, “https”, “ws”, or “wss”, then the origin is a tuple of the scheme, host, and port.
///
/// - If the scheme is anything else, the origin is opaque, meaning the URL does not have the same origin as any other URL.
///
/// Note: This field is always `none` for `file:` URLs with opaque origins. As a result, the `origin` fields of URLs with different origins might be equal (all `none`), even though their origins are not be considered equivalent.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.origin")[`Url::origin`]
/// and #link("https://docs.rs/url/latest/url/enum.Origin.html")[`url::Origin`] in rust docs.
///
/// #example(`
///   // URL with ftp scheme
///   #assert.eq(
///     parse-supplementary("ftp://example.com/foo").origin,
///     ("ftp", "example.com", 21),
///   )
///
///   // URL with blob scheme
///   #assert.eq(
///     parse-supplementary("blob:https://example.com/foo").origin,
///     ("https", "example.com", 443),
///   )
///
///   // URL with file scheme
///   #assert.eq(
///     parse-supplementary("file:///tmp/foo").origin,
///     none,
///   )
///
///   // URL with other scheme
///   #assert.eq(
///     parse-supplementary("foo:bar").origin,
///     none,
///   )
/// `)
///
/// == `is-special: bool`
///
/// Whether the URL is special (has a special scheme)
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.is_special")[`Url::is_special` in rust docs].
///
/// #example(`
///   #assert.eq(
///     parse-supplementary("http:///tmp/foo").is-special,
///     true,
///   )
///   #assert.eq(
///     parse-supplementary("file:///tmp/foo").is-special,
///     true,
///   )
///   #assert.eq(
///     parse-supplementary("moz:///tmp/foo").is-special,
///     false,
///   );
/// `)
///
/// == `authority: str`
///
/// The ‘authority’ of this URL as an ASCII string, which can contain a username, password, host, and port number.
///
/// Non-ASCII domains are punycode-encoded per IDNA if this is the host of a special URL, or percent encoded for non-special URLs. IPv6 addresses are given between `[` and `]` brackets. Ports are omitted if they match the well known port of a special URL.
///
/// Username and password are percent-encoded.
///
/// The authority is empty, if the URL is either path-only like `unix:/run/foo.socket`, or cannot-be-a-base like `data:text/plain,Stuff`.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.authority")[`Url::authority`]
/// and #link("https://docs.rs/url/latest/url/struct.Url.html#method.has_authority")[`Url::has_authority`] in rust docs.
///
/// #example(`
///   #assert.eq(
///     parse-supplementary("ftp://rms@example.com").authority,
///     "rms@example.com",
///   )
///   #assert.eq(
///     parse-supplementary("https://user:password@example.com/tmp/foo").authority,
///     "user:password@example.com",
///   )
///   #assert.eq(
///     parse-supplementary("irc://àlex.рф.example.com:6667/foo").authority,
///     "%C3%A0lex.%D1%80%D1%84.example.com:6667",
///   )
///   #assert.eq(
///     parse-supplementary("http://àlex.рф.example.com:80/foo").authority,
///     "xn--lex-8ka.xn--p1ai.example.com",
///   )
///
///   // Empty authority
///   #for url in ("unix:/run/foo.socket", "data:text/plain,Stuff", "file:///tmp/foo") {
///     assert.eq(
///       parse-supplementary(url).authority,
///       "",
///     )
///   }
/// `)
///
/// == `domain: str | none`
///
/// If this URL has a host and it is a domain name (not an IP address), then `domain` is set to it. Otherwise, `domain` is `none`.
///
/// Non-ASCII domains are punycode-encoded per IDNA if this is the host of a special URL, or percent encoded for non-special URLs.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.domain")[`Url::domain` in rust docs].
///
/// #example(`
///   #assert.eq(
///     parse-supplementary("https://127.0.0.1/").domain,
///     none,
///   );
///   #assert.eq(
///     parse-supplementary("mailto:rms@example.net").domain,
///     none,
///   );
///   #assert.eq(
///     parse-supplementary("https://example.com/").domain,
///     "example.com",
///   )
/// `)
///
/// == `port-or-known-default: int | none`
///
/// The port number for this URL, or the default port number if it is known.
///
/// This field only knows the default port number of the `http`, `https`, `ws`, `wss` and `ftp` schemes.
///
/// For URLs in these schemes, this method always returns `int`. For other schemes, it is the same as `parse("…").port`.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.port_or_known_default")[`Url::port_or_known_default` in rust docs].
///
/// #example(`
///   #assert.eq(parse-supplementary("foo://example.com").port-or-known-default, none)
///   #assert.eq(parse-supplementary("foo://example.com:1456").port-or-known-default, 1456)
///   #assert.eq(parse-supplementary("https://example.com").port-or-known-default, 443)
/// `)
///
/// == `path-segments: array<str> | none`
///
/// Unless this URL is cannot-be-a-base, this field is an array of ‘/’ slash-separated path segments, each as a percent-encoded ASCII string.
///
/// This filed is `none` for cannot-be-a-base URLs.
///
/// When this field is `array`, it always contains at least one string (which may be empty).
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.path_segments")[`Url::path_segments` in rust docs].
///
/// #example(`
///   #assert.eq(
///     parse-supplementary("https://example.com/foo/bar").path-segments,
///     ("foo", "bar"),
///   )
///   #assert.eq(
///     parse-supplementary("https://example.com").path-segments,
///     ("",),
///   )
///   #assert.eq(
///     parse-supplementary("data:text/plain,HelloWorld").path-segments,
///     none,
///   )
///   #assert.eq(
///     parse-supplementary("https://example.com/countries/việt nam").path-segments,
///     ("countries", "vi%E1%BB%87t%20nam"),
///   )
/// `)
///
/// == `query-pairs: array<(str, str)>`
///
/// Parse the URL’s query string, if any, as `application/x-www-form-urlencoded` and set to an array of (key, value) pairs.
///
/// The names and values are percent-decoded.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.query_pairs")[`Url::query_pairs`]
/// and #link("https://docs.rs/form_urlencoded/1.2.1/form_urlencoded/fn.parse.html")[`form_urlencoded::parse`] in rust docs.
///
/// #example(`
///   #assert.eq(
///     parse-supplementary("https://example.com/products?page=2&sort=desc").query-pairs,
///     (
///       ("page", "2"),
///       ("sort", "desc"),
///     ),
///   )
///
///   // Percent-decoded
///   #assert.eq(
///     parse-supplementary("https://example.com/?%23first=%25try%25").query-pairs,
///     (
///       ("#first", "%try%"),
///     ),
///   )
/// `)
///
/// = Panics
///
/// If the function can not parse an URL from the given string
/// with this URL as the base URL, a `ParseError` will be thrown.
///
/// - input (str):
/// -> dict
#let parse-supplementary(input) = cbor(p.parse_supplementary(bytes(input)))

/// Parse a string as an URL, with this URL as the base URL.
///
/// The inverse of this is `make-relative`.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.join")[`Url::join` in rust docs].
///
/// = Notes
///
/// - A trailing slash is significant.
///   Without it, the last path component is considered to be a “file” name
///   to be removed to get at the “directory” that is used as the base.
/// - A #link("https://url.spec.whatwg.org/#scheme-relative-special-url-string")[scheme relative special URL]
///   as input replaces everything in the base URL after the scheme.
/// - An absolute URL (with a scheme) as input replaces the whole base URL (even the scheme).
///
/// = Examples
///
/// #example(`
///   // Base without a trailing slash
///   #assert.eq(
///     join("https://example.net/a/b.html", "c.png"),
///     "https://example.net/a/c.png", // Not /a/b.html/c.png
///   )
///
///   // Base with a trailing slash
///   #assert.eq(
///     join("https://example.net/a/b/", "c.png"),
///     "https://example.net/a/b/c.png",
///   )
///
///   // Input as scheme relative special URL
///   #assert.eq(
///     join("https://alice.com/a", "//eve.com/b"),
///     "https://eve.com/b",
///   )
///
///   // Input as absolute URL
///   #assert.eq(
///     join("https://alice.com/a", "http://eve.com/b"),
///     "http://eve.com/b", // http instead of https
///   )
/// `)
///
/// = Panics
///
/// If the function can not parse an URL from the given string
/// with this URL as the base URL, a `ParseError` will be thrown.
///
/// - base (str):
/// - url (str):
/// -> str
#let join(base, url) = str(p.join(bytes(base), bytes(url)))

/// Creates a relative URL if possible, with this URL as the base URL.
///
/// This is the inverse of `join`.
///
/// See also #link("https://docs.rs/url/latest/url/struct.Url.html#method.make_relative")[`Url::make_relative` in rust docs].
///
/// = Examples
///
/// #example(`
///   #assert.eq(
///     make-relative("https://example.net/a/b.html", "https://example.net/a/c.png"),
///     "c.png",
///   )
///
///   #assert.eq(
///     make-relative("https://example.net/a/b/", "https://example.net/a/b/c.png"),
///     "c.png",
///   )
///
///   #assert.eq(
///     make-relative("https://example.net/a/b/", "https://example.net/a/d/c.png"),
///     "../d/c.png",
///   )
///
///   #assert.eq(
///     make-relative("https://example.net/a/b.html?c=d", "https://example.net/a/b.html?e=f"),
///     "?e=f",
///   )
/// `)
///
/// = Errors
///
/// If this URL can’t be a base for the given URL, `none` is returned. This is for example the case if the scheme, host or port are not the same.
///
/// - base (str):
/// - url (str):
/// -> str
#let make-relative(base, url) = cbor(p.make_relative(bytes(base), bytes(url)))
